class FileLogWriter {
  Future<void> write(String content) async {}
  Future<void> openLocation() async {}
  Future<int> getSize() async => 0;
  Future<void> clear() async {}
}

class FileLogResult {
  final String logFilePath;
  final FileLogWriter writer;
  FileLogResult(this.logFilePath, this.writer);
}

Future<FileLogResult?> initFileLoggerPlatform() async => null;
