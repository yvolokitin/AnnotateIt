import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../../models/project.dart';
import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';
import '../../models/shape/rect_shape.dart';

import 'base_dataset_exporter.dart';

class YOLOExporter extends BaseDatasetExporter {
  static final Logger _logger = Logger('YOLOExporter');

  YOLOExporter({
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
    _logger.info('Exporting dataset in YOLO format');

    final archive = Archive();
    final Map<int, int> labelIdToClassIndex = {
      for (int i = 0; i < labels.length; i++) labels[i].id: i
    };

    // Export classes.txt
    if (exportLabels) {
      final classText = labels.map((l) => l.name).join('\n');
      archive.addFile(ArchiveFile('classes.txt', classText.length, utf8.encode(classText)));
    }

    for (final mediaItem in mediaItems) {
      if (mediaItem.type != MediaType.image || mediaItem.id == null) continue;

      final file = File(mediaItem.filePath);
      final fileName = path.basename(mediaItem.filePath);
      final imageBaseName = path.basenameWithoutExtension(fileName);

      // Add image to archive
      if (await file.exists()) {
        try {
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile('images/$fileName', bytes.length, bytes));
        } catch (e) {
          _logger.severe('Failed to read ${file.path}: $e');
          continue;
        }
      } else {
        _logger.warning('Image file not found: ${file.path}');
        continue;
      }

      // Generate label file content
      final buffer = StringBuffer();

      if (exportAnnotations) {
        final annotations = annotationsByMediaId[mediaItem.id!] ?? [];

        if (project.type.toLowerCase().contains('detection')) {
          for (final annotation in annotations) {
            if (annotation.annotationType != 'bbox' || annotation.labelId == null) continue;

            final classIndex = labelIdToClassIndex[annotation.labelId];
            if (classIndex == null) continue;

            final line = _convertAnnotationToYOLO(
              annotation: annotation,
              imageWidth: mediaItem.width ?? 0,
              imageHeight: mediaItem.height ?? 0,
              classIndex: classIndex,
            );
            if (line != null) buffer.writeln(line);
          }
        } else if (project.type.toLowerCase().contains('classification')) {
          for (final annotation in annotations) {
            if (annotation.labelId == null) continue;
            final classIndex = labelIdToClassIndex[annotation.labelId];
            if (classIndex != null) buffer.writeln(classIndex);
          }
        }
      }

      // Add label file if it has content
      if (buffer.isNotEmpty) {
        final labelPath = 'labels/$imageBaseName.txt';
        final labelBytes = utf8.encode(buffer.toString());
        archive.addFile(ArchiveFile(labelPath, labelBytes.length, labelBytes));
      }
    }

    // Add data.yaml
    final yaml = '''
# YOLO dataset exported from AnnotateIt
path: .
train: images
val: images
test: images

nc: ${labels.length}
names: ${jsonEncode(labels.map((l) => l.name).toList())}
''';
    archive.addFile(ArchiveFile('data.yaml', yaml.length, utf8.encode(yaml)));

    return archive;
  }

  /// YOLO format: <class_index> <center_x> <center_y> <width> <height>
  String? _convertAnnotationToYOLO({
    required Annotation annotation,
    required int imageWidth,
    required int imageHeight,
    required int classIndex,
  }) {
    if (imageWidth <= 0 || imageHeight <= 0) return null;
    final shape = annotation.shape;
    if (shape is RectShape) {
      final centerX = (shape.x + shape.width / 2) / imageWidth;
      final centerY = (shape.y + shape.height / 2) / imageHeight;
      final normWidth = shape.width / imageWidth;
      final normHeight = shape.height / imageHeight;

      return '$classIndex '
          '${centerX.toStringAsFixed(6)} '
          '${centerY.toStringAsFixed(6)} '
          '${normWidth.toStringAsFixed(6)} '
          '${normHeight.toStringAsFixed(6)}';
    }
    return null;
  }
}
