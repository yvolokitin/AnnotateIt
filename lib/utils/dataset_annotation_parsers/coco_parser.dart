import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../models/shape/rect_shape.dart'; // Import RectShape
import '../../data/annotation_database.dart';

class COCOParser {
  static final Logger _logger = Logger('COCOParser');

  static Future<int> parse({
    required String datasetPath,
    required Map<String, MediaItem> mediaItemsMap,
    required AnnotationDatabase annotationDb,
    required int projectId,
    required int annotatorId,
  }) async {
    final annotationsFile = File('$datasetPath/annotations/instances_train.json');
    if (!await annotationsFile.exists()) return 0;

    final content = await annotationsFile.readAsString();
    final jsonData = json.decode(content);
    final images = jsonData['images'] as List<dynamic>;
    final annotations = jsonData['annotations'] as List<dynamic>;

    final imageIdToFileName = {
      for (var img in images) img['id'] as int: img['file_name'] as String,
    };

    int count = 0;
    for (var ann in annotations) {
      final imageId = ann['image_id'] as int;
      final fileName = imageIdToFileName[imageId];
      if (fileName == null) continue;
      final mediaItem = mediaItemsMap[fileName];
      if (mediaItem == null) continue;

      final bbox = ann['bbox'] as List<dynamic>;
      final rectShape = RectShape(
        (bbox[0] as num).toDouble(),
        (bbox[1] as num).toDouble(),
        (bbox[2] as num).toDouble(),
        (bbox[3] as num).toDouble(),
      );
      await annotationDb.insertAnnotation(Annotation(
        mediaItemId: mediaItem.id!,
        labelId: ann['category_id'] as int?,
        shape: rectShape, // Use RectShape object
        confidence: (ann['score'] as num?)?.toDouble(),
        annotatorId: annotatorId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      count++;
    }

    _logger.info('COCO: Added $count annotations');
    return count;
  }
}