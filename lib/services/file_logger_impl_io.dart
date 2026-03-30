import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileLogWriter {
  final File _file;
  FileLogWriter(this._file);

  Future<void> write(String content) async {
    await _file.writeAsString(content, mode: FileMode.append);
  }

  Future<void> openLocation() async {
    if (!Platform.isWindows) return;
    try {
      final directory = path.dirname(_file.path);
      await Process.run('explorer', [directory]);
    } catch (_) {}
  }

  Future<int> getSize() async {
    if (!await _file.exists()) return 0;
    try {
      final stat = await _file.stat();
      return stat.size;
    } catch (_) {
      return 0;
    }
  }

  Future<void> clear() async {
    await _file.writeAsString('');
  }
}

class FileLogResult {
  final String logFilePath;
  final FileLogWriter writer;
  FileLogResult(this.logFilePath, this.writer);
}

Future<FileLogResult?> initFileLoggerPlatform() async {
  final documentsDir = await getApplicationDocumentsDirectory();
  final appDir = Directory(path.join(documentsDir.path, 'AnnotateIt'));
  if (!await appDir.exists()) {
    await appDir.create(recursive: true);
  }
  final logFilePath = path.join(appDir.path, 'log.txt');
  final logFile = File(logFilePath);
  if (!await logFile.exists()) {
    await logFile.create();
  }
  return FileLogResult(logFilePath, FileLogWriter(logFile));
}
