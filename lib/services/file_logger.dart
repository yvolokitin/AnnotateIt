import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';

class FileLogger {
  static FileLogger? _instance;
  static FileLogger get instance => _instance ??= FileLogger._();
  
  FileLogger._();
  
  File? _logFile;
  String? _logFilePath;
  bool _isInitialized = false;
  
  /// Initialize the file logger and return the log file path
  Future<String?> initialize() async {
    try {
      // Get the Documents directory (guaranteed user access on Windows)
      Directory? documentsDir;
      
      if (Platform.isWindows) {
        documentsDir = await getApplicationDocumentsDirectory();
      } else {
        // Fallback for other platforms
        documentsDir = await getApplicationDocumentsDirectory();
      }
      
      if (documentsDir == null) {
        print('[FileLogger] Could not get documents directory');
        return null;
      }
      
      // Create AnnotateIt folder in Documents if it doesn't exist
      final appDir = Directory(path.join(documentsDir.path, 'AnnotateIt'));
      if (!await appDir.exists()) {
        await appDir.create(recursive: true);
      }
      
      // Create log file path
      _logFilePath = path.join(appDir.path, 'log.txt');
      _logFile = File(_logFilePath!);
      
      // Create log file if it doesn't exist
      if (!await _logFile!.exists()) {
        await _logFile!.create();
      }
      
      // Write initial log entry
      await _writeToFile('[${DateTime.now()}] AnnotateIt logging started\n');
      
      _isInitialized = true;
      print('[FileLogger] Initialized successfully. Log file: $_logFilePath');
      
      return _logFilePath;
    } catch (e) {
      print('[FileLogger] Failed to initialize: $e');
      return null;
    }
  }
  
  /// Write a log record to the file
  Future<void> writeLogRecord(LogRecord record) async {
    if (!_isInitialized || _logFile == null) {
      return;
    }
    
    try {
      final timestamp = record.time.toIso8601String();
      final level = record.level.name;
      final logger = record.loggerName;
      final message = record.message;
      
      String logLine = '[$timestamp] $level: $logger: $message\n';
      
      // Add error information if present
      if (record.error != null) {
        logLine += '  Error: ${record.error}\n';
      }
      
      // Add stack trace if present
      if (record.stackTrace != null) {
        logLine += '  StackTrace: ${record.stackTrace}\n';
      }
      
      await _writeToFile(logLine);
    } catch (e) {
      // Silently fail to avoid recursive logging issues
      print('[FileLogger] Failed to write log: $e');
    }
  }
  
  /// Write raw text to the log file
  Future<void> _writeToFile(String content) async {
    try {
      await _logFile!.writeAsString(content, mode: FileMode.append);
    } catch (e) {
      print('[FileLogger] Failed to write to file: $e');
    }
  }
  
  /// Get the current log file path
  String? get logFilePath => _logFilePath;
  
  /// Check if the logger is initialized
  bool get isInitialized => _isInitialized;
  
  /// Open the log file location in file explorer (Windows only)
  Future<void> openLogFileLocation() async {
    if (_logFilePath == null || !Platform.isWindows) {
      return;
    }
    
    try {
      final directory = path.dirname(_logFilePath!);
      await Process.run('explorer', [directory]);
    } catch (e) {
      print('[FileLogger] Failed to open log file location: $e');
    }
  }
  
  /// Get log file size in bytes
  Future<int> getLogFileSize() async {
    if (_logFile == null || !await _logFile!.exists()) {
      return 0;
    }
    
    try {
      final stat = await _logFile!.stat();
      return stat.size;
    } catch (e) {
      return 0;
    }
  }
  
  /// Clear the log file
  Future<void> clearLogFile() async {
    if (_logFile == null) {
      return;
    }
    
    try {
      await _logFile!.writeAsString('');
      await _writeToFile('[${DateTime.now()}] Log file cleared\n');
    } catch (e) {
      print('[FileLogger] Failed to clear log file: $e');
    }
  }
}