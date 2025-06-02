import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';

import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/annotation_database.dart';

class LabelMeParser {
  static final Logger _logger = Logger('LabelMeParser');

  static Future<int> parse({
    required String datasetPath,
    required Map<String, MediaItem> mediaItemsMap,
    required AnnotationDatabase annotationDb,
    required int projectId,
    required int annotatorId,
  }) async {
    final annotationsDir = Directory('$datasetPath/annotations');
    if (!await annotationsDir.exists()) {
      _logger.warning('[LabelMe] No annotations directory found: ${annotationsDir.path}');
      return 0;
    }

    int addedCount = 0;
    final files = annotationsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.json'));

    for (final file in files) {
      final jsonContent = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(jsonContent);

      final imagePath = jsonData['imagePath'] as String?;
      if (imagePath == null) continue;

      final mediaItem = mediaItemsMap[imagePath];
      if (mediaItem == null) {
        _logger.warning('[LabelMe] Image "$imagePath" not found in mediaItems map. Skipping.');
        continue;
      }

      final shapes = jsonData['shapes'] as List<dynamic>? ?? [];
      for (final shape in shapes) {
        if (shape is! Map<String, dynamic>) continue;

        final label = shape['label'];
        final points = shape['points'] as List<dynamic>?;

        if (points == null || points.isEmpty) continue;

        // Convert points to list of {x, y}
        final pointList = points.map((point) {
          if (point is List && point.length >= 2) {
            return {'x': point[0], 'y': point[1]};
          }
          return null;
        }).where((p) => p != null).toList();

        final annotation = Annotation(
          mediaItemId: mediaItem.id!,
          labelId: null, // optional: map label to label table
          annotationType: 'polygon',
          data: {
            'points': pointList,
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

    _logger.info('[LabelMe] Added $addedCount annotations from ${annotationsDir.path}');
    return addedCount;
  }
}