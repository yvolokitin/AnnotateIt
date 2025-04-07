// import 'dart:math';
// import 'package:uuid/uuid.dart';

import 'package:sqflite/sqflite.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

import '../models/project.dart';
import '../models/dataset.dart';

 // import 'dataset_database.dart';

class ProjectDatabase {
  static final ProjectDatabase instance = ProjectDatabase._init();
  static Database? _database;

  ProjectDatabase._init();

  final _log = Logger('ProjectDatabase');

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
        defaultDatasetId TEXT,
        ownerId INTEGER NOT NULL,
        FOREIGN KEY (ownerId) REFERENCES users (id) ON DELETE CASCADE
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

  Future<int> createProject(Project project) async {
    final db = await database;

    // Fallback to 'Project' if name is null or empty
    final String projectName = (project.name.trim().isEmpty) ? 'Project' : project.name.trim();

    // Step 1: Insert project without defaultDatasetId
    int projectId = await db.insert('projects', {
      'name': projectName,
      'type': project.type,
      'icon': project.icon,
      'creationDate': project.creationDate.toIso8601String(),
      'lastUpdated': project.creationDate.toIso8601String(),
      'labels': project.labels.join(','), // or jsonEncode()
      'labelColors': project.labelColors.join(','), // or jsonEncode()
      'ownerId': project.ownerId,
    });

    // Step 2: Create the default dataset
    final dataset = Dataset(
      id: uuid.v4(),
      projectId: projectId,
      name: 'Default Dataset',
      description: 'Default dataset for ${project.name}',
      createdAt: DateTime.now(),
    );

    await db.insert('datasets', dataset.toMap());

    // Step 3: Update the project with the defaultDatasetId
    await db.update(
      'projects',
      {
        'defaultDatasetId': dataset.id,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [projectId],
    );

    return projectId;
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
        _log.info('No changes detected for project "${project.name}", skipping update.');
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

  Future<int> deleteProject(int projectId) async {
    final db = await database;

    return await db.transaction((txn) async {
      // Step 1: Get all datasets linked to the project
      final datasets = await txn.query(
        'datasets',
        where: 'projectId = ?',
        whereArgs: [projectId],
      );

      for (var dataset in datasets) {
        final datasetId = dataset['id'] as String;

        // Step 2: Delete media items linked to the dataset
        await txn.delete(
          'media_items',
          where: 'datasetId = ?',
          whereArgs: [datasetId],
        );
      }

      // Step 3: Delete datasets linked to the project
      await txn.delete(
        'datasets',
        where: 'projectId = ?',
        whereArgs: [projectId],
      );

      // Step 4: Delete the project itself
      return await txn.delete(
        'projects',
        where: 'id = ?',
        whereArgs: [projectId],
      );
    });
  }

  Future<List<Project>> fetchProjects() async {
    final db = await database;
    final result = await db.query('projects');
    return result.map((map) => Project.fromMap(map)).toList();
  }

  Future<List<Project>> fetchProjectsbyUser({required int userId}) async {
    final db = await database;
    final result = await db.query(
      'projects',
      where: 'ownerId = ?',
      whereArgs: [userId],
    );
    return result.map((map) => Project.fromMap(map)).toList();
  }

  Future<void> closeDB() async {
    final db = await database;
    db.close();
  }
}
