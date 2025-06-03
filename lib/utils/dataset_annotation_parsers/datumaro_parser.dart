import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';

import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/annotation_database.dart';
import '../../models/shape/shape.dart';
import '../../models/shape/rect_shape.dart';
import '../../models/shape/polygon_shape.dart';
import 'package:flutter/painting.dart'; // For Offset

class DatumaroParser {
  static final Logger _logger = Logger('DatumaroParser');

  static Future<int> parse({
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

    int addedCount = 0;

    // ✅ CASE 1: Old format with "annotations"
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
                final String type = ann['type'] as String? ?? 'unknown';
                final shapeData = ann['data'] ?? ann;
                Shape? finalShape;

                if (type == 'bbox' && shapeData is Map<String, dynamic> && shapeData.containsKey('bbox')) {
                  final bbox = shapeData['bbox'] as List<dynamic>;
                  if (bbox.length == 4) {
                    finalShape = RectShape(
                      (bbox[0] as num).toDouble(),
                      (bbox[1] as num).toDouble(),
                      (bbox[2] as num).toDouble(),
                      (bbox[3] as num).toDouble(),
                    );
                  }
                } else if (type == 'polygon' && shapeData is Map<String, dynamic> && shapeData.containsKey('points')) {
                  final pointsRaw = shapeData['points'] as List<dynamic>;
                  List<Offset> points = [];
                  for (int i = 0; i < pointsRaw.length; i += 2) {
                    points.add(Offset(
                      (pointsRaw[i] as num).toDouble(),
                      (pointsRaw[i+1] as num).toDouble(),
                    ));
                  }
                  if (points.isNotEmpty) {
                    finalShape = PolygonShape(points);
                  }
                } else {
                  _logger.warning('[Datumaro] Unsupported shape type "$type" or invalid data for item "${mediaItem.fileName}".');
                }

                if (finalShape != null) {
                  await annotationDb.insertAnnotation(
                    Annotation(
                      id: null,
                      mediaItemId: mediaItem.id!,
                      labelId: ann['label_id'] as int?,
                      shape: finalShape,
                      confidence: (ann['confidence'] != null)
                          ? (ann['confidence'] as num).toDouble()
                          : null,
                      annotatorId: annotatorId,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );
                  addedCount++;
                }
                addedCount++;
              }
            }
          }
        }
      }

    // ✅ CASE 2: New Datumaro 2.x+ format with "items"
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
                  final String type = ann['type'] as String? ?? 'unknown';
                  // In new format, 'ann' itself is the shape data container
                  Shape? finalShape;

                  if (type == 'bbox' && ann.containsKey('bbox')) {
                    final bbox = ann['bbox'] as List<dynamic>;
                    if (bbox.length == 4) {
                      finalShape = RectShape(
                        (bbox[0] as num).toDouble(),
                        (bbox[1] as num).toDouble(),
                        (bbox[2] as num).toDouble(),
                        (bbox[3] as num).toDouble(),
                      );
                    }
                  } else if (type == 'polygon' && ann.containsKey('points')) {
                    final pointsRaw = ann['points'] as List<dynamic>;
                    List<Offset> points = [];
                    for (int i = 0; i < pointsRaw.length; i += 2) {
                      points.add(Offset(
                        (pointsRaw[i] as num).toDouble(),
                        (pointsRaw[i+1] as num).toDouble(),
                      ));
                    }
                    if (points.isNotEmpty) {
                      finalShape = PolygonShape(points);
                    }
                  } else {
                     _logger.warning('[Datumaro] Unsupported shape type "$type" or invalid data structure for item "${mediaItem.fileName}". Ann data: $ann');
                  }

                  if (finalShape != null) {
                    await annotationDb.insertAnnotation(
                      Annotation(
                        id: null,
                        mediaItemId: mediaItem.id!,
                        labelId: ann['label_id'] as int?,
                        shape: finalShape,
                        confidence: (ann['confidence'] != null)
                            ? (ann['confidence'] as num).toDouble()
                            : null,
                        annotatorId: annotatorId,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ),
                    );
                    addedCount++;
                  }
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