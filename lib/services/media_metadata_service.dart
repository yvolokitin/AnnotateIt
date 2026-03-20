import 'dart:io';

import 'package:image/image.dart' as img;

class MediaMetadataService {
  static final MediaMetadataService instance = MediaMetadataService._();

  MediaMetadataService._();

  Future<Map<String, dynamic>> getImageMetadata(String path) async {
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return {'width': 0, 'height': 0};
    }

    return {'width': decoded.width, 'height': decoded.height};
  }

  Future<Map<String, dynamic>> getVideoMetadata(String path) async {
    // Placeholder: no cross-platform ffprobe integration yet.
    return {'width': 0, 'height': 0, 'duration': 0.0, 'fps': 0.0};
  }
}
