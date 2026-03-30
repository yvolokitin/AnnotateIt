import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

Future<String> getAppDatabaseDirectory() async {
  final dbPath = await getDatabasesPath();
  return path.join(dbPath, 'AnnotateIt');
}

Future<void> ensureDirectoryExists(String dirPath) async {
  // No-op on web — sqflite handles virtual FS internally
}
