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
import '../../models/shape/circle_shape.dart';
import '../../models/shape/rotated_rect_shape.dart';

import 'base_dataset_exporter.dart';

class DatumaroExporter extends BaseDatasetExporter {
  static final Logger _logger = Logger('DatumaroExporter');

  DatumaroExporter({
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
    _logger.info('Exporting dataset in Datumaro format');

    final Archive archive = Archive();

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

    // Add categories
    if (exportLabels) {
      final Map<String, dynamic> labelCategories = {};
      String categoryType = 'label';

      if (project.type.toLowerCase().contains('detection')) {
        categoryType = 'bbox';
      } else if (project.type.toLowerCase().contains('segmentation')) {
        categoryType = 'polygon';
      }

      labelCategories[categoryType] = {
        'labels': labels.map((label) => label.name).toList(),
        'attributes': {},
      };

      datasetJson['categories'] = labelCategories;
    }

    // Add media and annotations
    for (final mediaItem in mediaItems) {
      if (mediaItem.type != MediaType.image || mediaItem.id == null) continue;

      final sourceFile = File(mediaItem.filePath);
      final imageFileName = path.basename(mediaItem.filePath);

      if (await sourceFile.exists()) {
        try {
          final bytes = await sourceFile.readAsBytes();
          if (bytes.isNotEmpty) {
            archive.addFile(ArchiveFile('images/$imageFileName', bytes.length, bytes));
            _logger.fine('Added to ZIP: images/$imageFileName');
          }
        } catch (e) {
          _logger.severe('Failed to read ${sourceFile.path}: $e');
          continue;
        }
      } else {
        _logger.warning('Image file not found: ${mediaItem.filePath}');
        continue;
      }

      final Map<String, dynamic> item = {
        'id': mediaItem.id,
        'image': {
          'path': 'images/$imageFileName',
          'size': [mediaItem.width ?? 0, mediaItem.height ?? 0],
        },
        'annotations': <Map<String, dynamic>>[],
      };

      if (exportAnnotations) {
        final annotations = annotationsByMediaId[mediaItem.id!] ?? [];

        for (final annotation in annotations) {
          if (annotation.labelId == null) continue;

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

          final datumaroAnnotation = _convertAnnotationToDatumaro(
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

    // Add annotations/default.json
    final annotationJson = jsonEncode(datasetJson);
    archive.addFile(ArchiveFile(
      'annotations/default.json',
      utf8.encode(annotationJson).length,
      utf8.encode(annotationJson),
    ));

    // Add README.md
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

    archive.addFile(ArchiveFile(
      'README.md',
      readmeContent.length,
      utf8.encode(readmeContent),
    ));

    return archive;
  }

  Map<String, dynamic>? _convertAnnotationToDatumaro({
    required Annotation annotation,
    required Label label,
  }) {
    final projectTypeLower = project.type.toLowerCase();

    final Map<String, dynamic> datumaroAnnotation = {
      'id': annotation.id,
      'attributes': {},
    };

    if (projectTypeLower.contains('detection') && annotation.annotationType == 'bbox') {
      final shape = annotation.shape;
      if (shape is RectShape) {
        datumaroAnnotation['type'] = 'bbox';
        datumaroAnnotation['label'] = label.name;
        datumaroAnnotation['bbox'] = [shape.x, shape.y, shape.width, shape.height];
        if (annotation.confidence != null) {
          datumaroAnnotation['attributes']['score'] = annotation.confidence;
        }
        return datumaroAnnotation;
      }
    } else if (projectTypeLower.contains('segmentation') && annotation.annotationType == 'polygon') {
      final shape = annotation.shape;
      if (shape is PolygonShape) {
        final points = shape.points
            .map((p) => [p.dx, p.dy])
            .toList();
        datumaroAnnotation['type'] = 'polygon';
        datumaroAnnotation['label'] = label.name;
        datumaroAnnotation['points'] = points;
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
