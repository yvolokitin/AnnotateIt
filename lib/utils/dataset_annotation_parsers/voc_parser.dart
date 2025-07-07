import 'dart:io';
import 'dart:math';

import 'package:xml/xml.dart';
import 'package:logging/logging.dart';

import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../data/annotation_database.dart';
import '../../data/labels_database.dart';

class VOCParser {
  static final Logger _logger = Logger('VOCParser');
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
    final annotationsDir = Directory('$datasetPath/Annotations');
    if (!await annotationsDir.exists()) {
      _logger.warning('[VOC] No VOC annotations folder found: ${annotationsDir.path}');
      return 0;
    }

    final Map<String, Label> labelNameMap = {
      for (final label in projectLabels) label.name.toLowerCase(): label
    };

    final projectTypeLower = projectType.toLowerCase();
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

        final labelName = nameElements.first.text.toLowerCase();
        Label? label = labelNameMap[labelName];

        if (label == null || label.id == null) {
          _logger.warning('[VOC] Unknown label "$labelName". Skipping object in $filename');
          continue;
        }

        // Assign random color if needed
        if (label.color == '#000000') {
          final newColor = _randomHexColor();
          label = label.copyWith(color: newColor);
          await LabelsDatabase.instance.updateLabel(label);
          _logger.fine('[VOC] Assigned color $newColor to label "$labelName"');
        }

        final bndbox = bndboxElements.first;
        final xmin = double.tryParse(bndbox.findElements('xmin').first.text) ?? 0;
        final ymin = double.tryParse(bndbox.findElements('ymin').first.text) ?? 0;
        final xmax = double.tryParse(bndbox.findElements('xmax').first.text) ?? 0;
        final ymax = double.tryParse(bndbox.findElements('ymax').first.text) ?? 0;

        if (projectTypeLower.contains('detection')) {
          final annotation = Annotation(
            mediaItemId: mediaItem.id!,
            labelId: label.id!,
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
        } else {
          _logger.warning('[VOC] Skipping non-detection object in $filename');
        }
      }
    }

    _logger.info('[VOC] Added $addedCount annotations from ${annotationsDir.path}');
    return addedCount;
  }

  static String _randomHexColor() {
    return '#${_random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}
