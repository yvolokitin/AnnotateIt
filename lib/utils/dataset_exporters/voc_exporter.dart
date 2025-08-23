import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../../models/project.dart';
import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../models/shape/rect_shape.dart';

import 'base_dataset_exporter.dart';

/// Minimal Pascal VOC (XML) exporter
/// - Images are stored under JPEGImages/
/// - Annotations are stored under Annotations/ as <image>.xml
/// - Only detection (bbox) annotations are exported to VOC objects.
class VOCExporter extends BaseDatasetExporter {
  static final Logger _logger = Logger('VOCExporter');

  VOCExporter({
    required super.project,
    required super.exportLabels,
    required super.exportAnnotations,
  });

  @override
  Future<Archive> buildArchive({
    required List<Label> labels,
    required List<MediaItem> mediaItems,
    required Map<int, List<Annotation>> annotationsByMediaId,
  }) async {
    _logger.info('Exporting dataset in Pascal VOC format');

    final archive = Archive();

    // Optional: export labels list for reference (not part of standard VOC spec)
    if (exportLabels) {
      final content = labels.map((l) => l.name).join('\n');
      final bytes = utf8.encode(content);
      archive.addFile(ArchiveFile('labels.txt', bytes.length, bytes));
    }

    // Build map labelId -> label name for quick lookup
    final Map<int, String> labelIdToName = {
      for (final l in labels) if (l.id != null) l.id!: l.name
    };

    for (final mediaItem in mediaItems) {
      if (mediaItem.type != MediaType.image || mediaItem.id == null) continue;

      // Add image bytes
      final file = File(mediaItem.filePath);
      final fileName = path.basename(mediaItem.filePath);
      final baseName = path.basenameWithoutExtension(fileName);
      if (await file.exists()) {
        try {
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile('JPEGImages/$fileName', bytes.length, bytes));
        } catch (e) {
          _logger.severe('Failed to read image ${file.path}: $e');
          continue;
        }
      } else {
        _logger.warning('Image file not found: ${file.path}');
        continue;
      }

      if (exportAnnotations) {
        final xml = _buildVocXml(
          mediaItem: mediaItem,
          annotations: annotationsByMediaId[mediaItem.id!] ?? const [],
          labelIdToName: labelIdToName,
        );
        if (xml != null && xml.isNotEmpty) {
          final xmlBytes = utf8.encode(xml);
          archive.addFile(ArchiveFile('Annotations/$baseName.xml', xmlBytes.length, xmlBytes));
        }
      }
    }

    // Add a simple marker to indicate the format
    const marker = 'voc';
    final markerBytes = utf8.encode(marker);
    archive.addFile(ArchiveFile('format.txt', markerBytes.length, markerBytes));

    return archive;
  }

  String? _buildVocXml({
    required MediaItem mediaItem,
    required List<Annotation> annotations,
    required Map<int, String> labelIdToName,
  }) {
    // Only export detection boxes for VOC
    final isDetectionProject = project.type.toLowerCase().contains('detection');
    if (!isDetectionProject) {
      // No suitable VOC annotations for non-detection types
      return _vocEnvelope(
        mediaItem: mediaItem,
        objectsXml: '',
      );
    }

    final width = mediaItem.width ?? 0;
    final height = mediaItem.height ?? 0;
    final depth = 3; // assume RGB

    final buffer = StringBuffer();

    for (final ann in annotations) {
      if (ann.annotationType != 'bbox' || ann.labelId == null) continue;
      final shape = ann.shape;
      if (shape is! RectShape) continue;

      final name = labelIdToName[ann.labelId];
      if (name == null) continue;

      // clamp bbox within image bounds and convert to VOC int coordinates
      int xmin = shape.x.round();
      int ymin = shape.y.round();
      int xmax = (shape.x + shape.width).round();
      int ymax = (shape.y + shape.height).round();

      if (width > 0 && height > 0) {
        xmin = xmin.clamp(0, width - 1);
        ymin = ymin.clamp(0, height - 1);
        xmax = xmax.clamp(0, width - 1);
        ymax = ymax.clamp(0, height - 1);
      }

      if (xmax <= xmin || ymax <= ymin) continue; // skip invalid

      buffer.write('''
  <object>
    <name>${_xmlEscape(name)}</name>
    <pose>Unspecified</pose>
    <truncated>0</truncated>
    <difficult>0</difficult>
    <bndbox>
      <xmin>$xmin</xmin>
      <ymin>$ymin</ymin>
      <xmax>$xmax</xmax>
      <ymax>$ymax</ymax>
    </bndbox>
  </object>
''');
    }

    return _vocEnvelope(
      mediaItem: mediaItem,
      objectsXml: buffer.toString(),
      width: width,
      height: height,
      depth: depth,
    );
  }

  String _vocEnvelope({
    required MediaItem mediaItem,
    required String objectsXml,
    int? width,
    int? height,
    int? depth,
  }) {
    final fileName = path.basename(mediaItem.filePath);
    final folder = 'JPEGImages';
    final w = (width ?? 0);
    final h = (height ?? 0);
    final d = (depth ?? 3);

    return '''<?xml version="1.0" encoding="UTF-8"?>
<annotation>
  <folder>${_xmlEscape(folder)}</folder>
  <filename>${_xmlEscape(fileName)}</filename>
  <path>${_xmlEscape(mediaItem.filePath)}</path>
  <source>
    <database>Unknown</database>
  </source>
  <size>
    <width>$w</width>
    <height>$h</height>
    <depth>$d</depth>
  </size>
  <segmented>0</segmented>
${objectsXml.isEmpty ? '' : objectsXml}</annotation>
''';
  }

  String _xmlEscape(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
