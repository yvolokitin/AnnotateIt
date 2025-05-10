import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'package:archive/archive_io.dart';
import 'package:xml/xml.dart';

import '../models/dataset_info.dart';

class DatasetAnnotationStats {
  final int annotationCount;
  final int annotatedFilesCount;
  final Set<String> labels;

  DatasetAnnotationStats({
    required this.annotationCount,
    required this.annotatedFilesCount,
    required this.labels,
  });
}

Future<DatasetAnnotationStats> countDatasetAnnotations(
    Directory datasetDir, String datasetType) async {
  int annotationCount = 0;
  final annotatedMediaFiles = <String>{};
  final labels = <String>{};

  final allFiles = datasetDir.listSync(recursive: true).whereType<File>().toList();

  if (datasetType == 'COCO') {
    final cocoFile = allFiles.firstWhere(
        (f) => f.path.toLowerCase().endsWith('.json'),
        orElse: () => File(''));

    if (await cocoFile.exists()) {
      final jsonMap = jsonDecode(await cocoFile.readAsString());
      if (jsonMap is Map) {
        // labels from categories
        if (jsonMap.containsKey('categories')) {
          final categories = jsonMap['categories'] as List;
          for (final category in categories) {
            if (category is Map && category.containsKey('name')) {
              labels.add(category['name'].toString());
            }
          }
        }
        // annotation count + image_ids
        if (jsonMap.containsKey('annotations')) {
          final annotations = jsonMap['annotations'] as List;
          annotationCount = annotations.length;
          for (final annotation in annotations) {
            if (annotation is Map) {
              if (annotation.containsKey('image_id')) {
                annotatedMediaFiles.add(annotation['image_id'].toString());
              }
              if (annotation.containsKey('category_id')) {
                labels.add(annotation['category_id'].toString()); // fallback
              }
            }
          }
        }
      }
    }
  } else if (datasetType == 'YOLO') {
    final txtFiles = allFiles.where((f) => f.path.toLowerCase().endsWith('.txt'));
    for (final file in txtFiles) {
      final lines = await file.readAsLines();
      if (lines.isNotEmpty) {
        annotationCount += lines.length;
        annotatedMediaFiles.add(file.uri.pathSegments.last.replaceAll('.txt', ''));
        for (final line in lines) {
          final parts = line.trim().split(' ');
          if (parts.isNotEmpty) {
            labels.add(parts.first); // class id as label
          }
        }
      }
    }
  } else if (datasetType == 'VOC') {
    final xmlFiles = allFiles.where((f) => f.path.toLowerCase().endsWith('.xml'));
    for (final file in xmlFiles) {
      final document = XmlDocument.parse(await file.readAsString());
      final objects = document.findAllElements('object').toList();
      if (objects.isNotEmpty) {
        annotationCount += objects.length;
        final filenameElement = document.findAllElements('filename').firstOrNull;
        if (filenameElement != null) {
          annotatedMediaFiles.add(filenameElement.text);
        }
        // labels
        for (final obj in objects) {
          final nameElem = obj.findElements('name').firstOrNull;
          if (nameElem != null) {
            labels.add(nameElem.text);
          }
        }
      }
    }
  } else if (datasetType == 'LabelMe') {
    final jsonFiles = allFiles.where((f) => f.path.toLowerCase().endsWith('.json'));
    for (final file in jsonFiles) {
      final jsonMap = jsonDecode(await file.readAsString());
      if (jsonMap is Map && jsonMap.containsKey('shapes')) {
        final shapes = jsonMap['shapes'] as List;
        if (shapes.isNotEmpty) {
          annotationCount += shapes.length;
          annotatedMediaFiles.add(file.uri.pathSegments.last.replaceAll('.json', ''));
          for (final shape in shapes) {
            if (shape is Map && shape.containsKey('label')) {
              labels.add(shape['label'].toString());
            }
          }
        }
      }
    }
  } else if (datasetType == 'Datumaro') {
    final jsonFiles = allFiles.where((f) => f.path.toLowerCase().endsWith('.json'));
    for (final file in jsonFiles) {
      final jsonMap = jsonDecode(await file.readAsString());
      if (jsonMap is Map) {
        // labels from categories
        if (jsonMap.containsKey('categories')) {
          final categories = jsonMap['categories'] as Map;
          for (final category in categories.values) {
            if (category is Map && category.containsKey('labels')) {
              final labelsList = category['labels'] as List;
              for (final label in labelsList) {
                if (label is Map && label.containsKey('name')) {
                  labels.add(label['name'].toString());
                }
              }
            }
          }
        }
        // annotations + annotated items
        if (jsonMap.containsKey('items') && jsonMap['items'] is List) {
          final items = jsonMap['items'] as List;
          for (final item in items) {
            if (item is Map) {
              final itemAnnotations = item['annotations'] as List? ?? [];
              if (itemAnnotations.isNotEmpty) {
                annotationCount += itemAnnotations.length;
                annotatedMediaFiles.add(item['id'].toString());
                for (final annotation in itemAnnotations) {
                  if (annotation is Map && annotation.containsKey('label')) {
                    labels.add(annotation['label'].toString());
                  }
                }
              }
            }
          }
        }
      }
    }
  } else {
    // fallback heuristic for unknown dataset types
    final jsonFiles = allFiles.where((f) => f.path.toLowerCase().endsWith('.json'));
    for (final file in jsonFiles) {
      final jsonMap = jsonDecode(await file.readAsString());
      if (jsonMap is Map && jsonMap.containsKey('annotations')) {
        final annotations = jsonMap['annotations'] as List;
        if (annotations.isNotEmpty) {
          annotationCount += annotations.length;
          annotatedMediaFiles.add(file.uri.pathSegments.last.replaceAll('.json', ''));
        }
      }
    }
  }

  return DatasetAnnotationStats(
    annotationCount: annotationCount,
    annotatedFilesCount: annotatedMediaFiles.length,
    labels: labels,
  );
}

