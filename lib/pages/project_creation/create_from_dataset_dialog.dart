import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';

import '../../../session/user_session.dart';
import '../../../utils/responsive_utils.dart';
import '../../../utils/dataset_import_utils.dart';

import '../../../widgets/project_creation/dataset_step_progress_bar.dart';
import '../../../widgets/project_creation/upload_prompt.dart';
import '../../../widgets/project_creation/step_description_widget.dart';
import '../../../widgets/project_creation/label_editor_widget.dart';
import '../../widgets/project_creation/dataset_step_dataset_overview.dart';

import 'create_dataset_logic.dart';

class CreateFromDatasetDialog extends StatefulWidget {
  const CreateFromDatasetDialog({super.key});

  @override
  State<CreateFromDatasetDialog> createState() => _CreateFromDatasetDialogState();
}

class _CreateFromDatasetDialogState extends State<CreateFromDatasetDialog> {
  final Logger _logger = Logger('CreateFromDatasetDialog');
  File? _selectedFile;
  bool _isUploading = false;
  int _currentStep = 1;
  String? _detectedTaskType;
  String? _detectedDatasetType;
  String? _extractedPath;
  double _progress = 0.0;
  int _mediaCount = 0;
  int _annotationCount = 0;
  List<String> _detectedLabels = [];

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['zip']);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() => _selectedFile = file);
      await _processZipLocally(file);
    }
  }

  Future<void> _cleanupExtractedPath() async {
    if (_extractedPath != null) {
      final dir = Directory(_extractedPath!);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        _logger.info('Cleaned up extracted directory: $_extractedPath');
      }
      try {
        final rootFolder = dir.parent;
        if (await rootFolder.exists()) {
          final contents = rootFolder.listSync();
          if (contents.isEmpty) {
            await rootFolder.delete();
            _logger.info('Cleaned up root folder: ${rootFolder.path}');
          }
        }
      } catch (e) {
        _logger.warning('Failed to remove root folder: $e');
      }
    }
  }

  Future<void> _processZipLocally(File file) async {
    setState(() {
      _isUploading = true;
      _progress = 0.0;
      _currentStep = 2;
    });

    final receivePort = ReceivePort();

    try {
      final storagePath = await getDefaultStoragePath(() => UserSession.instance.getCurrentUserDatasetFolder());
      await Isolate.spawn(extractInIsolate, [file.path, storagePath, receivePort.sendPort]);

      await for (final message in receivePort) {
        if (message is Map<String, dynamic> && message['type'] == 'extract_progress') {
          setState(() {
            _progress = message['progress'] ?? _progress;
          });
        } else if (message is Map<String, dynamic> && message['type'] == 'extract_done') {
          setState(() {
            _extractedPath = message['path'];
            _currentStep = 3;
            _progress = 0.0;
          });

          final detectionReceivePort = ReceivePort();
          await Isolate.spawn(detectInIsolate, [message['path'], detectionReceivePort.sendPort]);

          await for (final detectionMessage in detectionReceivePort) {
            if (detectionMessage is Map<String, dynamic> && detectionMessage['type'] == 'detect_progress') {
              setState(() {
                _progress = detectionMessage['progress'] ?? _progress;
              });
            } else if (detectionMessage is Map<String, dynamic> && detectionMessage['type'] == 'detect_done') {
              final allFiles = Directory(message['path']).listSync(recursive: true).whereType<File>().toList();
              final mediaExtensions = ['.jpg', '.jpeg', '.png', '.bmp', '.webp', '.mp4', '.avi', '.mov', '.mkv'];
              final annotationExtensions = ['.json', '.xml', '.txt'];

              final mediaFiles = allFiles.where((f) => mediaExtensions.any((ext) => f.path.toLowerCase().endsWith(ext))).toList();
              final annotationFiles = allFiles.where((f) => annotationExtensions.any((ext) => f.path.toLowerCase().endsWith(ext))).toList();

              setState(() {
                _detectedDatasetType = detectionMessage['datasetType'];
                _detectedTaskType = detectionMessage['taskType'];
                _detectedLabels = List<String>.from(detectionMessage['labels'] ?? []);
                _mediaCount = mediaFiles.length;
                _annotationCount = annotationFiles.length;
                _isUploading = false;
                _progress = 1.0;
              });
              break;
            }
          }

          break;
        }
      }
    } catch (e, stack) {
      _logger.warning('Failed to process ZIP file: $e', e, stack);
      await _cleanupExtractedPath();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Import failed: $e")),
      );
      setState(() {
        _isUploading = false;
        _currentStep = 1;
      });
    }
  }

  void _goToNextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep += 1);
    }
  }

  void _handleCancel() async {
    if (_isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait until dataset is fully processed."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_extractedPath != null) {
      final shouldCancel = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Discard Imported Dataset?", style: TextStyle(color: Colors.white)),
          content: const Text(
            "You have already imported a dataset. Cancelling now will delete the extracted files. Are you sure you want to proceed?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Keep", style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Discard", style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      );

      if (shouldCancel != true) return;
    }

    await _cleanupExtractedPath();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 1600;
        final isTablet = constraints.maxWidth >= 800 && constraints.maxWidth < 1600;
        final dialogWidth = constraints.maxWidth * (isLargeScreen ? 0.9 : 1.0);
        final dialogHeight = constraints.maxHeight * (isLargeScreen ? 0.9 : 1.0);
        final dialogPadding = isLargeScreen
            ? const EdgeInsets.all(60)
            : isTablet
                ? const EdgeInsets.all(24)
                : const EdgeInsets.all(12);

        return WillPopScope(
          onWillPop: () async {
            if (_isUploading) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please wait until dataset is fully processed."),
                  duration: Duration(seconds: 2),
                ),
              );
              return false;
            }

            if (_extractedPath != null) {
              final shouldCancel = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: Colors.grey[900],
                  title: const Text("Discard Imported Dataset?", style: TextStyle(color: Colors.white)),
                  content: const Text(
                    "You have already imported a dataset. Cancelling now will delete the extracted files. Are you sure you want to proceed?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Keep", style: TextStyle(color: Colors.white54)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Discard", style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              );

              if (shouldCancel != true) return false;
              await _cleanupExtractedPath();
            }
            return true;
          },
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.grey[850],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            child: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: Padding(
                padding: dialogPadding,
                child: _buildDialogContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogContent() {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Import Dataset to Create Project",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            StepDescriptionWidget(
              currentStep: _currentStep,
              extractedPath: _extractedPath,
              detectedTaskType: _detectedTaskType,
            ),
            const SizedBox(height: 32),
            DatasetStepProgressBar(currentStep: _currentStep),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: _isUploading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.redAccent,
                            strokeWidth: 5,
                            value: _progress == 0.0 || _progress == 1.0 ? null : _progress,
                          ),
                          const SizedBox(height: 24),
                          Text("Processing... ${(100 * _progress).toInt()}%", style: const TextStyle(color: Colors.white70, fontSize: 18)),
                        ],
                      )
                    : _currentStep == 1
                        ? UploadPrompt(onPickFile: _pickFile)
                        : _currentStep == 4
                            ? const LabelEditorWidget()
                            : StepDatasetOverview(
                                info: DatasetInfo(
                                  datasetPath: _extractedPath ?? 'Unknown',
                                  mediaCount: _mediaCount,
                                  annotationCount: _annotationCount,
                                  datasetFormat: _detectedDatasetType ?? 'Unknown',
                                  taskType: _detectedTaskType ?? 'Unknown',
                                  labels: _detectedLabels,
                                ),
                              ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    if (_isUploading) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please wait until dataset is fully processed."),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }
                    _handleCancel();
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
                ),
                if (_currentStep == 3 && !_isUploading)
                  ElevatedButton(
                    onPressed: _goToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Continue", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: 'Close',
            onPressed: () {
              if (_isUploading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please wait until dataset is fully processed."),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              _handleCancel();
            },
          ),
        ),
      ],
    );
  }
}