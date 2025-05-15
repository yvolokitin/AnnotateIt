import 'dart:io';
import 'dart:math';

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
      await addLabelsToProject(
        projectId: newProjectId,
        labelNames: datasetInfo.labels,
      );
    } else {
      print("No labels detected in dataset. Skipping label import.");
    }

    final mediaItemsMap = await fetchMediaItemsMap(defaultDatasetId);

    final importer = DatasetAnnotationImporter(annotationDb: AnnotationDatabase.instance);
    final addedCount = await importer.addAnnotationsToProjectFromDataset(
      datasetPath: datasetInfo.datasetPath,
      format: datasetInfo.datasetFormat,
      mediaItemsMap: mediaItemsMap,
      projectId: newProjectId,
      annotatorId: currentUser.id ?? -1,
    );

    print('Added $addedCount annotations.');

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
      if (entity is Directory) {
        folderCount++;
      } else if (entity is File) {
        fileCount++;

        final ext = p.extension(entity.path).toLowerCase().replaceAll('.', '');
        if (allowedExtensions.contains(ext)) {
          mediaFiles.add(entity);

          if (firstImagePath == null && imageExtensions.contains(ext)) {
            firstImagePath = entity.path;
            print("🖼️ First image for thumbnail: $firstImagePath");
          }
        } else {
          print("ERROR: Skipped file (unsupported extension: .$ext): ${entity.path}");
        }
      } else {
        print("Warning: Unknown entity type: ${entity.path}");
      }
    }

    print("Scan complete: $folderCount folders, $fileCount files found.");
    print("Total media files to insert: ${mediaFiles.length}");

    final total = mediaFiles.length;
    if (total == 0) {
      throw Exception("No media files found. Nothing to insert.");
    }

    int current = 0;
    for (final file in mediaFiles) {
      final ext = p.extension(file.path).toLowerCase().replaceAll('.', '');
      await DatasetDatabase.instance.insertMediaItem(datasetId, file.path, ext, ownerId: ownerId);

      current++;
      if (current % 100 == 0 || current == total) {
        onProgress(current, total);
        print("Progress update: $current / $total files inserted");
      }
    }

    print("Finished inserting $total media files into dataset $datasetId");
    return firstImagePath;
  }

  static Future<void> addLabelsToProject({
    required int projectId,
    required List<String> labelNames,
  }) async {
    if (labelNames.isEmpty) {
      print("No labels to add.");
      return;
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

    final labels = labelNames.map((name) => Label(
      id: null,
      projectId: projectId,
      name: name.trim(),
      color: generateRandomColor(),
      description: null,
    )).toList();

    await LabelsDatabase.instance.updateProjectLabels(projectId, labels);
    print("Added ${labels.length} labels to project $projectId");
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
}
