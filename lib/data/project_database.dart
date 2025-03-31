import 'dart:math';
import 'package:uuid/uuid.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/project.dart';
import '../models/dataset.dart';

import 'dataset_database.dart';

class ProjectDatabase {
  static final ProjectDatabase instance = ProjectDatabase._init();
  static Database? _database;

  ProjectDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDB('projects.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createProjectDBTables);
  }

  Future<void> _createProjectDBTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        creationDate TEXT NOT NULL,
        lastUpdated TEXT NOT NULL,
        labels TEXT NOT NULL,
        labelColors TEXT NOT NULL,
        defaultDatasetId TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE datasets (
        id TEXT PRIMARY KEY,
        projectId INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (projectId) REFERENCES projects(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE media_items (
        id TEXT PRIMARY KEY,
        datasetId TEXT,
        filePath TEXT,
        type TEXT,
        uploadDate TEXT,
        owner TEXT,
        lastAnnotator TEXT,
        lastAnnotatedDate TEXT,
        numberOfFrames INTEGER,
        FOREIGN KEY(datasetId) REFERENCES datasets(id) ON DELETE CASCADE
      );
    ''');
  }

  // TBD: Probably should be removed
  Future<int> insertProject(Project project) async {
    final db = await database;
    return await db.insert('projects', {
      'name': project.name,
      'type': project.type,
      'icon': project.icon,
      'creationDate': project.creationDate.toIso8601String(),
      
      // When a project is created, lastUpdated is set to creationDate
      'lastUpdated': project.creationDate.toIso8601String(),
      'labels': project.labels.join(','),
      'labelColors': project.labelColors.join(','),
    });
  }

  Future<int> updateProjectName(Project project) async {
    final db = await database;

    // Fetch current project name from database
    List<Map<String, dynamic>> result = await db.query(
      'projects',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [project.id],
    );

    if (result.isNotEmpty) {
      String currentName = result.first['name'];
      // If the name has not changed, do nothing and return 0 (no update)
      if (currentName == project.name) {
        print("No changes detected, skipping update");
        return 0; // No update performed
      }
    }

    // If name changed, update name + lastUpdated timestamp
    return await db.update(
      'projects',
      {
        'name': project.name,
        // Update project lastUpdated column with current time
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  Future<Dataset> createDatasetForProject({required int projectId, String name = 'New Dataset', String description = '', bool isDefault = false,}) async {
    final db = await database;

    // Check if a default dataset already exists
    if (isDefault) {
      final List<Map<String, dynamic>> existing = await db.query(
        'projects',
        where: 'id = ? AND defaultDatasetId IS NOT NULL',
        whereArgs: [projectId],
      );

      if (existing.isNotEmpty) {
        throw Exception('Default dataset already exists for this project.');
      }
    }

    // Create dataset
    final dataset = Dataset(
      id: uuid.v4(),
      projectId: projectId,
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );

    await db.insert('datasets', dataset.toMap());

    // If it's a default dataset, update the project record
    if (isDefault) {
      await db.update(
        'projects',
        {
          'defaultDatasetId': dataset.id,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [projectId],
      );

    } else { // else update only lastUpdated timestamp
      await db.update(
        'projects',
        {
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [projectId],
      );
    }

    return dataset;
  }

  Future<void> updateProjectlastUpdated(int projectId) async {
    final db = await database;
    final currentTime = DateTime.now().toIso8601String();

    await db.update(
      'projects',
      {'lastUpdated': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  Future<int> updateProjectIcon(int projectId, String new_project_icon) async {
    final db = await database;

    return await db.update(
      'projects',
      {
        'icon': new_project_icon,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  Future<int> updateProjectLabels(int projectId, List<String> newLabels, List<String> newColors) async {
    final db = await database;

    return await db.update(
      'projects',
      {
        'labels': newLabels.join(','),
        'labelColors': newColors.join(','),
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  Future<int> deleteProject(int id) async {
    final db = await database;
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Project>> fetchProjects() async {
    final db = await database;
    final result = await db.query('projects');
    return result.map((map) => Project.fromMap(map)).toList();
  }

  Future<void> closeDB() async {
    final db = await database;
    db.close();
  }

  // this is for Development purposes only, if i need to update certain tables in the database
Future<void> runManualSQLUpdate() async {
  final db = await ProjectDatabase.instance.database;

  // Check if media_items table exists
  final result = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name='media_items'"
  );

  final mediaTableExists = result.isNotEmpty;

  if (!mediaTableExists) {
    print("Creating 'media_items' table...");
    await db.execute('''
      CREATE TABLE media_items (
        id TEXT PRIMARY KEY,
        datasetId TEXT NOT NULL,
        filePath TEXT NOT NULL,
        type TEXT NOT NULL,
        uploadDate TEXT NOT NULL,
        owner TEXT NOT NULL,
        lastAnnotator TEXT,
        lastAnnotatedDate TEXT,
        numberOfFrames INTEGER,
        FOREIGN KEY (datasetId) REFERENCES datasets(id)
      )
    ''');
    print("✅ 'media_items' table created successfully.");
  } else {
    print("ℹ️ 'media_items' table already exists. Checking for missing columns...");

    // Add new columns if they don't exist
    final columnCheck = await db.rawQuery("PRAGMA table_info(media_items)");
    final existingColumns = columnCheck.map((row) => row['name']).toSet();

    Future<void> tryAddColumn(String name, String type) async {
      if (!existingColumns.contains(name)) {
        print("➕ Adding missing column '$name'...");
        await db.execute("ALTER TABLE media_items ADD COLUMN $name $type");
      }
    }

    await tryAddColumn('uploadDate', 'TEXT');
    await tryAddColumn('owner', 'TEXT');
    await tryAddColumn('lastAnnotator', 'TEXT');
    await tryAddColumn('lastAnnotatedDate', 'TEXT');
    await tryAddColumn('numberOfFrames', 'INTEGER');

    print("✅ Column structure ensured.");

    // Set default values for old rows
    print("🔄 Updating old media_items entries with default values...");
    await db.execute('''
      UPDATE media_items SET
        uploadDate = COALESCE(uploadDate, datetime('now')),
        owner = COALESCE(owner, 'system')
    ''');

    print("✅ Existing media items updated with default values.");
  }
}

}
