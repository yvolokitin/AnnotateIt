import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/media_item.dart';
import '../models/annotation.dart';
import '../models/annotated_labeled_media.dart';

import '../data/dataset_database.dart';
import '../../data/annotation_database.dart';

Future<File?> generateThumbnailFromImage(File imageFile, String projectId) async {
  try {
    // read original image and decode
    final originalBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(originalBytes);
    if (originalImage == null) return null;

    // resize for thumbnail to use less space from original image
    final thumbnailImage = img.copyResize(originalImage, width: 460);
    final thumbnailBytes = img.encodeJpg(thumbnailImage);

    final directory = await getApplicationDocumentsDirectory();
    final thumbnailsDir = Directory(path.join(directory.path, 'thumbnails'));
    if (!thumbnailsDir.existsSync()) {
      thumbnailsDir.createSync(recursive: true);
    }

    // save thumbnail in the file system
    final thumbnailPath = path.join(thumbnailsDir.path, '$projectId.jpg');
    final thumbnailFile = File(thumbnailPath);
    await thumbnailFile.writeAsBytes(thumbnailBytes);

    print('Thumbnail created at: $thumbnailPath');
    return thumbnailFile;

  } catch (e) {
    print('Error when tried to create thumbnail: $e');
    return null;
  }
}

Future<void> duplicateMediaItem({
  required AnnotatedLabeledMedia original,
  required String datasetId,
  required bool withAnnotations,
}) async {
  final originalFile = File(original.mediaItem.filePath);
  final originalExt = path.extension(originalFile.path);

  // Ensure original file is readable and directory is writable
  if (!await originalFile.exists()) {
    throw FileSystemException("Original file does not exist", originalFile.path);
  }

  final parentDir = originalFile.parent;

  // Check if we can write to the directory
  final testFile = File(path.join(parentDir.path, '.write_test_${DateTime.now().millisecondsSinceEpoch}'));
  try {
    await testFile.writeAsString('test');
    await testFile.delete(); // cleanup
  } catch (e) {
    throw FileSystemException(
      "Cannot write to directory: ${parentDir.path}. On macOS, use user-selected folders or app-specific storage.",
      parentDir.path,
    );
  }

  // Generate a unique filename
  String newFileName;
  String newPath;
  File newFile;
  do {
    newFileName = '${DateTime.now().millisecondsSinceEpoch}${originalExt}';
    newPath = path.join(originalFile.parent.path, newFileName);
    newFile = File(newPath);
  } while (await newFile.exists());

  // Copy the file
  await originalFile.copy(newPath);

  // Insert new media item into the database
  final cleanedExt = originalExt.replaceFirst('.', '');
  await DatasetDatabase.instance.insertMediaItem(
    datasetId,
    newPath,
    cleanedExt,
    ownerId: original.mediaItem.ownerId ?? 0,
    numberOfFrames: original.mediaItem.numberOfFrames,
    width: original.mediaItem.width,
    height: original.mediaItem.height,
    duration: original.mediaItem.duration,
    fps: original.mediaItem.fps,
    source: 'duplicated',
  );

  // Fetch the newly inserted MediaItem to get its ID
  final allItems = await DatasetDatabase.instance.fetchMediaForDataset(datasetId);
  final newMediaItemRef = allItems.firstWhere((m) => m.filePath == newPath);
  final newMediaId = newMediaItemRef.id!;

  // Duplicate annotations if needed
  if (withAnnotations) {
    final now = DateTime.now();
    final newAnnotations = original.annotations.map((ann) => Annotation(
      id: null, // ensure SQLite generates a new ID
      mediaItemId: newMediaId,
      labelId: ann.labelId,
      annotationType: ann.annotationType,
      data: Map<String, dynamic>.from(ann.data),
      confidence: ann.confidence,
      annotatorId: ann.annotatorId,
      comment: ann.comment,
      status: ann.status,
      version: ann.version,
      createdAt: now,
      updatedAt: now,
    )).toList();

    await AnnotationDatabase.instance.insertAnnotationsBatch(newAnnotations);
  }
}

// await deleteMediaItem(mediaItem: item, deleteAnnotations: true, deleteFile: false);
/// Deletes the media item from database and (optionally) its annotations and file from disk.
///
/// - [mediaItem] — объект MediaItem, который нужно удалить.
/// - [deleteFile] — если true, удаляет сам файл с диска.
Future<void> deleteMediaItem({
  required MediaItem mediaItem,
  bool deleteFile = true,
}) async {
  try {
    await AnnotationDatabase.instance.deleteAnnotationsByMedia(mediaItem.id!);
    await DatasetDatabase.instance.deleteMediaItemWithAnnotations(mediaItem.id!);

    if (deleteFile) {
      final file = File(mediaItem.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    print('Media item ${mediaItem.id} deleted (file: $deleteFile)');
  } catch (e) {
    print('Error deleting media item: $e');
    rethrow;
  }
}
