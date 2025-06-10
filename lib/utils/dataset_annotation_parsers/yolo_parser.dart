import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../models/label.dart';
import '../../data/annotation_database.dart';
import '../../models/media_item.dart';
import '../../models/annotation.dart';

class YOLOParser {
  static final Logger _logger = Logger('YOLOParser');

  static Future<int> parse({
    required List<Label> projectLabels,
    required String datasetPath,
    required Map<String, MediaItem> mediaItemsMap,
    required AnnotationDatabase annotationDb,
    required int projectId,
    required int annotatorId,
  }) async {
    final labelsDir = Directory(p.join(datasetPath, 'labels'));
    if (!await labelsDir.exists()) {
      _logger.warning('[YOLO] labels folder not found at ${labelsDir.path}');
      return 0;
    }

    int added = 0;
    await for (var file in labelsDir.list()) {
      if (file is! File || !file.path.endsWith('.txt')) continue;

      final name = p.basenameWithoutExtension(file.path);
      final mediaItem = mediaItemsMap['$name.jpg'] ?? mediaItemsMap['$name.png'];
      if (mediaItem == null) continue;

      final lines = await file.readAsLines();
      for (final line in lines) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length != 5) continue;

        final labelId = int.tryParse(parts[0]);
        final x = double.tryParse(parts[1]);
        final y = double.tryParse(parts[2]);
        final width = double.tryParse(parts[3]);
        final height = double.tryParse(parts[4]);

        if ([labelId, x, y, width, height].contains(null)) continue;

        await annotationDb.insertAnnotation(Annotation(
          mediaItemId: mediaItem.id!,
          labelId: labelId,
          annotationType: 'bbox',
          data: {
            'x_center': x,
            'y_center': y,
            'width': width,
            'height': height,
          },
          confidence: null,
          annotatorId: annotatorId,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        added++;
      }
    }

    _logger.info('[YOLO] added $added annotations');
    return added;
  }
}