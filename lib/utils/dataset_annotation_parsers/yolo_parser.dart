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
      for (int i = 0; i < projectLabels.length; i++) i: projectLabels[i],
    };

    final batch = <Annotation>[];
    await for (var file in labelsDir.list()) {
      if (file is! File || !file.path.endsWith('.txt')) continue;

      final name = p.basenameWithoutExtension(file.path);
      final mediaItem =
          mediaItemsMap['$name.jpg'] ?? mediaItemsMap['$name.png'];
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

        if (label.color == '#000000') {
          final randomColor = _randomHexColor();
          label = label.copyWith(color: randomColor);
          await LabelsDatabase.instance.updateLabel(label);
          _logger.fine(
            '[YOLO] assigned color $randomColor to label "${label.name}"',
          );
        }

        final now = DateTime.now();

        if (projectTypeLower.contains('detection')) {
          if (parts.length != 5) continue;

          final xCenter = double.tryParse(parts[1]);
          final yCenter = double.tryParse(parts[2]);
          final widthNorm = double.tryParse(parts[3]);
          final heightNorm = double.tryParse(parts[4]);

          if ([xCenter, yCenter, widthNorm, heightNorm].contains(null))
            continue;
          final imageWidth = mediaItem.width?.toDouble();
          final imageHeight = mediaItem.height?.toDouble();
          if (imageWidth == null ||
              imageHeight == null ||
              imageWidth <= 0 ||
              imageHeight <= 0) {
            _logger.warning(
              '[YOLO] missing media dimensions for ${mediaItem.filePath}; skipping bbox import',
            );
            continue;
          }

          final boxWidth = widthNorm! * imageWidth;
          final boxHeight = heightNorm! * imageHeight;
          final rawX = (xCenter! * imageWidth) - (boxWidth / 2);
          final rawY = (yCenter! * imageHeight) - (boxHeight / 2);

          final x = rawX.clamp(0.0, imageWidth);
          final y = rawY.clamp(0.0, imageHeight);
          final width = boxWidth.clamp(0.0, imageWidth - x);
          final height = boxHeight.clamp(0.0, imageHeight - y);
          if (width <= 0 || height <= 0) {
            _logger.warning('[YOLO] invalid bbox size in $name, skipping');
            continue;
          }

          batch.add(Annotation(
            mediaItemId: mediaItem.id!,
            labelId: label.id,
            annotationType: 'bbox',
            data: {'x': x, 'y': y, 'width': width, 'height': height},
            confidence: null,
            annotatorId: annotatorId,
            createdAt: now,
            updatedAt: now,
          ));
        } else if (projectTypeLower.contains('segmentation')) {
          if (parts.length < 6 || (parts.length - 1) % 2 != 0) {
            _logger.warning('[YOLO] invalid polygon annotation in $name');
            continue;
          }

          final imageWidth = mediaItem.width?.toDouble();
          final imageHeight = mediaItem.height?.toDouble();
          if (imageWidth == null ||
              imageHeight == null ||
              imageWidth <= 0 ||
              imageHeight <= 0) {
            _logger.warning(
              '[YOLO] missing media dimensions for ${mediaItem.filePath}; skipping polygon import',
            );
            continue;
          }

          final points = <List<double>>[];
          bool valid = true;
          for (int i = 1; i < parts.length - 1; i += 2) {
            final xNorm = double.tryParse(parts[i]);
            final yNorm = double.tryParse(parts[i + 1]);
            if (xNorm == null || yNorm == null) {
              _logger.warning('[YOLO] invalid polygon point in $name');
              valid = false;
              break;
            }
            points.add([
              (xNorm * imageWidth).clamp(0.0, imageWidth),
              (yNorm * imageHeight).clamp(0.0, imageHeight),
            ]);
          }
          if (!valid || points.length < 3) continue;

          batch.add(Annotation(
            mediaItemId: mediaItem.id!,
            labelId: label.id,
            annotationType: 'polygon',
            data: {'points': points},
            confidence: null,
            annotatorId: annotatorId,
            createdAt: now,
            updatedAt: now,
          ));
        } else {
          _logger.warning(
            '[YOLO] skipping unsupported project type: $projectType',
          );
        }
      }
    }

    if (batch.isNotEmpty) {
      await annotationDb.insertAnnotationsBatch(batch);
    }

    _logger.info('[YOLO] added ${batch.length} annotations');
    return batch.length;
  }

  static String _randomHexColor() {
    return '#${_random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}
