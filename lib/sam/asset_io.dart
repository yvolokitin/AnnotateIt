import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

/// Copies an asset to a writable temp file and returns its absolute path.
/// (ONNX Runtime needs a real file path, not an asset key.)
Future<String> ensureAssetFile(String assetPath, {String? filename}) async {
  final bytes = await rootBundle.load(assetPath);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${filename ?? assetPath.split('/').last}');
  if (!await file.exists() || (await file.length()) != bytes.lengthInBytes) {
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
  }
  return file.path;
}
