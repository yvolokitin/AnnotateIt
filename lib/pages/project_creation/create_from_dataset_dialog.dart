import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';

import '../../../session/user_session.dart';
import '../../../utils/dataset_import_utils.dart';
import '../../../models/dataset_info.dart';

import '../../../widgets/project_creation/dataset_step_progress_bar.dart';
import '../../../widgets/project_creation/upload_prompt.dart';
import '../../../widgets/project_creation/step_description_widget.dart';
import '../../../widgets/project_creation/label_editor_widget.dart';

import '../../widgets/project_creation/dataset_step_dataset_overview.dart';
import '../../widgets/project_creation/dataset_discard_confirmation_dialog.dart';

class CreateFromDatasetDialog extends StatefulWidget {
  const CreateFromDatasetDialog({super.key});

  @override
  State<CreateFromDatasetDialog> createState() => _CreateFromDatasetDialogState();
}

class _CreateFromDatasetDialogState extends State<CreateFromDatasetDialog> {
  final Logger _logger = Logger('CreateFromDatasetDialog');

  static const int DATASET_ISOLATE_THRESHOLD = 500 * 1024 * 1024;

  bool _isUploading = false;
  bool _useIsolateMode = false;
  int _currentStep = 1;
  DatasetInfo? _datasetInfo;
  double _progress = 0.0;

  void _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await _processZip(file);
    }
  }

  Future<void> _processZip(File file) async {
    setState(() {
      _isUploading = true;
      _progress = 0.0;
      _currentStep = 2;
      _useIsolateMode = false;
    });

    try {
      final storagePath = await getDefaultStoragePath(() =>
          UserSession.instance.getCurrentUserDatasetFolder());

      final fileSize = await file.length();

      final info = fileSize > DATASET_ISOLATE_THRESHOLD
          ? await (() async {
              _useIsolateMode = true;
              return await processZipLocallyWithIsolates(
                zipFile: file,
                storagePath: storagePath,
                onExtractProgress: (progress) => setState(() => _progress = progress),
                onExtractDone: (path) => setState(() {
                  _progress = 0.0;
                  _currentStep = 3;
                }),
                onDetectProgress: (progress) => setState(() => _progress = progress),
              );
            })()
          : await processZipLocally(
              zipFile: file,
              storagePath: storagePath,
              onExtractProgress: (progress) => setState(() => _progress = progress),
              onExtractDone: (path) => setState(() {
                _progress = 0.0;
                _currentStep = 3;
              }),
              onDetectProgress: (progress) => setState(() => _progress = progress),
            );

      setState(() {
        _datasetInfo = info;
        _isUploading = false;
        _progress = 1.0;
      });
    } catch (e, stack) {
      _logger.warning('Failed to process ZIP file: $e', e, stack);
      if (_datasetInfo != null) {
        await cleanupExtractedPath(
          _datasetInfo!.datasetPath,
          onLog: (msg) => _logger.info(msg),
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Import failed: $e")),
      );
      setState(() {
        _isUploading = false;
        _currentStep = 1;
        _datasetInfo = null;
      });
    }
  }

  void _goToNextStep() {
    if (_currentStep < 5) {
      setState(() => _currentStep += 1);
    }
  }

  Future<void> _handleCancel() async {
    if (_isUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please wait until dataset is fully processed."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_datasetInfo != null) {
      final shouldCancel = await DatasetImportDiscardConfirmationDialog.show(context);
      if (shouldCancel != true) return;

      await cleanupExtractedPath(
        _datasetInfo!.datasetPath,
        onLog: (msg) => _logger.info(msg),
      );
    }

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

            if (_datasetInfo != null) {
              final shouldCancel = await DatasetImportDiscardConfirmationDialog.show(context);
              if (shouldCancel != true) return false;
              await cleanupExtractedPath(
                _datasetInfo!.datasetPath,
                onLog: (msg) => _logger.info(msg),
              );
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
              extractedPath: _datasetInfo?.datasetPath,
              detectedTaskType: _datasetInfo?.taskType,
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
                          Text(
                            _progress == 0
                                ? "Processing..."
                                : "Processing... ${(100 * _progress).toInt()}%",
                            style: const TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _useIsolateMode ? "Isolate Mode Enabled" : "Normal Mode",
                            style: const TextStyle(color: Colors.white38, fontSize: 14),
                          ),
                        ],
                      )
                    : _currentStep == 1
                        ? UploadPrompt(onPickFile: _pickFile)
                        : _currentStep == 4
                            ? const LabelEditorWidget()
                            : _datasetInfo != null
                                ? StepDatasetOverview(info: _datasetInfo!)
                                : const Text("No dataset loaded.", style: TextStyle(color: Colors.white70)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _handleCancel,
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
                    child: const Text("Create Project", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            onPressed: _handleCancel,
          ),
        ),
      ],
    );
  }
}
