import 'package:sqflite/sqflite.dart';
import '../models/annotation.dart';

class AnnotationDatabase {
  static final AnnotationDatabase instance = AnnotationDatabase._init();
  static Database? _db;

  AnnotationDatabase._init();

  void setDatabase(Database db) {
    _db = db;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    throw Exception("Database not set.");
  }

  // Insert new annotation into the database
  Future<void> insertAnnotation(Annotation annotation) async {
    final db = await database;
    await db.insert('annotations', annotation.toMap());
  }

  // Insert multiple annotations in a single transaction
  Future<void> insertAnnotationsBatch(List<Annotation> annotations) async {
    if (annotations.isEmpty) return;
  
    final db = await database;
    await db.transaction((txn) async {
      for (final annotation in annotations) {
        await txn.insert('annotations', annotation.toMap());
      }
    });
  }

  Future<void> insertAnnotationAndUpdateMediaItem(
    Annotation annotation,
    String taskType,
  ) async {
    final db = await database;

    // Insert the annotation
    await db.insert('annotations', annotation.toMap());

    // Count total annotations for this media item
    final countResult = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM annotations WHERE media_item_id = ?',
      [annotation.mediaItemId],
    ));
    final count = countResult ?? 0;

    // Fields to update
    final updateFields = <String, dynamic>{
      'isAnnotated': count > 0 ? 1 : 0,
      'annotationCount': count,
      'lastAnnotator': annotation.annotatorId?.toString(),
      'lastAnnotatedDate': DateTime.now().toIso8601String(),
    };

    // Check if task is classification-like (case-insensitive)
    final taskTypeLower = taskType.toLowerCase();
    final isClassification = taskTypeLower.contains('classification');

    if (isClassification && annotation.labelId != null) {
      final labelResult = await db.query(
        'labels',
        columns: ['name', 'color'],
        where: 'id = ?',
        whereArgs: [annotation.labelId],
        limit: 1,
      );

      if (labelResult.isNotEmpty) {
        updateFields['classificationLabelName'] = labelResult.first['name'];
        updateFields['classificationLabelColor'] = labelResult.first['color'];
      }
    }

    // Update the media_items table
    await db.update(
      'media_items',
      updateFields,
      where: 'id = ?',
      whereArgs: [annotation.mediaItemId],
    );
  }

  Future<void> recountAnnotationsForDataset(String datasetId) async {
    final db = await database;

    // Fetch all media_items in the given dataset
    final mediaItems = await db.query(
      'media_items',
      columns: ['id'],
      where: 'datasetId = ?',
      whereArgs: [datasetId],
    );

    final now = DateTime.now().toIso8601String();

    for (final media in mediaItems) {
      final mediaItemId = media['id'] as int;

      // Count annotations for this media item
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM annotations WHERE media_item_id = ?',
        [mediaItemId],
      );
      final count = Sqflite.firstIntValue(countResult) ?? 0;

      int isAnnotated = count > 0 ? 1 : 0;

      // Get last annotator (if any annotations exist)
      String? annotatorId;
      if (isAnnotated == 1) {
        final annotatorResult = await db.rawQuery('''
          SELECT annotator_id
          FROM annotations
          WHERE media_item_id = ?
          ORDER BY updated_at DESC
          LIMIT 1
        ''', [mediaItemId]);

        annotatorId = annotatorResult.isNotEmpty
          ? annotatorResult.first['annotator_id']?.toString()
          : null;
      }

      // Check for classification annotation to extract label info
      String? classificationLabelName;
      String? classificationLabelColor;

      final classificationResult = await db.rawQuery('''
        SELECT l.name, l.color
        FROM annotations a
        JOIN labels l ON l.id = a.label_id
        WHERE a.media_item_id = ? AND a.annotation_type = 'classification'
        LIMIT 1
      ''', [mediaItemId]);

      if (classificationResult.isNotEmpty) {
        classificationLabelName = classificationResult.first['name'] as String?;
        classificationLabelColor = classificationResult.first['color'] as String?;
      }

      // Update the media_items record
      await db.update(
        'media_items',
        {
          'isAnnotated': isAnnotated,
          'annotationCount': count,
          'lastAnnotatedDate': isAnnotated == 1 ? now : null,
          'lastAnnotator': annotatorId,
          'classificationLabelName': classificationLabelName,
          'classificationLabelColor': classificationLabelColor,
        },
        where: 'id = ?',
        whereArgs: [mediaItemId],
      );
    }

    print('[AnnotationDatabase] Updated annotation summaries for ${mediaItems.length} media items in dataset $datasetId');
  }

  Future<int?> getLabelIdByName(int projectId, String name) async {
    final db = await database;
    final result = await db.query(
      'labels',
      columns: ['id'],
      where: 'project_id = ? AND name = ?',
      whereArgs: [projectId, name],
      limit: 1,
    );
    return result.isNotEmpty ? result.first['id'] as int : null;
  }

  /// Fetches annotations for a specific media item.
  ///
  /// [mediaItemId] – ID of the media item to fetch annotations for.
  ///
  /// [type] – Optional filter to return only annotations of a specific type.
  /// 
  /// Supported types include:
  /// - `'bbox'` – Bounding box annotations. `data` should contain: `x`, `y`, `width`, `height`.
  /// - `'classification'` – Whole-image or region classification. `data` may contain: `class`, `score`, etc.
  /// - `'segmentation'` – Segmentation masks. `data` may contain polygon points or RLE.
  /// - `'keypoints'` – Keypoint or landmark annotations. `data` should contain a list of `x`, `y` points and optional names.
  ///
  /// If [type] is omitted or `null`, all annotation types will be returned.
  ///
  /// Returns a list of [Annotation] objects.
  Future<List<Annotation>> fetchAnnotations(int mediaItemId, {String? type}) async {
    final db = await database;

    final whereClause = type != null
        ? 'media_item_id = ? AND annotation_type = ?'
        : 'media_item_id = ?';
    final whereArgs = type != null
        ? [mediaItemId, type]
        : [mediaItemId];

    final result = await db.query(
      'annotations',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return result.map((map) => Annotation.fromMap(map)).toList();
  }

  // Optional: Delete all annotations for a specific media item
  Future<void> deleteAnnotationsByMedia(int mediaItemId) async {
    final db = await database;
    await db.delete('annotations', where: 'media_item_id = ?', whereArgs: [mediaItemId]);
  }
}
