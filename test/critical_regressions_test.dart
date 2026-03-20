import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:annotateit/data/annotation_database.dart';
import 'package:annotateit/data/create_initial_schema.dart';
import 'package:annotateit/data/dataset_database.dart';
import 'package:annotateit/data/labels_database.dart';
import 'package:annotateit/models/annotation.dart';
import 'package:annotateit/models/label.dart';
import 'package:annotateit/models/media_item.dart';
import 'package:annotateit/utils/dataset_annotation_parsers/yolo_parser.dart';

class _FakePathProviderPlatform extends PathProviderPlatform {
  _FakePathProviderPlatform(this.rootPath);

  final String rootPath;

  @override
  Future<String?> getTemporaryPath() async => rootPath;

  @override
  Future<String?> getApplicationSupportPath() async => rootPath;

  @override
  Future<String?> getLibraryPath() async => rootPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => rootPath;

  @override
  Future<String?> getApplicationCachePath() async => rootPath;

  @override
  Future<String?> getExternalStoragePath() async => rootPath;

  @override
  Future<List<String>?> getExternalCachePaths() async => <String>[rootPath];

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => <String>[rootPath];

  @override
  Future<String?> getDownloadsPath() async => rootPath;
}

Future<Database> _createTestDatabase() async {
  final db = await databaseFactory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: createInitialSchema,
    ),
  );
  AnnotationDatabase.instance.setDatabase(db);
  DatasetDatabase.instance.setDatabase(db);
  LabelsDatabase.instance.setDatabase(db);
  return db;
}

Future<({int projectId, String datasetId})> _seedProjectAndDataset(
  Database db, {
  String projectType = 'classification',
}) async {
  final now = DateTime.now().toIso8601String();
  final projectId = await db.insert('projects', {
    'name': 'Test Project',
    'description': 'regression tests',
    'type': projectType,
    'icon': 'assets/images/empty_project_folder.png',
    'creationDate': now,
    'lastUpdated': now,
    'defaultDatasetId': null,
    'ownerId': 1,
    'project_order': 0,
  });

  final datasetId = 'dataset_$projectId';
  await db.insert('datasets', {
    'id': datasetId,
    'projectId': projectId,
    'dataset_order': 0,
    'name': 'Dataset',
    'description': 'default',
    'type': projectType,
    'source': 'manual',
    'format': 'custom',
    'version': '1.0.0',
    'mediaCount': 0,
    'annotationCount': 0,
    'defaultDataset': 1,
    'license': null,
    'metadata': null,
    'createdAt': now,
    'updatedAt': now,
  });

  await db.update(
    'projects',
    {'defaultDatasetId': datasetId},
    where: 'id = ?',
    whereArgs: [projectId],
  );

  return (projectId: projectId, datasetId: datasetId);
}

Future<int> _insertMedia(
  Database db, {
  required String datasetId,
  required String fileName,
  int width = 640,
  int height = 480,
}) async {
  return db.insert('media_items', {
    'uuid': 'uuid_$fileName',
    'datasetId': datasetId,
    'filePath': '/tmp/$fileName',
    'extension': 'jpg',
    'type': 'image',
    'width': width,
    'height': height,
    'duration': null,
    'fps': null,
    'source': 'imported',
    'uploadDate': DateTime.now().toIso8601String(),
    'owner_id': 1,
    'lastAnnotator': null,
    'lastAnnotatedDate': null,
    'numberOfFrames': null,
  });
}

