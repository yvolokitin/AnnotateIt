import 'dart:io';
import 'dart:ui';
import 'package:logging/logging.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path;

import '../../models/project.dart';
import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/project_database.dart';
import '../../data/labels_database.dart';
import '../../data/dataset_database.dart';
import '../../data/annotation_database.dart';

import 'base_dataset_exporter.dart';
import 'coco_exporter.dart';
import 'yolo_exporter.dart';
import 'datumaro_exporter.dart';

/// Utility class for dataset export operations
class DatasetExportUtils {
  static final Logger _logger = Logger('DatasetExportUtils');
  
  /// Create an exporter for the specified dataset type
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
  
  /// Fetch all data needed for export
  static Future<Map<String, dynamic>> fetchProjectData(Project project) async {
    _logger.info('Fetching data for project ${project.name}');
    
    // Fetch labels
    final labels = project.labels.isNotEmpty
        ? project.labels
        : await LabelsDatabase.instance.fetchLabelsByProject(project.id!);
    
    // Fetch datasets for the project
    final datasets = await DatasetDatabase.instance.fetchDatasetsForProject(project.id!);
    
    // Fetch media items for all datasets
    final List<MediaItem> mediaItems = [];
    for (final dataset in datasets) {
      final datasetMediaItems = await DatasetDatabase.instance.fetchMediaForDataset(dataset.id);
      mediaItems.addAll(datasetMediaItems);
    }
    
    // Fetch annotations for each media item
    final Map<int, List<Annotation>> annotationsByMediaId = {};
    for (final mediaItem in mediaItems) {
      if (mediaItem.id != null) {
        final annotations = await AnnotationDatabase.instance.fetchAnnotations(mediaItem.id!);
        if (annotations.isNotEmpty) {
          annotationsByMediaId[mediaItem.id!] = annotations;
        }
      }
    }
    
    return {
      'labels': labels,
      'mediaItems': mediaItems,
      'annotationsByMediaId': annotationsByMediaId,
    };
  }
  
  /// Create a ZIP file from a directory
  static Future<File> createZipFile(String sourceDir, String destinationPath) async {
    _logger.info('Creating ZIP file at $destinationPath');
    
    // Ensure the destination directory exists
    final destinationDir = Directory(path.dirname(destinationPath));
    if (!await destinationDir.exists()) {
      await destinationDir.create(recursive: true);
    }
    
    try {
      // Create a ZIP encoder
      final zipEncoder = ZipFileEncoder();
      zipEncoder.create(destinationPath);
      
      // Add all files in the source directory to the ZIP
      final sourceDirectory = Directory(sourceDir);
      await for (final entity in sourceDirectory.list(recursive: true)) {
        if (entity is File) {
          final relativePath = path.relative(entity.path, from: sourceDir);
          zipEncoder.addFile(entity, path.join(relativePath));
        }
      }
      
      // Close the ZIP encoder
      zipEncoder.close();
      
      return File(destinationPath);
    } catch (e) {
      _logger.severe('Error creating ZIP file: $e');
      rethrow;
    }
  }
  
  /// Export a project to a dataset
  static Future<String> exportProject({
    required Project project,
    required String datasetType,
    required String exportPath,
    required bool exportLabels,
    required bool exportAnnotations,
  }) async {
    _logger.info('Exporting project ${project.name} to $datasetType format');
    
    try {
      // Create the exporter
      final exporter = createExporter(
        datasetType: datasetType,
        project: project,
        exportLabels: exportLabels,
        exportAnnotations: exportAnnotations,
      );
      
      // Fetch project data
      final projectData = await fetchProjectData(project);
      
      // Create a temporary directory for the export
      final tempDir = await Directory.systemTemp.createTemp('annotate_it_export_');
      try {
        // Prepare the export directory
        await exporter.prepareExportDirectory(tempDir.path);
        
        // Export the dataset
        await exporter.exportDataset(
          exportDir: tempDir.path,
          labels: projectData['labels'],
          mediaItems: projectData['mediaItems'],
          annotationsByMediaId: projectData['annotationsByMediaId'],
        );
        
        // Create a ZIP file
        await createZipFile(tempDir.path, exportPath);
        
        return exportPath;
      } finally {
        // Clean up the temporary directory
        await tempDir.delete(recursive: true);
      }
    } catch (e, stack) {
      _logger.severe('Error exporting project: $e\n$stack');
      rethrow;
    }
  }
}