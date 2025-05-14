import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';

import '../session/user_session.dart';

import '../data/project_database.dart';
import '../data/dataset_database.dart';

import '../models/dataset_info.dart';
import '../models/project.dart';

class DatasetImportProjectCreation {
  static final Logger _logger = Logger('DatasetImportProjectCreation');

  /// Call this to create a project + default dataset in DB
  static Future<void> createProjectWithDataset(DatasetInfo datasetInfo) async {
    final currentUser = UserSession.instance.getUser();

    // Create new project
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
    if (defaultDatasetId != null) {
      print("Default Dataset ID: $defaultDatasetId");
    } else {
      print("No default dataset assigned for project $newProjectId");
    }

    await addMediaItemsToDataset(
      datasetPath: datasetInfo.datasetPath,
      datasetId: defaultDatasetId!,
      ownerId: currentUser.id ?? -1,
      onProgress: (current, total) {
        // i can call setState() here to update UI
        print("Imported $current of $total media files");
      },
    );

    // Simulate work for demo (remove in production)
    await Future.delayed(const Duration(seconds: 2));
  }

  static Future<void> addMediaItemsToDataset({
    required String datasetPath,
    required String datasetId,
    required int ownerId,
    required void Function(int current, int total) onProgress,
  }) async {
    final db = await DatasetDatabase.instance.database;

    // 1. Get all media files recursively
    final mediaFiles = <File>[];
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'bmp', 'gif', 'mp4', 'mov'];

    final dir = Directory(datasetPath);
    if (!await dir.exists()) {
      throw Exception("Dataset folder not found: $datasetPath");
    }

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase().replaceAll('.', '');
        if (allowedExtensions.contains(ext)) {
          mediaFiles.add(entity);
        }
      }
    }

    final total = mediaFiles.length;
    if (total == 0) return;

    // 2. Insert with progress
    int current = 0;

    for (final file in mediaFiles) {
      final ext = p.extension(file.path).toLowerCase().replaceAll('.', '');

      await DatasetDatabase.instance.insertMediaItem(
        datasetId,
        file.path,
        ext,
        ownerId: ownerId,
      );

      current++;
      if (current % 100 == 0 || current == total) {
        // Update every 100 files or last file
        onProgress(current, total);
      }
    }
  }
}
