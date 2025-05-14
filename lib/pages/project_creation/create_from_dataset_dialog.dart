import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';

import '../../../models/dataset_info.dart';
import '../../../session/user_session.dart';
import '../../../utils/dataset_import_utils.dart';
import '../../../utils/dataset_import_project_creation.dart';

import '../../widgets/project_creation/dataset_upload_prompt.dart';
import '../../widgets/project_creation/dataset_step_description_widget.dart';
import '../../widgets/project_creation/dataset_step_task_confirmation.dart';
import '../../../widgets/project_creation/dataset_step_progress_bar.dart';
import '../../../widgets/project_creation/dataset_step_dataset_overview.dart';
import '../../../widgets/project_creation/dataset_step_project_creation.dart';

import '../../../widgets/project_creation/dataset_dialog_discard_confirmation.dart';

class CreateFromDatasetDialog extends StatefulWidget {
  const CreateFromDatasetDialog({super.key});

  @override
  State<CreateFromDatasetDialog> createState() => _CreateFromDatasetDialogState();
}

class _CreateFromDatasetDialogState extends State<CreateFromDatasetDialog> {
  final Logger _logger = Logger('CreateFromDatasetDialog');
  String? _projectCreationError;

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

  Future<void> _goToNextStep() async {
    // move from Step 3 to Step 4 (task confirmation)
    if (_currentStep == 3 && _datasetInfo != null) {
      _datasetInfo = _datasetInfo!.withDefaultSelectedTaskType();
      setState(() => _currentStep = 4);

    // move from Step 4 to Step 5 (create project)
    } else if (_currentStep == 4 && _datasetInfo != null) {
      final selectedTask = _datasetInfo!.selectedTaskType?.trim();
      if (selectedTask == null || selectedTask.isEmpty || selectedTask == 'Unknown') {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              title: const Text(
                'No any Project type selected',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Please select a Project Type based on the detected annotation types in your dataset, or enable project type change to choose a different type.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  child: const Text('OK', style: TextStyle(color: Colors.redAccent)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
        return;
      }

      setState(() {
        _currentStep = 5;
        _projectCreationError = null;
      });

      try {
        await DatasetImportProjectCreation.createProjectWithDataset(_datasetInfo!);
        if (!mounted) return;
        Navigator.of(context).pop(); // Close full dialog after success

      } catch (e) {
        _logger.severe('Failed to create project: $e');
        if (!mounted) return;
        setState(() {
          _projectCreationError = e.toString();
        });
      }

    } else if (_currentStep < 5) {
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
            const SizedBox(height: 8),
            StepDescriptionWidget(
              currentStep: _currentStep,
              extractedPath: _datasetInfo?.datasetPath,
              datasetFormat: _datasetInfo?.datasetFormat,
            ),
            const SizedBox(height: 24),
            DatasetStepProgressBar(currentStep: _currentStep),
            const SizedBox(height: 24),
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
                                : "Processing... \${(100 * _progress).toInt()}%",
                            style: const TextStyle(color: Colors.white70, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _useIsolateMode ? "Isolate Mode Enabled" : "Normal Mode",
                            style: const TextStyle(color: Colors.white38, fontSize: 14),
                          ),
                        ],
                      )
                    : _buildStepContent(),
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
                if ((_currentStep == 3 || _currentStep == 4) && !_isUploading)
                  ElevatedButton(
                    onPressed: _goToNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      _currentStep == 3 ? "Next: Confirm Task" : "Create Project",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
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

  Widget _buildStepContent() {
    if (_currentStep == 1) {
      return UploadPrompt(onPickFile: _pickFile);
    
    } else if (_currentStep == 3 && _datasetInfo != null) {
      return StepDatasetOverview(info: _datasetInfo!);

    } else if (_currentStep == 4 && _datasetInfo != null) {
      return StepDatasetTaskConfirmation(
        info: _datasetInfo!,
        onSelectionChanged: (selectedTask) {
          setState(() {
            _datasetInfo = _datasetInfo!.copyWith(selectedTaskType: selectedTask);
          });
        },
      );
    } else if (_currentStep == 5) {
      return StepDatasetProjectCreation(errorMessage: _projectCreationError);
    } else {
      return const Text("No dataset loaded.", style: TextStyle(color: Colors.white70));
    }
  }
}
