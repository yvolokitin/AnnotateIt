import 'dart:io';
import 'package:xml/xml.dart';
import 'package:logging/logging.dart';

import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/annotation_database.dart';

class VOCParser {
  static final Logger _logger = Logger('VOCParser');

  static Future<int> parse({
    required String datasetPath,
    required Map<String, MediaItem> mediaItemsMap,
    required AnnotationDatabase annotationDb,
    required int projectId,
    required int annotatorId,
  }) async {
    final annotationsDir = Directory('$datasetPath/Annotations');
    if (!await annotationsDir.exists()) {
      _logger.warning('[VOC] No VOC annotations folder found: ${annotationsDir.path}');
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

      final filenameElements = document.findAllElements('filename');
      if (filenameElements.isEmpty) continue;

      final filename = filenameElements.first.text;
      final mediaItem = mediaItemsMap[filename];
      if (mediaItem == null) {
        _logger.warning('[VOC] Image "$filename" not found in mediaItems map. Skipping.');
        continue;
      }

      final objects = document.findAllElements('object');
      for (final obj in objects) {
        final nameElements = obj.findElements('name');
        final bndboxElements = obj.findElements('bndbox');

        if (nameElements.isEmpty || bndboxElements.isEmpty) continue;

        final bndbox = bndboxElements.first;
        final xmin = double.tryParse(bndbox.findElements('xmin').first.text) ?? 0;
        final ymin = double.tryParse(bndbox.findElements('ymin').first.text) ?? 0;
        final xmax = double.tryParse(bndbox.findElements('xmax').first.text) ?? 0;
        final ymax = double.tryParse(bndbox.findElements('ymax').first.text) ?? 0;

        final annotation = Annotation(
          mediaItemId: mediaItem.id!,
          labelId: null, // optional: map label name to label ID
          annotationType: 'bbox',
          data: {
            'x': xmin,
            'y': ymin,
            'width': xmax - xmin,
            'height': ymax - ymin,
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

    _logger.info('[VOC] Added $addedCount annotations from ${annotationsDir.path}');
    return addedCount;
  }
}