import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'package:archive/archive_io.dart' as zip;
import 'package:xml/xml.dart';

import '../models/archive.dart';

import 'dataset_task_type_detector.dart';

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

Future<DatasetAnnotationStats> countDatasetAnnotationsAndLabels(Directory datasetDir, String datasetType) async {
  int annotationCount = 0;
  final annotatedMediaFiles = <String>{};
  final labels = <String>{};

  final allFiles = datasetDir.listSync(recursive: true).whereType<File>().toList();

  if (datasetType == 'COCO') {
    final cocoFile = allFiles.firstWhere(
      (f) => f.path.toLowerCase().endsWith('.json'),
      orElse: () => File(''));

    if (await cocoFile.exists()) {
      await _parseCocoAnnotations(
        cocoFile,
        labels,
        annotatedMediaFiles,
        (count) => annotationCount = count,
      );
    }

  } else if (datasetType == 'YOLO') {
    await _parseYOLOAnnotations(
      allFiles,
      labels,
      annotatedMediaFiles,
      (count) => annotationCount = count,
    );

  } else if (datasetType == 'VOC') {
    await _parseVOCAnnotations(
      allFiles,
      labels,
      annotatedMediaFiles,
      (count) => annotationCount = count,
    );

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
    await _parseDatumaroAnnotations(
      allFiles,
      labels,
      annotatedMediaFiles,
      (count) => annotationCount = count,
    );

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

  print('labels: $labels');
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

Future<void> _parseCocoAnnotations(
    File cocoFile,
    Set<String> labels,
    Set<String> annotatedMediaFiles,
    void Function(int count) setAnnotationCount) async {

  final jsonMap = jsonDecode(await cocoFile.readAsString());
  if (jsonMap is! Map) return;

  // Prepare categoryId → name map
  final categoryIdToName = <int, String>{};
  if (jsonMap.containsKey('categories')) {
    final categories = jsonMap['categories'] as List;
    for (final category in categories) {
      if (category is Map &&
          category.containsKey('id') &&
          category.containsKey('name')) {
        categoryIdToName[category['id']] = category['name'].toString();
        labels.add(category['name'].toString());
      }
    }
  }

  // Count annotations + collect image_ids
  if (jsonMap.containsKey('annotations')) {
    final annotations = jsonMap['annotations'] as List;
    setAnnotationCount(annotations.length);
    for (final annotation in annotations) {
      if (annotation is Map) {
        if (annotation.containsKey('image_id')) {
          annotatedMediaFiles.add(annotation['image_id'].toString());
        }
        if (annotation.containsKey('category_id')) {
          final categoryId = annotation['category_id'];
          if (categoryIdToName.containsKey(categoryId)) {
            labels.add(categoryIdToName[categoryId]!);
          }
        }
      }
    }
  }
}

Future<void> _parseYOLOAnnotations(
  List<File> allFiles,
  Set<String> labels,
  Set<String> annotatedMediaFiles,
  void Function(int count) setAnnotationCount,
) async {
  int annotationCount = 0;

  // Exclude dataset split and metadata files
  final excludedFiles = {'train.txt', 'val.txt', 'test.txt'};
  final txtFiles = allFiles.where((f) =>
      f.path.toLowerCase().endsWith('.txt') &&
      !excludedFiles.contains(f.uri.pathSegments.last.toLowerCase())
  );

  // Step 1: Load classes.txt or obj.names if exists
  Map<String, String> classMap = {};
  final classesFile = allFiles.firstWhere(
    (f) => f.path.toLowerCase().endsWith('classes.txt') ||
           f.path.toLowerCase().endsWith('obj.names'),
    orElse: () => File(''),
  );

  if (await classesFile.exists()) {
    final lines = await classesFile.readAsLines();
    for (int i = 0; i < lines.length; i++) {
      final className = lines[i].trim();
      if (className.isNotEmpty) {
        classMap[i.toString()] = className;
      }
    }
  }

  // Step 2: Parse annotation files
  for (final file in txtFiles) {
    final fileName = file.uri.pathSegments.last.toLowerCase();
    if (fileName == 'classes.txt' || fileName == 'obj.names') {
      continue; // skip classes file
    }

    final lines = await file.readAsLines();
    if (lines.isNotEmpty) {
      annotationCount += lines.length;

      // Add media file name (usually image file with same name)
      annotatedMediaFiles.add(
          file.uri.pathSegments.last.replaceAll('.txt', ''));

      for (final line in lines) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.isNotEmpty) {
          final classId = parts.first;
          // Use mapped label if available, otherwise fallback to class ID
          labels.add(classMap[classId] ?? classId);
        }
      }
    }
  }

  setAnnotationCount(annotationCount);
}

