import 'dart:io';
import 'dart:math';
import 'package:xml/xml.dart';
import 'package:logging/logging.dart';

import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/annotation_database.dart';
import '../../data/labels_database.dart';

class CVATParser {
  static final Logger _logger = Logger('CVATParser');
  static final Random _random = Random();

  /// Parses CVAT XML annotations and inserts them into the annotation database.
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
      _logger.warning('[CVAT] No annotations directory found: ${annotationsDir.path}');
      return 0;
    }

    final labelMap = {
      for (var label in projectLabels) label.name.toLowerCase(): label
    };

    int addedCount = 0;
    final files = annotationsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.xml'));

    final projectTypeLower = projectType.toLowerCase();

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

        final now = DateTime.now();

        // BBox annotations
        if (projectTypeLower.contains('detection')) {
          final boxes = image.findElements('box');
          for (final box in boxes) {
            final labelName = box.getAttribute('label');
            final label = labelName != null ? labelMap[labelName.toLowerCase()] : null;
            if (label == null || label.id == null) continue;

            // Assign random color if not set
            if (label.color == '#000000') {
              final hexColor = _randomHexColor();
              final updated = label.copyWith(color: hexColor);
              await LabelsDatabase.instance.updateLabel(updated);
              labelMap[label.name.toLowerCase()] = updated;
              _logger.fine('[CVAT] Assigned color $hexColor to label "${label.name}"');
            }

            final xtl = double.tryParse(box.getAttribute('xtl') ?? '');
            final ytl = double.tryParse(box.getAttribute('ytl') ?? '');
            final xbr = double.tryParse(box.getAttribute('xbr') ?? '');
            final ybr = double.tryParse(box.getAttribute('ybr') ?? '');

            if (xtl == null || ytl == null || xbr == null || ybr == null) continue;

            await annotationDb.insertAnnotation(Annotation(
              mediaItemId: mediaItem.id!,
              labelId: label.id!,
              annotationType: 'bbox',
              data: {
                'x': xtl,
                'y': ytl,
                'width': xbr - xtl,
                'height': ybr - ytl,
              },
              confidence: null,
              annotatorId: annotatorId,
              createdAt: now,
              updatedAt: now,
            ));
            addedCount++;
          }
        }

        // Polygon annotations
        if (projectTypeLower.contains('segmentation')) {
          final polygons = image.findElements('polygon');
          for (final poly in polygons) {
            final labelName = poly.getAttribute('label');
            final label = labelName != null ? labelMap[labelName.toLowerCase()] : null;
            if (label == null || label.id == null) continue;

            if (label.color == '#000000') {
              final hexColor = _randomHexColor();
              final updated = label.copyWith(color: hexColor);
              await LabelsDatabase.instance.updateLabel(updated);
              labelMap[label.name.toLowerCase()] = updated;
              _logger.fine('[CVAT] Assigned color $hexColor to label "${label.name}"');
            }

            final pointsStr = poly.getAttribute('points');
            if (pointsStr == null) continue;

            final points = pointsStr
                .split(';')
                .map((pair) => pair.trim().split(',').map(double.parse).toList())
                .toList();

            await annotationDb.insertAnnotation(Annotation(
              mediaItemId: mediaItem.id!,
              labelId: label.id!,
              annotationType: 'polygon',
              data: {'points': points},
              confidence: null,
              annotatorId: annotatorId,
              createdAt: now,
              updatedAt: now,
            ));
            addedCount++;
          }
        }
      }
    }

    _logger.info('[CVAT] Added $addedCount annotations from ${annotationsDir.path}');
    return addedCount;
  }

  static String _randomHexColor() {
    return '#${_random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}