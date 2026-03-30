import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';
import 'package:logging/logging.dart';

import '../../widgets/app_snackbar.dart';
import '../../widgets/dialogs/alert_error_dialog.dart';
import '../../session/user_session.dart';

import '../../models/project.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../models/user.dart';

import '../../gen_l10n/app_localizations.dart';
import '../../data/dataset_database.dart';
import '../../data/annotation_database.dart';
import '../../utils/dataset_exporters/exporter_factory.dart';
import '../../utils/web_download_helper.dart';
import '../../utils/theme.dart';

class ExportProjectDialog extends StatefulWidget {
  final Project project;

  const ExportProjectDialog({
    super.key,
    required this.project,
  });

  @override
  ExportProjectDialogState createState() => ExportProjectDialogState();
}

class ExportProjectDialogState extends State<ExportProjectDialog> {
  final _logger = Logger('ExportProjectDialog');
  String selectedDatasetType = 'COCO';
  bool exportLabels = true;
  bool exportAnnotations = true;
  bool _isExporting = false;
  bool _showExportLabelsButton = true;
  bool mergeDatasets = true;
  final Map<String, String> _datasetIdToFolderName = {};
  
  @override
  void initState() {
    super.initState();
    // Get user setting for showing export labels button
    final user = UserSession.instance.getUser();
    _showExportLabelsButton = user.showExportLabelsButton;
    
    // If the export labels button is hidden, ensure exportLabels is true by default
    if (!_showExportLabelsButton) {
      exportLabels = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1600;
    final isTablet = screenWidth >= 900 && screenWidth < 1600;
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dialogPadding = isLargeScreen
            ? const EdgeInsets.all(60)
            : isTablet
                ? const EdgeInsets.all(24)
                : const EdgeInsets.all(12);

        final dialogWidth = constraints.maxWidth * (isLargeScreen ? 0.9 : 1.0);
        final dialogHeight = constraints.maxHeight * (isLargeScreen ? 0.9 : 1.0);

        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: AppColors.darkCard,
          shape: (screenWidth > 1600)
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).colorScheme.success, width: 1),
                )
              : RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Stack(
              children: [
                Padding(
                  padding: dialogPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(screenWidth),
                      const SizedBox(height: 12),
                      Divider(color: Theme.of(context).colorScheme.success),
                      const SizedBox(height: 12),
                      Expanded(child: _buildExportOptions(screenWidth)),
                      const SizedBox(height: 12),
                      _buildBottomButtons(l10n),
                    ],
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.muted),
                    tooltip: l10n.buttonClose,
                    onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
                  ),
                ),
                if (_isExporting)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(double screenWidth) {
    final isSmall = screenWidth < 800;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.upload_file,
              size: isSmall ? 26 : (screenWidth >= 1600 ? 34 : 30),
              color: Theme.of(context).colorScheme.success,
            ),
            const SizedBox(width: 12),
            Text(
              'Export Project as Dataset',
              style: TextStyle(
                fontSize: isSmall ? 20 : (screenWidth >= 1600 ? 26 : 22),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.success,
              ),
            ),
          ],
        ),
        if (screenWidth > 445) ...[
          const SizedBox(height: 4),
          Text(
            'Export "${widget.project.name}" as a dataset',
            style: TextStyle(
              fontSize: screenWidth >= 1600 ? 22 : (screenWidth > 660) ? 18 : 12,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).colorScheme.muted,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExportOptions(double screenWidth) {
    final isSmall = screenWidth < 800;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dataset Type',
            style: TextStyle(
              fontSize: isSmall ? 16 : (screenWidth > 1200 ? 22 : 18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmall ? 10 : 16),
          Wrap(
            spacing: isSmall ? 10 : 16,
            runSpacing: isSmall ? 10 : 16,
            children: [
              _buildDatasetTypeCard('COCO', 'Common Objects in Context', Icons.photo_library),
              _buildDatasetTypeCard('YOLO', 'You Only Look Once', Icons.view_in_ar),
              _buildDatasetTypeCard('VOC', 'Pascal VOC (XML)', Icons.description),
              _buildDatasetTypeCard('Datumaro', 'Universal Dataset Format', Icons.data_object),
              _buildDatasetTypeCard('ZIP', 'Simple ZIP Archive', Icons.folder_zip),
            ],
          ),
          SizedBox(height: isSmall ? 20 : 32),
          Text(
            'Export Options',
            style: TextStyle(
              fontSize: isSmall ? 16 : (screenWidth > 1200 ? 22 : 18),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isSmall ? 10 : 16),
          // Merge datasets toggle (first option)
          SwitchListTile(
            title: Text(
              'Merge all datasets into one images folder',
              style: TextStyle(
                fontSize: isSmall ? 14 : (screenWidth > 1200 ? 20 : 16),
                color: Colors.white,
              ),
            ),
            subtitle: !mergeDatasets
                ? Text(
                    'All datasets will be placed in separate folders by dataset name',
                    style: TextStyle(
                      fontSize: isSmall ? 11 : (screenWidth > 1200 ? 14 : 12),
                      color: Theme.of(context).colorScheme.muted,
                    ),
                  )
                : null,
            value: mergeDatasets,
            onChanged: _isExporting ? null : (v) => setState(() => mergeDatasets = v),
            activeColor: Theme.of(context).colorScheme.success,
          ),
          if (_showExportLabelsButton)
            _buildExportToggle(
              'Export All Labels',
              exportLabels,
              (value) => setState(() {
                exportLabels = value;
                if (!exportLabels) {
                  exportAnnotations = false;
                }
              }),
              screenWidth,
            ),
          if (!_showExportLabelsButton || exportLabels)
            _buildExportToggle(
              'Export All Annotations',
              exportAnnotations,
              (value) => setState(() => exportAnnotations = value),
              screenWidth,
            ),
        ],
      ),
    );
  }

  Widget _buildDatasetTypeCard(String type, String description, IconData icon) {
    final isSelected = selectedDatasetType == type;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 800;
    
    return InkWell(
      onTap: () => setState(() => selectedDatasetType = type),
      child: Container(
        width: isSmall ? 170 : 220,
        height: isSmall ? 130 : 160,
        padding: EdgeInsets.all(isSmall ? 12 : 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.success.withOpacity(0.2) : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.success : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Theme.of(context).colorScheme.success : Theme.of(context).colorScheme.muted,
                  size: isSmall ? 22 : 28,
                ),
                SizedBox(width: isSmall ? 8 : 10),
                Expanded(
                  child: Text(
                    type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmall ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).colorScheme.success : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmall ? 6 : 8),
            Expanded(
              child: Text(
                description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isSmall ? 12 : 15,
                  color: Theme.of(context).colorScheme.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportToggle(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    double screenWidth,
  ) {
    final isSmall = screenWidth < 800;
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: isSmall ? 14 : (screenWidth > 1200 ? 20 : 16),
          color: Colors.white,
        ),
      ),
      value: value,
      onChanged: _isExporting ? null : onChanged,
      activeColor: Theme.of(context).colorScheme.success,
    );
  }

  Widget _buildBottomButtons(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 800;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: Text(
            l10n.buttonCancel,
            style: TextStyle(
              color: Theme.of(context).colorScheme.muted,
              fontSize: isSmall ? 16 : null,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _handleExport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkCard,
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16, vertical: isSmall ? 10 : 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(color: Theme.of(context).colorScheme.success, width: 2),
            ),
          ),
          child: Text(
            'Export',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 18 : 20,
            ),
          ),
        ),
      ],
    );
  }

  String _sanitizeFolderName(String input) {
    var s = input.trim();
    s = s.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    s = s.replaceAll(RegExp(r'\s+'), '_');
    if (s.isEmpty) s = 'dataset';
    return s;
  }

  Future<List<MediaItem>> _fetchMediaItems() async {
    final datasets = await DatasetDatabase.instance.fetchDatasetsForProject(widget.project.id!);
    _datasetIdToFolderName.clear();
    final mediaItems = <MediaItem>[];
    for (final dataset in datasets) {
      // build mapping from datasetId to sanitized folder name
      final folderName = _sanitizeFolderName(dataset.name.isNotEmpty ? dataset.name : 'dataset');
      _datasetIdToFolderName[dataset.id] = folderName;
      final items = await DatasetDatabase.instance.fetchMediaForDataset(dataset.id);
      mediaItems.addAll(items);
    }
    return mediaItems;
  }

  Future<Map<int, List<Annotation>>> _fetchAnnotations(List<MediaItem> mediaItems) async {
    final annotationsByMediaId = <int, List<Annotation>>{};
    for (final mediaItem in mediaItems.where((m) => m.id != null)) {
      final annotations = await AnnotationDatabase.instance.fetchAnnotations(mediaItem.id!);
      if (annotations.isNotEmpty) {
        annotationsByMediaId[mediaItem.id!] = annotations;
      }
    }
    return annotationsByMediaId;
  }

  void _handleExport() async {
    if (_isExporting) return;

    // If the export labels button is hidden, ensure exportLabels is true
    if (!_showExportLabelsButton) {
      exportLabels = true;
    }
    // If labels are not exported, annotations cannot be exported
    if (!exportLabels) {
      exportAnnotations = false;
    }

    setState(() => _isExporting = true);

    try {
      _logger.info('Starting project export: ${widget.project.name} as $selectedDatasetType');
      
      // Resolve and ensure export folder exists (platform-aware)
      final exportFolder = await UserSession.instance.getCurrentUserDatasetExportFolder();
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${widget.project.name.replaceAll(' ', '_')}_${selectedDatasetType.toLowerCase()}_$timestamp.zip';
      final exportPath = path.join(exportFolder, filename);
      
      _logger.info('Fetching media items for project: ${widget.project.id}');
      final mediaItems = await _fetchMediaItems();
      _logger.info('Fetched ${mediaItems.length} media items');
      
      _logger.info('Fetching annotations');
      final annotationsByMediaId = await _fetchAnnotations(mediaItems);
      _logger.info('Fetched annotations for ${annotationsByMediaId.length} media items');

      _logger.info('Creating exporter for $selectedDatasetType');
      final exporter = ExporterFactory.createExporter(
        datasetType: selectedDatasetType,
        project: widget.project,
        exportLabels: exportLabels,
        exportAnnotations: exportAnnotations,
      );

      _logger.info('Building archive');
      final archive = await exporter.buildArchive(
        labels: widget.project.labels,
        mediaItems: mediaItems,
        annotationsByMediaId: annotationsByMediaId,
        mergeDatasets: mergeDatasets,
        datasetIdToFolderName: _datasetIdToFolderName,
      );

      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      if (zipData == null) {
        throw Exception('Failed to encode archive: zip data is null');
      }

      if (kIsWeb) {
        _triggerWebDownload(Uint8List.fromList(zipData), filename);
        if (!mounted) return;
        AppSnackbar.show(
          context,
          'Project exported successfully as $filename',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.of(context).pop('refresh');
      } else {
        // Native: write to filesystem with retry
        const maxRetries = 3;
        int retryCount = 0;
        bool success = false;
        Exception? lastException;
        StackTrace? lastStack;

        while (retryCount < maxRetries && !success) {
          try {
            _logger.info('Creating zip file (attempt ${retryCount + 1}/$maxRetries): $exportPath');

            final zipFile = File(exportPath);
            await zipFile.writeAsBytes(zipData);

            success = true;
            _logger.info('Successfully created zip file: $exportPath');

            if (!mounted) return;

            AppSnackbar.show(
              context,
              'Project exported successfully to ${path.basename(zipFile.path)}',
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );

            Navigator.of(context).pop('refresh');
          } catch (e, stack) {
            retryCount++;
            lastException = e is Exception ? e : Exception(e.toString());
            lastStack = stack;

            final errorMessage = 'Failed to create zip file (attempt $retryCount/$maxRetries): $exportPath';
            _logger.warning(errorMessage, e, stack);

            if (retryCount < maxRetries) {
              await Future.delayed(Duration(milliseconds: 500 * (1 << retryCount)));
            }
          }
        }

        if (!success) {
          _logger.severe('All attempts to create zip file failed: $exportPath', lastException, lastStack);
          throw lastException!;
        }
      }
    } catch (e, stack) {
      _logger.severe('Error while exporting project', e, stack);

      if (!mounted) return;

      // Provide more detailed error message based on the exception type
      String errorTitle = 'Export Failed';
      String errorMessage = 'Something went wrong while exporting your project.';
      String errorTips = '';
      
      if (e is FileSystemException) {
        errorTitle = 'File System Error';
        errorMessage = 'Failed to access the file system during export.';
        errorTips = 'Please check if you have write permissions to the export folder and sufficient disk space.\n\nError details: ${e.toString()}';
      } else if (e.toString().contains('directory does not exist')) {
        errorTitle = 'Directory Not Found';
        errorMessage = 'The export directory does not exist.';
        errorTips = 'Please set a valid export directory in your account settings.\n\nError details: ${e.toString()}';
      } else {
        errorTips = 'Please try again or contact support.\n\nError details: ${e.toString()}';
      }

      AlertErrorDialog.show(
        context,
        errorTitle,
        errorMessage,
        tips: errorTips,
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _triggerWebDownload(Uint8List bytes, String filename) {
    if (!kIsWeb) return;
    webDownloadBytes(bytes, filename);
  }
}