// Dart 3 helper extension
extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

/// Extracts a ZIP file to the given [storagePath] folder.
/// 
/// [zipFile] is the input file. [onProgress] is called with progress between 0.0 and 1.0.
/// 
/// Returns the created [Directory] where files were extracted.
Future<Directory> extractZipToAppFolder(
  File zipFile,
  String storagePath, {
  void Function(double progress)? onProgress,
}) async {
  final outputDir = Directory('$storagePath/${DateTime.now().millisecondsSinceEpoch}');
  await outputDir.create(recursive: true);

  final bytes = zipFile.readAsBytesSync();
  final archive = ZipDecoder().decodeBytes(bytes);

  final totalFiles = archive.length;
  int extractedCount = 0;

  for (final file in archive) {
    final sanitizedName = file.name
        .replaceAll('\\', '/')
        .replaceAll(RegExp(r'\.\.(\/|\\)'), '')
        .replaceAll(RegExp(r'^\/+'), '');

    final outPath = '${outputDir.path}/$sanitizedName';

    if (file.isFile) {
      final outFile = File(outPath)..createSync(recursive: true);
      outFile.writeAsBytesSync(file.content as List<int>);
    } else {
      Directory(outPath).createSync(recursive: true);
    }

    if (onProgress != null) {
      extractedCount++;
      onProgress(extractedCount / totalFiles);
    }
  }

  return outputDir;
}

