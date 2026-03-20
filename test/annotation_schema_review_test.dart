import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:annotateit/data/annotation_database.dart';
import 'package:annotateit/models/annotation.dart';
import 'package:annotateit/models/annotation_review.dart';

Future<Database> _createTestDatabase() async {
  final db = await databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) async {
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
            annotation_schema_version INTEGER NOT NULL DEFAULT 1,
            provenance TEXT,
            review_status TEXT NOT NULL DEFAULT 'draft',
            reviewed_by INTEGER,
            reviewed_at TEXT,
            review_comment TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
      },
    ),
  );
  AnnotationDatabase.instance.setDatabase(db);
  return db;
}

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Annotation schema and review lifecycle', () {
    test(
      'insert persists schema v1 and draft review status by default',
      () async {
        final db = await _createTestDatabase();
        addTearDown(() async => db.close());

        final id = await AnnotationDatabase.instance.insertAnnotation(
          Annotation(
            mediaItemId: 1,
            labelId: null,
            annotationType: 'classification',
            data: const {},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        final row =
            (await db.query(
              'annotations',
              where: 'id = ?',
              whereArgs: [id],
            )).single;
        expect(
          row['annotation_schema_version'],
          AnnotationSchema.currentVersion,
        );
        expect(row['review_status'], AnnotationReviewStatus.draft);
      },
    );

    test('invalid review status is rejected before insert', () async {
      final db = await _createTestDatabase();
      addTearDown(() async => db.close());

      expect(
        () => AnnotationDatabase.instance.insertAnnotation(
          Annotation(
            mediaItemId: 1,
            labelId: null,
            annotationType: 'classification',
            data: const {},
            reviewStatus: 'invalid_status',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        throwsArgumentError,
      );
    });

    test(
      'review transition updates status, version, and reviewer metadata',
      () async {
        final db = await _createTestDatabase();
        addTearDown(() async => db.close());

        final id = await AnnotationDatabase.instance.insertAnnotation(
          Annotation(
            mediaItemId: 1,
            labelId: 1,
            annotationType: 'bbox',
            data: const {'x': 1.0, 'y': 2.0, 'width': 30.0, 'height': 20.0},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        final updated = await AnnotationDatabase.instance
            .transitionReviewStatus(
              annotationId: id,
              expectedVersion: 1,
              nextStatus: AnnotationReviewStatus.proposed,
              reviewerId: 7,
              reviewComment: 'ready for QA',
            );
        expect(updated, 1);

        final row =
            (await db.query(
              'annotations',
              where: 'id = ?',
              whereArgs: [id],
            )).single;
        expect(row['review_status'], AnnotationReviewStatus.proposed);
        expect(row['version'], 2);
        expect(row['reviewed_by'], 7);
        expect(row['review_comment'], 'ready for QA');
        expect(row['reviewed_at'], isNotNull);
      },
    );

    test('invalid review transition is blocked', () async {
      final db = await _createTestDatabase();
      addTearDown(() async => db.close());

      final id = await AnnotationDatabase.instance.insertAnnotation(
        Annotation(
          mediaItemId: 1,
          labelId: 1,
          annotationType: 'bbox',
          data: const {'x': 1.0, 'y': 2.0, 'width': 30.0, 'height': 20.0},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      expect(
        () => AnnotationDatabase.instance.transitionReviewStatus(
          annotationId: id,
          expectedVersion: 1,
          nextStatus: AnnotationReviewStatus.accepted,
          reviewerId: 9,
        ),
        throwsStateError,
      );
    });

    test('review transition uses optimistic locking on version', () async {
      final db = await _createTestDatabase();
      addTearDown(() async => db.close());

      final id = await AnnotationDatabase.instance.insertAnnotation(
        Annotation(
          mediaItemId: 1,
          labelId: 1,
          annotationType: 'bbox',
          data: const {'x': 1.0, 'y': 2.0, 'width': 30.0, 'height': 20.0},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final first = await AnnotationDatabase.instance.transitionReviewStatus(
        annotationId: id,
        expectedVersion: 1,
        nextStatus: AnnotationReviewStatus.proposed,
        reviewerId: 2,
      );
      expect(first, 1);

      final stale = await AnnotationDatabase.instance.transitionReviewStatus(
        annotationId: id,
        expectedVersion: 1,
        nextStatus: AnnotationReviewStatus.accepted,
        reviewerId: 2,
      );
      expect(stale, 0);
    });

    test('legacy annotation maps are hydrated with safe defaults', () {
      final annotation = Annotation.fromMap(<String, dynamic>{
        'id': 1,
        'media_item_id': 10,
        'label_id': null,
        'annotation_type': 'classification',
        'data': '{}',
        'confidence': null,
        'annotator_id': null,
        'comment': null,
        'status': 'pending',
        'version': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      expect(
        annotation.annotationSchemaVersion,
        AnnotationSchema.currentVersion,
      );
      expect(annotation.reviewStatus, AnnotationReviewStatus.draft);
      expect(annotation.provenance, isNull);
    });
  });
}
