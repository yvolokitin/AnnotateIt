import 'package:sqflite/sqflite.dart';
import '../models/annotation.dart';
import '../models/annotation_review.dart';

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
  Future<int> insertAnnotation(Annotation annotation) async {
    _validateAnnotation(annotation);
    final db = await database;
    return await db.insert('annotations', annotation.toMap());
  }

  // Insert multiple annotations in a single transaction
  Future<void> insertAnnotationsBatch(List<Annotation> annotations) async {
    if (annotations.isEmpty) return;

    final db = await database;
    await db.transaction((txn) async {
      for (final annotation in annotations) {
        _validateAnnotation(annotation);
        await txn.insert('annotations', annotation.toMap());
      }
    });
  }

  Future<bool> labelExists(int labelId, int projectId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT id FROM labels
      WHERE id = ? AND project_id = ?
      LIMIT 1;
    ''',
      [labelId, projectId],
    );
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
  Future<List<Annotation>> fetchAnnotations(
    int mediaItemId, {
    String? type,
  }) async {
    final db = await database;

    final whereClause =
        type != null
            ? 'media_item_id = ? AND annotation_type = ?'
            : 'media_item_id = ?';
    final whereArgs = type != null ? [mediaItemId, type] : [mediaItemId];

    final result = await db.query(
      'annotations',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return result.map((map) => Annotation.fromMap(map)).toList();
  }

  Future<int> updateAnnotation(Annotation annotation) async {
    if (annotation.id == null) {
      throw ArgumentError('Cannot update annotation without id.');
    }

    _validateAnnotation(annotation);
    final db = await database;
    final updatePayload =
        annotation
            .copyWith(
              version: annotation.version + 1,
              updatedAt: DateTime.now(),
            )
            .toMap()
          ..remove('id');

    return await db.update(
      'annotations',
      updatePayload,
      where: 'id = ? AND version = ?',
      whereArgs: [annotation.id, annotation.version],
    );
  }

  Future<int> transitionReviewStatus({
    required int annotationId,
    required int expectedVersion,
    required String nextStatus,
    int? reviewerId,
    String? reviewComment,
  }) async {
    final rawNext = nextStatus.trim().toLowerCase();
    if (!AnnotationReviewStatus.isValid(rawNext)) {
      throw ArgumentError('Invalid review status: $nextStatus');
    }
    final normalizedNext = AnnotationReviewStatus.normalize(rawNext);

    final db = await database;
    return db.transaction<int>((txn) async {
      final rows = await txn.query(
        'annotations',
        columns: ['version', 'review_status'],
        where: 'id = ?',
        whereArgs: [annotationId],
        limit: 1,
      );
      if (rows.isEmpty) {
        return 0;
      }

      final row = rows.first;
      final currentVersion = (row['version'] as num?)?.toInt() ?? 1;
      if (currentVersion != expectedVersion) {
        return 0;
      }

      final currentStatus = AnnotationReviewStatus.normalize(
        row['review_status'] as String?,
      );
      if (!AnnotationReviewStatus.canTransition(
        currentStatus,
        normalizedNext,
      )) {
        throw StateError(
          'Invalid review transition: $currentStatus -> $normalizedNext',
        );
      }

      final nowIso = DateTime.now().toIso8601String();
      return txn.update(
        'annotations',
        {
          'review_status': normalizedNext,
          'reviewed_by': reviewerId,
          'reviewed_at': nowIso,
          'review_comment': reviewComment,
          'version': expectedVersion + 1,
          'updated_at': nowIso,
        },
        where: 'id = ? AND version = ?',
        whereArgs: [annotationId, expectedVersion],
      );
    });
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
        await txn.delete('annotations', where: 'id = ?', whereArgs: [id]);
      }
    });
  }

  // Optional: Delete all annotations for a specific media item
  Future<void> deleteAnnotationsByMedia(int mediaItemId) async {
    final db = await database;
    await db.delete(
      'annotations',
      where: 'media_item_id = ?',
      whereArgs: [mediaItemId],
    );
  }

  Future<int> deleteAnnotationsByMediaAndType(
    int mediaItemId,
    String annotationType,
  ) async {
    final db = await database;
    return await db.delete(
      'annotations',
      where: 'media_item_id = ? AND annotation_type = ?',
      whereArgs: [mediaItemId, annotationType],
    );
  }

  // Delete all annotations for a specific label
  Future<void> deleteAnnotationsByLabelId(int labelId) async {
    final db = await database;
    await db.delete('annotations', where: 'label_id = ?', whereArgs: [labelId]);
  }

  void _validateAnnotation(Annotation annotation) {
    if (annotation.annotationSchemaVersion < 1) {
      throw ArgumentError(
        'annotationSchemaVersion must be >= 1, got ${annotation.annotationSchemaVersion}',
      );
    }
    if (!AnnotationReviewStatus.isValid(annotation.reviewStatus)) {
      throw ArgumentError('Invalid reviewStatus: ${annotation.reviewStatus}');
    }

    if (annotation.annotationType == 'bbox') {
      final data = annotation.data;
      const required = <String>['x', 'y', 'width', 'height'];
      final hasAny = required.any(data.containsKey);
      if (hasAny) {
        final hasAll = required.every(data.containsKey);
        if (!hasAll) {
          throw ArgumentError(
            'bbox annotation requires x, y, width, height keys when any bbox key is present.',
          );
        }
        final width = data['width'];
        final height = data['height'];
        if (width is! num || height is! num || width <= 0 || height <= 0) {
          throw ArgumentError('bbox width/height must be positive numbers.');
        }
      }
    }
  }
}