/// Detects dataset type by analyzing files inside [datasetDir].
/// 
/// [onProgress] reports scanning progress between 0.0 and 1.0.
/// 
/// Returns dataset type as string: e.g. COCO, YOLO, VOC, LabelMe, etc.
Future<String> detectDatasetType(
  Directory datasetDir, {
  void Function(double progress)? onProgress,
}) async {
  bool isCOCO = false;
  bool isYOLO = false;
  bool isVOC = false;
  bool isLabelMe = false;
  bool isCVAT = false;
  bool isDatumaro = false;

  bool hasImages = false;
  bool hasVideos = false;

  final allFiles = datasetDir.listSync(recursive: true).whereType<File>().toList();
  final total = allFiles.length;
  int processed = 0;

  for (final file in allFiles) {
    final name = file.path.toLowerCase();

    if (name.endsWith('.jpg') || name.endsWith('.jpeg') ||
        name.endsWith('.png') || name.endsWith('.bmp') ||
        name.endsWith('.webp')) {
      hasImages = true;
    } else if (name.endsWith('.mp4') || name.endsWith('.avi') ||
        name.endsWith('.mov') || name.endsWith('.mkv')) {
      hasVideos = true;
    }

    try {
      if (name.endsWith('.json')) {
        final text = await file.readAsString();
        final jsonMap = jsonDecode(text);

        if (jsonMap is Map) {
          // Datumaro native format
          if (jsonMap.containsKey('items') && jsonMap['items'] is List &&
              jsonMap.containsKey('categories') && jsonMap['categories'] is Map) {
            isDatumaro = true;
          }
          // COCO
          else if (jsonMap.containsKey('images') && jsonMap.containsKey('annotations')) {
            isCOCO = true;
          }
          // LabelMe
          else if (jsonMap.containsKey('version') &&
                   jsonMap.containsKey('flags') &&
                   jsonMap.containsKey('shapes')) {
            isLabelMe = true;
          }
          // CVAT XML exported to JSON
          else if (jsonMap.containsKey('meta') &&
                   jsonMap['meta'] is Map &&
                   jsonMap['meta']['task']?['id'] != null) {
            isCVAT = true;
          }
        }
      } else if (name.endsWith('.xml')) {
        final text = await file.readAsString();
        if (text.contains('<annotation') && text.contains('<object>') && text.contains('<bndbox>')) {
          isVOC = true;
        } else if (text.contains('<annotations>') &&
                   text.contains('<image>') &&
                   text.contains('<box') &&
                   text.contains('label=')) {
          isCVAT = true;
        }
      } else if (name.endsWith('.txt')) {
        // YOLO format heuristic
        final lines = await file.readAsLines();
        if (lines.isNotEmpty) {
          final parts = lines.first.trim().split(' ');
          if (parts.length == 5 && parts.every((p) => double.tryParse(p) != null)) {
            isYOLO = true;
          }
        }
      }
    } catch (_) {
      // Ignore file parsing errors
    }

    processed++;
    if (onProgress != null) {
      onProgress(processed / total);
    }
  }

  // return priority order
  if (isDatumaro) return 'Datumaro';
  if (isCOCO) return 'COCO';
  if (isYOLO) return 'YOLO';
  if (isVOC) return 'VOC';
  if (isLabelMe) return 'LabelMe';
  if (isCVAT) return 'CVAT';

  if (hasImages && !hasVideos) return 'ImagesOnly';
  if (hasVideos && !hasImages) return 'VideosOnly';
  if (hasImages && hasVideos) return 'ImagesAndVideos';

  return 'Unknown';
}

Future<String> detectDatasetTaskType(Directory datasetDir) async {
  final annotationExtensions = ['.json', '.xml', '.txt'];
  final allFiles = datasetDir.listSync(recursive: true).whereType<File>().toList();

  final annotationFiles = allFiles.where((f) =>
      annotationExtensions.any((ext) => f.path.toLowerCase().endsWith(ext))).toList();

  if (annotationFiles.isEmpty) {
    return "Unknown";
  }

  final File firstAnnotation = annotationFiles.first;
  final String name = firstAnnotation.path.toLowerCase();

  try {
    if (name.endsWith('.json')) {
      final text = await firstAnnotation.readAsString();
      final jsonMap = jsonDecode(text);

      if (jsonMap is Map) {
        // Datumaro format detection
        if (jsonMap.containsKey('items') && jsonMap['items'] is List) {
          final items = jsonMap['items'] as List;
          if (items.isNotEmpty && items.first is Map) {
            final item = items.first as Map;
            if (item.containsKey('annotations') && item['annotations'] is List) {
              final annotations = item['annotations'] as List;
              if (annotations.isNotEmpty && annotations.first is Map) {
                final annotation = annotations.first as Map;
                final type = annotation['type'];
                if (type == 'bbox') return "Detection";
                if (type == 'polygon' || type == 'mask' || type == 'segmentation') return "Segmentation";
              }
            }
          }
        }

        // COCO style
        if (jsonMap.containsKey('annotations')) {
          final annotations = jsonMap['annotations'];
          if (annotations is List && annotations.isNotEmpty) {
            final first = annotations.first;
            if (first is Map) {
              if (first.containsKey('bbox') || first.containsKey('oriented_bbox')) {
                return "Detection";
              }
              if (first.containsKey('segmentation') || first.containsKey('mask') || first.containsKey('rle')) {
                return "Segmentation";
              }
            }
          }
        }

        // LabelMe style
        if (jsonMap.containsKey('shapes')) {
          return "Detection";
        }

        // Datumaro label-only dataset
        if (jsonMap.containsKey('labels') || jsonMap.containsKey('categories')) {
          return "Classification";
        }
      }
    } else if (name.endsWith('.xml')) {
      final text = await firstAnnotation.readAsString();
      if (text.contains('<bndbox>') || text.contains('<oriented_bbox>')) {
        return "Detection";
      }
      if (text.contains('<segmentation>') || text.contains('<mask>')) {
        return "Segmentation";
      }
    } else if (name.endsWith('.txt')) {
      final lines = await firstAnnotation.readAsLines();
      if (lines.isNotEmpty) {
        final parts = lines.first.trim().split(' ');
        if (parts.length >= 5 && parts.every((p) => double.tryParse(p) != null || int.tryParse(p) != null)) {
          return "Detection";
        }
        if (parts.length == 1) {
          return "Classification";
        }
      }
    }
  } catch (_) {}

  return "Unknown";
}

