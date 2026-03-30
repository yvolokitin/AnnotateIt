import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<String> getAppDatabaseDirectory() async {
  final supportDir = await getApplicationSupportDirectory();
  return path.join(supportDir.path, 'AnnotateIt');
}

Future<void> ensureDirectoryExists(String dirPath) async {
  final dir = Directory(dirPath);
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
}
