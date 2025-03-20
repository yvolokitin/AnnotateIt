import 'dart:math';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/project.dart';

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
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        creationDate TEXT NOT NULL,
        lastUpdated TEXT NOT NULL,
        labels TEXT NOT NULL,
        labelColors TEXT NOT NULL
      )
    ''');
  }

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

  Future<int> updateProject(Project project) async {
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

  // this is for Development purposes only, if i need to update certain tables in the database
  Future<void> runManualSQLUpdate() async {
    final db = await ProjectDatabase.instance.database;
    List<Map<String, dynamic>> columns = await db.rawQuery("PRAGMA table_info(projects)");
    bool columnExists = columns.any((column) => column['name'] == 'labelColors');

    if (!columnExists) {
      print("Adding labelColors column...");
      await db.execute("ALTER TABLE projects ADD COLUMN labelColors TEXT");
    } else {
      print("Column labelColors already exists.");
    }

    List<Map<String, dynamic>> projects = await db.query('projects');
    for (var project in projects) {
      String labelsString = project['labels'] as String;
      int projectId = project['id'] as int;

      if (labelsString.isNotEmpty) {
        List<String> labels = labelsString.split(',');
        List<String> labelColors = labels.map((_) => _generateRandomColor()).toList();
        await db.update(
          'projects',
          {'labelColors': labelColors.join(',')},
          where: 'id = ?',
          whereArgs: [projectId],
        );
      print("Database updated successfully!");
      }
    }
  }

  String _generateRandomColor() {
    Random random = Random();
    return '#${(random.nextInt(0xFFFFFF) + 0x1000000).toRadixString(16).substring(1).toUpperCase()}';
  }

  Future<void> closeDB() async {
    final db = await database;
    db.close();
  }
}