/// Deletes extracted dataset folder at [extractedPath].
/// 
/// Optionally logs messages via [onLog].
Future<void> cleanupExtractedPath(
  String extractedPath, {
  void Function(String message)? onLog,
}) async {
  final dir = Directory(extractedPath);
  if (await dir.exists()) {
    await dir.delete(recursive: true);
    onLog?.call('Cleaned up extracted directory: $extractedPath');
  }

  try {
    final rootFolder = dir.parent;
    if (await rootFolder.exists()) {
      final contents = rootFolder.listSync();
      if (contents.isEmpty) {
        await rootFolder.delete();
        onLog?.call('Cleaned up root folder: ${rootFolder.path}');
      }
    }
  } catch (e) {
    onLog?.call('Failed to remove root folder: $e');
  }
}

/// Extracts + detects dataset (non-isolate mode).
/// 
/// Best for small to medium dataset sizes.
/// Reports progress via [onExtractProgress], [onDetectProgress].
/// Calls [onExtractDone] after extraction.
/// 
/// Returns [DatasetInfo].
Future<DatasetInfo> processZipLocally({
  required File zipFile,
  required String storagePath,
  required void Function(double progress) onExtractProgress,
  required void Function(String path) onExtractDone,
  required void Function(double progress) onDetectProgress,
}) async {
  // Extract dataset ZIP
  final extractedDir = await extractZipToAppFolder(
    zipFile,
    storagePath,
    onProgress: onExtractProgress,
  );

  onExtractDone(extractedDir.path);

  // Detect dataset type (COCO, YOLO, VOC, etc.)
  String datasetType = await detectDatasetType(
    extractedDir,
    onProgress: onDetectProgress,
  );

  // Detect task type (Detection, Segmentation, Classification etc.)
  String taskType = await detectDatasetTaskType(extractedDir);

  // Get media files
  final allFiles = extractedDir.listSync(recursive: true).whereType<File>().toList();
  final mediaExtensions = ['.jpg', '.jpeg', '.png', '.bmp', '.webp', '.mp4', '.avi', '.mov', '.mkv'];
  final mediaFiles = allFiles.where((f) =>
      mediaExtensions.any((ext) => f.path.toLowerCase().endsWith(ext))).toList();

  // 🟢 Use new high-quality annotation stats function
  final stats = await countDatasetAnnotations(extractedDir, datasetType);

  // Just collect annotation file names for label list (same as before)
  final annotationExtensions = ['.json', '.xml', '.txt'];
  final annotationFiles = allFiles.where((f) =>
      annotationExtensions.any((ext) => f.path.toLowerCase().endsWith(ext))).toList();

  return DatasetInfo(
    datasetPath: extractedDir.path,
    mediaCount: mediaFiles.length,
    annotationCount: stats.annotationCount,
    annotatedFilesCount: stats.annotatedFilesCount,
    datasetFormat: datasetType,
    taskType: taskType,
    labels: stats.labels.toList(),
  );
}

