import 'dart:io';
import 'dart:typed_data';
import '../data/dataset_database.dart';

/// Native implementation: loads image bytes from filesystem.
Future<Uint8List?> loadMediaBytes(String filePath, {int? mediaItemId}) async {
  final file = File(filePath);
  if (await file.exists()) {
    return file.readAsBytes();
  }
  if (mediaItemId != null) {
    return DatasetDatabase.instance.getMediaItemImageData(mediaItemId);
  }
  return null;
}

/// Native: check if the file exists on disk.
bool mediaFileExists(String filePath) {
  return File(filePath).existsSync();
}
