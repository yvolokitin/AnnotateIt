import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../../models/project.dart';
import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../models/shape/rect_shape.dart';
import '../../models/shape/polygon_shape.dart';

import 'base_dataset_exporter.dart';

class COCOExporter extends BaseDatasetExporter {
  static final Logger _logger = Logger('COCOExporter');

  COCOExporter({
    required super.project,
    required super.exportLabels,
    required super.exportAnnotations,
  });

  @override
  Future<Archive> buildArchive({
    required List<Label> labels,
    required List<MediaItem> mediaItems,
    required Map<int, List<Annotation>> annotationsByMediaId,
  }) async {
    _logger.info('Exporting dataset in COCO format');

    final archive = Archive();

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

    // Add categories
    final Map<int, int> labelIdToCategoryId = {};
    if (exportLabels) {
      for (int i = 0; i < labels.length; i++) {
        final label = labels[i];
        cocoJson['categories'].add({
          'id': i + 1,
          'name': label.name,
          'supercategory': 'none',
        });
        labelIdToCategoryId[label.id] = i + 1;
      }
    }

    int imageId = 1;
    final Map<int, int> mediaIdToImageId = {};

    for (final mediaItem in mediaItems) {
      if (mediaItem.type != MediaType.image || mediaItem.id == null) continue;

      final fileName = path.basename(mediaItem.filePath);
      final file = File(mediaItem.filePath);
      if (!await file.exists()) {
        _logger.warning('Image file not found: ${mediaItem.filePath}');
        continue;
      }

      try {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          archive.addFile(ArchiveFile('images/$fileName', bytes.length, bytes));
        }
      } catch (e) {
        _logger.severe('Failed to read ${mediaItem.filePath}: $e');
        continue;
      }

      cocoJson['images'].add({
        'id': imageId,
        'width': mediaItem.width ?? 0,
        'height': mediaItem.height ?? 0,
        'file_name': fileName,
        'license': 1,
        'flickr_url': '',
        'coco_url': '',
        'date_captured': mediaItem.uploadDate.toIso8601String(),
      });

      mediaIdToImageId[mediaItem.id!] = imageId;
      imageId++;
    }

    if (exportAnnotations) {
      int annotationId = 1;

      for (final mediaId in annotationsByMediaId.keys) {
        final annotations = annotationsByMediaId[mediaId]!;
        final imageId = mediaIdToImageId[mediaId];
        if (imageId == null) continue;

        for (final annotation in annotations) {
          final labelId = annotation.labelId;
          if (labelId == null) continue;

          final categoryId = labelIdToCategoryId[labelId];
          if (categoryId == null) continue;

          final cocoAnnotation = _convertAnnotationToCOCO(
            annotation: annotation,
            annotationId: annotationId,
            imageId: imageId,
            categoryId: categoryId,
          );

          if (cocoAnnotation != null) {
            cocoJson['annotations'].add(cocoAnnotation);
            annotationId++;
          }
        }
      }
    }

    final jsonStr = jsonEncode(cocoJson);
    archive.addFile(ArchiveFile('annotations/instances_default.json', jsonStr.length, utf8.encode(jsonStr)));

    return archive;
  }

  Map<String, dynamic>? _convertAnnotationToCOCO({
    required Annotation annotation,
    required int annotationId,
    required int imageId,
    required int categoryId,
  }) {
    final type = project.type.toLowerCase();

    if (type.contains('detection') && annotation.annotationType == 'bbox') {
      final shape = annotation.shape;
      if (shape is RectShape) {
        return {
          'id': annotationId,
          'image_id': imageId,
          'category_id': categoryId,
          'bbox': [shape.x, shape.y, shape.width, shape.height],
          'area': shape.width * shape.height,
          'segmentation': [],
          'iscrowd': 0,
        };
      }
    } else if (type.contains('segmentation') && annotation.annotationType == 'polygon') {
      final shape = annotation.shape;
      if (shape is PolygonShape) {
        final points = shape.points;
        final flatPoints = <double>[];
        for (final p in points) {
          flatPoints.add(p.dx);
          flatPoints.add(p.dy);
        }

        // area using shoelace formula
        double area = 0;
        for (int i = 0; i < points.length; i++) {
          final j = (i + 1) % points.length;
          area += points[i].dx * points[j].dy;
          area -= points[j].dx * points[i].dy;
        }
        area = area.abs() / 2;

        // bbox
        final xs = points.map((p) => p.dx);
        final ys = points.map((p) => p.dy);
        final bbox = [
          xs.reduce((a, b) => a < b ? a : b),
          ys.reduce((a, b) => a < b ? a : b),
          xs.reduce((a, b) => a > b ? a : b) - xs.reduce((a, b) => a < b ? a : b),
          ys.reduce((a, b) => a > b ? a : b) - ys.reduce((a, b) => a < b ? a : b),
        ];

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
    } else if (type.contains('classification')) {
      return {
        'id': annotationId,
        'image_id': imageId,
        'category_id': categoryId,
        'bbox': [0, 0, 0, 0],
        'area': 0,
        'segmentation': [],
        'iscrowd': 0,
      };
    }

    return null;
  }
}