/// Extracts + detects dataset (isolate mode).
/// 
/// Best for very large datasets (avoids UI freezes).
/// Reports progress via [onExtractProgress], [onDetectProgress].
/// Calls [onExtractDone] after extraction.
/// 
/// Returns [DatasetInfo].
Future<DatasetInfo> processZipLocallyWithIsolates({
  required File zipFile,
  required String storagePath,
  required void Function(double progress) onExtractProgress,
  required void Function(String path) onExtractDone,
  required void Function(double progress) onDetectProgress,
}) async {
  final receivePort = ReceivePort();

  // Extract in isolate
  await Isolate.spawn(extractInIsolate, [
    zipFile.path,
    storagePath,
    receivePort.sendPort,
  ]);

  String extractedPath = '';
  await for (final message in receivePort) {
    if (message is Map<String, dynamic>) {
      if (message['type'] == 'extract_progress') {
        onExtractProgress(message['progress'] ?? 0.0);
      } else if (message['type'] == 'extract_done') {
        extractedPath = message['path'];
        onExtractDone(extractedPath);
        break;
      } else if (message['type'] == 'extract_error') {
        throw Exception("Extract isolate error: ${message['error']}");
      }
    }
  }

  // Detect dataset type in isolate
  final detectionPort = ReceivePort();
  await Isolate.spawn(detectInIsolate, [
    extractedPath,
    detectionPort.sendPort,
  ]);

  String datasetType = '';
  await for (final message in detectionPort) {
    if (message is Map<String, dynamic>) {
      if (message['type'] == 'detect_progress') {
        onDetectProgress(message['progress'] ?? 0.0);
      } else if (message['type'] == 'detect_done') {
        datasetType = message['taskType'];
        break;
      }
    }
  }

  final extractedDir = Directory(extractedPath);
  final allFiles = extractedDir.listSync(recursive: true).whereType<File>().toList();
  final mediaExtensions = ['.jpg', '.jpeg', '.png', '.bmp', '.webp', '.mp4', '.avi', '.mov', '.mkv'];

  final mediaFiles = allFiles.where((f) =>
      mediaExtensions.any((ext) => f.path.toLowerCase().endsWith(ext))).toList();

  // Count real annotation + annotated media files
  final stats = await countDatasetAnnotations(extractedDir, datasetType);

  // Detect task type based on dataset type + annotations
  String taskType = await detectDatasetTaskType(extractedDir);

  // Collect annotation file names for label list (same as before)
  final annotationExtensions = ['.json', '.xml', '.txt'];
  final annotationFiles = allFiles.where((f) =>
      annotationExtensions.any((ext) => f.path.toLowerCase().endsWith(ext))).toList();

  return DatasetInfo(
    datasetPath: extractedPath,
    mediaCount: mediaFiles.length,
    annotationCount: stats.annotationCount,
    annotatedFilesCount: stats.annotatedFilesCount,
    datasetFormat: datasetType,
    taskType: taskType,
    labels: stats.labels.toList(),
  );
}

/// Isolate function: extracts dataset in background.
Future<void> extractInIsolate(List<dynamic> args) async {
  final zipPath = args[0] as String;
  final storagePath = args[1] as String;
  final sendPort = args[2] as SendPort;

  final zipFile = File(zipPath);

  try {
    final extractedDir = await extractZipToAppFolder(
      zipFile,
      storagePath,
      onProgress: (progress) {
        sendPort.send({"type": "extract_progress", "progress": progress});
      },
    );

    sendPort.send({"type": "extract_done", "path": extractedDir.path});
  } catch (e, stack) {
    sendPort.send({
      "type": "extract_error",
      "error": e.toString(),
      "stack": stack.toString(),
    });
  }
}

/// Isolate function: detects dataset type in background.
Future<void> detectInIsolate(List<dynamic> args) async {
  final path = args[0] as String;
  final sendPort = args[1] as SendPort;
  final dir = Directory(path);

  final taskType = await detectDatasetType(dir, onProgress: (progress) {
    sendPort.send({"type": "detect_progress", "progress": progress});
  });

  sendPort.send({"type": "detect_done", "taskType": taskType});
}

/// Generates a unique folder path inside base path from [getBasePath].
/// 
/// Useful for preparing dataset extraction folders.
Future<String> getDefaultStoragePath(Future<String> Function() getBasePath) async {
  final basePath = await getBasePath();
  final uniqueFolder = 'dataset_${DateTime.now().millisecondsSinceEpoch}';
  final fullPath = Directory("$basePath/$uniqueFolder");
  await fullPath.create(recursive: true);
  return fullPath.path;
}
