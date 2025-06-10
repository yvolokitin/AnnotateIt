import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';

import "image_utils.dart";
import 'dataset_annotation_importer.dart';

import '../session/user_session.dart';
import '../data/project_database.dart';
import '../data/dataset_database.dart';
import '../data/labels_database.dart';
import '../data/annotation_database.dart';

import '../models/label.dart';
import '../models/project.dart';
import '../models/dataset_info.dart';
import '../models/media_item.dart';

typedef ProgressCallback = void Function(int current, int total);

class DatasetImportProjectCreation {
  static final Logger _logger = Logger('DatasetImportProjectCreation');

  static Future<int> createProjectWithDataset(
    DatasetInfo datasetInfo,
    {required ProgressCallback onProgress}
  ) async {
    final currentUser = UserSession.instance.getUser();

    final newProjectId = await ProjectDatabase.instance.createProject(
      Project(
        name: datasetInfo.zipFileName,
        type: datasetInfo.selectedTaskType ?? 'Unknown',
        icon: "assets/images/default_project_image.svg",
        creationDate: DateTime.now(),
        lastUpdated: DateTime.now(),
        defaultDatasetId: null,
        ownerId: currentUser.id ?? -1,
      ),
    );

    final String? defaultDatasetId = await ProjectDatabase.instance.getDefaultDatasetId(newProjectId);
    if (defaultDatasetId == null) {
      throw Exception("Created Project $newProjectId has no default dataset assigned.");
    }

    final String? firstImagePath = await addMediaItemsToDataset(
      datasetPath: datasetInfo.datasetPath,
      datasetId: defaultDatasetId,
      ownerId: currentUser.id ?? -1,
      onProgress: onProgress,
    );

    if (firstImagePath != null) {
      final thumbnailFile = await generateThumbnailFromImage(File(firstImagePath), newProjectId.toString());
      if (thumbnailFile != null) {
        await ProjectDatabase.instance.updateProjectIcon(newProjectId, thumbnailFile.path);
      }
    }

    if (datasetInfo.labels.isNotEmpty) {
      final projectLabels = await addLabelsToProject(
        projectId: newProjectId,
        labelNames: datasetInfo.labels,
      );

      final mediaItemsMap = await fetchMediaItemsMap(defaultDatasetId);

      final importer = DatasetAnnotationImporter(annotationDb: AnnotationDatabase.instance);
      final addedCount = await importer.addAnnotationsToProjectFromDataset(
        projectLabels: projectLabels,
        datasetPath: datasetInfo.datasetPath,
        format: datasetInfo.datasetFormat,
        mediaItemsMap: mediaItemsMap,
        projectId: newProjectId,
        annotatorId: currentUser.id ?? -1,
      );
    
      print('Added $addedCount annotations.');

    } else {
      print("No labels detected in dataset. Skipping label import.");
    }

    return newProjectId;
  }

  static Future<String?> addMediaItemsToDataset({
    required String datasetPath,
    required String datasetId,
    required int ownerId,
    required void Function(int current, int total) onProgress,
  }) async {
    final db = await DatasetDatabase.instance.database;

    final mediaFiles = <File>[];
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'jfif', 'webp', 'mp4', 'mov'];
    final imageExtensions = ['bmp', 'gif', 'jpeg', 'jfif', 'jpg', 'png', 'webp'];

    final dir = Directory(datasetPath);
    if (!await dir.exists()) {
      print("ERROR: Dataset folder not found: $datasetPath");
      throw Exception("Dataset folder not found: $datasetPath");
    }

    String? firstImagePath;
    int folderCount = 0;
    int fileCount = 0;

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      final path = entity.path;

      if (path.contains('__MACOSX')) continue;

