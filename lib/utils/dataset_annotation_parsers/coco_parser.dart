import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';

import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/annotation_database.dart';

class COCOParser {
  static final Logger _logger = Logger('COCOParser');

  static Future<int> parse({
    required List<Label> projectLabels,
    required String datasetPath,
    required Map<String, MediaItem> mediaItemsMap,
    required AnnotationDatabase annotationDb,
    required int projectId,
    required int annotatorId,
  }) async {
    final annotationsFile = File('$datasetPath/annotations/instances_default.json');
    if (!await annotationsFile.exists()) {
      _logger.warning('[COCO] annotations file not found: ${annotationsFile.path}');
      return 0;
    }

    final content = await annotationsFile.readAsString();
    final jsonData = json.decode(content);

    final images = jsonData['images'] as List<dynamic>;
    final annotations = jsonData['annotations'] as List<dynamic>;
    final categories = jsonData['categories'] as List<dynamic>;

    // Build category_id -> project label ID mapping
    final Map<int, int> categoryIdToLabelId = {};
    for (final category in categories) {
      final cocoId = category['id'] as int?;
      final name = category['name'] as String?;
      if (cocoId == null || name == null) continue;

      final label = projectLabels.firstWhere(
        (lbl) => lbl.name.toLowerCase() == name.toLowerCase(),
        orElse: () => Label(id: -1, labelOrder: 0, projectId: projectId, name: 'INVALID', color: '#000000'),
      );

      if (label.id != null && label.id != -1) {
        categoryIdToLabelId[cocoId] = label.id!;
      } else {
        _logger.warning('[COCO] label name "$name" not found in project labels');
      }
    }

    final imageIdToFileName = {
      for (var img in images) img['id'] as int: img['file_name'] as String,
    };

    int count = 0;
    for (var ann in annotations) {
      final imageId = ann['image_id'] as int?;
      final fileName = imageId != null ? imageIdToFileName[imageId] : null;
      if (fileName == null) {
        _logger.warning('[COCO] image_id $imageId not found in image list');
        continue;
      }

      final mediaItem = mediaItemsMap[fileName];
      if (mediaItem == null) {
        _logger.warning('[COCO] mediaItem for "$fileName" not found in mediaItemsMap');
        continue;
      }

      final cocoLabelId = ann['category_id'] as int?;
      final labelId = categoryIdToLabelId[cocoLabelId];
      if (labelId == null) {
        _logger.warning('[COCO] unknown category_id: $cocoLabelId for image $fileName');
        continue;
      }

      final bbox = ann['bbox'] as List<dynamic>?;
      if (bbox == null || bbox.length < 4) {
        _logger.warning('[COCO] invalid or missing bbox for annotation in image $fileName');
        continue;
      }

      await annotationDb.insertAnnotation(Annotation(
        mediaItemId: mediaItem.id!,
        labelId: labelId,
        annotationType: 'bbox',
        data: {
          'x': bbox[0],
          'y': bbox[1],
          'width': bbox[2],
          'height': bbox[3],
        },
        confidence: (ann['score'] as num?)?.toDouble(),
        annotatorId: annotatorId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      count++;
    }

    _logger.info('[COCO] Added $count annotations from ${annotationsFile.path}');
    return count;
  }
}