Future<int> _insertLabel(
  Database db, {
  required int projectId,
  String name = 'label',
  String color = '#ff0000',
}) async {
  return db.insert('labels', {
    'label_order': 0,
    'project_id': projectId,
    'name': name,
    'color': color,
    'is_default': 0,
    'description': null,
    'createdAt': DateTime.now().toIso8601String(),
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late final PathProviderPlatform originalPathProvider;
  late final Directory tempRoot;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    tempRoot = await Directory.systemTemp.createTemp('annotateit_test_root_');
    originalPathProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _FakePathProviderPlatform(tempRoot.path);
  });

  tearDownAll(() async {
    PathProviderPlatform.instance = originalPathProvider;
    if (await tempRoot.exists()) {
      await tempRoot.delete(recursive: true);
    }
  });

  group('Critical regressions', () {
    test('annotation update uses optimistic locking', () async {
      final db = await _createTestDatabase();
      addTearDown(() async => db.close());

      final setup = await _seedProjectAndDataset(db, projectType: 'detection');
      final mediaId = await _insertMedia(
        db,
        datasetId: setup.datasetId,
        fileName: 'a.jpg',
      );
      final labelId = await _insertLabel(
        db,
        projectId: setup.projectId,
        name: 'car',
      );

      final base = Annotation(
        mediaItemId: mediaId,
        labelId: labelId,
        annotationType: 'bbox',
        data: {'x': 10.0, 'y': 20.0, 'width': 30.0, 'height': 40.0},
        comment: 'initial',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final insertedId = await AnnotationDatabase.instance.insertAnnotation(
        base,
      );
      final loaded =
          (await AnnotationDatabase.instance.fetchAnnotations(mediaId)).single;

      final firstUpdate = Annotation(
        id: insertedId,
        mediaItemId: loaded.mediaItemId,
        labelId: loaded.labelId,
        annotationType: loaded.annotationType,
        data: loaded.data,
        comment: 'first-update',
        version: loaded.version,
        createdAt: loaded.createdAt,
        updatedAt: loaded.updatedAt,
      );
      final firstRows = await AnnotationDatabase.instance.updateAnnotation(
        firstUpdate,
      );
      expect(firstRows, 1);

      final staleUpdate = Annotation(
        id: insertedId,
        mediaItemId: loaded.mediaItemId,
        labelId: loaded.labelId,
        annotationType: loaded.annotationType,
        data: loaded.data,
        comment: 'stale-write',
        version: loaded.version,
        createdAt: loaded.createdAt,
        updatedAt: loaded.updatedAt,
      );
      final staleRows = await AnnotationDatabase.instance.updateAnnotation(
        staleUpdate,
      );
      expect(staleRows, 0);

      final row =
          (await db.query(
            'annotations',
            where: 'id = ?',
            whereArgs: [insertedId],
          )).single;
      expect(row['version'], 2);
      expect(row['comment'], 'first-update');
    });

    test(
      'delete by media+type only removes targeted annotation type',
      () async {
        final db = await _createTestDatabase();
        addTearDown(() async => db.close());

        final setup = await _seedProjectAndDataset(
          db,
          projectType: 'classification',
        );
        final mediaId = await _insertMedia(
          db,
          datasetId: setup.datasetId,
          fileName: 'b.jpg',
        );
        final labelId = await _insertLabel(
          db,
          projectId: setup.projectId,
          name: 'cat',
        );

        await AnnotationDatabase.instance.insertAnnotationsBatch([
          Annotation(
            mediaItemId: mediaId,
            labelId: labelId,
            annotationType: 'classification',
            data: const {},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Annotation(
            mediaItemId: mediaId,
            labelId: labelId,
            annotationType: 'bbox',
            data: {'x': 1.0, 'y': 2.0, 'width': 3.0, 'height': 4.0},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ]);

        final deleted = await AnnotationDatabase.instance
            .deleteAnnotationsByMediaAndType(mediaId, 'classification');
        expect(deleted, 1);

        final remaining = await AnnotationDatabase.instance.fetchAnnotations(
          mediaId,
        );
        expect(remaining.length, 1);
        expect(remaining.single.annotationType, 'bbox');
      },
    );

    test(
      'dataset pagination and index-based reads are deterministic by id',
      () async {
        final db = await _createTestDatabase();
        addTearDown(() async => db.close());

        final setup = await _seedProjectAndDataset(
          db,
          projectType: 'detection',
        );
        final id1 = await _insertMedia(
          db,
          datasetId: setup.datasetId,
          fileName: '1.jpg',
        );
        final id2 = await _insertMedia(
          db,
          datasetId: setup.datasetId,
          fileName: '2.jpg',
        );
        final id3 = await _insertMedia(
          db,
          datasetId: setup.datasetId,
          fileName: '3.jpg',
        );
        expect([id1, id2, id3], orderedEquals([id1, id2, id3]));

        final page = await DatasetDatabase.instance
            .fetchAnnotatedLabeledMediaBatch(
              datasetId: setup.datasetId,
              offset: 1,
              limit: 1,
            );
        expect(page.length, 1);
        expect(page.single.mediaItem.id, id2);

        final indexed = await DatasetDatabase.instance.loadMediaAtIndex(
          setup.datasetId,
          1,
        );
        expect(indexed, isNotNull);
        expect(indexed!.mediaItem.id, id2);
      },
    );

    test('foreign keys are enforced and critical indexes exist', () async {
      final db = await _createTestDatabase();
      addTearDown(() async => db.close());

      final invalid = Annotation(
        mediaItemId: 999999,
        labelId: null,
        annotationType: 'classification',
        data: const {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await expectLater(
        AnnotationDatabase.instance.insertAnnotation(invalid),
        throwsA(isA<DatabaseException>()),
      );

      final indexRows = await db.query(
        'sqlite_master',
        columns: ['name'],
        where: "type = 'index'",
      );
      final indexNames = indexRows.map((r) => r['name'] as String).toSet();

      expect(indexNames, contains('idx_projects_owner_id'));
      expect(indexNames, contains('idx_datasets_project_id_order'));
      expect(indexNames, contains('idx_media_items_dataset_id'));
      expect(indexNames, contains('idx_annotations_media_item_id'));
      expect(indexNames, contains('idx_annotations_label_id'));
      expect(indexNames, contains('idx_labels_project_id'));
    });

    test(
      'YOLO detection parser stores bbox in pixel-space x/y/width/height',
      () async {
        final db = await _createTestDatabase();
        addTearDown(() async => db.close());

        final setup = await _seedProjectAndDataset(
          db,
          projectType: 'detection',
        );
        final mediaId = await _insertMedia(
          db,
          datasetId: setup.datasetId,
          fileName: 'sample.jpg',
          width: 200,
          height: 100,
        );
        final labelId = await _insertLabel(
          db,
          projectId: setup.projectId,
          name: 'dog',
        );

        final tempDataset = await Directory.systemTemp.createTemp(
          'annotateit_yolo_ds_',
        );
        addTearDown(() async {
          if (await tempDataset.exists()) {
            await tempDataset.delete(recursive: true);
          }
        });
        final labelsDir = Directory('${tempDataset.path}/labels');
        await labelsDir.create(recursive: true);
        final yoloFile = File('${labelsDir.path}/sample.txt');
        await yoloFile.writeAsString('0 0.5 0.5 0.4 0.2\n');

        final mediaItem = MediaItem(
          id: mediaId,
          uuid: 'uuid_sample',
          datasetId: setup.datasetId,
          filePath: '/tmp/sample.jpg',
          extension: 'jpg',
          type: MediaType.image,
          width: 200,
          height: 100,
          uploadDate: DateTime.now(),
          ownerId: 1,
        );
        final label = Label(
          id: labelId,
          labelOrder: 0,
          projectId: setup.projectId,
          name: 'dog',
          color: '#ff0000',
        );

        final added = await YOLOParser.parse(
          projectType: 'detection',
          projectLabels: [label],
          datasetPath: tempDataset.path,
          mediaItemsMap: {'sample.jpg': mediaItem},
          annotationDb: AnnotationDatabase.instance,
          projectId: setup.projectId,
          annotatorId: 1,
        );
        expect(added, 1);

        final inserted =
            (await AnnotationDatabase.instance.fetchAnnotations(
              mediaId,
            )).single;
        expect(inserted.annotationType, 'bbox');
        expect(inserted.data.containsKey('x_center'), isFalse);
        expect(inserted.data.containsKey('y_center'), isFalse);
        expect(
          inserted.data.keys.toSet(),
          containsAll(<String>['x', 'y', 'width', 'height']),
        );
        expect((inserted.data['x'] as num).toDouble(), closeTo(60.0, 0.001));
        expect((inserted.data['y'] as num).toDouble(), closeTo(40.0, 0.001));
        expect(
          (inserted.data['width'] as num).toDouble(),
          closeTo(80.0, 0.001),
        );
        expect(
          (inserted.data['height'] as num).toDouble(),
          closeTo(20.0, 0.001),
        );
      },
    );
  });
}
