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

  Future<bool> labelExists(int labelId, int projectId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT id FROM labels
      WHERE id = ? AND project_id = ?
      LIMIT 1;
    ''', [labelId, projectId]);
    return result.isNotEmpty;
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

  Future<int> updateAnnotation(Annotation annotation) async {
    final db = await database;
    return await db.update(
      'annotations',
      annotation.toMap(),
      where: 'id = ?',
      whereArgs: [annotation.id],
    );
  }

  /// Deletes a specific annotation from the database
  /// 
  /// [annotationId] - The ID of the annotation to delete
  /// 
  /// Returns the number of rows affected (1 if successful, 0 if not found)
  Future<int> deleteAnnotation(int annotationId) async {
    final db = await database;
    return await db.delete(
      'annotations',
      where: 'id = ?',
      whereArgs: [annotationId],
    );
  }

  // Delete multiple annotations in a single transaction
  Future<void> deleteAnnotationsBatch(List<int> annotationIds) async {
    if (annotationIds.isEmpty) return;
    
    final db = await database;
    await db.transaction((txn) async {
      for (final id in annotationIds) {
        await txn.delete(
          'annotations',
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }

  // Optional: Delete all annotations for a specific media item
  Future<void> deleteAnnotationsByMedia(int mediaItemId) async {
    final db = await database;
    await db.delete('annotations', where: 'media_item_id = ?', whereArgs: [mediaItemId]);
  }
}