      if (entity is Directory) {
        folderCount++;
      } else if (entity is File) {
        fileCount++;

        final ext = p.extension(path).toLowerCase().replaceAll('.', '');
        if (!allowedExtensions.contains(ext)) {
          print("Skipped unsupported file: $path");
          continue;
        }

        final fileLength = await entity.length();
        if (fileLength < 100) {
          print("Skipped tiny/corrupt file (<100 bytes): $path");
          continue;
        }

        if (firstImagePath == null && imageExtensions.contains(ext)) {
          try {
            final bytes = await entity.readAsBytes();
            await ui.instantiateImageCodec(bytes); // Validate
            firstImagePath = path;
            print("First valid image for thumbnail: $firstImagePath");
          } catch (e) {
            print("Invalid image file skipped (cannot decode): $path\n$e");
            continue;
          }
        }

        mediaFiles.add(entity);
      }
    }

    final total = mediaFiles.length;
    print("Scan complete: $folderCount folders, $fileCount files found.");
    print("Total media files to insert: $total");

    if (total == 0) {
      throw Exception("No valid media files found. Nothing to insert.");
    }

    final extractMetadata = total <= 5000; // ⚠️ Threshold logic here
    print("Metadata extraction: ${extractMetadata ? 'ENABLED' : 'DISABLED'}");

    int current = 0;
    onProgress(0, total);

    for (final file in mediaFiles) {
      final ext = p.extension(file.path).toLowerCase().replaceAll('.', '');
      final isVideo = ['mp4', 'mov'].contains(ext);

      int? width;
      int? height;
      double? duration;
      double? fps;
      int? numberOfFrames;

      if (extractMetadata) {
        if (isVideo) {
          final meta = await getVideoMetadata(file.path);
          width = meta['width'];
          height = meta['height'];
          duration = meta['duration'];
          fps = meta['fps'];
          numberOfFrames = (duration != null && fps != null)
            ? (duration * fps).round()
            : null;
        } else {
          final meta = await getImageMetadata(file.path);
          width = meta['width'];
          height = meta['height'];
        }
      }

      await DatasetDatabase.instance.insertMediaItem(
        datasetId,
        file.path,
        ext,
        ownerId: ownerId,
        width: width,
        height: height,
        duration: duration,
        fps: fps,
        numberOfFrames: numberOfFrames,
        source: 'imported.' + datasetPath,
      );

      current++;
      if (current % 100 == 0 || current == total) {
        onProgress(current, total);
        print("Progress update: $current / $total files inserted");
      }
    }

    print("Finished inserting $total media files into dataset $datasetId");
    return firstImagePath;
  }

  static Future<List<Label>> addLabelsToProject({
    required int projectId,
    required List<String> labelNames,
  }) async {
    if (labelNames.isEmpty) {
      print("No labels to add.");
      return [];
    }

    final random = Random();
    String generateRandomColor() {
      final r = random.nextInt(256);
      final g = random.nextInt(256);
      final b = random.nextInt(256);
      return '#${r.toRadixString(16).padLeft(2, '0')}'
          '${g.toRadixString(16).padLeft(2, '0')}'
          '${b.toRadixString(16).padLeft(2, '0')}';
    }

    final db = await LabelsDatabase.instance.database;
    final List<Label> insertedLabels = [];

    for (final name in labelNames) {
      final label = Label(
        id: null,
        projectId: projectId,
        name: name.trim(),
        color: generateRandomColor(),
        description: null,
      );

      final labelId = await db.insert('labels', label.toMap());
      insertedLabels.add(label.copyWith(id: labelId));
    }

    print("Added ${insertedLabels.length} labels to project $projectId");
    return insertedLabels;
  }

  static Future<Map<String, MediaItem>> fetchMediaItemsMap(String datasetId) async {
    final mediaItems = await DatasetDatabase.instance.fetchMediaForDataset(datasetId);

    final map = <String, MediaItem>{};
    for (final item in mediaItems) {
      final normalizedPath = item.filePath.replaceAll('\\', '/');
      final fileName = p.basename(normalizedPath).toLowerCase();
      final fileNameNoExt = p.basenameWithoutExtension(normalizedPath).toLowerCase();

      map[fileName] = item;
      map[fileNameNoExt] = item;
    }

    _logger.info('[fetchMediaItemsMap] Loaded ${map.length} media items for dataset $datasetId');
    return map;
  }

  static Future<Map<String, dynamic>> getImageMetadata(String path) async {
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      // throw Exception("Unable to decode image: $path");
      print("Warning: Unable to decode image: $path");
      return {'width': 0, 'height': 0};
    }

    return {
      'width': decoded.width,
      'height': decoded.height,
    };
  }

  static Future<Map<String, dynamic>> getVideoMetadata(String path) async {
    return {
      'width': 0,
      'height': 0,
      'duration': 0.0,
      'fps': 0.0,
    };
  }
}
