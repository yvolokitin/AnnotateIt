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

  Future<void> updateDataset(Dataset dataset) async {
    final db = await database;

    await db.update(
      'datasets',
      dataset.toMap(),
      where: 'id = ?',
      whereArgs: [dataset.id],
    );
  }

  Future<void> deleteDataset(String datasetId) async {
    final db = await database;

    await db.transaction((txn) async {
      // Step 1: Delete media items linked to the dataset
      await txn.delete(
        'media_items',
        where: 'datasetId = ?',
        whereArgs: [datasetId],
      );

      // Step 2: Delete the dataset itself
      await txn.delete(
        'datasets',
        where: 'id = ?',
        whereArgs: [datasetId],
      );
    });
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

  /// Inserts a new media item into the `media_items` table.
  ///
  /// This method creates a media record with the specified dataset ID, file path,
  /// file extension, and owner ID. It determines the media type automatically
  /// based on the extension (`image` or `video`).
  ///
  /// The database will auto-generate the `id` (INTEGER PRIMARY KEY AUTOINCREMENT).
  ///
  /// ### Parameters:
  /// - [datasetId]: The ID of the dataset the media belongs to.
  /// - [filePath]: The full file path of the media (e.g. `/images/cat.jpg`).
  /// - [ext]: File extension (e.g. `jpg`, `png`, `mp4`). Will be lowercased internally.
  /// - [ownerId]: The user ID (from the `users` table) who owns the media item.
  /// - [numberOfFrames] (optional): Number of frames if the media is a video.
  ///
  /// ### Media Type Detection:
  /// - If [ext] is `'mp4'` or `'mov'`, the media type is set to `MediaType.video`
  /// - Otherwise, it defaults to `MediaType.image`
  ///
  /// Throws if the database is not initialized or [ownerId] is invalid.
  ///
  /// Example:
  /// ```dart
  /// await insertMediaItem(
  ///   datasetId: 'ds123',
  ///   filePath: '/data/sample.mp4',
  ///   ext: 'mp4',
  ///   ownerId: 1,
  ///   numberOfFrames: 300,
  /// );
  /// ```
  Future<void> insertMediaItem(String datasetId, String filePath, String ext, {required int ownerId, int? numberOfFrames,}) async {
    final type = (ext == 'mp4' || ext == 'mov')
      ? MediaType.video
      : MediaType.image;

    final mediaItem = MediaItem(
      datasetId: datasetId,
      filePath: filePath,
      extension: ext.toLowerCase(),
      type: type,
      uploadDate: DateTime.now(),
      ownerId: ownerId,
      lastAnnotator: null,
      lastAnnotatedDate: null,
      numberOfFrames: type == MediaType.video ? numberOfFrames : null,
    );

    final db = await database;
    await db.insert('media_items', mediaItem.toMap());
  }
}
