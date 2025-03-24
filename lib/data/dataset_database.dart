import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/dataset.dart';
import '../models/media_item.dart';

class DatasetDatabase {
  static final DatasetDatabase instance = DatasetDatabase._init();
  static Database? _db;
  final _uuid = Uuid();

  DatasetDatabase._init();

  // Receive shared db from external source
  Future<Database> get database async {
    if (_db != null) return _db!;
    throw Exception("Database is not initialized. Inject it via setDatabase().");
  }

  void setDatabase(Database db) {
    _db = db;
  }

  Future<void> createTable(Database db) async {
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
  }

  Future<Dataset> createDatasetForProject({
    required int projectId,
    String name = 'New Dataset',
    String description = '',
    bool isDefault = false,
    void Function(String datasetId)? onDefaultSet,
  }) async {
    final db = await database;

    if (isDefault) {
      final result = await db.query(
        'projects',
        columns: ['defaultDatasetId'],
        where: 'id = ?',
        whereArgs: [projectId],
      );

      if (result.isNotEmpty && result.first['defaultDatasetId'] != null) {
        throw Exception('Default dataset already exists for this project.');
      }
    }

    final dataset = Dataset(
      id: _uuid.v4(),
      projectId: projectId,
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );

    await db.insert('datasets', dataset.toMap());

    if (isDefault && onDefaultSet != null) {
      onDefaultSet(dataset.id);
    }

    return dataset;
  }

  Future<List<Dataset>> fetchDatasetsForProject(int projectId) async {
    final db = await database;
    final result = await db.query('datasets', where: 'projectId = ?', whereArgs: [projectId]);
    return result.map((map) => Dataset.fromMap(map)).toList();
  }

  Future<List<MediaItem>> fetchMediaForDataset(String datasetId) async {
    final db = await database;

    final mediaMaps = await db.query(
      'media_items',
      where: 'datasetId = ?',
      whereArgs: [datasetId],
    );

    return mediaMaps.map((map) => MediaItem.fromMap(map)).toList();
  }

  Future<void> insertMediaItem(MediaItem item) async {
    final db = await database;
    await db.insert('media_items', item.toMap());
  }

}
