import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:annotateit/models/bbox_geometry.dart';
import 'package:annotateit/models/video_asset.dart';
import 'package:annotateit/models/video_frame.dart';
import 'package:annotateit/models/frame_identity.dart';
import 'package:annotateit/repositories/sqlite_video_asset_repository.dart';
import 'package:annotateit/repositories/sqlite_video_frame_repository.dart';
import 'package:annotateit/repositories/sqlite_track_repository.dart';
import 'package:annotateit/usecases/track_usecases.dart';
import 'package:annotateit/controllers/timeline_controller.dart';

void main() {
  // -----------------------------------------------------------------------
  // BboxGeometry pure-logic tests (no DB needed)
  // -----------------------------------------------------------------------

  group('BboxGeometry', () {
    test('toMap / fromMap roundtrip', () {
      const bbox = BboxGeometry(x: 10, y: 20, width: 100, height: 50, rotation: 0.5);
      final restored = BboxGeometry.fromMap(bbox.toMap());
      expect(restored, bbox);
    });

    test('toJson / fromJson roundtrip', () {
      const bbox = BboxGeometry(x: 5, y: 15, width: 200, height: 100, rotation: 1.2);
      final restored = BboxGeometry.fromJson(bbox.toJson());
      expect(restored, bbox);
    });

    test('fromMap defaults rotation to 0 when absent', () {
      final bbox = BboxGeometry.fromMap({'x': 0, 'y': 0, 'width': 10, 'height': 10});
      expect(bbox.rotation, 0.0);
    });

    test('zero constant', () {
      expect(BboxGeometry.zero.x, 0);
      expect(BboxGeometry.zero.area, 0);
      expect(BboxGeometry.zero.isValid, false);
    });

    test('isValid', () {
      expect(const BboxGeometry(x: 0, y: 0, width: 10, height: 10).isValid, true);
      expect(const BboxGeometry(x: 0, y: 0, width: 0, height: 10).isValid, false);
      expect(const BboxGeometry(x: 0, y: 0, width: 10, height: 0).isValid, false);
    });

    test('centerX / centerY', () {
      const bbox = BboxGeometry(x: 10, y: 20, width: 100, height: 60);
      expect(bbox.centerX, 60);
      expect(bbox.centerY, 50);
    });

    test('area', () {
      const bbox = BboxGeometry(x: 0, y: 0, width: 10, height: 5);
      expect(bbox.area, 50);
    });

    test('copyWith', () {
      const bbox = BboxGeometry(x: 1, y: 2, width: 3, height: 4, rotation: 0.1);
      final modified = bbox.copyWith(width: 99);
      expect(modified.width, 99);
      expect(modified.x, 1);
      expect(modified.rotation, 0.1);
    });
  });

  group('BboxGeometry.lerp', () {
    test('t=0 returns start', () {
      const a = BboxGeometry(x: 0, y: 0, width: 100, height: 50);
      const b = BboxGeometry(x: 200, y: 100, width: 300, height: 150);
      final result = BboxGeometry.lerp(a, b, 0.0);
      expect(result.x, 0);
      expect(result.y, 0);
      expect(result.width, 100);
      expect(result.height, 50);
    });

    test('t=1 returns end', () {
      const a = BboxGeometry(x: 0, y: 0, width: 100, height: 50);
      const b = BboxGeometry(x: 200, y: 100, width: 300, height: 150);
      final result = BboxGeometry.lerp(a, b, 1.0);
      expect(result.x, 200);
      expect(result.y, 100);
      expect(result.width, 300);
      expect(result.height, 150);
    });

    test('t=0.5 returns midpoint', () {
      const a = BboxGeometry(x: 0, y: 0, width: 100, height: 50);
      const b = BboxGeometry(x: 200, y: 100, width: 300, height: 150);
      final result = BboxGeometry.lerp(a, b, 0.5);
      expect(result.x, closeTo(100, 0.01));
      expect(result.y, closeTo(50, 0.01));
      expect(result.width, closeTo(200, 0.01));
      expect(result.height, closeTo(100, 0.01));
    });

    test('t=0.25 returns quarter point', () {
      const a = BboxGeometry(x: 0, y: 0, width: 100, height: 100);
      const b = BboxGeometry(x: 400, y: 400, width: 500, height: 500);
      final result = BboxGeometry.lerp(a, b, 0.25);
      expect(result.x, closeTo(100, 0.01));
      expect(result.y, closeTo(100, 0.01));
      expect(result.width, closeTo(200, 0.01));
      expect(result.height, closeTo(200, 0.01));
    });

    test('rotation uses shortest arc: 350° → 10° goes through 0°', () {
      final a = BboxGeometry(
        x: 0, y: 0, width: 10, height: 10,
        rotation: 350 * math.pi / 180,
      );
      final b = BboxGeometry(
        x: 0, y: 0, width: 10, height: 10,
        rotation: 10 * math.pi / 180,
      );
      final mid = BboxGeometry.lerp(a, b, 0.5);
      final midDeg = mid.rotation * 180 / math.pi;
      // Should be close to 0° (or 360°), not 180°
      expect(midDeg.abs() % 360, closeTo(0, 2));
    });

    test('rotation interpolates linearly for small angles', () {
      const a = BboxGeometry(x: 0, y: 0, width: 10, height: 10, rotation: 0.0);
      final b = BboxGeometry(
        x: 0, y: 0, width: 10, height: 10,
        rotation: math.pi / 2,
      );
      final mid = BboxGeometry.lerp(a, b, 0.5);
      expect(mid.rotation, closeTo(math.pi / 4, 0.001));
    });

    test('rotation handles identical angles', () {
      const a = BboxGeometry(x: 0, y: 0, width: 10, height: 10, rotation: 1.0);
      const b = BboxGeometry(x: 0, y: 0, width: 10, height: 10, rotation: 1.0);
      final mid = BboxGeometry.lerp(a, b, 0.5);
      expect(mid.rotation, closeTo(1.0, 0.001));
    });
  });

  // -----------------------------------------------------------------------
  // InterpolateTrackSegment integration tests with DB
  // -----------------------------------------------------------------------

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<Database> openTestDb() async {
    final db = await openDatabase(inMemoryDatabasePath, version: 1);
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, firstName TEXT NOT NULL, createdAt TEXT NOT NULL)');
    await db.execute('CREATE TABLE projects (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, ownerId INTEGER NOT NULL, FOREIGN KEY(ownerId) REFERENCES users(id))');
    await db.execute('CREATE TABLE labels (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, project_id INTEGER NOT NULL, FOREIGN KEY(project_id) REFERENCES projects(id))');
    await db.execute('CREATE TABLE media_items (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT UNIQUE, type TEXT)');
    await db.execute('''CREATE TABLE video_assets (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT UNIQUE NOT NULL, media_item_id INTEGER, project_id INTEGER NOT NULL, file_path TEXT NOT NULL, file_name TEXT NOT NULL, width INTEGER NOT NULL DEFAULT 0, height INTEGER NOT NULL DEFAULT 0, duration_sec REAL NOT NULL DEFAULT 0.0, fps_nominal REAL NOT NULL DEFAULT 0.0, frame_count_estimate INTEGER NOT NULL DEFAULT 0, codec TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY(media_item_id) REFERENCES media_items(id) ON DELETE SET NULL, FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE)''');
    await db.execute('''CREATE TABLE video_frames (id INTEGER PRIMARY KEY AUTOINCREMENT, video_asset_id INTEGER NOT NULL, media_item_id INTEGER, frame_index INTEGER NOT NULL, timestamp_ms REAL NOT NULL DEFAULT 0.0, source_fps REAL NOT NULL DEFAULT 0.0, sampling_policy TEXT NOT NULL DEFAULT 'fixedFps', extraction_run_id TEXT NOT NULL, file_path TEXT, created_at TEXT NOT NULL, FOREIGN KEY(video_asset_id) REFERENCES video_assets(id) ON DELETE CASCADE, FOREIGN KEY(media_item_id) REFERENCES media_items(id) ON DELETE SET NULL)''');
    await db.execute('''CREATE TABLE annotation_tracks (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT UNIQUE NOT NULL, video_asset_id INTEGER NOT NULL, label_id INTEGER, status TEXT NOT NULL DEFAULT 'active', annotation_type TEXT NOT NULL DEFAULT 'bbox', review_status TEXT NOT NULL DEFAULT 'draft', reviewed_by INTEGER, reviewed_at TEXT, review_comment TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY(video_asset_id) REFERENCES video_assets(id) ON DELETE CASCADE, FOREIGN KEY(label_id) REFERENCES labels(id) ON DELETE SET NULL)''');
    await db.execute('''CREATE TABLE track_keyframes (id INTEGER PRIMARY KEY AUTOINCREMENT, track_id INTEGER NOT NULL, frame_id INTEGER NOT NULL, geometry TEXT NOT NULL, confidence REAL DEFAULT 1.0, is_manual INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY(track_id) REFERENCES annotation_tracks(id) ON DELETE CASCADE, FOREIGN KEY(frame_id) REFERENCES video_frames(id) ON DELETE CASCADE)''');
    return db;
  }

  Future<int> seedProject(Database db) async {
    final now = DateTime.now().toIso8601String();
    final uid = await db.insert('users', {'firstName': 'T', 'createdAt': now});
    return await db.insert('projects', {'name': 'P', 'ownerId': uid});
  }

  Future<VideoAsset> seedAsset(SqliteVideoAssetRepository repo, int pid) async {
    final now = DateTime.now();
    final a = VideoAsset(uuid: 'va-${now.microsecondsSinceEpoch}', projectId: pid, filePath: '/v.mp4', fileName: 'v.mp4', createdAt: now, updatedAt: now);
    return a.copyWith(id: await repo.insert(a));
  }

  Future<List<VideoFrame>> seedFrames(SqliteVideoFrameRepository repo, int vaId, int n) async {
    final now = DateTime.now();
    final result = <VideoFrame>[];
    for (int i = 0; i < n; i++) {
      final f = VideoFrame(videoAssetId: vaId, frameIndex: i, timestampMs: i * 33.33, sourceFps: 30.0, samplingPolicy: SamplingPolicy.fixedFps, extractionRunId: 'run', createdAt: now);
      final id = await repo.insert(f);
      result.add(VideoFrame(id: id, videoAssetId: vaId, frameIndex: i, timestampMs: i * 33.33, sourceFps: 30.0, extractionRunId: 'run', createdAt: now));
    }
    return result;
  }

  group('InterpolateTrackSegment with BboxGeometry', () {
    late Database db;
    late SqliteVideoAssetRepository assetRepo;
    late SqliteVideoFrameRepository frameRepo;
    late SqliteTrackRepository trackRepo;
    late int projectId;

    setUp(() async {
      db = await openTestDb();
      assetRepo = SqliteVideoAssetRepository(db);
      frameRepo = SqliteVideoFrameRepository(db);
      trackRepo = SqliteTrackRepository(db);
      projectId = await seedProject(db);
    });

    tearDown(() async => await db.close());

    test('interpolates bbox x/y/w/h linearly with rotation', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 5);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      final bboxA = const BboxGeometry(x: 0, y: 0, width: 100, height: 50, rotation: 0.0);
      final bboxB = const BboxGeometry(x: 200, y: 100, width: 300, height: 150, rotation: math.pi / 2);

      await AddKeyframe(trackRepo)(trackId: track.id!, frameId: frames[0].id!, geometry: bboxA.toMap());
      await AddKeyframe(trackRepo)(trackId: track.id!, frameId: frames[4].id!, geometry: bboxB.toMap());

      final results = await InterpolateTrackSegment(trackRepo, frameRepo)(
        trackId: track.id!,
        videoAssetId: asset.id!,
        annotationType: 'bbox',
      );

      expect(results.length, 5);

      // Frame 0 = manual keyframe A
      expect(results[0].isManual, true);
      expect(results[0].bbox.x, closeTo(0, 0.01));

      // Frame 2 = interpolated midpoint
      final mid = results[2];
      expect(mid.isManual, false);
      expect(mid.bbox.x, closeTo(100, 0.01));
      expect(mid.bbox.y, closeTo(50, 0.01));
      expect(mid.bbox.width, closeTo(200, 0.01));
      expect(mid.bbox.height, closeTo(100, 0.01));
      expect(mid.bbox.rotation, closeTo(math.pi / 4, 0.01));

      // Frame 4 = manual keyframe B
      expect(results[4].isManual, true);
      expect(results[4].bbox.x, closeTo(200, 0.01));
    });

    test('isManual distinguishes keyframes from interpolated', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 5);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      await AddKeyframe(trackRepo)(trackId: track.id!, frameId: frames[0].id!, geometry: {'x': 0.0, 'y': 0.0, 'width': 10.0, 'height': 10.0});
      await AddKeyframe(trackRepo)(trackId: track.id!, frameId: frames[4].id!, geometry: {'x': 40.0, 'y': 40.0, 'width': 50.0, 'height': 50.0});

      final results = await InterpolateTrackSegment(trackRepo, frameRepo)(
        trackId: track.id!,
        videoAssetId: asset.id!,
      );

      final manualFrames = results.where((f) => f.isManual).toList();
      final interpolatedFrames = results.where((f) => !f.isManual).toList();

      expect(manualFrames.length, 2);
      expect(interpolatedFrames.length, 3);
    });

    test('InterpolatedFrame.bbox convenience accessor works', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 3);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      const geo = BboxGeometry(x: 10, y: 20, width: 30, height: 40, rotation: 0.5);
      await AddKeyframe(trackRepo)(trackId: track.id!, frameId: frames[1].id!, geometry: geo.toMap());

      final results = await InterpolateTrackSegment(trackRepo, frameRepo)(
        trackId: track.id!,
        videoAssetId: asset.id!,
      );

      expect(results.length, 1);
      final bbox = results.first.bbox;
      expect(bbox.x, 10);
      expect(bbox.y, 20);
      expect(bbox.width, 30);
      expect(bbox.height, 40);
      expect(bbox.rotation, closeTo(0.5, 0.001));
    });

    test('adjacent keyframes produce no interpolated frames between them', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 5);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      await AddKeyframe(trackRepo)(trackId: track.id!, frameId: frames[2].id!, geometry: {'x': 0.0, 'y': 0.0, 'width': 10.0, 'height': 10.0});
      await AddKeyframe(trackRepo)(trackId: track.id!, frameId: frames[3].id!, geometry: {'x': 10.0, 'y': 10.0, 'width': 20.0, 'height': 20.0});

      final results = await InterpolateTrackSegment(trackRepo, frameRepo)(
        trackId: track.id!,
        videoAssetId: asset.id!,
      );

      expect(results.length, 2);
      expect(results.every((f) => f.isManual), true);
    });
  });

  group('TimelineController showInterpolated toggle', () {
    late TimelineController ctrl;

    setUp(() {
      ctrl = TimelineController(totalFrames: 50, sourceFps: 30.0);
    });

    tearDown(() => ctrl.dispose());

    test('defaults to true', () {
      expect(ctrl.showInterpolated, true);
    });

    test('toggleShowInterpolated flips value', () {
      ctrl.toggleShowInterpolated();
      expect(ctrl.showInterpolated, false);
      ctrl.toggleShowInterpolated();
      expect(ctrl.showInterpolated, true);
    });

    test('setter notifies listeners', () {
      int count = 0;
      ctrl.addListener(() => count++);
      ctrl.showInterpolated = false;
      expect(count, 1);
    });

    test('setter does not notify when value unchanged', () {
      int count = 0;
      ctrl.addListener(() => count++);
      ctrl.showInterpolated = true;
      expect(count, 0);
    });
  });
}
