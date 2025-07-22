import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../../models/project.dart';
import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../models/shape/rect_shape.dart';
import '../../models/shape/polygon_shape.dart';

import 'base_dataset_exporter.dart';

/// Exporter for COCO format datasets
class COCOExporter extends BaseDatasetExporter {
  static final Logger _logger = Logger('COCOExporter');
  
  COCOExporter({
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
    _logger.info('Exporting dataset in COCO format');
    
    // Create the COCO JSON structure
    final Map<String, dynamic> cocoJson = {
      'info': {
        'description': 'Exported from AnnotateIt',
        'url': '',
        'version': '1.0',
        'year': DateTime.now().year,
        'contributor': '',
        'date_created': DateTime.now().toIso8601String(),
      },
      'licenses': [
        {
          'id': 1,
          'name': 'Unknown',
          'url': '',
        },
      ],
      'images': <Map<String, dynamic>>[],
      'annotations': <Map<String, dynamic>>[],
      'categories': <Map<String, dynamic>>[],
    };
    
    // Add categories (labels)
    if (exportLabels) {
      for (int i = 0; i < labels.length; i++) {
        final label = labels[i];
        cocoJson['categories'].add({
          'id': i + 1, // COCO uses 1-based indexing for categories
          'name': label.name,
          'supercategory': 'none',
        });
      }
    }
    
    // Create a map of label ID to COCO category ID
    final Map<int, int> labelIdToCategoryId = {};
    for (int i = 0; i < labels.length; i++) {
      labelIdToCategoryId[labels[i].id] = i + 1;
    }
    
    // Add images and copy image files
    int imageId = 1;
    final Map<int, int> mediaIdToImageId = {};
    
    for (final mediaItem in mediaItems) {
      if (mediaItem.type != MediaType.image) {
        continue; // Skip non-image media items
      }
      
      // Add image to COCO JSON
      cocoJson['images'].add({
        'id': imageId,
        'width': mediaItem.width,
        'height': mediaItem.height,
        'file_name': path.basename(mediaItem.filePath),
        'license': 1,
        'flickr_url': '',
        'coco_url': '',
        'date_captured': mediaItem.uploadDate.toIso8601String(),
      });
      
      // Copy image file to export directory
      final sourceFile = File(mediaItem.filePath);
      if (await sourceFile.exists()) {
        final destFile = File(path.join(exportDir, 'images', path.basename(mediaItem.filePath)));
        await sourceFile.copy(destFile.path);
      } else {
        _logger.warning('Image file not found: ${mediaItem.filePath}');
      }
      
      mediaIdToImageId[mediaItem.id!] = imageId;
      imageId++;
    }
    
    // Add annotations
    if (exportAnnotations) {
      int annotationId = 1;
      
      for (final mediaId in annotationsByMediaId.keys) {
        final annotations = annotationsByMediaId[mediaId]!;
        final cocoImageId = mediaIdToImageId[mediaId];
        
        if (cocoImageId == null) {
          continue; // Skip if media item was not included
        }
        
        for (final annotation in annotations) {
          final labelId = annotation.labelId;
          if (labelId == null) {
            continue; // Skip annotations without a label
          }
          
          final categoryId = labelIdToCategoryId[labelId];
          if (categoryId == null) {
            continue; // Skip if label was not included
          }
          
          // Convert annotation to COCO format based on annotation type
          final Map<String, dynamic>? cocoAnnotation = _convertAnnotationToCOCO(
            annotation: annotation,
            annotationId: annotationId,
            imageId: cocoImageId,
            categoryId: categoryId,
          );
          
          if (cocoAnnotation != null) {
            cocoJson['annotations'].add(cocoAnnotation);
            annotationId++;
          }
        }
      }
    }
    
    // Write COCO JSON to file
    final cocoJsonFile = File(path.join(exportDir, 'annotations', 'instances_default.json'));
    await cocoJsonFile.writeAsString(jsonEncode(cocoJson));
  }
  
  /// Convert an annotation to COCO format
  Map<String, dynamic>? _convertAnnotationToCOCO({
    required Annotation annotation,
    required int annotationId,
    required int imageId,
    required int categoryId,
  }) {
    final projectTypeLower = project.type.toLowerCase();
    
    if (projectTypeLower.contains('detection') && annotation.annotationType == 'bbox') {
      // Get the bounding box data
      final shape = annotation.shape;
      if (shape is RectShape) {
        final bbox = [
          shape.x,
          shape.y,
          shape.width,
          shape.height,
        ];
        
        return {
          'id': annotationId,
          'image_id': imageId,
          'category_id': categoryId,
          'bbox': bbox,
          'area': shape.width * shape.height,
          'segmentation': [],
          'iscrowd': 0,
        };
      }
    } else if (projectTypeLower.contains('segmentation') && annotation.annotationType == 'polygon') {
      // Get the polygon data
      final shape = annotation.shape;
      if (shape is PolygonShape) {
        final points = shape.points;
        final List<double> flatPoints = [];
        
        // Flatten the points into a single list [x1, y1, x2, y2, ...]
        for (final point in points) {
          flatPoints.add(point.dx);
          flatPoints.add(point.dy);
        }
        
        // Calculate the area of the polygon
        double area = 0;
        for (int i = 0; i < points.length; i++) {
          final j = (i + 1) % points.length;
          area += points[i].dx * points[j].dy;
          area -= points[j].dx * points[i].dy;
        }
        area = area.abs() / 2;
        
        // Calculate bounding box directly
        double minX = double.infinity;
        double minY = double.infinity;
        double maxX = double.negativeInfinity;
        double maxY = double.negativeInfinity;
        
        for (final point in points) {
          if (point.dx < minX) minX = point.dx;
          if (point.dy < minY) minY = point.dy;
          if (point.dx > maxX) maxX = point.dx;
          if (point.dy > maxY) maxY = point.dy;
        }
        
        final bbox = [minX, minY, maxX - minX, maxY - minY];
        
        return {
          'id': annotationId,
          'image_id': imageId,
          'category_id': categoryId,
          'bbox': bbox,
          'area': area,
          'segmentation': [flatPoints],
          'iscrowd': 0,
        };
      }
    } else if (projectTypeLower.contains('classification')) {
      // For classification, we just need the category ID
      return {
        'id': annotationId,
        'image_id': imageId,
        'category_id': categoryId,
        'bbox': [0, 0, 0, 0], // Empty bbox
        'area': 0,
        'segmentation': [],
        'iscrowd': 0,
      };
    }
    
    return null;
  }
  
}