Future<void> _parseVOCAnnotations(
    List<File> allFiles,
    Set<String> labels,
    Set<String> annotatedMediaFiles,
    void Function(int count) setAnnotationCount) async {

  int annotationCountLocal = 0;
  final xmlFiles = allFiles.where((f) => f.path.toLowerCase().endsWith('.xml'));

  if (xmlFiles.isNotEmpty) {
    // Standard VOC XML parsing
    for (final file in xmlFiles) {
      final document = XmlDocument.parse(await file.readAsString());
      final objects = document.findAllElements('object').toList();
      if (objects.isNotEmpty) {
        annotationCountLocal += objects.length;
        final filenameElement =
            document.findAllElements('filename').firstOrNull;
        if (filenameElement != null) {
          annotatedMediaFiles.add(filenameElement.text);
        }
        for (final obj in objects) {
          final nameElem = obj.findElements('name').firstOrNull;
          if (nameElem != null) {
            labels.add(nameElem.text);
          }
        }
      }
    }
  }

  if (annotationCountLocal == 0) {
    // Fallback: check for labelmap.txt (custom dataset style)
    final labelmapFile = allFiles.firstWhere(
        (f) => f.path.toLowerCase().endsWith('labelmap.txt'),
        orElse: () => File(''));
    if (await labelmapFile.exists()) {
      final lines = await labelmapFile.readAsLines();
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

        final parts = trimmed.split(':');
        if (parts.isNotEmpty) {
          final label = parts.first.trim();
          // skip background + empty labels
          if (label.toLowerCase() != 'background' && label.isNotEmpty) {
            labels.add(label);
          }
        }
      }
    }

    // Fallback: assume every image file belongs to dataset
    final imageFiles = allFiles.where((f) =>
        f.path.toLowerCase().endsWith('.jpg') ||
        f.path.toLowerCase().endsWith('.jpeg') ||
        f.path.toLowerCase().endsWith('.png') ||
        f.path.toLowerCase().endsWith('.bmp') ||
        f.path.toLowerCase().endsWith('.webp'));

    annotatedMediaFiles.addAll(
        imageFiles.map((f) => f.uri.pathSegments.last));

    annotationCountLocal = imageFiles.length; // fake annotation count = image count
  }

  setAnnotationCount(annotationCountLocal);
}

Future<void> _parseDatumaroAnnotations(
    List<File> allFiles,
    Set<String> labels,
    Set<String> annotatedMediaFiles,
    void Function(int count) setAnnotationCount) async {

  int annotationCountLocal = 0;
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
              annotationCountLocal += itemAnnotations.length;
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

  setAnnotationCount(annotationCountLocal);
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
  if (bytes.isEmpty) throw Exception("ZIP file is empty.");
  zip.Archive archive;
  try {
    archive = zip.ZipDecoder().decodeBytes(bytes);
  } catch (e) {
    throw Exception("Failed to decode ZIP file: $e");
  }

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
        if (file.uri.pathSegments.last.toLowerCase() == 'labelmap.txt') {
          isVOC = true;
        } else if (lines.isNotEmpty) {
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

/// Deletes extracted dataset folder at [extractedPath].
/// 
/// Optionally logs messages via [onLog].
Future<void> cleanupExtractedPath(
  String extractedPath, {
  void Function(String message)? onLog,
}) async {
  final dir = Directory(extractedPath);

  try {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
      onLog?.call('Cleaned up extracted directory: $extractedPath');
    } else {
      onLog?.call('Directory not found, skipping deletion: $extractedPath');
    }
  } catch (e) {
    onLog?.call('Failed to delete extracted directory: $e');
  }

  try {
    final rootFolder = dir.parent;
    if (await rootFolder.exists()) {
      final contents = await rootFolder.list().toList();
      if (contents.isEmpty) {
        await rootFolder.delete();
        onLog?.call('Cleaned up root folder: ${rootFolder.path}');
      }
    }
  } catch (e) {
    onLog?.call('Failed to delete root folder: $e');
  }
}

/// Extracts + detects dataset (non-isolate mode).
/// 
/// Best for small to medium dataset sizes.
/// Reports progress via [onExtractProgress], [onDetectProgress].
/// Calls [onExtractDone] after extraction.
/// 
/// Returns [Archive].
Future<Archive> processZipLocally({
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
  List<String> detectedTaskTypes = await detectDatasetAllTaskTypes(extractedDir);

  // Get media files
  final allFiles = extractedDir.listSync(recursive: true).whereType<File>().toList();
  final mediaExtensions = ['.jpg', '.jpeg', '.png', '.bmp', '.webp', '.mp4', '.avi', '.mov', '.mkv'];
  final mediaFiles = allFiles.where((f) =>
      mediaExtensions.any((ext) => f.path.toLowerCase().endsWith(ext))).toList();

  // Use new high-quality annotation stats function
  final stats = await countDatasetAnnotationsAndLabels(extractedDir, datasetType);

  // Just collect annotation file names for label list (same as before)
  final annotationExtensions = ['.json', '.xml', '.txt'];
  final annotationFiles = allFiles.where((f) =>
      annotationExtensions.any((ext) => f.path.toLowerCase().endsWith(ext))).toList();

  return Archive(
    zipFileName: zipFile.path.split(Platform.pathSeparator).last,
    datasetPath: extractedDir.path,
    mediaCount: mediaFiles.length,
    annotationCount: stats.annotationCount,
    annotatedFilesCount: stats.annotatedFilesCount,
    datasetFormat: datasetType,
    taskTypes: detectedTaskTypes,
    labels: stats.labels.toList(),
  );
}

/// Extracts + detects dataset (isolate mode).
/// 
/// Best for very large datasets (avoids UI freezes).
/// Reports progress via [onExtractProgress], [onDetectProgress].
/// Calls [onExtractDone] after extraction.
/// 
/// Returns [Archive].
Future<Archive> processZipLocallyWithIsolates({
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
  final stats = await countDatasetAnnotationsAndLabels(extractedDir, datasetType);

  // Detect task type based on dataset type + annotations
  List<String> detectedTaskTypes = await detectDatasetAllTaskTypes(extractedDir);

  // Collect annotation file names for label list (same as before)
  // final annotationExtensions = ['.json', '.xml', '.txt'];
  // final annotationFiles = allFiles.where((f) =>
  //    annotationExtensions.any((ext) => f.path.toLowerCase().endsWith(ext))).toList();

  return Archive(
    zipFileName: zipFile.path.split(Platform.pathSeparator).last,
    datasetPath: extractedPath,
    mediaCount: mediaFiles.length,
    annotationCount: stats.annotationCount,
    annotatedFilesCount: stats.annotatedFilesCount,
    datasetFormat: datasetType,
    taskTypes: detectedTaskTypes,
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
