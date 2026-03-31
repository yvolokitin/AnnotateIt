import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<void> createPrerequisiteTables(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        ownerId INTEGER NOT NULL,
        FOREIGN KEY(ownerId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE labels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        project_id INTEGER NOT NULL,
        FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE media_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE,
        type TEXT
      )
    ''');
  }

  Future<void> applyTemporalMigration(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS video_assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        media_item_id INTEGER,
        project_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        file_name TEXT NOT NULL,
        width INTEGER NOT NULL DEFAULT 0,
        height INTEGER NOT NULL DEFAULT 0,
        duration_sec REAL NOT NULL DEFAULT 0.0,
        fps_nominal REAL NOT NULL DEFAULT 0.0,
        frame_count_estimate INTEGER NOT NULL DEFAULT 0,
        codec TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(media_item_id) REFERENCES media_items(id) ON DELETE SET NULL,
        FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS video_frames (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        video_asset_id INTEGER NOT NULL,
        media_item_id INTEGER,
        frame_index INTEGER NOT NULL,
        timestamp_ms REAL NOT NULL DEFAULT 0.0,
        source_fps REAL NOT NULL DEFAULT 0.0,
        sampling_policy TEXT NOT NULL DEFAULT 'fixedFps',
        extraction_run_id TEXT NOT NULL,
        file_path TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY(video_asset_id) REFERENCES video_assets(id) ON DELETE CASCADE,
        FOREIGN KEY(media_item_id) REFERENCES media_items(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS annotation_tracks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        video_asset_id INTEGER NOT NULL,
        label_id INTEGER,
        status TEXT NOT NULL DEFAULT 'active',
        annotation_type TEXT NOT NULL DEFAULT 'bbox',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(video_asset_id) REFERENCES video_assets(id) ON DELETE CASCADE,
        FOREIGN KEY(label_id) REFERENCES labels(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS track_keyframes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        track_id INTEGER NOT NULL,
        frame_id INTEGER NOT NULL,
        geometry TEXT NOT NULL,
        confidence REAL DEFAULT 1.0,
        is_manual INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(track_id) REFERENCES annotation_tracks(id) ON DELETE CASCADE,
        FOREIGN KEY(frame_id) REFERENCES video_frames(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX IF NOT EXISTS idx_video_assets_project ON video_assets(project_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_video_assets_media_item ON video_assets(media_item_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_video_frames_video_asset ON video_frames(video_asset_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_video_frames_asset_index ON video_frames(video_asset_id, frame_index)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_video_frames_run ON video_frames(extraction_run_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_annotation_tracks_video ON annotation_tracks(video_asset_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_annotation_tracks_label ON annotation_tracks(label_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_track_keyframes_track ON track_keyframes(track_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_track_keyframes_frame ON track_keyframes(frame_id)');
  }

  Future<Database> openTestDb() async {
    final db = await openDatabase(inMemoryDatabasePath, version: 1);
    await createPrerequisiteTables(db);
    await applyTemporalMigration(db);
    return db;
  }

  Future<List<String>> tableNames(Database db) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<List<String>> indexNames(Database db) async {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='index' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<List<String>> columnNames(Database db, String table) async {
    final rows = await db.rawQuery('PRAGMA table_info($table)');
    return rows.map((r) => r['name'] as String).toList();
  }

  group('Temporal migration creates expected schema', () {
    late Database db;

    setUp(() async {
      db = await openTestDb();
    });

    tearDown(() async {
      await db.close();
    });

    test('video_assets table has expected columns', () async {
      final tables = await tableNames(db);
      expect(tables, contains('video_assets'));

      final cols = await columnNames(db, 'video_assets');
      expect(cols, containsAll([
        'id', 'uuid', 'media_item_id', 'project_id',
        'file_path', 'file_name',
        'width', 'height', 'duration_sec', 'fps_nominal',
        'frame_count_estimate', 'codec',
        'created_at', 'updated_at',
      ]));
    });

    test('video_frames table has expected columns', () async {
      final cols = await columnNames(db, 'video_frames');
      expect(cols, containsAll([
        'id', 'video_asset_id', 'media_item_id',
        'frame_index', 'timestamp_ms', 'source_fps',
        'sampling_policy', 'extraction_run_id',
        'file_path', 'created_at',
      ]));
    });

    test('annotation_tracks table has expected columns', () async {
      final cols = await columnNames(db, 'annotation_tracks');
      expect(cols, containsAll([
        'id', 'uuid', 'video_asset_id', 'label_id',
        'status', 'annotation_type',
        'created_at', 'updated_at',
      ]));
    });

    test('track_keyframes table has expected columns', () async {
      final cols = await columnNames(db, 'track_keyframes');
      expect(cols, containsAll([
        'id', 'track_id', 'frame_id',
        'geometry', 'confidence', 'is_manual',
        'created_at', 'updated_at',
      ]));
    });

    test('all temporal indexes are created', () async {
      final indexes = await indexNames(db);
      expect(indexes, containsAll([
        'idx_video_assets_project',
        'idx_video_assets_media_item',
        'idx_video_frames_video_asset',
        'idx_video_frames_asset_index',
        'idx_video_frames_run',
        'idx_annotation_tracks_video',
        'idx_annotation_tracks_label',
        'idx_track_keyframes_track',
        'idx_track_keyframes_frame',
      ]));
    });

    test('migration is idempotent — running twice does not throw', () async {
      await applyTemporalMigration(db);
      final tables = await tableNames(db);
      expect(tables, containsAll([
        'video_assets', 'video_frames',
        'annotation_tracks', 'track_keyframes',
      ]));
    });
  });

  group('Temporal tables support CRUD operations', () {
    late Database db;
    final now = DateTime.now().toIso8601String();
    late int projectId;

    setUp(() async {
      db = await openTestDb();
      final userId = await db.insert('users', {
        'firstName': 'Test',
        'createdAt': now,
      });
      projectId = await db.insert('projects', {
        'name': 'Test Project',
        'ownerId': userId,
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('insert and query video_asset', () async {
      final id = await db.insert('video_assets', {
        'uuid': 'va-001',
        'project_id': projectId,
        'file_path': '/videos/test.mp4',
        'file_name': 'test.mp4',
        'width': 1920,
        'height': 1080,
        'duration_sec': 30.5,
        'fps_nominal': 29.97,
        'frame_count_estimate': 914,
        'codec': 'h264',
        'created_at': now,
        'updated_at': now,
      });
      expect(id, greaterThan(0));

      final rows = await db.query('video_assets', where: 'id = ?', whereArgs: [id]);
      expect(rows.length, 1);
      expect(rows.first['uuid'], 'va-001');
      expect(rows.first['width'], 1920);
      expect(rows.first['codec'], 'h264');
    });

    test('insert video_frame linked to video_asset', () async {
      final vaId = await db.insert('video_assets', {
        'uuid': 'va-002',
        'project_id': projectId,
        'file_path': '/v.mp4',
        'file_name': 'v.mp4',
        'created_at': now,
        'updated_at': now,
      });

      final frameId = await db.insert('video_frames', {
        'video_asset_id': vaId,
        'frame_index': 0,
        'timestamp_ms': 0.0,
        'source_fps': 30.0,
        'sampling_policy': 'fixedFps',
        'extraction_run_id': 'run-abc',
        'file_path': '/frames/f_00000.png',
        'created_at': now,
      });
      expect(frameId, greaterThan(0));

      final frames = await db.query(
        'video_frames',
        where: 'video_asset_id = ?',
        whereArgs: [vaId],
      );
      expect(frames.length, 1);
      expect(frames.first['frame_index'], 0);
      expect(frames.first['sampling_policy'], 'fixedFps');
    });

    test('insert annotation_track and track_keyframe', () async {
      final vaId = await db.insert('video_assets', {
        'uuid': 'va-003',
        'project_id': projectId,
        'file_path': '/v.mp4',
        'file_name': 'v.mp4',
        'created_at': now,
        'updated_at': now,
      });
      final frameId = await db.insert('video_frames', {
        'video_asset_id': vaId,
        'frame_index': 5,
        'timestamp_ms': 166.7,
        'source_fps': 30.0,
        'sampling_policy': 'fixedFps',
        'extraction_run_id': 'run-def',
        'created_at': now,
      });

      final trackId = await db.insert('annotation_tracks', {
        'uuid': 'track-001',
        'video_asset_id': vaId,
        'status': 'active',
        'annotation_type': 'bbox',
        'created_at': now,
        'updated_at': now,
      });
      expect(trackId, greaterThan(0));

      final kfId = await db.insert('track_keyframes', {
        'track_id': trackId,
        'frame_id': frameId,
        'geometry': '{"x":10,"y":20,"width":100,"height":50}',
        'confidence': 0.95,
        'is_manual': 1,
        'created_at': now,
        'updated_at': now,
      });
      expect(kfId, greaterThan(0));

      final kfs = await db.query(
        'track_keyframes',
        where: 'track_id = ?',
        whereArgs: [trackId],
      );
      expect(kfs.length, 1);
      expect(kfs.first['geometry'], contains('width'));
      expect(kfs.first['confidence'], 0.95);
    });

    test('cascade delete: deleting video_asset removes frames, tracks, keyframes', () async {
      final vaId = await db.insert('video_assets', {
        'uuid': 'va-cascade',
        'project_id': projectId,
        'file_path': '/v.mp4',
        'file_name': 'v.mp4',
        'created_at': now,
        'updated_at': now,
      });
      final fId = await db.insert('video_frames', {
        'video_asset_id': vaId,
        'frame_index': 0,
        'extraction_run_id': 'run-cas',
        'created_at': now,
      });
      final tId = await db.insert('annotation_tracks', {
        'uuid': 'track-cas',
        'video_asset_id': vaId,
        'created_at': now,
        'updated_at': now,
      });
      await db.insert('track_keyframes', {
        'track_id': tId,
        'frame_id': fId,
        'geometry': '{}',
        'created_at': now,
        'updated_at': now,
      });

      await db.delete('video_assets', where: 'id = ?', whereArgs: [vaId]);

      expect(await db.query('video_frames', where: 'video_asset_id = ?', whereArgs: [vaId]), isEmpty);
      expect(await db.query('annotation_tracks', where: 'video_asset_id = ?', whereArgs: [vaId]), isEmpty);
      expect(await db.query('track_keyframes', where: 'track_id = ?', whereArgs: [tId]), isEmpty);
    });

    test('uuid uniqueness is enforced on video_assets', () async {
      await db.insert('video_assets', {
        'uuid': 'unique-uuid',
        'project_id': projectId,
        'file_path': '/a.mp4',
        'file_name': 'a.mp4',
        'created_at': now,
        'updated_at': now,
      });

      expect(
        () => db.insert('video_assets', {
          'uuid': 'unique-uuid',
          'project_id': projectId,
          'file_path': '/b.mp4',
          'file_name': 'b.mp4',
          'created_at': now,
          'updated_at': now,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
