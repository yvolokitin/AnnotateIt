import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/dataset.dart';
import '../models/media_item.dart';
import '../models/annotation.dart';
import '../models/label.dart';
import '../models/annotated_labeled_media.dart';

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

  Future<void> insertMediaItem(
    String datasetId,
    String filePath,
    String ext, {
    required int ownerId,
    int? numberOfFrames,
    int? width,
    int? height,
    double? duration,
    double? fps,
    String? source, // e.g., 'uploaded', 'imported', 'url'
  }) async {
    final type = (ext.toLowerCase() == 'mp4' || ext.toLowerCase() == 'mov')
      ? MediaType.video
      : MediaType.image;

    final mediaItem = MediaItem(
      uuid: const Uuid().v4(),
      datasetId: datasetId,
      filePath: filePath,
      extension: ext.toLowerCase(),
      type: type,
      width: width,
      height: height,
      duration: type == MediaType.video ? duration : null,
      fps: type == MediaType.video ? fps : null,
      source: source ?? 'uploaded',
      uploadDate: DateTime.now(),
      ownerId: ownerId,
      lastAnnotator: null,
      lastAnnotatedDate: null,
      numberOfFrames: type == MediaType.video ? numberOfFrames : null,
      isAnnotated: false,
      annotationCount: 0,
      classificationLabelName: null,
      classificationLabelColor: null,
    );

    final db = await database;
    await db.insert('media_items', mediaItem.toMap());
  }

  Future<List<AnnotatedLabeledMedia>> fetchAnnotatedLabeledMediaBatch({
    required String datasetId,
    required int offset,
    required int limit,
  }) async {
    final db = await database;

    // Step 1: Fetch paginated media items
    final mediaMaps = await db.query(
      'media_items',
      where: 'datasetId = ?',
      whereArgs: [datasetId],
      offset: offset,
      limit: limit,
    );
    final mediaItems = mediaMaps.map((map) => MediaItem.fromMap(map)).toList();

    if (mediaItems.isEmpty) return [];

    // Step 2: Fetch annotations for these media items
    final mediaIds = mediaItems.map((m) => m.id).toList();
    final annotationMaps = await db.query(
      'annotations',
      where: 'media_item_id IN (${List.filled(mediaIds.length, '?').join(',')})',
      whereArgs: mediaIds,
    );
    final annotations = annotationMaps.map((map) => Annotation.fromMap(map)).toList();

    // Step 3: Fetch unique label IDs used in annotations (excluding nulls)
    final Set<int> labelIds = annotations
      .where((a) => a.labelId != null)
      .map((a) => a.labelId!)
      .toSet();

    final List<Label> labels = labelIds.isEmpty
      ? []
      : await db.query(
          'labels',
          where: 'id IN (${List.filled(labelIds.length, '?').join(',')})',
          whereArgs: labelIds.toList(),
        ).then((rows) => rows.map((e) => Label.fromMap(e)).toList());

    // Step 4: Group annotations by mediaId
    final Map<int, List<Annotation>> annotationsByMediaId = {};
    for (final annotation in annotations) {
      annotationsByMediaId.putIfAbsent(annotation.mediaItemId, () => []).add(annotation);
    }

    // Step 5: Assemble AnnotatedLabeledMedia list
    return mediaItems.map((media) {
      final itemAnnotations = annotationsByMediaId[media.id] ?? [];
      return AnnotatedLabeledMedia(
        mediaItem: media,
        annotations: itemAnnotations,
        labels: labels,
      );
    }).toList();
  }
}
