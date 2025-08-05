import 'dart:io';
import 'package:logging/logging.dart';
import 'lib/services/file_logger.dart';

void main() async {
  print('Testing file logging system...');
  
  // Initialize file logger
  String? logFilePath;
  try {
    logFilePath = await FileLogger.instance.initialize();
    print('FileLogger initialized. Log file: $logFilePath');
  } catch (e) {
    print('Failed to initialize FileLogger: $e');
    return;
  }
  
  // Setup logging (similar to main.dart)
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // Console output
    print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('StackTrace: ${record.stackTrace}');
    }
    
    // File output
    FileLogger.instance.writeLogRecord(record);
  });
  
  final log = Logger('test');
  
  // Test different log levels
  log.info('Testing INFO level logging');
  log.warning('Testing WARNING level logging');
  log.severe('Testing SEVERE level logging');
  
  // Test error logging
  try {
    throw Exception('Test exception for logging');
  } catch (e, stackTrace) {
    log.severe('Testing error logging with stack trace', e, stackTrace);
  }
  
  // Wait a bit for file operations to complete
  await Future.delayed(Duration(milliseconds: 500));
  
  // Check if log file exists and has content
  if (logFilePath != null) {
    final logFile = File(logFilePath);
    if (await logFile.exists()) {
      final content = await logFile.readAsString();
      print('\n--- Log file content ---');
      print(content);
      print('--- End of log file ---\n');
      
      final size = await FileLogger.instance.getLogFileSize();
      print('Log file size: $size bytes');
    } else {
      print('Log file does not exist!');
    }
  }
  
  print('Test completed.');
}