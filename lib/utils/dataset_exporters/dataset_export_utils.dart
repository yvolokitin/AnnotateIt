import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../../models/project.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../models/label.dart';
import '../../data/labels_database.dart';
import '../../data/dataset_database.dart';
import '../../data/annotation_database.dart';

import 'base_dataset_exporter.dart';
import 'coco_exporter.dart';
import 'yolo_exporter.dart';
import 'datumaro_exporter.dart';

class DatasetExportUtils {
  static final Logger _logger = Logger('DatasetExportUtils');

  static BaseDatasetExporter createExporter({
    required String datasetType,
    required Project project,
    required bool exportLabels,
    required bool exportAnnotations,
  }) {
    switch (datasetType.toUpperCase()) {
      case 'COCO':
        return COCOExporter(
          project: project,
          exportLabels: exportLabels,
          exportAnnotations: exportAnnotations,
        );
      case 'YOLO':
        return YOLOExporter(
          project: project,
          exportLabels: exportLabels,
          exportAnnotations: exportAnnotations,
        );
      case 'DATUMARO':
        return DatumaroExporter(
          project: project,
          exportLabels: exportLabels,
          exportAnnotations: exportAnnotations,
        );
      default:
        throw ArgumentError('Unsupported dataset type: $datasetType');
    }
  }

  static Future<Map<String, dynamic>> fetchProjectData(Project project) async {
    _logger.info('Fetching data for project ${project.name}');

    final labels = project.labels.isNotEmpty
        ? project.labels
        : await LabelsDatabase.instance.fetchLabelsByProject(project.id!);

    final datasets = await DatasetDatabase.instance.fetchDatasetsForProject(project.id!);

    final List<MediaItem> mediaItems = [];
    for (final dataset in datasets) {
      mediaItems.addAll(await DatasetDatabase.instance.fetchMediaForDataset(dataset.id));
    }

    final annotationsByMediaId = <int, List<Annotation>>{};
    for (final mediaItem in mediaItems.where((m) => m.id != null)) {
      final annotations = await AnnotationDatabase.instance.fetchAnnotations(mediaItem.id!);
      if (annotations.isNotEmpty) {
        annotationsByMediaId[mediaItem.id!] = annotations;
      }
    }

    return {
      'labels': labels,
      'mediaItems': mediaItems,
      'annotationsByMediaId': annotationsByMediaId,
    };
  }

  static Future<String> exportProject({
    required Project project,
    required String datasetType,
    required String exportPath,
    required bool exportLabels,
    required bool exportAnnotations,
  }) async {
    _logger.info('Exporting project ${project.name} to $datasetType format');

    final exporter = createExporter(
      datasetType: datasetType,
      project: project,
      exportLabels: exportLabels,
      exportAnnotations: exportAnnotations,
    );

    final projectData = await fetchProjectData(project);

    final archive = await exporter.buildArchive(
      labels: projectData['labels'],
      mediaItems: projectData['mediaItems'],
      annotationsByMediaId: projectData['annotationsByMediaId'],
    );

    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null || zipBytes.isEmpty) {
      throw Exception('Failed to encode ZIP archive');
    }

    final zipFile = File(exportPath);
    await zipFile.parent.create(recursive: true);
    await zipFile.writeAsBytes(zipBytes);

    final zipSize = (await zipFile.stat()).size;
    _logger.info('Created ZIP file (${zipSize} bytes) at ${zipFile.path}');

    if (zipSize <= 1024) {
      throw Exception('Created ZIP file is too small ($zipSize bytes), likely empty');
    }

    return exportPath;
  }
}
