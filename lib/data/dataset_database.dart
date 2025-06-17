import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/label.dart';
import '../models/dataset.dart';
import '../models/media_item.dart';
import '../models/annotation.dart';
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
    required String projectType,
    String name = 'New Dataset',
    String description = '',
    bool isDefault = false,
    void Function(String datasetId)? onDefaultSet,
  }) async {
    final db = await database;

    // Prevent multiple default datasets
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

    final now = DateTime.now();
    final dataset = Dataset(
      id: _uuid.v4(),
      projectId: projectId,
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

  Future<Dataset?> loadDatasetWithFolderIds(String datasetId) async {
    final db = await database;

    // Step 1: Load dataset
    final datasetResult = await db.query(
      'datasets',
      where: 'id = ?',
      whereArgs: [datasetId],
    );

    if (datasetResult.isEmpty) return null;

    final datasetMap = datasetResult.first;

    // Step 2: Load folder IDs via the junction table
    final folderResults = await db.rawQuery('''
      SELECT folderId FROM dataset_media_folders
      WHERE datasetId = ?
    ''', [datasetId]);

    final folderIds = folderResults.map((row) => row['folderId'] as int).toList();

    // Step 3: Return Dataset with folders field populated
    return Dataset.fromMap(datasetMap).copyWith(folders: folderIds);
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
    );

    final db = await database;
    await db.insert('media_items', mediaItem.toMap());
  }

  Future<void> deleteMediaItemWithAnnotations(int mediaItemId) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      await txn.delete(
        'annotations',
        where: 'media_item_id = ?',
        whereArgs: [mediaItemId],
      );

      await txn.delete(
        'media_items',
        where: 'id = ?',
        whereArgs: [mediaItemId],
      );
    });
  }

  Future<int> countMediaItemsInDataset(String datasetId) async {
    final db = await database;

    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM media_items WHERE datasetId = ?',
      [datasetId],
    );

    // Safely extract the count
    return Sqflite.firstIntValue(countResult) ?? 0;
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
    List<Annotation> annotations = annotationMaps.map((map) => Annotation.fromMap(map)).toList();

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

    // Create label map and assign name + color to annotations
    final labelMap = {
      for (var label in labels)
        label.id: {
          'name': label.name,
          'color': label.toColor(),
        }
    };

    annotations = annotations.map((a) {
      final info = a.labelId != null ? labelMap[a.labelId] : null;
      return a.copyWith(
        name: info?['name'] as String?,
        color: info?['color'] as Color?, // already parsed
      );
    }).toList();

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

  Future<AnnotatedLabeledMedia?> loadMediaAtIndex(String datasetId, int index, ) async {
    final db = await database;

    final mediaMaps = await db.query(
      'media_items',
      where: 'datasetId = ?',
      whereArgs: [datasetId],
      limit: 1,
      offset: index,
    );

    if (mediaMaps.isEmpty) return null;

    final mediaItem = MediaItem.fromMap(mediaMaps.first);

    final annotationMaps = await db.query(
      'annotations',
      where: 'media_item_id = ?',
      whereArgs: [mediaItem.id],
    );
    final annotations = annotationMaps.map((map) => Annotation.fromMap(map)).toList();

    final labelIds = annotations
      .where((a) => a.labelId != null)
      .map((a) => a.labelId!)
      .toSet();

    final List<Label> labels = labelIds.isEmpty
      ? []
      : (await db.query(
        'labels',
        where: 'id IN (${List.filled(labelIds.length, '?').join(',')})',
        whereArgs: labelIds.toList(),
      )).map((e) => Label.fromMap(e)).toList();

    // Enrich annotations
    final Map<int, Label> labelMap = {
      for (var label in labels) label.id!: label,
    };

    for (var annotation in annotations) {
      final label = labelMap[annotation.labelId];
      if (label != null) {
        annotation.name = label.name;
        annotation.color = label.toColor();
      }
    }
  
    return AnnotatedLabeledMedia(
      mediaItem: mediaItem,
      annotations: annotations,
      labels: labels,
    );
  }

  Future<int> createMediaFolder({
    required String path,
    required String name,
    required DateTime createdAt,
  }) async {
    final db = await database;
    final folderMap = {
      'path': path,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };

    return await db.insert('media_folders', folderMap);
  }

  Future<void> linkMediaFolderToDataset({
    required String datasetId,
    required int folderId,
  }) async {
    final db = await database;
    await db.insert('dataset_media_folders', {
      'datasetId': datasetId,
      'folderId': folderId,
    });
  }

  Future<String?> getMediaFolderPath(int folderId) async {
    final db = await database;
    final result = await db.query(
      'media_folders',
      columns: ['path'],
      where: 'id = ?',
      whereArgs: [folderId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return result.first['path'] as String;
    }
    return null;
  }

  Future<void> deleteMediaFolderLink({
    required String datasetId,
    required int folderId,
  }) async {
    final db = await database;
    await db.delete(
      'dataset_media_folders',
      where: 'datasetId = ? AND folderId = ?',
      whereArgs: [datasetId, folderId],
    );
  }

  Future<void> deleteDatasetsForProject({required int projectId}) async {
    final db = await database;

    // Get all datasets linked to the project
    final datasets = await fetchDatasetsForProject(projectId);

    for (final dataset in datasets) {
      // Remove all folder links for the dataset
      await db.delete(
        'dataset_media_folders',
        where: 'datasetId = ?',
        whereArgs: [dataset.id],
      );

      // Delete annotations and media
      final mediaItems = await fetchMediaForDataset(dataset.id);
      for (final media in mediaItems) {
        if (media.id != null) {
          await deleteMediaItemWithAnnotations(media.id!);
        }
      }

      // Delete the dataset
      await db.delete(
        'datasets',
        where: 'id = ?',
        whereArgs: [dataset.id],
      );
    }
  }

  Future<List<int>> getFolderIdsForDataset(String datasetId) async {
    final db = await database;
    final results = await db.query(
      'dataset_media_folders',
      columns: ['folderId'],
      where: 'datasetId = ?',
      whereArgs: [datasetId],
    );

    return results.map((row) => row['folderId'] as int).toList();
  }

  Future<List<String>> getOtherProjectNamesUsingFolder({
    required int folderId,
    required String currentDatasetId,
  }) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT DISTINCT p.name
      FROM projects p
      JOIN datasets d ON p.id = d.projectId
      JOIN dataset_media_folders f ON d.id = f.datasetId
      WHERE f.folderId = ? AND d.id != ?
    ''', [folderId, currentDatasetId]);

    return results.map((row) => row['name'] as String).toList();
  }

}
