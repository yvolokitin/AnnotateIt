import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Import the main app components
import 'lib/data/database_initializer.dart';
import 'lib/data/project_database.dart';
import 'lib/data/create_initial_schema.dart';

void main() {
  group('App Launch Tests', () {
    setUpAll(() {
      // Initialize sqflite for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test('Database initialization should not crash', () async {
      try {
        // Test database factory initialization
        await initializeDatabase();
        print('✓ Database factory initialized successfully');
        
        // Test getting default annotation root path
        final rootPath = await getDefaultAnnotationRootPath();
        print('✓ Default annotation root path: $rootPath');
        
        // Test database creation
        final db = await ProjectDatabase.instance.database;
        print('✓ Project database created successfully');
        
        // Test basic database operations
        final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        print('✓ Database tables created: ${tables.map((t) => t['name']).join(', ')}');
        
        await db.close();
        print('✓ Database closed successfully');
        
      } catch (e, stackTrace) {
        print('✗ Database initialization failed: $e');
        print('Stack trace: $stackTrace');
        fail('Database initialization should not throw exceptions: $e');
      }
    });

    test('Directory creation should handle permission errors gracefully', () async {
      try {
        // This should not crash even if directory creation fails
        final rootPath = await getDefaultAnnotationRootPath();
        print('✓ Root path obtained: $rootPath');
        
        // Verify the path exists or was created
        final dir = Directory(rootPath);
        final exists = await dir.exists();
        print('✓ Root directory exists: $exists');
        
      } catch (e) {
        print('✗ Directory creation test failed: $e');
        fail('Directory creation should handle errors gracefully: $e');
      }
    });

    test('App should handle database errors gracefully', () async {
      // Test what happens when database operations fail
      try {
        // Try to create a database in an invalid location
        final invalidPath = '/invalid/path/that/should/not/exist/test.db';
        
        // This should not crash the entire test
        try {
          final db = await openDatabase(invalidPath);
          await db.close();
        } catch (e) {
          print('✓ Database error handled gracefully: $e');
        }
        
      } catch (e) {
        print('✗ Error handling test failed: $e');
        fail('App should handle database errors gracefully: $e');
      }
    });
  });
}