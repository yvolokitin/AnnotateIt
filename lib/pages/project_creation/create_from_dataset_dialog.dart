import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logging/logging.dart';

import '../../gen_l10n/app_localizations.dart';

import '../../../models/archive.dart';
import '../../../session/user_session.dart';
import '../../../utils/dataset_import_utils.dart';
import '../../../utils/dataset_import_project_creation.dart';
import '../../widgets/dialogs/alert_error_dialog.dart';
import '../../widgets/project_creation_from_dataset/dataset_upload_prompt.dart';
import '../../widgets/project_creation_from_dataset/dataset_step_description_widget.dart';
import '../../widgets/project_creation_from_dataset/dataset_step_progress_bar.dart';
import '../../widgets/project_creation_from_dataset/dataset_step_4_task_confirmation.dart';
import '../../widgets/project_creation_from_dataset/dataset_step_3_dataset_overview.dart';
import '../../widgets/project_creation_from_dataset/dataset_step_5_project_creation.dart';
import '../../widgets/project_creation_from_dataset/dataset_dialog_discard_confirmation.dart';

class CreateFromDatasetDialog extends StatefulWidget {
  const CreateFromDatasetDialog({super.key});

  @override
  State<CreateFromDatasetDialog> createState() => _CreateFromDatasetDialogState();
}

class _CreateFromDatasetDialogState extends State<CreateFromDatasetDialog> {
  final Logger _logger = Logger('CreateFromDatasetDialog');
  static const int _datasetIsolateThreshold = 500 * 1024 * 1024; // 500MB

  // State variables
  String? _projectCreationError;
  bool _isUploading = false;
  bool _isCreatingProject = false;
  bool _useIsolateMode = false;
  int _currentStep = 1;
  int _progressCurrent = 0;
  int _progressTotal = 0;
  double _processingProgress = 0.0;
  Archive? _archive;

  @override
  void dispose() {
    // Cleanup extracted files if dialog is closed before completion
    if (_archive != null && _currentStep < 5) {
      _cleanupExtractedFiles();
    }
    super.dispose();
  }

  Future<void> _cleanupExtractedFiles() async {
    if (_archive?.datasetPath?.isNotEmpty ?? false) {
      await cleanupExtractedPath(
        _archive!.datasetPath,
        onLog: (msg) => _logger.info(msg),
      );
    }
  }

