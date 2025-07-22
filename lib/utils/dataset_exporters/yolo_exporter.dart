import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../../models/project.dart';
import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../models/shape/rect_shape.dart';

import 'base_dataset_exporter.dart';

/// Exporter for YOLO format datasets
class YOLOExporter extends BaseDatasetExporter {
  static final Logger _logger = Logger('YOLOExporter');
  
  YOLOExporter({
    required Project project,
    required bool exportLabels,
    required bool exportAnnotations,
  }) : super(
    project: project,
    exportLabels: exportLabels,
    exportAnnotations: exportAnnotations,
  );
  
  @override
  Future<void> prepareExportDirectory(String exportDir) async {
    // Create the images directory
    final imagesDir = Directory(path.join(exportDir, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    // Create the labels directory
    final labelsDir = Directory(path.join(exportDir, 'labels'));
    if (!await labelsDir.exists()) {
      await labelsDir.create(recursive: true);
    }
  }
  
  @override
  Future<void> exportDataset({
    required String exportDir,
    required List<Label> labels,
    required List<MediaItem> mediaItems,
    required Map<int, List<Annotation>> annotationsByMediaId,
  }) async {
    _logger.info('Exporting dataset in YOLO format');
    
    // Create a map of label ID to YOLO class index
    final Map<int, int> labelIdToClassIndex = {};
    for (int i = 0; i < labels.length; i++) {
      labelIdToClassIndex[labels[i].id] = i;
    }
    
    // Export class names file
    if (exportLabels) {
      final classesFile = File(path.join(exportDir, 'classes.txt'));
      final classesContent = labels.map((label) => label.name).join('\n');
      await classesFile.writeAsString(classesContent);
    }
    
    // Process each media item
    for (final mediaItem in mediaItems) {
      if (mediaItem.type != MediaType.image || mediaItem.id == null) {
        continue; // Skip non-image media items or items without an ID
      }
      
      // Copy image file to export directory
      final sourceFile = File(mediaItem.filePath);
      if (await sourceFile.exists()) {
        final destFile = File(path.join(exportDir, 'images', path.basename(mediaItem.filePath)));
        await sourceFile.copy(destFile.path);
      } else {
        _logger.warning('Image file not found: ${mediaItem.filePath}');
        continue;
      }
      
      // Export annotations for this media item
      if (exportAnnotations) {
        final annotations = annotationsByMediaId[mediaItem.id!] ?? [];
        
        // Create a label file for this image
        final imageBaseName = path.basenameWithoutExtension(mediaItem.filePath);
        final labelFile = File(path.join(exportDir, 'labels', '$imageBaseName.txt'));
        
        // Only process annotations if the project type is compatible with YOLO
        if (project.type.toLowerCase().contains('detection')) {
          final labelLines = <String>[];
          
          for (final annotation in annotations) {
            if (annotation.annotationType != 'bbox' || annotation.labelId == null) {
              continue; // Skip non-bbox annotations or annotations without a label
            }
            
            final classIndex = labelIdToClassIndex[annotation.labelId];
            if (classIndex == null) {
              continue; // Skip if label was not included
            }
            
            // Convert annotation to YOLO format
            final yoloAnnotation = _convertAnnotationToYOLO(
              annotation: annotation,
              imageWidth: mediaItem.width ?? 0,
              imageHeight: mediaItem.height ?? 0,
              classIndex: classIndex,
            );
            
            if (yoloAnnotation != null) {
              labelLines.add(yoloAnnotation);
            }
          }
          
          // Write label file
          await labelFile.writeAsString(labelLines.join('\n'));
        } else if (project.type.toLowerCase().contains('classification')) {
          // For classification, we just need the class index
          final classIndices = <int>[];
          
          for (final annotation in annotations) {
            if (annotation.labelId == null) {
              continue; // Skip annotations without a label
            }
            
            final classIndex = labelIdToClassIndex[annotation.labelId];
            if (classIndex != null) {
              classIndices.add(classIndex);
            }
          }
          
          // Write label file with one class index per line
          if (classIndices.isNotEmpty) {
            await labelFile.writeAsString(classIndices.map((index) => index.toString()).join('\n'));
          }
        }
      }
    }
    
    // Create a data.yaml file for YOLO
    final dataYaml = '''
# YOLO dataset exported from AnnotateIt
path: .
train: images
val: images
test: images

nc: ${labels.length}
names: ${labels.map((label) => label.name).toList()}
''';
    
    final dataYamlFile = File(path.join(exportDir, 'data.yaml'));
    await dataYamlFile.writeAsString(dataYaml);
  }
  
  /// Convert an annotation to YOLO format
  /// YOLO format: <class_index> <center_x> <center_y> <width> <height>
  /// All values are normalized to [0, 1]
  String? _convertAnnotationToYOLO({
    required Annotation annotation,
    required int imageWidth,
    required int imageHeight,
    required int classIndex,
  }) {
    if (imageWidth <= 0 || imageHeight <= 0) {
      return null; // Skip if image dimensions are invalid
    }
    
    final shape = annotation.shape;
    if (shape is RectShape) {
      // Calculate normalized values
      final centerX = (shape.x + shape.width / 2) / imageWidth;
      final centerY = (shape.y + shape.height / 2) / imageHeight;
      final normalizedWidth = shape.width / imageWidth;
      final normalizedHeight = shape.height / imageHeight;
      
      // Format with 6 decimal places
      return '$classIndex ${centerX.toStringAsFixed(6)} ${centerY.toStringAsFixed(6)} ${normalizedWidth.toStringAsFixed(6)} ${normalizedHeight.toStringAsFixed(6)}';
    }
    
    return null;
  }
}