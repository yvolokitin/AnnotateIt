import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../../models/project.dart';
import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/media_item.dart';

import 'base_dataset_exporter.dart';

/// Simple ZIP exporter that includes:
/// - Media files in 'images/' directory
/// - Labels in 'labels.json' file
/// - Annotations in 'annotations.json' file (if enabled)
class ZipExporter extends BaseDatasetExporter {
  static final Logger _logger = Logger('ZipExporter');

  ZipExporter({
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
    _logger.info('Exporting dataset in simple ZIP format');

    final archive = Archive();

    // Add metadata file
    final metadata = {
      'project': {
        'id': project.id,
        'name': project.name,
        'type': project.type,
        'description': project.description,
        'created_at': project.creationDate.toIso8601String(),
        'exported_at': DateTime.now().toIso8601String(),
      },
    };
    
    final metadataJson = jsonEncode(metadata);
    archive.addFile(ArchiveFile('metadata.json', metadataJson.length, utf8.encode(metadataJson)));

    // Add labels file if exportLabels is true
    if (exportLabels) {
      final labelsJson = jsonEncode(labels.map((label) => {
        'id': label.id,
        'name': label.name,
        'color': label.color,
      }).toList());
      
      archive.addFile(ArchiveFile('labels.json', labelsJson.length, utf8.encode(labelsJson)));
    }

    // Add media files
    final Map<int, String> mediaIdToFilename = {};
    
    for (final mediaItem in mediaItems) {
      if (mediaItem.id == null) continue;

      final fileName = path.basename(mediaItem.filePath);
      final file = File(mediaItem.filePath);
      
      if (!await file.exists()) {
        _logger.warning('Media file not found: ${mediaItem.filePath}');
        continue;
      }

      try {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          archive.addFile(ArchiveFile('images/$fileName', bytes.length, bytes));
          mediaIdToFilename[mediaItem.id!] = fileName;
        }
      } catch (e) {
        _logger.severe('Failed to read ${mediaItem.filePath}: $e');
        continue;
      }
    }

    // Add annotations file if exportAnnotations is true
    if (exportAnnotations) {
      final annotationsMap = <String, List<Map<String, dynamic>>>{};
      
      for (final mediaId in annotationsByMediaId.keys) {
        final fileName = mediaIdToFilename[mediaId];
        if (fileName == null) continue;
        
        final annotations = annotationsByMediaId[mediaId]!;
        final annotationsList = <Map<String, dynamic>>[];
        
        for (final annotation in annotations) {
          annotationsList.add({
            'id': annotation.id,
            'label_id': annotation.labelId,
            'annotation_type': annotation.annotationType,
            'shape': annotation.shape?.toJson(),
            'created_at': annotation.createdAt.toIso8601String(),
          });
        }
        
        if (annotationsList.isNotEmpty) {
          annotationsMap[fileName] = annotationsList;
        }
      }
      
      final annotationsJson = jsonEncode(annotationsMap);
      archive.addFile(ArchiveFile('annotations.json', annotationsJson.length, utf8.encode(annotationsJson)));
    }

    // Add format.txt to identify this as a simple ZIP export
    final formatContent = 'simple_zip';
    archive.addFile(ArchiveFile('format.txt', formatContent.length, utf8.encode(formatContent)));

    return archive;
  }
}