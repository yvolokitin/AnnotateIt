import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../../models/project.dart';
import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../models/shape/rect_shape.dart';
import '../../models/shape/polygon_shape.dart';
import '../../models/shape/circle_shape.dart';
import '../../models/shape/rotated_rect_shape.dart';

import 'base_dataset_exporter.dart';

/// Exporter for Datumaro format datasets
class DatumaroExporter extends BaseDatasetExporter {
  static final Logger _logger = Logger('DatumaroExporter');
  
  DatumaroExporter({
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
    
    // Create the annotations directory
    final annotationsDir = Directory(path.join(exportDir, 'annotations'));
    if (!await annotationsDir.exists()) {
      await annotationsDir.create(recursive: true);
    }
  }
  
  @override
  Future<void> exportDataset({
    required String exportDir,
    required List<Label> labels,
    required List<MediaItem> mediaItems,
    required Map<int, List<Annotation>> annotationsByMediaId,
  }) async {
    _logger.info('Exporting dataset in Datumaro format');
    
    // Create the Datumaro dataset structure
    final Map<String, dynamic> datasetJson = {
      'info': {
        'description': 'Exported from AnnotateIt',
        'contributor': '',
        'date_created': DateTime.now().toIso8601String(),
        'version': '1.0',
      },
      'categories': <String, dynamic>{},
      'items': <Map<String, dynamic>>[],
    };
    
    // Add categories (labels)
    if (exportLabels) {
      final Map<String, dynamic> labelCategories = {};
      
      // Determine the category type based on project type
      String categoryType = 'label';
      if (project.type.toLowerCase().contains('detection')) {
        categoryType = 'bbox';
      } else if (project.type.toLowerCase().contains('segmentation')) {
        categoryType = 'polygon';
      }
      
      // Add labels to the appropriate category type
      labelCategories[categoryType] = {
        'labels': labels.map((label) => label.name).toList(),
        'attributes': {},
      };
      
      datasetJson['categories'] = labelCategories;
    }
    
    // Process each media item
    for (final mediaItem in mediaItems) {
      if (mediaItem.type != MediaType.image || mediaItem.id == null) {
        continue; // Skip non-image media items or items without an ID
      }
      
      // Copy image file to export directory
      final sourceFile = File(mediaItem.filePath);
      final imageFileName = path.basename(mediaItem.filePath);
      
      if (await sourceFile.exists()) {
        final destFile = File(path.join(exportDir, 'images', imageFileName));
        await sourceFile.copy(destFile.path);
      } else {
        _logger.warning('Image file not found: ${mediaItem.filePath}');
        continue;
      }
      
      // Create item entry
      final Map<String, dynamic> item = {
        'id': mediaItem.id,
        'image': {
          'path': 'images/$imageFileName',
          'size': [
            mediaItem.width ?? 0,
            mediaItem.height ?? 0,
          ],
        },
        'annotations': <Map<String, dynamic>>[],
      };
      
      // Add annotations for this media item
      if (exportAnnotations) {
        final annotations = annotationsByMediaId[mediaItem.id!] ?? [];
        
        for (final annotation in annotations) {
          if (annotation.labelId == null) {
            continue; // Skip annotations without a label
          }
          
          // Find the label for this annotation
          final label = labels.firstWhere(
            (l) => l.id == annotation.labelId,
            orElse: () => Label(
              id: -1,
              labelOrder: 0,
              projectId: project.id ?? -1,
              name: 'Unknown',
              color: '#000000',
            ),
          );
          
          // Convert annotation to Datumaro format
          final Map<String, dynamic>? datumaroAnnotation = _convertAnnotationToDatumaro(
            annotation: annotation,
            label: label,
          );
          
          if (datumaroAnnotation != null) {
            item['annotations'].add(datumaroAnnotation);
          }
        }
      }
      
      datasetJson['items'].add(item);
    }
    
    // Write Datumaro JSON to file
    final datasetJsonFile = File(path.join(exportDir, 'annotations', 'default.json'));
    await datasetJsonFile.writeAsString(jsonEncode(datasetJson));
    
    // Create a README.md file with information about the dataset
    final readmeContent = '''
# Datumaro Dataset

This dataset was exported from AnnotateIt.

## Project Information
- Name: ${project.name}
- Type: ${project.type}
- Creation Date: ${project.creationDate.toIso8601String()}
- Last Updated: ${project.lastUpdated.toIso8601String()}

## Dataset Statistics
- Number of Images: ${mediaItems.where((m) => m.type == MediaType.image).length}
- Number of Labels: ${labels.length}
''';
    
    final readmeFile = File(path.join(exportDir, 'README.md'));
    await readmeFile.writeAsString(readmeContent);
  }
  
  /// Convert an annotation to Datumaro format
  Map<String, dynamic>? _convertAnnotationToDatumaro({
    required Annotation annotation,
    required Label label,
  }) {
    final projectTypeLower = project.type.toLowerCase();
    
    // Base annotation structure
    final Map<String, dynamic> datumaroAnnotation = {
      'id': annotation.id,
      'attributes': {},
    };
    
    if (projectTypeLower.contains('detection') && annotation.annotationType == 'bbox') {
      final shape = annotation.shape;
      if (shape is RectShape) {
        datumaroAnnotation['type'] = 'bbox';
        datumaroAnnotation['label'] = label.name;
        datumaroAnnotation['bbox'] = [
          shape.x,
          shape.y,
          shape.width,
          shape.height,
        ];
        
        if (annotation.confidence != null) {
          datumaroAnnotation['attributes']['score'] = annotation.confidence;
        }
        
        return datumaroAnnotation;
      }
    } else if (projectTypeLower.contains('segmentation') && annotation.annotationType == 'polygon') {
      final shape = annotation.shape;
      if (shape is PolygonShape) {
        final points = shape.points;
        final List<List<double>> pointsList = [];
        
        // Convert points to list of [x, y] coordinates
        for (final point in points) {
          pointsList.add([point.dx, point.dy]);
        }
        
        datumaroAnnotation['type'] = 'polygon';
        datumaroAnnotation['label'] = label.name;
        datumaroAnnotation['points'] = pointsList;
        
        if (annotation.confidence != null) {
          datumaroAnnotation['attributes']['score'] = annotation.confidence;
        }
        
        return datumaroAnnotation;
      }
    } else if (annotation.annotationType == 'circle') {
      final shape = annotation.shape;
      if (shape is CircleShape) {
        datumaroAnnotation['type'] = 'circle';
        datumaroAnnotation['label'] = label.name;
        datumaroAnnotation['center'] = [shape.center.dx, shape.center.dy];
        datumaroAnnotation['radius'] = shape.radius;
        
        if (annotation.confidence != null) {
          datumaroAnnotation['attributes']['score'] = annotation.confidence;
        }
        
        return datumaroAnnotation;
      }
    } else if (annotation.annotationType == 'rotated_rect') {
      final shape = annotation.shape;
      if (shape is RotatedRectShape) {
        datumaroAnnotation['type'] = 'rotated_bbox';
        datumaroAnnotation['label'] = label.name;
        // Use the correct property names from RotatedRectShape
        datumaroAnnotation['center'] = [shape.centerX, shape.centerY];
        datumaroAnnotation['width'] = shape.width;
        datumaroAnnotation['height'] = shape.height;
        datumaroAnnotation['rotation'] = shape.angle;
        
        if (annotation.confidence != null) {
          datumaroAnnotation['attributes']['score'] = annotation.confidence;
        }
        
        return datumaroAnnotation;
      }
    } else if (projectTypeLower.contains('classification')) {
      // For classification, we just need the label
      datumaroAnnotation['type'] = 'label';
      datumaroAnnotation['label'] = label.name;
      
      if (annotation.confidence != null) {
        datumaroAnnotation['attributes']['score'] = annotation.confidence;
      }
      
      return datumaroAnnotation;
    }
    
    return null;
  }
}