import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../data/annotation_database.dart';
import '../../models/media_item.dart';
import '../../models/annotation.dart';
import '../../models/shape/rect_shape.dart'; // Import RectShape

class YOLOParser {
  static final Logger _logger = Logger('YOLOParser');

  static Future<int> parse({
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
        final x_center_norm = double.tryParse(parts[1]);
        final y_center_norm = double.tryParse(parts[2]);
        final width_norm = double.tryParse(parts[3]);
        final height_norm = double.tryParse(parts[4]);

        if ([labelId, x_center_norm, y_center_norm, width_norm, height_norm].contains(null)) {
          _logger.warning('[YOLO] Skipped invalid line: $line in ${file.path}');
          continue;
        }

        if (mediaItem.width == null || mediaItem.height == null) {
          _logger.warning('[YOLO] Skipped annotation for ${mediaItem.fileName}, missing image dimensions.');
          continue;
        }

        // Denormalize and convert to top-left format
        final imgWidth = mediaItem.width!.toDouble();
        final imgHeight = mediaItem.height!.toDouble();

        final absWidth = width_norm! * imgWidth;
        final absHeight = height_norm! * imgHeight;
        final absXCenter = x_center_norm! * imgWidth;
        final absYCenter = y_center_norm! * imgHeight;

        final rectX = absXCenter - (absWidth / 2);
        final rectY = absYCenter - (absHeight / 2);

        final rectShape = RectShape(rectX, rectY, absWidth, absHeight);

        await annotationDb.insertAnnotation(Annotation(
          mediaItemId: mediaItem.id!,
          labelId: labelId,
          shape: rectShape, // Use RectShape object
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