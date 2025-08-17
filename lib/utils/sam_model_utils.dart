import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SamModelUtils {
  // Keys used around the app
  static const String keyMobile = 'mobile';
  static const String keySam2BasePlus = 'sam2_hiera_base_plus';
  static const String keySam2Large = 'sam2_hiera_large';

  // Minimum valid sizes to avoid counting tiny/HTML files as downloaded
  static int _minValidBytes(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.onnx')) return 5 * 1024 * 1024; // ≥ 5 MB for model binaries
    if (p.endsWith('.yaml') || p.endsWith('.yml')) return 20; // small YAML is fine
    return 100; // default small threshold for any other file
  }
  
  /// Returns true if the specified SAM model (by key) is downloaded to the
  /// application documents directory using the ModelCard download convention.
  ///
  /// Mobile is always considered available (built-in), returns true.
  static Future<bool> isDownloaded(String key) async {
    if (key == keyMobile) return true;

    try {
      final dir = await getApplicationDocumentsDirectory();

      // Folder names are based on ModelCard.id (from models_page.dart)
      // Base+: folder id is 'sam2_hiera_base' (files named ...base_plus.*)
      // Large: folder id is 'sam2_hiera_large'
      String folderName;
      List<String> expectedFiles;

      if (key == keySam2BasePlus || key == 'sam2_hiera_base') {
        folderName = 'sam2_hiera_base';
        expectedFiles = const [
          'sam2_hiera_base_plus.encoder.onnx',
          'sam2_hiera_base_plus.decoder.onnx',
          'config.yaml',
        ];
      } else if (key == keySam2Large) {
        folderName = 'sam2_hiera_large';
        expectedFiles = const [
          'sam2_hiera_large.encoder.onnx',
          'sam2_hiera_large.decoder.onnx',
          'config.yaml',
        ];
      } else {
        // Unknown key
        return false;
      }

      final basePath = '${dir.path}/AnnotateIt/models/$folderName';
      final baseDir = Directory(basePath);
      if (!baseDir.existsSync()) return false;

      for (final name in expectedFiles) {
        final f = File('$basePath/$name');
        if (!f.existsSync()) return false;
        if (f.lengthSync() < _minValidBytes(f.path)) return false;
      }
      return true;
    } catch (_) {
      // On web or any failure, treat as not downloaded
      return false;
    }
  }

  /// Returns the list of available SAM model keys including mobile (always).
  static Future<List<String>> availableKeysWithMobile() async {
    final result = <String>[keyMobile];
    if (await isDownloaded(keySam2Large)) {
      result.add(keySam2Large);
    }
    if (await isDownloaded(keySam2BasePlus)) {
      result.add(keySam2BasePlus);
    }
    return result;
  }
}
