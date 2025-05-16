import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:logging/logging.dart';

import 'package:uuid/uuid.dart';
import 'package:path/path.dart';

import '../models/project.dart';
import '../models/dataset.dart';

const String kDatabaseFileName = 'projects.db';

class ProjectDatabase {
  static final ProjectDatabase instance = ProjectDatabase._init();
  static Database? _database;

  ProjectDatabase._init();

  final _log = Logger('ProjectDatabase');
  final uuid = Uuid();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDB(kDatabaseFileName);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createProjectDBTables);
  }

  Future<void> _createProjectDBTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL,
        iconPath TEXT,
        datasetFolder TEXT,
        thumbnailFolder TEXT,
        themeMode TEXT NOT NULL,
        language TEXT NOT NULL,
        autoSave INTEGER NOT NULL,
        showTips INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    final rootPath = await _getDefaultAnnotationRootPath();
    final datasetPath = '$rootPath/datasets';
    final thumbnailPath = '$rootPath/thumbnails';

    // Create folders if they don't exist
    await Directory(datasetPath).create(recursive: true);
    await Directory(thumbnailPath).create(recursive: true);
    
    _log.info('_createProjectDBTables:: Created $datasetPath and $thumbnailPath folders');
    
    final now = DateTime.now().toIso8601String();
    await db.insert('users', {
      'firstName': 'Captain',
      'lastName': 'Annotator',
      'email': 'captain@labelship.local',
      'iconPath': '',
      'datasetFolder': datasetPath,
      'thumbnailFolder': thumbnailPath,
      'themeMode': 'dark',
      'language': 'en',
      'autoSave': 1,
      'showTips': 1,
      'createdAt': now,
      'updatedAt': now,
    });

    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        creationDate TEXT NOT NULL,
        lastUpdated TEXT NOT NULL,
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
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE media_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE,
        datasetId TEXT,
        filePath TEXT,
        extension TEXT,
        type TEXT,
        uploadDate TEXT,
        owner_id INTEGER NOT NULL,
        lastAnnotator TEXT,
        lastAnnotatedDate TEXT,
        numberOfFrames INTEGER,
        FOREIGN KEY(datasetId) REFERENCES datasets(id) ON DELETE CASCADE,
        FOREIGN KEY(owner_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    // Labels table (per project)
    await db.execute('''
      CREATE TABLE labels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        color TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE
      );
    ''');
    
    // Annotations table
    // annotation_type TEXT NOT NULL,        -- "bbox", "classification", "segmentation", "keypoints", etc.
    // data TEXT NOT NULL,                   -- JSON-string with coordinates, masks, or key poinrts etc.
    await db.execute('''
      CREATE TABLE annotations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        media_item_id INTEGER NOT NULL,
        label_id INTEGER,
        annotation_type TEXT NOT NULL,
        data TEXT NOT NULL,
        confidence REAL,
        annotator_id INTEGER,
        comment TEXT,
        status TEXT,
        version INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(media_item_id) REFERENCES media_items(id) ON DELETE CASCADE,
        FOREIGN KEY(label_id) REFERENCES labels(id) ON DELETE CASCADE,
        FOREIGN KEY(annotator_id) REFERENCES users(id) ON DELETE SET NULL
      );
    ''');
  }

  Future<int> createProject(Project project) async {
    final db = await database;

    // Fallback name if empty
    final String projectName = (project.name.trim().isEmpty)
      ? 'Project'
      : project.name.trim();

    final now = DateTime.now().toIso8601String();

    // Start a DB transaction
    return await db.transaction<int>((txn) async {
      // Step 1: Insert project without defaultDatasetId
      final projectId = await txn.insert('projects', {
        'name': projectName,
        'type': project.type,
        'icon': project.icon,
        'creationDate': now,
        'lastUpdated': now,
        'ownerId': project.ownerId,
      });

      // Step 2: Create the default dataset
      final dataset = Dataset(
        id: uuid.v4(),
        projectId: projectId,
        name: 'Default Dataset',
        description: 'Default dataset for $projectName',
        createdAt: DateTime.now(),
      );

      await txn.insert('datasets', dataset.toMap());

      // Step 3: Update the project with the defaultDatasetId
      await txn.update(
        'projects',
        {
          'defaultDatasetId': dataset.id,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [projectId],
      );

      return projectId;
    });
  }

  Future<String?> getDefaultDatasetId(int projectId) async {
    final db = await database;

    final result = await db.query(
      'projects',
      columns: ['defaultDatasetId'],
      where: 'id = ?',
      whereArgs: [projectId],
    );

    if (result.isNotEmpty) {
      return result.first['defaultDatasetId'] as String?;
    }

    // project not found or no default dataset set
    return null;
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

  Future<void> updateDefaultDataset({required int projectId, required String datasetId, }) async {
    final db = await database;

    await db.update(
      'projects',
      {
        'defaultDatasetId': datasetId,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [projectId],
    );

    _log.info('Set dataset $datasetId as default for project $projectId');
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

  Future<void> updateProjectLastUpdated(int projectId) async {
    final db = await database;

    await db.update(
      'projects',
      {'lastUpdated': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  Future<int> updateProjectIcon(int projectId, String newProjectIcon) async {
    final db = await database;

    return await db.update(
      'projects',
      {
        'icon': newProjectIcon,
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

  Future<Project?> fetchProjectById(int projectId) async {
    final db = await database;

    final result = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [projectId],
    );

    if (result.isNotEmpty) {
      return Project.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<String> _getDefaultAnnotationRootPath() async {
    if (Platform.isWindows) {
      return 'C:\\Users\\${Platform.environment['USERNAME']}\\Documents\\AnnotateItApp';
    } else if (Platform.isLinux || Platform.isMacOS) {
      return '/home/${Platform.environment['USER']}/AnnotateItApp';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return '/storage/emulated/0/AnnotateItApp';
    } else {
      return '/AnnotateItApp';
    }
  }

  Future<int> getProjectCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM projects');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getLabelCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM labels');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getMediaCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM media_items');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getAnnotationCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM annotations');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
