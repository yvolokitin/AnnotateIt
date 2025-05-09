import 'dart:io';
import 'dart:convert';
import 'package:archive/archive_io.dart';

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
    // Sanitize file path to prevent traversal attacks
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

    if (name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.bmp') ||
        name.endsWith('.webp')) {
      hasImages = true;
    } else if (name.endsWith('.mp4') ||
        name.endsWith('.avi') ||
        name.endsWith('.mov') ||
        name.endsWith('.mkv')) {
      hasVideos = true;
    }

    try {
      final text = await file.readAsString();

      if (name.endsWith('.json')) {
        final jsonMap = jsonDecode(text);
        if (jsonMap is Map) {
          if (jsonMap.containsKey('images') && jsonMap.containsKey('annotations')) {
            isCOCO = true;
          } else if (jsonMap.containsKey('version') &&
              jsonMap.containsKey('flags') &&
              jsonMap.containsKey('shapes')) {
            isLabelMe = true;
          } else if (jsonMap.containsKey('meta') &&
              jsonMap['meta'] is Map &&
              jsonMap['meta']['project']?['name'] != null) {
            isDatumaro = true;
          }
        }
      } else if (name.endsWith('.xml')) {
        if (text.contains('<annotation') &&
            text.contains('<object>') &&
            text.contains('<bndbox>')) {
          isVOC = true;
        } else if (text.contains('<annotations>') &&
            text.contains('<image>') &&
            text.contains('<box') &&
            text.contains('label=')) {
          isCVAT = true;
        }
      } else if (name.endsWith('.txt')) {
        final lines = await file.readAsLines();
        if (lines.isNotEmpty) {
          final parts = lines.first.trim().split(' ');
          if (parts.length == 5 && parts.every((p) => double.tryParse(p) != null)) {
            isYOLO = true;
          }
        }
      }
    } catch (_) {
      // Skip unreadable files
    }

    processed++;
    if (onProgress != null) {
      onProgress(processed / total);
    }
  }

  if (isCOCO) return 'COCO';
  if (isYOLO) return 'YOLO';
  if (isVOC) return 'VOC';
  if (isLabelMe) return 'LabelMe';
  if (isCVAT) return 'CVAT';
  if (isDatumaro) return 'Datumaro';

  if (hasImages && !hasVideos) return 'ImagesOnly';
  if (hasVideos && !hasImages) return 'VideosOnly';
  if (hasImages && hasVideos) return 'ImagesAndVideos';

  return 'Unknown';
}
