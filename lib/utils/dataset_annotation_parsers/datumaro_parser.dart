import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';

import '../../data/annotation_database.dart';
import '../../data/labels_database.dart';

import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';

class DatumaroParser {
  static final Logger _logger = Logger('DatumaroParser');
  static final Random _random = Random();

  /// Parses Datumaro-format annotations and inserts them into the annotation database.
  static Future<int> parse({
    required String projectType,
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

    // Load colors from mask.colormap
    final Map<int, String> labelColors = {};
    final colormap = data['categories']?['mask']?['colormap'];
    if (colormap is List) {
      for (final entry in colormap) {
        final id = entry['label_id'];
        final r = entry['r'], g = entry['g'], b = entry['b'];
        if (id != null && r != null && g != null && b != null) {
          labelColors[id] = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
        }
      }
    }

    final Map<int, Label> labelIndexMap = {
      for (int i = 0; i < projectLabels.length; i++) i: projectLabels[i]
    };
    final Map<String, Label> labelNameMap = {
      for (final label in projectLabels) label.name.toLowerCase(): label
    };

    int addedCount = 0;
    final Map<int, int> labelCount = {};
    final DateTime timestamp = DateTime.now();
    final projectTypeLower = projectType.toLowerCase();

    void logAndSkip(String msg) => _logger.warning('[Datumaro] $msg');

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

      // Assign color if missing
      if (label.color == null || label.color == '#000000') {
        final hexColor = labelIndex != null && labelColors.containsKey(labelIndex)
            ? labelColors[labelIndex]!
            : _randomHexColor();
        label = label.copyWith(color: hexColor);
        await LabelsDatabase.instance.updateLabel(label);
        _logger.fine('[Datumaro] assigned color $hexColor to label "${label.name}"');
      }

      final type = ann['type'] ?? 'unknown';

      if (projectTypeLower.contains('detection') && type == 'bbox') {
        final data = ann['data'] ?? ann;
        await annotationDb.insertAnnotation(Annotation(
          id: null,
          mediaItemId: mediaItem.id!,
          labelId: label.id!,
          annotationType: 'bbox',
          data: data,
          confidence: (ann['confidence'] as num?)?.toDouble(),
          annotatorId: annotatorId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ));
        addedCount++;
        labelCount[label.id!] = (labelCount[label.id!] ?? 0) + 1;

      } else if (projectTypeLower.contains('segmentation') && type == 'polygon') {
        final data = ann['points'] ?? ann['data'] ?? ann;
        await annotationDb.insertAnnotation(Annotation(
          id: null,
          mediaItemId: mediaItem.id!,
          labelId: label.id!,
          annotationType: 'polygon',
          data: {'points': data},
          confidence: (ann['confidence'] as num?)?.toDouble(),
          annotatorId: annotatorId,
          createdAt: timestamp,
          updatedAt: timestamp,
        ));
        addedCount++;
        labelCount[label.id!] = (labelCount[label.id!] ?? 0) + 1;

      } else if (projectTypeLower.contains('classification') && type == 'label') {
        // For binary classification, only allow one of the first two labels
        if (projectTypeLower.contains('binary')) {
          if (labelIndex == 0 || labelIndex == 1) {
            await annotationDb.insertAnnotation(Annotation(
              id: null,
              mediaItemId: mediaItem.id!,
              labelId: label.id!,
              annotationType: 'classification',
              data: {}, // classification doesn't need geometry
              confidence: (ann['confidence'] as num?)?.toDouble(),
              annotatorId: annotatorId,
              createdAt: timestamp,
              updatedAt: timestamp,
            ));
            addedCount++;
          } else {
            logAndSkip('Binary classification allows only first two labels. Skipping labelId $labelIndex in ${mediaItem.filePath}');
          }

        // Multi-class: only allow the first classification per image
        } else if (projectTypeLower.contains('multi-class')) {
          if ((labelCount[mediaItem.id!] ?? 0) == 0) {
            await annotationDb.insertAnnotation(Annotation(
              id: null,
              mediaItemId: mediaItem.id!,
              labelId: label.id!,
              annotationType: 'classification',
              data: {},
              confidence: (ann['confidence'] as num?)?.toDouble(),
              annotatorId: annotatorId,
              createdAt: timestamp,
              updatedAt: timestamp,
            ));
            addedCount++;
            labelCount[mediaItem.id!] = 1;
          } else {
            logAndSkip('Multi-class classification allows only one label per image. Skipping extra label in ${mediaItem.filePath}');
          }

        // Multi-label: allow multiple labels per image
        } else if (projectTypeLower.contains('multi-label')) {
          await annotationDb.insertAnnotation(Annotation(
            id: null,
            mediaItemId: mediaItem.id!,
            labelId: label.id!,
            annotationType: 'classification',
            data: {},
            confidence: (ann['confidence'] as num?)?.toDouble(),
            annotatorId: annotatorId,
            createdAt: timestamp,
            updatedAt: timestamp,
          ));
          addedCount++;
        } else {
          logAndSkip('Unrecognized classification type "$projectType" in ${mediaItem.filePath}');
        }

      } else {
        logAndSkip('Skipped annotation of type "$type" in ${mediaItem.filePath} for projectType "$projectType"');
      }
    }

    /// Process annotations based on structure
    if (data.containsKey('items')) {
      // Preferred format
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
    } else if (data.containsKey('annotations')) {
      // Older format
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
    } else {
      _logger.warning('[Datumaro] unknown format: missing "items" or "annotations" key');
    }

    for (final entry in labelCount.entries) {
      _logger.info('[Datumaro] labelId ${entry.key} -> ${entry.value} annotations');
    }

    _logger.info('[Datumaro] added $addedCount annotations from ${annotationFile.path}');
    return addedCount;
  }

  static String _randomHexColor() {
    return '#${_random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }
}
