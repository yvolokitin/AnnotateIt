import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import '../models/project.dart';
import '../models/dataset.dart';
import '../models/label.dart';

import 'create_initial_schema.dart';

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
    final returnPath = path.join(dbPath, fileName);
    return await openDatabase(returnPath, version: 1, onCreate: createInitialSchema);
  }

Future<Project> createProject(Project project) async {
  final db = await database;

  final String projectName = (project.name.trim().isEmpty)
    ? 'Project'
    : project.name.trim();

  final now = DateTime.now();

  return await db.transaction<Project>((txn) async {
    // Insert project without defaultDatasetId
    final projectId = await txn.insert('projects', {
      'name': projectName,
      'type': project.type,
      'icon': project.icon,
      'creationDate': now.toIso8601String(),
      'lastUpdated': now.toIso8601String(),
      'ownerId': project.ownerId,
    });

    // Create default dataset
    final dataset = Dataset(
      id: uuid.v4(),
      projectId: projectId,
      datasetOrder: 0,
      name: 'Dataset',
      description: 'Default dataset for $projectName',
      type: project.type,
      source: 'manual',
      format: 'custom',
      version: '1.0.0',
      mediaCount: 0,
      annotationCount: 0,
      defaultDataset: true,
      license: null,
      metadata: null,
      createdAt: now,
      updatedAt: now,
    );

    await txn.insert('datasets', dataset.toMap());

    // Update project with defaultDatasetId
    await txn.update(
      'projects',
      {
        'defaultDatasetId': dataset.id,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [projectId],
    );

    print('dataset.id ${dataset.id} for $projectName created');

    // Return a new complete Project object
    return project.copyWith(
      id: projectId,
      defaultDatasetId: dataset.id,
    );
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

  Future<int> updateProjectName(int projectId, String projectName) async {
    final db = await database;

    // Fetch current project name from database
    List<Map<String, dynamic>> result = await db.query(
      'projects',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [projectId],
    );

    if (result.isNotEmpty) {
      String currentName = result.first['name'];
      // If the name has not changed, do nothing and return 0 (no update)
      if (currentName == projectName) {
        _log.info('No changes detected for project "$projectName", skipping update.');
        return 0; // No update performed
      }
    }

    // If name changed, update name + lastUpdated timestamp
    return await db.update(
      'projects',
      {
        'name': projectName,
        // Update project lastUpdated column with current time
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [projectId],
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

  Future<Dataset> createDatasetForProject({
      required int projectId,
      required String projectType,
      String name = 'New Dataset',
      String description = '',
      bool isDefault = false
    }) async {
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

      final countResult = await db.rawQuery(
        'SELECT COUNT(*) FROM datasets WHERE projectId = ?',
        [projectId],
      );
      final nextOrder = Sqflite.firstIntValue(countResult) ?? 0;

      final now = DateTime.now();
      // Create dataset
      final dataset = Dataset(
        id: uuid.v4(),
        projectId: projectId,
        datasetOrder: nextOrder,
        name: name.trim().isEmpty ? 'Dataset' : name.trim(),
        description: description,
        type: projectType,
        source: 'manual',
        format: 'custom',
        version: '1.0.0',
        mediaCount: 0,
        annotationCount: 0,
        defaultDataset: isDefault,
        license: null,
        metadata: null,
        createdAt: now,
        updatedAt: now,
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

  Future<void> updateProjectTypeAndTimestamp({
    required int projectId,
    required String newType,
  }) async {
    final db = await database;
    await db.update(
      'projects',
      {
        'type': newType,
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

  Future<List<Project>> fetchProjectsWithLabels() async {
    final db = await database;
    final projectMaps = await db.query('projects');
    final projects = projectMaps.map((map) => Project.fromMap(map)).toList();

    final labelMaps = await db.query('labels');

    final labelsByProjectId = <int, List<Label>>{};
    for (final labelMap in labelMaps) {
      final label = Label.fromMap(labelMap);
      final projectId = labelMap['project_id'] as int;
      labelsByProjectId.putIfAbsent(projectId, () => []).add(label);
    }

    return projects.map((project) {
      final labels = labelsByProjectId[project.id] ?? [];
      return project.copyWith(labels: labels);
    }).toList();
  }

  Future<Project?> fetchProjectWithLabelsById(int projectId) async {
    final db = await database;
    final result = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [projectId],
    );

    if (result.isEmpty) return null;
    final project = Project.fromMap(result.first);
    final labelMaps = await db.query(
      'labels',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
    final labels = labelMaps.map((map) => Label.fromMap(map)).toList();

    return project.copyWith(labels: labels);
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
