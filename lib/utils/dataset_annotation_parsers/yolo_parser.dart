import 'dart:io';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../../models/label.dart';
import '../../data/annotation_database.dart';
import '../../models/media_item.dart';
import '../../models/annotation.dart';
import '../../data/labels_database.dart';

class YOLOParser {
  static final Logger _logger = Logger('YOLOParser');
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
    final labelsDir = Directory(p.join(datasetPath, 'labels'));
    if (!await labelsDir.exists()) {
      _logger.warning('[YOLO] labels folder not found at ${labelsDir.path}');
      return 0;
    }

    final projectTypeLower = projectType.toLowerCase();
    final Map<int, Label> labelIndexMap = {
      for (int i = 0; i < projectLabels.length; i++) i: projectLabels[i]
    };

    int added = 0;
    await for (var file in labelsDir.list()) {
      if (file is! File || !file.path.endsWith('.txt')) continue;

      final name = p.basenameWithoutExtension(file.path);
      final mediaItem = mediaItemsMap['$name.jpg'] ?? mediaItemsMap['$name.png'];
      if (mediaItem == null) {
        _logger.warning('[YOLO] media item for $name not found');
        continue;
      }

      final lines = await file.readAsLines();
      for (final line in lines) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length < 5) continue;

        final labelIndex = int.tryParse(parts[0]);
        if (labelIndex == null || !labelIndexMap.containsKey(labelIndex)) {
          _logger.warning('[YOLO] unknown label index $labelIndex in $name');
          continue;
        }

        Label label = labelIndexMap[labelIndex]!;

        // Assign a random color if the label doesn't have a proper one
        if (label.color == '#000000') {
          final randomColor = _randomHexColor();
          label = label.copyWith(color: randomColor);
          await LabelsDatabase.instance.updateLabel(label);
          _logger.fine('[YOLO] assigned color $randomColor to label "${label.name}"');
        }

        if (projectTypeLower.contains('detection')) {
          if (parts.length != 5) continue;

          final x = double.tryParse(parts[1]);
          final y = double.tryParse(parts[2]);
          final width = double.tryParse(parts[3]);
          final height = double.tryParse(parts[4]);

          if ([x, y, width, height].contains(null)) continue;

          await annotationDb.insertAnnotation(Annotation(
            mediaItemId: mediaItem.id!,
            labelId: label.id!,
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
        } else if (projectTypeLower.contains('segmentation')) {
          if (parts.length < 6 || (parts.length - 1) % 2 != 0) {
            _logger.warning('[YOLO] invalid polygon annotation in $name');
            continue;
          }

          final points = <double>[];
          for (int i = 1; i < parts.length; i++) {
            final value = double.tryParse(parts[i]);
            if (value == null) {
              _logger.warning('[YOLO] invalid polygon point in $name');
              continue;
            }
            points.add(value);
          }

          await annotationDb.insertAnnotation(Annotation(
            mediaItemId: mediaItem.id!,
            labelId: label.id!,
            annotationType: 'polygon',
            data: {'points': points},
            confidence: null,
            annotatorId: annotatorId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
          added++;
        } else {
          _logger.warning('[YOLO] skipping unsupported project type: $projectType');
        }
      }
    }

    _logger.info('[YOLO] added $added annotations');
    return added;
  }

  static String _randomHexColor() {
    return '#${_random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}
