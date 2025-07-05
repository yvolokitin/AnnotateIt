import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';

import '../../../models/archive.dart';
import '../../../session/user_session.dart';

import '../../../utils/dataset_import_utils.dart';
import '../../../utils/dataset_import_project_creation.dart';

import '../../widgets/dialogs/alert_error_dialog.dart';

import '../../widgets/project_creation_from_dataset/dataset_upload_prompt.dart';
import '../../widgets/project_creation_from_dataset/dataset_step_description_widget.dart';
import '../../widgets/project_creation_from_dataset/dataset_step_task_confirmation.dart';
import '../../widgets/project_creation_from_dataset/dataset_step_progress_bar.dart';
import '../../widgets/project_creation_from_dataset/dataset_step_dataset_overview.dart';
import '../../widgets/project_creation_from_dataset/dataset_step_project_creation.dart';
import '../../widgets/project_creation_from_dataset/dataset_dialog_discard_confirmation.dart';

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
  bool _isCreatingProject = false;

  int _progressCurrent = 0;
  int _progressTotal = 0;

  bool _useIsolateMode = false;
  int _currentStep = 1;
  Archive? _archive;
  double _progress = 0.0;

  // progress callback for project creation step
  void _onMediaImportProgress(int current, int total) {
    print('PROGRESS UI: $current / $total');
    setState(() {
      _progressCurrent = current;
      _progressTotal = total;
    });
  }

  void _pickZipArchive() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await _processZipArchive(file);
    }
  }

Future<void> _processZipArchive(File file) async {
  setState(() {
    _isUploading = true;
    _progress = 0.0;
    _currentStep = 2;
    _useIsolateMode = false;
  });

  try {
    final storagePath = await getDefaultStoragePath(() =>
        UserSession.instance.getCurrentUserDatasetImportFolder());

    final fileSize = await file.length();
    final bool useIsolate = fileSize > DATASET_ISOLATE_THRESHOLD;
    _useIsolateMode = useIsolate;

    Archive archive;

    if (useIsolate) {
      archive = await processZipLocallyWithIsolates(
        zipFile: file,
        storagePath: storagePath,
        onExtractProgress: (progress) => setState(() => _progress = progress),
        onExtractDone: (path) => setState(() {
          _progress = 0.0;
          _currentStep = 3;
        }),
        onDetectProgress: (progress) => setState(() => _progress = progress),
      );
    } else {
      archive = await processZipLocally(
        zipFile: file,
        storagePath: storagePath,
        onExtractProgress: (progress) => setState(() => _progress = progress),
        onExtractDone: (path) => setState(() {
          _progress = 0.0;
          _currentStep = 3;
        }),
        onDetectProgress: (progress) => setState(() => _progress = progress),
      );
    }

    setState(() {
      _archive = archive;
      _isUploading = false;
      _progress = 1.0;
    });
  } catch (e, stack) {
    _logger.warning('CreateFromDatasetDialog: Failed to process ZIP file: $e', e, stack);

    final extractedPath = _archive?.datasetPath;
    if (extractedPath != null && extractedPath.isNotEmpty) {
      await cleanupExtractedPath(
        extractedPath,
        onLog: (msg) => _logger.info(msg),
      );
    }

    if (!mounted) return;

    await AlertErrorDialog.show(
      context,
      "Import Failed",
      "The ZIP file could not be processed. It may be corrupted, incomplete, or not a valid dataset archive.",
      tips: "Try re-exporting or re-zipping your dataset.\nEnsure it is in COCO, YOLO, VOC, or supported format.\n\nError: $e",
    );
    
    setState(() {
      _isUploading = false;
      _progress = 0.0;
      _currentStep = 1;
      _archive = null;
    });
  }
}

  Future<void> _goToNextStep() async {
    if (_currentStep == 3 && _archive != null) {
      _archive = _archive!.withDefaultSelectedTaskType();
      setState(() => _currentStep = 4);

    } else if (_currentStep == 4 && _archive != null) {
      final selectedTask = _archive!.selectedTaskType?.trim();
      if (selectedTask == null || selectedTask.isEmpty || selectedTask == 'Unknown') {
        await AlertErrorDialog.show(
          context,
          'No Project Type Selected',
          'Please select a Project Type based on the detected annotation types in your dataset.',
          tips: 'Check your dataset format and ensure annotations follow a supported structure like COCO, YOLO, VOC or Datumaro.',
        );
        return;
      }

      setState(() {
        _currentStep = 5;
        _projectCreationError = null;
      });

      try {
        // set it true to block cancellation request
        setState(() => _isCreatingProject = true);

        final int newProjectId = await DatasetImportProjectCreation.createProjectWithDataset(
          _archive!,
          onProgress: _onMediaImportProgress,
        );
        if (!mounted) return;
        Navigator.of(context).pop(newProjectId);

      } catch (e) {
        _logger.severe('Failed to create project: $e');
        if (!mounted) return;
        setState(() {
          _projectCreationError = e.toString();
        });

      } finally {
        setState(() => _isCreatingProject = false);
      }

    } else if (_currentStep < 5) {
      setState(() => _currentStep += 1);
    }
  }

  Future<void> _handleCancel() async {
    if (_isUploading) {
      await AlertErrorDialog.show(
        context,
        "Processing Dataset",
        "We are currently extracting your ZIP archive, analyzing its contents, and detecting the dataset format and annotation type. This may take a few seconds to a few minutes depending on the dataset size and structure. Please do not close this window or navigate away during the process.",
        tips: "Large archives with many images or annotation files can take longer to process.",
      );
      return;
    }

    if (_isCreatingProject) {
      await AlertErrorDialog.show(
        context,
        "Creating Project",
        "We are setting up your project, initializing its metadata, and saving all configurations. This includes assigning labels, creating datasets, and linking associated media files. Please wait a moment and avoid closing this window until the process is complete.",
        tips: "Projects with many labels or media files might take slightly longer.",
      );
      return;
    }

    if (_archive != null) {
      final shouldCancel = await DatasetImportDiscardConfirmationDialog.show(context);
      if (shouldCancel != true) return;

      await cleanupExtractedPath(
        _archive!.datasetPath,
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
              await AlertErrorDialog.show(
                context,
                "Processing Dataset",
                "We are currently analyzing your dataset archive. This includes extracting files, detecting dataset structure, identifying annotation formats, and collecting media and label information. Please wait until the process is complete. Closing the window or navigating away may interrupt the operation.",
                tips: "Large datasets with many files or complex annotations may take extra time.",
              );
              return false;
            }

            if (_archive != null) {
              final shouldCancel = await DatasetImportDiscardConfirmationDialog.show(context);
              if (shouldCancel != true) return false;
              await cleanupExtractedPath(
                _archive!.datasetPath,
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
              extractedPath: _archive?.datasetPath,
              datasetFormat: _archive?.datasetFormat,
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
      return UploadPrompt(onPickFile: _pickZipArchive);

    } else if (_currentStep == 3 && _archive != null) {
      return StepDatasetOverview(archive: _archive!);

    } else if (_currentStep == 4 && _archive != null) {
      return StepDatasetTaskConfirmation(
        archive: _archive!,
        onSelectionChanged: (selectedTask) {
          setState(() {
            _archive = _archive!.copyWith(selectedTaskType: selectedTask);
          });
        },
      );

    } else if (_currentStep == 5) {
      return StepDatasetProjectCreation(
        errorMessage: _projectCreationError,
        current: _progressCurrent,
        total: _progressTotal,
      );

    } else {
      return const Text("No dataset loaded.", style: TextStyle(color: Colors.white70));
    }
  }
}
