import 'dart:io';
import 'package:logging/logging.dart';

import '../models/project.dart';
import '../data/project_database.dart';
import '../data/dataset_database.dart';

final _log = Logger('ProjectUtils');

Future<void> deleteProjectSafe(
  Project project, {
  required bool deleteFromDisk,
}) async {
  final db = DatasetDatabase.instance;

  // 1. Get all datasets for the project
  final datasets = await db.fetchDatasetsForProject(project.id!);

  for (final dataset in datasets) {
    // 2. Get all media files
    final mediaItems = await db.fetchMediaForDataset(dataset.id);

    // 3. Optionally delete media files from disk
    if (deleteFromDisk) {
      for (final media in mediaItems) {
        if (media.filePath.isNotEmpty) {
          final file = File(media.filePath);
          try {
            if (await file.exists()) {
              await file.delete();
              _log.info('Deleted media file: ${file.path}');
            }
          } catch (e) {
            _log.warning('Failed to delete media file: ${file.path}, $e');
          }
        }
      }
    }

    // 4. Handle media folders
    final folderIds = await db.getFolderIdsForDataset(dataset.id);
    for (final folderId in folderIds) {
      final otherProjects = await db.getOtherProjectNamesUsingFolder(
        folderId: folderId,
        currentDatasetId: dataset.id,
      );


      if (otherProjects.isEmpty) {
        final folderPath = await db.getMediaFolderPath(folderId);
        await db.deleteMediaFolderLink(
          datasetId: dataset.id,
          folderId: folderId,
        );

        if (deleteFromDisk && folderPath != null) {
          final dir = Directory(folderPath);
          try {
            if (await dir.exists()) {
              await dir.delete(recursive: true);
              _log.info('Deleted media folder: ${dir.path}');
            }
          } catch (e) {
            _log.warning('Failed to delete folder ${dir.path}: $e');
          }
        }
      } else {
        _log.warning(
          'Folder ID $folderId is used in other projects: ${otherProjects.join(', ')}. Skipped.',
        );
      }
    }
  }

  // 5. Let DatasetDatabase handle deletion from DB
  await db.deleteDatasetsForProject(projectId: project.id!);

  // 6. Delete the project
  await ProjectDatabase.instance.deleteProject(project.id!);

  // 7. Delete custom project icon if applicable
  if (deleteFromDisk &&
      project.icon.isNotEmpty &&
      !project.icon.contains('default_project_image')) {
    final file = File(project.icon);
    try {
      if (await file.exists()) {
        await file.delete();
        _log.info('Deleted project icon: ${file.path}');
      }
    } catch (e) {
      _log.warning('Failed to delete project icon: ${file.path}, $e');
    }
  }

  _log.info('Successfully deleted project "${project.name}" (ID: ${project.id})');
}
