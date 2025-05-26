import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';

import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/annotation_database.dart';

class DatumaroParser {
  static final Logger _logger = Logger('DatumaroParser');

  static Future<int> parse({
    required String datasetPath,
    required String taskType,    
    required Map<String, MediaItem> mediaItemsMap,
    required AnnotationDatabase annotationDb,
    required int projectId,
    required int annotatorId,
  }) async {
    final annotationsPath = p.join(datasetPath, 'annotations');
    final annotationsDir = Directory(annotationsPath);

    if (!await annotationsDir.exists()) {
      _logger.warning('[Datumaro] annotations folder not found: $annotationsPath');
      return 0;
    }

    final jsonFiles = annotationsDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.toLowerCase().endsWith('.json'))
        .toList();

    if (jsonFiles.isEmpty) {
      _logger.warning('[Datumaro] no annotation JSON files found in $annotationsPath');
      return 0;
    }

    final annotationFile = jsonFiles.firstWhere(
      (file) => p.basename(file.path).toLowerCase() == 'default.json',
      orElse: () => jsonFiles.first,
    );

    _logger.info('[Datumaro] using annotation file: ${annotationFile.path}');

    final content = await annotationFile.readAsString();
    final Map<String, dynamic> data = jsonDecode(content);

    int addedCount = 0;

    // CASE 1: Old format with "annotations"
    if (data.containsKey('annotations')) {
      final annotations = data['annotations'];
      if (annotations is Map<String, dynamic>) {
        for (final entry in annotations.entries) {
          final imageName = entry.key;
          final annotationList = entry.value;

          final mediaItem = mediaItemsMap[imageName.toLowerCase()];
          if (mediaItem == null) {
            _logger.warning('[Datumaro] image "$imageName" not found in mediaItems. Skipping.');
            continue;
          }

          if (annotationList is List) {
            for (final ann in annotationList) {
              if (ann is Map<String, dynamic>) {
                await annotationDb.insertAnnotationAndUpdateMediaItem(
                // await annotationDb.insertAnnotation(
                  Annotation(
                    id: null,
                    mediaItemId: mediaItem.id!,
                    labelId: ann['label_id'] as int?,
                    annotationType: ann['type'] ?? 'unknown',
                    data: ann['data'] ?? ann,
                    confidence: (ann['confidence'] != null)
                        ? (ann['confidence'] as num).toDouble()
                        : null,
                    annotatorId: annotatorId,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                  taskType,
                );
                addedCount++;
              }
            }
          }
        }
      }

    // CASE 2: New Datumaro 2.x+ format with "items"
    } else if (data.containsKey('items')) {
      final items = data['items'];
      if (items is List) {
        for (final item in items) {
          if (item is Map<String, dynamic>) {
            final imageName = item['image']?['path'] ??
                              item['filename'] ??
                              item['id'];
            if (imageName == null) continue;

            final mediaItem = mediaItemsMap[p.basename(imageName).toLowerCase()];
            if (mediaItem == null) {
              _logger.warning('[Datumaro] item "$imageName" not found in mediaItems. Skipping.');
              continue;
            }

            final annotationList = item['annotations'];
            if (annotationList is List) {
              for (final ann in annotationList) {
                if (ann is Map<String, dynamic>) {
                  await annotationDb.insertAnnotationAndUpdateMediaItem(
                  // await annotationDb.insertAnnotation(
                    Annotation(
                      id: null,
                      mediaItemId: mediaItem.id!,
                      labelId: ann['label_id'] as int?,
                      annotationType: ann['type'] ?? 'unknown',
                      data: ann,
                      confidence: (ann['confidence'] != null)
                          ? (ann['confidence'] as num).toDouble()
                          : null,
                      annotatorId: annotatorId,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                    taskType,
                  );
                  addedCount++;
                }
              }
            }
          }
        }
      }
    } else {
      _logger.warning('[Datumaro] unknown Datumaro format: no "annotations" or "items" key');
    }

    _logger.info('[Datumaro] added $addedCount annotations from ${annotationFile.path}');
    return addedCount;
  }
}
