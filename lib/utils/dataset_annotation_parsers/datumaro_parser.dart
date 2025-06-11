import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';

import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/annotation_database.dart';

class DatumaroParser {
  static final Logger _logger = Logger('DatumaroParser');

  static Future<int> parse({
    required List<Label> projectLabels,
    required String datasetPath,
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

    final Map<int, Label> labelIndexMap = {
      for (int i = 0; i < projectLabels.length; i++) i: projectLabels[i]
    };
    final Map<String, Label> labelNameMap = {
      for (final label in projectLabels) label.name.toLowerCase(): label
    };

    int addedCount = 0;
    final Map<int, int> labelCount = {};
    final DateTime timestamp = DateTime.now();

    void logAndSkip(String message) {
      _logger.warning('[Datumaro] $message');
    }

    Future<void> tryAddAnnotation({
      required MediaItem mediaItem,
      required Map<String, dynamic> ann,
    }) async {
      final int? labelIndex = ann['label_id'] as int?;
      Label? label = (labelIndex != null) ? labelIndexMap[labelIndex] : null;

      if (label == null && ann.containsKey('label')) {
        final name = (ann['label'] as String?)?.toLowerCase();
        label = name != null ? labelNameMap[name] : null;
      }

      if (label == null || label.id == null) {
        logAndSkip('Unknown label for annotation in ${mediaItem.filePath}');
        return;
      }

      final type = ann['type'] ?? 'unknown';
      final data = ann['data'] ?? ann;

      await annotationDb.insertAnnotation(
        Annotation(
          id: null,
          mediaItemId: mediaItem.id!,
          labelId: label.id,
          annotationType: type,
          data: data,
          confidence: (ann['confidence'] != null)
              ? (ann['confidence'] as num).toDouble()
              : null,
          annotatorId: annotatorId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      labelCount[label.id!] = (labelCount[label.id!] ?? 0) + 1;
      addedCount++;
    }

    if (data.containsKey('annotations')) {
      final annotations = data['annotations'];
      if (annotations is Map<String, dynamic>) {
        for (final entry in annotations.entries) {
          final imageName = entry.key;
          final mediaItem = mediaItemsMap[p.basename(imageName).toLowerCase()];
          if (mediaItem == null) {
            logAndSkip('image "$imageName" not found in mediaItems. Skipping.');
            continue;
          }

          final annotationList = entry.value;
          if (annotationList is List) {
            for (final ann in annotationList) {
              if (ann is Map<String, dynamic>) {
                await tryAddAnnotation(mediaItem: mediaItem, ann: ann);
              }
            }
          }
        }
      }
    } else if (data.containsKey('items')) {
      final items = data['items'];
      if (items is List) {
        for (final item in items) {
          if (item is Map<String, dynamic>) {
            final imageName = item['image']?['path'] ?? item['filename'] ?? item['id'];
            if (imageName == null) continue;

            final mediaItem = mediaItemsMap[p.basename(imageName).toLowerCase()];
            if (mediaItem == null) {
              logAndSkip('item "$imageName" not found in mediaItems. Skipping.');
              continue;
            }

            final annotationList = item['annotations'];
            if (annotationList is List) {
              for (final ann in annotationList) {
                if (ann is Map<String, dynamic>) {
                  await tryAddAnnotation(mediaItem: mediaItem, ann: ann);
                }
              }
            }
          }
        }
      }
    } else {
      _logger.warning('[Datumaro] unknown format: missing "annotations" or "items" key');
    }

    for (final entry in labelCount.entries) {
      _logger.info('[Datumaro] labelId ${entry.key} -> ${entry.value} annotations');
    }

    _logger.info('[Datumaro] added $addedCount annotations from ${annotationFile.path}');
    return addedCount;
  }
}