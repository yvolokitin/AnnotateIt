import 'dart:typed_data';
import '../data/dataset_database.dart';

/// Web implementation: loads image bytes from SQLite BLOB.
Future<Uint8List?> loadMediaBytes(String filePath, {int? mediaItemId}) async {
  if (mediaItemId != null) {
    return DatasetDatabase.instance.getMediaItemImageData(mediaItemId);
  }
  return null;
}

/// On web, files don't exist on disk.
bool mediaFileExists(String filePath) => false;
