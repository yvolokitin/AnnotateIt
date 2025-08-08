import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

/// Копирует asset в temp-файл и возвращает абсолютный путь (ORT требуется файл).
Future<String> ensureAssetFile(String assetPath, {String? filename}) async {
  final bytes = await rootBundle.load(assetPath);
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${filename ?? assetPath.split('/').last}');
  if (!await file.exists() || (await file.length()) != bytes.lengthInBytes) {
    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
  }
  return file.path;
}
