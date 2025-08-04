import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart';

import '../models/project.dart';
import '../data/project_database.dart';
import '../data/dataset_database.dart';

final _log = Logger('ProjectUtils');

// Progress callback function type
typedef ProgressCallback = void Function(String step, double progress);
typedef ErrorCallback = void Function(String error);

// Helper function to delete file with existence check
Future<void> _deleteFileWithCheck(File file) async {
  if (await file.exists()) {
    await file.delete();
  }
}

// Helper function to delete directory with timeout
Future<void> _deleteDirectoryWithTimeout(Directory dir, {Duration timeout = const Duration(seconds: 30)}) async {
  if (await dir.exists()) {
    await Future.any([
      dir.delete(recursive: true),
      Future.delayed(timeout, () => throw TimeoutException('Directory deletion timeout', timeout)),
    ]);
  }
}

Future<void> deleteProjectSafe(
  Project project, {
  required bool deleteFromDisk,
  ProgressCallback? onProgress,
  ErrorCallback? onError,
}) async {
  try {
    final db = DatasetDatabase.instance;
    
    onProgress?.call('Preparing project deletion...', 0.0);

    // 1. Get all datasets for the project
    final datasets = await db.fetchDatasetsForProject(project.id!);
    onProgress?.call('Found ${datasets.length} datasets to process', 0.1);

    int totalSteps = datasets.length * 2 + 3; // datasets + folders + db cleanup + project deletion + icon
    int currentStep = 1;

    for (int i = 0; i < datasets.length; i++) {
      final dataset = datasets[i];
      onProgress?.call('Processing dataset ${i + 1}/${datasets.length}...', currentStep / totalSteps);
      
      // 2. Get all media files
      final mediaItems = await db.fetchMediaForDataset(dataset.id);
      onProgress?.call('Found ${mediaItems.length} media files in dataset ${i + 1}', currentStep / totalSteps);

      // 3. Optionally delete media files from disk
      if (deleteFromDisk && mediaItems.isNotEmpty) {
        onProgress?.call('Deleting ${mediaItems.length} media files...', currentStep / totalSteps);
        
        for (int j = 0; j < mediaItems.length; j++) {
          final media = mediaItems[j];
          if (media.filePath.isNotEmpty) {
            final file = File(media.filePath);
            try {
              // Add timeout for file operations
              await Future.any([
                _deleteFileWithCheck(file),
                Future.delayed(const Duration(seconds: 10), () => throw TimeoutException('File deletion timeout', const Duration(seconds: 10))),
              ]);
              _log.info('Deleted media file: ${file.path}');
            } catch (e) {
              final errorMsg = 'Failed to delete media file: ${file.path}, $e';
              _log.warning(errorMsg);
              onError?.call(errorMsg);
              // Continue with other files instead of failing completely
            }
          }
          
          // Update progress for individual files if there are many
          if (mediaItems.length > 10 && j % 5 == 0) {
            onProgress?.call('Deleting media files... (${j + 1}/${mediaItems.length})', currentStep / totalSteps);
          }
        }
      }
      currentStep++;

      // 4. Handle media folders for this dataset
      onProgress?.call('Processing folders for dataset ${i + 1}...', currentStep / totalSteps);
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
              onProgress?.call('Deleting folder: ${dir.path}', currentStep / totalSteps);
              await _deleteDirectoryWithTimeout(dir);
              _log.info('Deleted media folder: ${dir.path}');
            } catch (e) {
              final errorMsg = 'Failed to delete folder ${dir.path}: $e';
              _log.warning(errorMsg);
              onError?.call(errorMsg);
              // Continue with other folders instead of failing completely
            }
          }
        } else {
          _log.warning(
            'Folder ID $folderId is used in other projects: ${otherProjects.join(', ')}. Skipped.',
          );
        }
      }
      currentStep++;
    }

    // 5. Let DatasetDatabase handle deletion from DB
    onProgress?.call('Cleaning up database records...', currentStep / totalSteps);
    await db.deleteDatasetsForProject(projectId: project.id!);
    currentStep++;

    // 6. Delete the project
    onProgress?.call('Deleting project record...', currentStep / totalSteps);
    await ProjectDatabase.instance.deleteProject(project.id!);
    currentStep++;

    // 7. Delete custom project icon if applicable
    if (deleteFromDisk &&
        project.icon.isNotEmpty &&
        !project.icon.contains('default_project_image')) {
      onProgress?.call('Deleting project icon...', currentStep / totalSteps);
      final file = File(project.icon);
      try {
        await Future.any([
          _deleteFileWithCheck(file),
          Future.delayed(const Duration(seconds: 5), () => throw TimeoutException('Icon deletion timeout', const Duration(seconds: 5))),
        ]);
        _log.info('Deleted project icon: ${file.path}');
      } catch (e) {
        final errorMsg = 'Failed to delete project icon: ${file.path}, $e';
        _log.warning(errorMsg);
        onError?.call(errorMsg);
        // Don't fail the entire operation for icon deletion
      }
    }

    onProgress?.call('Project deletion completed successfully!', 1.0);
    _log.info('Successfully deleted project "${project.name}" (ID: ${project.id})');
    
  } catch (e) {
    final errorMsg = 'Critical error during project deletion: $e';
    _log.severe(errorMsg);
    onError?.call(errorMsg);
    onProgress?.call('Project deletion failed!', 1.0);
    rethrow; // Re-throw to let the UI handle the error
  }
}
