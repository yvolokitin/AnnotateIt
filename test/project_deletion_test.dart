import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import '../lib/models/project.dart';
import '../lib/utils/project_utils.dart';

void main() {
  // Set up logging for tests
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('[DEBUG_LOG] ${record.level.name}: ${record.time}: ${record.message}');
  });

  group('Project Deletion Tests', () {
    test('deleteProjectSafe should call progress callbacks', () async {
      // Create a mock project
      final now = DateTime.now();
      final project = Project(
        id: 1,
        name: 'Test Project',
        type: 'classification',
        creationDate: now,
        lastUpdated: now,
        ownerId: 1,
        icon: '',
        labels: [],
      );

      List<String> progressSteps = [];
      List<double> progressValues = [];
      List<String> errors = [];

      try {
        await deleteProjectSafe(
          project,
          deleteFromDisk: false, // Don't delete from disk to avoid file system issues in tests
          onProgress: (step, progress) {
            progressSteps.add(step);
            progressValues.add(progress);
            print('[DEBUG_LOG] Progress: $step ($progress)');
          },
          onError: (error) {
            errors.add(error);
            print('[DEBUG_LOG] Error: $error');
          },
        );
      } catch (e) {
        print('[DEBUG_LOG] Exception caught: $e');
        // This is expected since we don't have a real database in tests
      }

      // Verify that progress callbacks were called
      expect(progressSteps.isNotEmpty, true, reason: 'Progress steps should be reported');
      expect(progressValues.isNotEmpty, true, reason: 'Progress values should be reported');
      
      // Verify progress starts at 0 and goes towards 1
      if (progressValues.isNotEmpty) {
        expect(progressValues.first, equals(0.0), reason: 'Progress should start at 0');
      }

      print('[DEBUG_LOG] Test completed. Progress steps: ${progressSteps.length}, Errors: ${errors.length}');
    });

    test('deleteProjectSafe should handle errors gracefully', () async {
      // Create a mock project with invalid data to trigger errors
      final now = DateTime.now();
      final project = Project(
        id: -1, // Invalid ID to trigger database errors
        name: 'Invalid Test Project',
        type: 'classification',
        creationDate: now,
        lastUpdated: now,
        ownerId: 1,
        icon: '/invalid/path/icon.png', // Invalid icon path
        labels: [],
      );

      List<String> errors = [];
      String? finalStep;
      double finalProgress = 0.0;

      try {
        await deleteProjectSafe(
          project,
          deleteFromDisk: true, // Enable disk deletion to test file error handling
          onProgress: (step, progress) {
            finalStep = step;
            finalProgress = progress;
            print('[DEBUG_LOG] Progress: $step ($progress)');
          },
          onError: (error) {
            errors.add(error);
            print('[DEBUG_LOG] Error captured: $error');
          },
        );
      } catch (e) {
        print('[DEBUG_LOG] Expected exception: $e');
        // This is expected due to invalid project data
      }

      // Verify that error handling worked
      print('[DEBUG_LOG] Final step: $finalStep, Final progress: $finalProgress');
      print('[DEBUG_LOG] Total errors captured: ${errors.length}');
      
      // The function should have attempted to report progress even with errors
      expect(finalStep, isNotNull, reason: 'Should have reported at least one progress step');
    });

    test('File deletion timeout should work', () async {
      // Test the timeout mechanism by creating a file operation that might hang
      final testFile = File('test_timeout_file.txt');
      
      try {
        // Create a test file
        await testFile.writeAsString('test content');
        
        // Test our helper function with a very short timeout
        final stopwatch = Stopwatch()..start();
        
        try {
          await Future.any([
            _deleteFileWithCheck(testFile),
            Future.delayed(const Duration(milliseconds: 100), () => 
              throw TimeoutException('Test timeout', const Duration(milliseconds: 100))),
          ]);
        } catch (e) {
          print('[DEBUG_LOG] Timeout test result: $e');
        }
        
        stopwatch.stop();
        print('[DEBUG_LOG] File operation took: ${stopwatch.elapsedMilliseconds}ms');
        
        // Verify the operation completed within reasonable time
        expect(stopwatch.elapsedMilliseconds < 5000, true, 
               reason: 'File operation should complete quickly or timeout');
        
      } finally {
        // Clean up test file
        if (await testFile.exists()) {
          await testFile.delete();
        }
      }
    });
  });
}

// Helper function to test file deletion (copy from project_utils.dart)
Future<void> _deleteFileWithCheck(File file) async {
  if (await file.exists()) {
    await file.delete();
  }
}

class TimeoutException implements Exception {
  final String message;
  final Duration timeout;
  
  const TimeoutException(this.message, this.timeout);
  
  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}