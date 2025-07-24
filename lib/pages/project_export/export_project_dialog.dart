import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:archive/archive_io.dart';

import '../../widgets/app_snackbar.dart';
import '../../widgets/dialogs/alert_error_dialog.dart';
import '../../session/user_session.dart';

import '../../models/project.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';

import '../../gen_l10n/app_localizations.dart';
import '../../data/dataset_database.dart';
import '../../data/annotation_database.dart';
import '../../utils/dataset_exporters/exporter_factory.dart';

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
  String selectedDatasetType = 'COCO';
  bool exportLabels = true;
  bool exportAnnotations = true;
  bool _isExporting = false;

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
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
                      const Divider(color: Colors.white70),
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
                    icon: const Icon(Icons.close, color: Colors.white70),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.upload_file,
              size: screenWidth >= 1600 ? 34 : 30,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              'Export Project as Dataset',
              style: TextStyle(
                fontSize: screenWidth >= 1600 ? 26 : 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'CascadiaCode',
                color: Colors.white,
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
              fontFamily: 'CascadiaCode',
              color: Colors.white24,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExportOptions(double screenWidth) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dataset Type',
            style: TextStyle(
              fontSize: screenWidth > 1200 ? 22 : 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'CascadiaCode',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildDatasetTypeCard('COCO', 'Common Objects in Context', Icons.photo_library),
              _buildDatasetTypeCard('YOLO', 'You Only Look Once', Icons.view_in_ar),
              _buildDatasetTypeCard('Datumaro', 'Universal Dataset Format', Icons.data_object),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Export Options',
            style: TextStyle(
              fontSize: screenWidth > 1200 ? 22 : 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'CascadiaCode',
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildExportToggle(
            'Export All Labels',
            exportLabels,
            (value) => setState(() => exportLabels = value),
            screenWidth,
          ),
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
    
    return InkWell(
      onTap: () => setState(() => selectedDatasetType = type),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.2) : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.red : Colors.white70,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  type,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'CascadiaCode',
                    color: isSelected ? Colors.red : Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'CascadiaCode',
                color: Colors.white70,
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
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth > 1200 ? 20 : 16,
          fontFamily: 'CascadiaCode',
          color: Colors.white,
        ),
      ),
      value: value,
      onChanged: _isExporting ? null : onChanged,
      activeColor: Colors.red,
    );
  }

  Widget _buildBottomButtons(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: Text(
            l10n.buttonCancel,
            style: TextStyle(
              color: Colors.white54,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _handleExport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[850],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          child: Text(
            'Export',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  Future<List<MediaItem>> _fetchMediaItems() async {
    final datasets = await DatasetDatabase.instance.fetchDatasetsForProject(widget.project.id!);
    final mediaItems = <MediaItem>[];
    for (final dataset in datasets) {
      mediaItems.addAll(await DatasetDatabase.instance.fetchMediaForDataset(dataset.id));
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

    setState(() => _isExporting = true);

    try {
      final currentUser = UserSession.instance.getUser();
      final exportFolder = currentUser.datasetExportFolder;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${widget.project.name.replaceAll(' ', '_')}_${selectedDatasetType.toLowerCase()}_$timestamp.zip';
      final exportPath = path.join(exportFolder, filename);

      final mediaItems = await _fetchMediaItems();
      final annotationsByMediaId = await _fetchAnnotations(mediaItems);

      final exporter = ExporterFactory.createExporter(
        datasetType: selectedDatasetType,
        project: widget.project,
        exportLabels: exportLabels,
        exportAnnotations: exportAnnotations,
      );

      final archive = await exporter.buildArchive(
        labels: widget.project.labels,
        mediaItems: mediaItems,
        annotationsByMediaId: annotationsByMediaId,
      );

      // Create zip file
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);
      final zipFile = File(exportPath);
      await zipFile.writeAsBytes(zipData!);

      if (!mounted) return;

      AppSnackbar.show(
        context,
        'Project exported successfully to ${path.basename(zipFile.path)}',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.of(context).pop('refresh');
    } catch (e, stack) {
      debugPrint('Error while exporting project: $e\n$stack');

      if (!mounted) return;

      AlertErrorDialog.show(
        context,
        'Export Failed',
        'Something went wrong while exporting your project. Please try again or contact support.',
        tips: e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}
