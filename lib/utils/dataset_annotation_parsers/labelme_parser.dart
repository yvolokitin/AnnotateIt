import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/annotation_database.dart';
import '../../data/labels_database.dart';

class LabelMeParser {
  static final Logger _logger = Logger('LabelMeParser');
  static final Random _random = Random();

  static Future<int> parse({
    required String projectType,
    required List<Label> projectLabels,
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

    final projectTypeLower = projectType.toLowerCase();
    final Map<String, Label> labelNameMap = {
      for (final label in projectLabels) label.name.toLowerCase(): label
    };

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

      final mediaItem = mediaItemsMap[p.basename(imagePath).toLowerCase()];
      if (mediaItem == null) {
        _logger.warning('[LabelMe] Image "$imagePath" not found in mediaItems map. Skipping.');
        continue;
      }

      final shapes = jsonData['shapes'] as List<dynamic>? ?? [];
      for (final shape in shapes) {
        if (shape is! Map<String, dynamic>) continue;

        final labelName = (shape['label'] as String?)?.toLowerCase();
        final points = shape['points'] as List<dynamic>?;
        if (labelName == null || points == null || points.isEmpty) continue;

        Label? label = labelNameMap[labelName];
        if (label == null || label.id == null) {
          _logger.warning('[LabelMe] Unknown label "$labelName" in $imagePath');
          continue;
        }

        if (label.color == '#000000') {
          final newColor = _randomHexColor();
          label = label.copyWith(color: newColor);
          await LabelsDatabase.instance.updateLabel(label);
          _logger.fine('[LabelMe] Assigned color $newColor to label "$labelName"');
        }

        final pointList = points.map((point) {
          if (point is List && point.length >= 2) {
            return {'x': point[0], 'y': point[1]};
          }
          return null;
        }).whereType<Map<String, dynamic>>().toList();

        if (pointList.isEmpty) continue;

        if (projectTypeLower.contains('segmentation') || (shape['shape_type'] == 'polygon')) {
          if (pointList.length < 3) {
            _logger.warning('[LabelMe] Skipping polygon with <3 points in $imagePath');
            continue;
          }

          final annotation = Annotation(
            mediaItemId: mediaItem.id!,
            labelId: label.id!,
            annotationType: 'polygon',
            data: {'points': pointList},
            confidence: null,
            annotatorId: annotatorId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await annotationDb.insertAnnotation(annotation);
          addedCount++;
        } else if (projectTypeLower.contains('detection') || shape['shape_type'] == 'rectangle' || pointList.length == 2) {
          final x1 = pointList[0]['x'] as num;
          final y1 = pointList[0]['y'] as num;
          final x2 = pointList[1]['x'] as num;
          final y2 = pointList[1]['y'] as num;

          final x = x1 < x2 ? x1 : x2;
          final y = y1 < y2 ? y1 : y2;
          final width = (x1 - x2).abs();
          final height = (y1 - y2).abs();

          final annotation = Annotation(
            mediaItemId: mediaItem.id!,
            labelId: label.id!,
            annotationType: 'bbox',
            data: {
              'x': x,
              'y': y,
              'width': width,
              'height': height,
            },
            confidence: null,
            annotatorId: annotatorId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await annotationDb.insertAnnotation(annotation);
          addedCount++;
        } else {
          _logger.warning('[LabelMe] Unsupported shape in $imagePath');
        }
      }
    }

    _logger.info('[LabelMe] Added $addedCount annotations from ${annotationsDir.path}');
    return addedCount;
  }

  static String _randomHexColor() {
    return '#${_random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}