  Future<void> _pickZipArchive() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null && result.files.single.path != null) {
        await _processZipArchive(File(result.files.single.path!));
      }
    } catch (e, stack) {
      _logger.severe('Error picking file', e, stack);
      _showErrorDialog(
        l10n.datasetDialogFilePickErrorTitle,
        l10n.datasetDialogFilePickErrorMessage,
        l10n.datasetDialogImportFailedTips,
      );
    }
  }

  Future<void> _processZipArchive(File file) async {
    final l10n = AppLocalizations.of(context)!;
    if (!mounted) return;

    setState(() {
      _isUploading = true;
      _processingProgress = 0.0;
      _currentStep = 2;
      _useIsolateMode = false;
      _archive = null;
    });

    try {
      final storagePath = await getDefaultStoragePath(
        () => UserSession.instance.getCurrentUserDatasetImportFolder(),
      );

      final fileSize = await file.length();
      final useIsolate = fileSize > _datasetIsolateThreshold;

      setState(() => _useIsolateMode = useIsolate);

      final archive = useIsolate
          ? await _processWithIsolate(file, storagePath)
          : await _processLocally(file, storagePath);

      if (!mounted) return;

      setState(() {
        _archive = archive;
        _isUploading = false;
        _currentStep = 3;
      });
    } catch (e, stack) {
      _logger.warning('Failed to process ZIP file', e, stack);
      if (!mounted) return;

      await _cleanupExtractedFiles();
      _showErrorDialog(
        l10n.datasetDialogImportFailedTitle,
        '${l10n.datasetDialogImportFailedMessage}\n\n${e.toString()}',
        l10n.datasetDialogImportFailedTips,
      );
      
      _resetToInitialState();
    }
  }

  Future<Archive> _processWithIsolate(File file, String storagePath) async {
    return await processZipLocallyWithIsolates(
      zipFile: file,
      storagePath: storagePath,
      onExtractProgress: (progress) => setState(() => _processingProgress = progress * 0.5),
      onExtractDone: (_) => setState(() => _processingProgress = 0.5),
      onDetectProgress: (progress) => setState(() => _processingProgress = 0.5 + progress * 0.5),
    ).timeout(
      Duration(minutes: 10),
      onTimeout: () => throw Exception('Dataset processing timeout'),
    );
  }

  Future<Archive> _processLocally(File file, String storagePath) async {
    return await processZipLocally(
      zipFile: file,
      storagePath: storagePath,
      onExtractProgress: (progress) => setState(() => _processingProgress = progress * 0.5),
      onExtractDone: (_) => setState(() => _processingProgress = 0.5),
      onDetectProgress: (progress) => setState(() => _processingProgress = 0.5 + progress * 0.5),
    );
  }

  Future<void> _goToNextStep() async {
    final l10n = AppLocalizations.of(context)!;

    if (_currentStep == 3) {
      if (_archive == null) return;
      
      setState(() {
        _archive = _archive!.withDefaultSelectedTaskType();
        _currentStep = 4;
      });
    } 
    else if (_currentStep == 4) {
      if (_archive == null) return;
      
      final selectedTask = _archive!.selectedTaskType?.trim();
      if (selectedTask == null || selectedTask.isEmpty || selectedTask == 'Unknown') {
        await _showErrorDialog(
          l10n.datasetDialogNoProjectTypeTitle,
          l10n.datasetDialogNoProjectTypeMessage,
        );
        return;
      }

      setState(() {
        _currentStep = 5;
        _projectCreationError = null;
        _isCreatingProject = true;
      });

      try {
        final newProjectId = await DatasetImportProjectCreation.createProjectWithDataset(
          _archive!,
          onProgress: _onMediaImportProgress,
        );

        if (!mounted) return;
        Navigator.of(context).pop(newProjectId);
      } catch (e, stack) {
        _logger.severe('Project creation failed', e, stack);
        if (!mounted) return;

        setState(() {
          _projectCreationError = e.toString();
          _isCreatingProject = false;
        });
      }
    }
  }

  void _onMediaImportProgress(int current, int total) {
    if (mounted) {
      setState(() {
        _progressCurrent = current;
        _progressTotal = total;
      });
    }
  }

  Future<void> _handleCancel() async {
    if (_isUploading || _isCreatingProject) {
      await _showProcessingInProgressDialog();
      return;
    }

    if (_archive != null) {
      final shouldCancel = await DatasetImportDiscardConfirmationDialog.show(context);
      if (shouldCancel != true) return;
      await _cleanupExtractedFiles();
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showProcessingInProgressDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final title = _isUploading 
        ? l10n.datasetDialogProcessingDatasetTitle 
        : l10n.datasetDialogCreatingProjectTitle;
    final message = _isUploading 
        ? l10n.datasetDialogProcessingDatasetMessage 
        : l10n.datasetDialogCreatingProjectMessage;

    await AlertErrorDialog.show(context, title, message);
  }

  Future<void> _showErrorDialog(String title, String message, [String? tips]) async {
    final l10n = AppLocalizations.of(context)!;
    await AlertErrorDialog.show(
      context,
      title,
      message,
      tips: tips ?? l10n.datasetDialogGenericErrorTips,
    );
  }

  void _resetToInitialState() {
    if (mounted) {
      setState(() {
        _isUploading = false;
        _isCreatingProject = false;
        _processingProgress = 0.0;
        _currentStep = 1;
        _archive = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            if (_isUploading || _isCreatingProject) {
              await _showProcessingInProgressDialog();
              return false;
            }

            if (_archive != null) {
              final shouldCancel = await DatasetImportDiscardConfirmationDialog.show(context);
              if (shouldCancel != true) return false;
              await _cleanupExtractedFiles();
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
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.datasetDialogTitle,
              style: TextStyle(
                fontSize: screenWidth > 1200 ? 26 : 22,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
                    ? _buildProcessingIndicator()
                    : _buildCurrentStepContent(),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
        Positioned(
          top: 5,
          right: 5,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: l10n.buttonClose,
            onPressed: _handleCancel,
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingIndicator() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: Colors.redAccent,
          strokeWidth: 5,
          value: _processingProgress == 0.0 || _processingProgress == 1.0 
              ? null 
              : _processingProgress,
        ),
        const SizedBox(height: 24),
        Text(
          _processingProgress == 0 
              ? l10n.datasetDialogProcessing 
              : "${l10n.datasetDialogProcessingProgress} ${(100 * _processingProgress).toInt()}%",
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'CascadiaCode',
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _useIsolateMode 
              ? l10n.datasetDialogModeIsolate 
              : l10n.datasetDialogModeNormal,
          style: const TextStyle(
            color: Colors.white38,
            fontFamily: 'CascadiaCode',
            fontSize: 14,
          ),
        ),

        Text(
          _progressTotal > 0 
            ? "${l10n.datasetDialogProcessingProgress} $_progressCurrent/$_progressTotal"
            : l10n.datasetDialogProcessing,
          ),
      ],
    );
  }

  Widget _buildCurrentStepContent() {
    final l10n = AppLocalizations.of(context)!;

    switch (_currentStep) {
      case 1:
        return UploadPrompt(onPickFile: _pickZipArchive);
      case 3:
        return _archive != null 
            ? StepDatasetOverview(archive: _archive!) 
            : Text(l10n.datasetDialogNoDatasetLoaded);
      case 4:
        return _archive != null 
            ? StepDatasetTaskConfirmation(
                archive: _archive!,
                onSelectionChanged: (selectedTask) {
                  setState(() {
                    _archive = _archive!.copyWith(selectedTaskType: selectedTask);
                  });
                },
              )
            : Text(l10n.datasetDialogNoDatasetLoaded);
      case 5:
        return StepDatasetProjectCreation(
          errorMessage: _projectCreationError,
          current: _progressCurrent,
          total: _progressTotal,
        );
      default:
        return Text(l10n.datasetDialogNoDatasetLoaded);
    }
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _handleCancel,
          child: Text(
            l10n.buttonCancel,
            style: const TextStyle(
              color: Colors.white54,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ),
        if ((_currentStep == 3 || _currentStep == 4) && !_isUploading)
          ElevatedButton(
            onPressed: _isCreatingProject ? null : _goToNextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            ),
            child: _isCreatingProject
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    _currentStep == 3 
                        ? l10n.buttonNextConfirmTask 
                        : l10n.buttonCreateProject,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
      ],
    );
  }
}
