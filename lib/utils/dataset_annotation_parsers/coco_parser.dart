import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';

import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/annotation_database.dart';

class COCOParser {
  static final Logger _logger = Logger('COCOParser');

  static Future<int> parse({
    required String datasetPath,
    required String taskType,
    required Map<String, MediaItem> mediaItemsMap,
    required AnnotationDatabase annotationDb,
    required int projectId,
    required int annotatorId,
  }) async {
    final annotationsFile = File('$datasetPath/annotations/instances_train.json');
    if (!await annotationsFile.exists()) {
      _logger.warning('COCO: Annotation file not found: ${annotationsFile.path}');
      return 0;
    }

    final content = await annotationsFile.readAsString();
    final jsonData = json.decode(content);

    final images = jsonData['images'] as List<dynamic>;
    final annotations = jsonData['annotations'] as List<dynamic>;
    final categories = jsonData['categories'] as List<dynamic>;

    // Build COCO category_id -> label_id map
    final Map<int, int> cocoCategoryIdToLabelId = {};

    for (var cat in categories) {
      final int cocoId = cat['id'];
      final String name = cat['name'];

      final labelId = await annotationDb.getLabelIdByName(projectId, name);
      if (labelId != null) {
        cocoCategoryIdToLabelId[cocoId] = labelId;
      } else {
        _logger.warning('COCO: Label "$name" not found in DB. Skipping category $cocoId.');
      }
    }

    final imageIdToFileName = {
      for (var img in images) img['id'] as int: img['file_name'] as String,
    };

    int count = 0;
    for (var ann in annotations) {
      final imageId = ann['image_id'] as int;
      final fileName = imageIdToFileName[imageId];
      if (fileName == null) continue;

      final mediaItem = mediaItemsMap[fileName];
      if (mediaItem == null) {
        _logger.warning('COCO: media item not found for $fileName');
        continue;
      }

      final categoryId = ann['category_id'] as int;
      final labelId = cocoCategoryIdToLabelId[categoryId];
      if (labelId == null) {
        _logger.warning('COCO: Skipping annotation with unknown category_id: $categoryId');
        continue;
      }

      final bbox = ann['bbox'] as List<dynamic>;
      final annotation = Annotation(
        id: null,
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
      );

      await annotationDb.insertAnnotationAndUpdateMediaItem(annotation, taskType);
      count++;
    }

    _logger.info('COCO: Added $count annotations');
    return count;
  }
}
