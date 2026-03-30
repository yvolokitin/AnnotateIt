import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

import 'file_logger_impl.dart';

class FileLogger {
  static FileLogger? _instance;
  static FileLogger get instance => _instance ??= FileLogger._();
  
  FileLogger._();
  
  FileLogWriter? _logFileWriter;
  String? _logFilePath;
  bool _isInitialized = false;
  
  /// Initialize the file logger and return the log file path
  Future<String?> initialize() async {
    if (kIsWeb) return null;
    try {
      final result = await initFileLoggerPlatform();
      if (result == null) return null;
      _logFilePath = result.logFilePath;
      _logFileWriter = result.writer;
      await _writeToFile('[${DateTime.now()}] AnnotateIt logging started\n');
      _isInitialized = true;
      if (kDebugMode) print('[FileLogger] Initialized successfully. Log file: $_logFilePath');
      return _logFilePath;
    } catch (e) {
      if (kDebugMode) print('[FileLogger] Failed to initialize: $e');
      return null;
    }
  }
  
  /// Write a log record to the file
  Future<void> writeLogRecord(LogRecord record) async {
    if (!_isInitialized || _logFileWriter == null) return;
    
    try {
      final timestamp = record.time.toIso8601String();
      final level = record.level.name;
      final logger = record.loggerName;
      final message = record.message;
      
      String logLine = '[$timestamp] $level: $logger: $message\n';
      if (record.error != null) logLine += '  Error: ${record.error}\n';
      if (record.stackTrace != null) logLine += '  StackTrace: ${record.stackTrace}\n';
      
      await _writeToFile(logLine);
    } catch (e) {
      if (kDebugMode) print('[FileLogger] Failed to write log: $e');
    }
  }
  
  Future<void> _writeToFile(String content) async {
    try {
      await _logFileWriter?.write(content);
    } catch (e) {
      if (kDebugMode) print('[FileLogger] Failed to write to file: $e');
    }
  }
  
  String? get logFilePath => _logFilePath;
  bool get isInitialized => _isInitialized;
  
  Future<void> openLogFileLocation() async {
    await _logFileWriter?.openLocation();
  }
  
  Future<int> getLogFileSize() async {
    return await _logFileWriter?.getSize() ?? 0;
  }
  
  Future<void> clearLogFile() async {
    try {
      await _logFileWriter?.clear();
      await _writeToFile('[${DateTime.now()}] Log file cleared\n');
    } catch (e) {
      if (kDebugMode) print('[FileLogger] Failed to clear log file: $e');
    }
  }
}