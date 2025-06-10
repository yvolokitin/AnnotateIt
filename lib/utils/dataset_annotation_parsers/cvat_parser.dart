import 'dart:io';
import 'package:xml/xml.dart';
import 'package:logging/logging.dart';

import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/annotation_database.dart';

class CVATParser {
  static final Logger _logger = Logger('CVATParser');

  static Future<int> parse({
    required List<Label> projectLabels,
    required String datasetPath,
    required Map<String, MediaItem> mediaItemsMap,
    required AnnotationDatabase annotationDb,
    required int projectId,
    required int annotatorId,
  }) async {
    final annotationsDir = Directory('$datasetPath/annotations');
    if (!await annotationsDir.exists()) {
      _logger.warning('[CVAT] No annotations directory found: ${annotationsDir.path}');
      return 0;
    }

    int addedCount = 0;
    final files = annotationsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.xml'));

    for (final file in files) {
      final xmlContent = await file.readAsString();
      final document = XmlDocument.parse(xmlContent);

      final images = document.findAllElements('image');
      for (final image in images) {
        final fileName = image.getAttribute('name');
        if (fileName == null) continue;

        final mediaItem = mediaItemsMap[fileName];
        if (mediaItem == null) {
          _logger.warning('[CVAT] Image "$fileName" not found in mediaItems map. Skipping.');
          continue;
        }

        // parse boxes
        final boxes = image.findElements('box');
        for (final box in boxes) {
          final label = box.getAttribute('label');
          final xtl = double.tryParse(box.getAttribute('xtl') ?? '');
          final ytl = double.tryParse(box.getAttribute('ytl') ?? '');
          final xbr = double.tryParse(box.getAttribute('xbr') ?? '');
          final ybr = double.tryParse(box.getAttribute('ybr') ?? '');

          if (xtl == null || ytl == null || xbr == null || ybr == null) continue;

          final annotation = Annotation(
            mediaItemId: mediaItem.id!,
            labelId: null, // optional: map label to your label table
            annotationType: 'bbox',
            data: {
              'x': xtl,
              'y': ytl,
              'width': xbr - xtl,
              'height': ybr - ytl,
            },
            confidence: null,
            annotatorId: annotatorId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await annotationDb.insertAnnotation(annotation);
          addedCount++;
        }
      }
    }

    _logger.info('[CVAT] Added $addedCount annotations from ${annotationsDir.path}');
    return addedCount;
  }
}