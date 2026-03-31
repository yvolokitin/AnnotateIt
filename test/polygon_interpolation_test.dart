import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:annotateit/models/polygon_geometry.dart';
import 'package:annotateit/models/video_asset.dart';
import 'package:annotateit/models/video_frame.dart';
import 'package:annotateit/models/frame_identity.dart';
import 'package:annotateit/repositories/sqlite_video_asset_repository.dart';
import 'package:annotateit/repositories/sqlite_video_frame_repository.dart';
import 'package:annotateit/repositories/sqlite_track_repository.dart';
import 'package:annotateit/usecases/track_usecases.dart';

void main() {
  // -----------------------------------------------------------------------
  // Point2D
  // -----------------------------------------------------------------------

  group('Point2D', () {
    test('lerp at t=0 returns a', () {
      const a = Point2D(0, 0);
      const b = Point2D(10, 20);
      final result = Point2D.lerp(a, b, 0.0);
      expect(result.x, 0);
      expect(result.y, 0);
    });

    test('lerp at t=1 returns b', () {
      const a = Point2D(0, 0);
      const b = Point2D(10, 20);
      final result = Point2D.lerp(a, b, 1.0);
      expect(result.x, 10);
      expect(result.y, 20);
    });

    test('lerp at t=0.5 returns midpoint', () {
      const a = Point2D(0, 0);
      const b = Point2D(10, 20);
      final result = Point2D.lerp(a, b, 0.5);
      expect(result.x, closeTo(5, 0.01));
      expect(result.y, closeTo(10, 0.01));
    });

    test('distanceTo computes Euclidean distance', () {
      const a = Point2D(0, 0);
      const b = Point2D(3, 4);
      expect(a.distanceTo(b), closeTo(5, 0.01));
    });

    test('equality', () {
      expect(const Point2D(1, 2), const Point2D(1, 2));
      expect(const Point2D(1, 2), isNot(const Point2D(1, 3)));
    });
  });

  // -----------------------------------------------------------------------
  // PolygonGeometry serialisation
  // -----------------------------------------------------------------------

  group('PolygonGeometry serialisation', () {
    test('toMap / fromMap roundtrip', () {
      final poly = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(100, 0),
        const Point2D(100, 100),
        const Point2D(0, 100),
      ]);
      final restored = PolygonGeometry.fromMap(poly.toMap());
      expect(restored.vertexCount, 4);
      expect(restored.vertices[0], const Point2D(0, 0));
      expect(restored.vertices[2], const Point2D(100, 100));
      expect(restored.closed, true);
    });

    test('toJson / fromJson roundtrip', () {
      final poly = PolygonGeometry(
        vertices: [
          const Point2D(10, 20),
          const Point2D(30, 40),
          const Point2D(50, 60),
        ],
        closed: false,
      );
      final restored = PolygonGeometry.fromJson(poly.toJson());
      expect(restored.vertexCount, 3);
      expect(restored.closed, false);
    });

    test('fromMap handles missing points gracefully', () {
      final poly = PolygonGeometry.fromMap({});
      expect(poly.vertexCount, 0);
      expect(poly.isValid, false);
    });

    test('fromMap handles odd-length points list', () {
      final poly = PolygonGeometry.fromMap({
        'points': [1.0, 2.0, 3.0],
      });
      expect(poly.vertexCount, 1);
      expect(poly.vertices[0], const Point2D(1, 2));
    });
  });

  // -----------------------------------------------------------------------
  // PolygonGeometry resample
  // -----------------------------------------------------------------------

  group('PolygonGeometry.resample', () {
    test('returns same polygon when target count matches', () {
      final poly = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(10, 0),
        const Point2D(10, 10),
      ]);
      final resampled = poly.resample(3);
      expect(resampled.vertexCount, 3);
      expect(identical(resampled, poly), true);
    });

    test('upsamples a triangle to 6 vertices', () {
      final poly = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(10, 0),
        const Point2D(0, 10),
      ]);
      final resampled = poly.resample(6);
      expect(resampled.vertexCount, 6);
    });

    test('downsamples preserves vertex count', () {
      final poly = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(5, 0),
        const Point2D(10, 0),
        const Point2D(10, 5),
        const Point2D(10, 10),
        const Point2D(0, 10),
      ]);
      final resampled = poly.resample(3);
      expect(resampled.vertexCount, 3);
    });

    test('single vertex replicates', () {
      final poly = PolygonGeometry(vertices: [const Point2D(5, 5)]);
      final resampled = poly.resample(4);
      expect(resampled.vertexCount, 4);
      for (final v in resampled.vertices) {
        expect(v, const Point2D(5, 5));
      }
    });

    test('empty polygon returns empty', () {
      final resampled = PolygonGeometry.empty.resample(5);
      expect(resampled.vertexCount, 0);
    });
  });

  // -----------------------------------------------------------------------
  // InterpolationQuality assessment
  // -----------------------------------------------------------------------

  group('InterpolationQuality', () {
    test('same vertex count → high', () {
      expect(PolygonGeometry.assessQuality(10, 10), InterpolationQuality.high);
    });

    test('similar vertex count → high', () {
      expect(PolygonGeometry.assessQuality(10, 11), InterpolationQuality.high);
    });

    test('moderate difference → medium', () {
      expect(PolygonGeometry.assessQuality(10, 15), InterpolationQuality.medium);
    });

    test('large difference → low', () {
      expect(PolygonGeometry.assessQuality(3, 20), InterpolationQuality.low);
    });

    test('zero vertex count → low', () {
      expect(PolygonGeometry.assessQuality(0, 5), InterpolationQuality.low);
      expect(PolygonGeometry.assessQuality(5, 0), InterpolationQuality.low);
    });
  });

  // -----------------------------------------------------------------------
  // PolygonGeometry.lerp
  // -----------------------------------------------------------------------

  group('PolygonGeometry.lerp', () {
    test('t=0 returns start polygon', () {
      final a = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(10, 0),
        const Point2D(10, 10),
      ]);
      final b = PolygonGeometry(vertices: [
        const Point2D(100, 100),
        const Point2D(200, 100),
        const Point2D(200, 200),
      ]);
      final result = PolygonGeometry.lerp(a, b, 0.0);
      expect(result.polygon.vertexCount, 3);
      expect(result.polygon.vertices[0].x, closeTo(0, 0.01));
      expect(result.polygon.vertices[0].y, closeTo(0, 0.01));
      expect(result.quality, InterpolationQuality.high);
    });

    test('t=1 returns end polygon', () {
      final a = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(10, 0),
        const Point2D(10, 10),
      ]);
      final b = PolygonGeometry(vertices: [
        const Point2D(100, 100),
        const Point2D(200, 100),
        const Point2D(200, 200),
      ]);
      final result = PolygonGeometry.lerp(a, b, 1.0);
      expect(result.polygon.vertices[0].x, closeTo(100, 0.5));
      expect(result.polygon.vertices[0].y, closeTo(100, 0.5));
    });

    test('t=0.5 returns midpoint vertices', () {
      final a = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(10, 0),
        const Point2D(10, 10),
      ]);
      final b = PolygonGeometry(vertices: [
        const Point2D(20, 20),
        const Point2D(30, 20),
        const Point2D(30, 30),
      ]);
      final result = PolygonGeometry.lerp(a, b, 0.5);
      expect(result.polygon.vertices[0].x, closeTo(10, 0.5));
      expect(result.polygon.vertices[0].y, closeTo(10, 0.5));
    });

    test('different vertex counts triggers resampling with quality', () {
      final a = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(10, 0),
        const Point2D(10, 10),
      ]);
      final b = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(5, 0),
        const Point2D(10, 0),
        const Point2D(10, 5),
        const Point2D(10, 10),
        const Point2D(0, 10),
      ]);
      final result = PolygonGeometry.lerp(a, b, 0.5);
      expect(result.polygon.vertexCount, 6);
      expect(result.quality, InterpolationQuality.medium);
    });

    test('empty polygons → high quality empty result', () {
      final result = PolygonGeometry.lerp(
        PolygonGeometry.empty,
        PolygonGeometry.empty,
        0.5,
      );
      expect(result.polygon.vertexCount, 0);
      expect(result.quality, InterpolationQuality.high);
    });
  });

  // -----------------------------------------------------------------------
  // InterpolatedFrame quality & warning badge
  // -----------------------------------------------------------------------

  group('InterpolatedFrame polygon helpers', () {
    test('polygon accessor parses correctly', () {
      final geo = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(10, 0),
        const Point2D(10, 10),
      ]).toMap();
      final frame = InterpolatedFrame(
        frameId: 1,
        geometry: geo,
        confidence: 1.0,
        isManual: true,
      );
      expect(frame.polygon.vertexCount, 3);
    });

    test('showWarningBadge true for low quality non-manual', () {
      final frame = InterpolatedFrame(
        frameId: 1,
        geometry: {},
        confidence: 0.5,
        isManual: false,
        quality: InterpolationQuality.low,
      );
      expect(frame.showWarningBadge, true);
    });

    test('showWarningBadge false for manual even if low quality', () {
      final frame = InterpolatedFrame(
        frameId: 1,
        geometry: {},
        confidence: 1.0,
        isManual: true,
        quality: InterpolationQuality.low,
      );
      expect(frame.showWarningBadge, false);
    });

    test('showWarningBadge false for high quality non-manual', () {
      final frame = InterpolatedFrame(
        frameId: 1,
        geometry: {},
        confidence: 1.0,
        isManual: false,
        quality: InterpolationQuality.high,
      );
      expect(frame.showWarningBadge, false);
    });
  });

  // -----------------------------------------------------------------------
  // InterpolateTrackSegment integration (polygon type)
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

  group('InterpolateTrackSegment with polygon type', () {
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

    test('interpolates polygon vertices linearly (same vertex count)', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 5);
      final track = await CreateTrack(trackRepo)(
        videoAssetId: asset.id!,
        annotationType: 'polygon',
      );

      final polyA = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(100, 0),
        const Point2D(100, 100),
      ]);
      final polyB = PolygonGeometry(vertices: [
        const Point2D(200, 200),
        const Point2D(300, 200),
        const Point2D(300, 300),
      ]);

      await AddKeyframe(trackRepo)(
        trackId: track.id!,
        frameId: frames[0].id!,
        geometry: polyA.toMap(),
      );
      await AddKeyframe(trackRepo)(
        trackId: track.id!,
        frameId: frames[4].id!,
        geometry: polyB.toMap(),
      );

      final results = await InterpolateTrackSegment(trackRepo, frameRepo)(
        trackId: track.id!,
        videoAssetId: asset.id!,
        annotationType: 'polygon',
      );

      expect(results.length, 5);

      expect(results[0].isManual, true);
      expect(results[0].quality, InterpolationQuality.high);

      final mid = results[2];
      expect(mid.isManual, false);
      expect(mid.quality, InterpolationQuality.high);

      final midPoly = mid.polygon;
      expect(midPoly.vertexCount, 3);
      expect(midPoly.vertices[0].x, closeTo(100, 1));
      expect(midPoly.vertices[0].y, closeTo(100, 1));

      expect(results[4].isManual, true);
    });

    test('different vertex counts produce medium quality', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 3);
      final track = await CreateTrack(trackRepo)(
        videoAssetId: asset.id!,
        annotationType: 'polygon',
      );

      final polyA = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(10, 0),
        const Point2D(10, 10),
        const Point2D(0, 10),
      ]);
      final polyB = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(5, 0),
        const Point2D(10, 0),
        const Point2D(10, 5),
        const Point2D(10, 10),
        const Point2D(5, 10),
        const Point2D(0, 10),
      ]);

      await AddKeyframe(trackRepo)(
        trackId: track.id!,
        frameId: frames[0].id!,
        geometry: polyA.toMap(),
      );
      await AddKeyframe(trackRepo)(
        trackId: track.id!,
        frameId: frames[2].id!,
        geometry: polyB.toMap(),
      );

      final results = await InterpolateTrackSegment(trackRepo, frameRepo)(
        trackId: track.id!,
        videoAssetId: asset.id!,
        annotationType: 'polygon',
      );

      expect(results.length, 3);
      final mid = results[1];
      expect(mid.isManual, false);
      expect(mid.quality, InterpolationQuality.medium);
      expect(mid.showWarningBadge, false);
    });

    test('vastly different vertex counts produce low quality + warning badge', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 3);
      final track = await CreateTrack(trackRepo)(
        videoAssetId: asset.id!,
        annotationType: 'polygon',
      );

      final polyA = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(10, 0),
        const Point2D(10, 10),
      ]);
      // 10 vertices — ratio = 3/10 = 0.3 → low
      final polyB = PolygonGeometry(vertices: List.generate(
        10,
        (i) => Point2D(i * 10.0, i * 5.0),
      ));

      await AddKeyframe(trackRepo)(
        trackId: track.id!,
        frameId: frames[0].id!,
        geometry: polyA.toMap(),
      );
      await AddKeyframe(trackRepo)(
        trackId: track.id!,
        frameId: frames[2].id!,
        geometry: polyB.toMap(),
      );

      final results = await InterpolateTrackSegment(trackRepo, frameRepo)(
        trackId: track.id!,
        videoAssetId: asset.id!,
        annotationType: 'polygon',
      );

      expect(results.length, 3);
      final mid = results[1];
      expect(mid.quality, InterpolationQuality.low);
      expect(mid.showWarningBadge, true);
    });

    test('polygon type falls back to generic lerp without points key', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 3);
      final track = await CreateTrack(trackRepo)(
        videoAssetId: asset.id!,
        annotationType: 'polygon',
      );

      await AddKeyframe(trackRepo)(
        trackId: track.id!,
        frameId: frames[0].id!,
        geometry: {'x': 0.0, 'y': 0.0},
      );
      await AddKeyframe(trackRepo)(
        trackId: track.id!,
        frameId: frames[2].id!,
        geometry: {'x': 100.0, 'y': 200.0},
      );

      final results = await InterpolateTrackSegment(trackRepo, frameRepo)(
        trackId: track.id!,
        videoAssetId: asset.id!,
        annotationType: 'polygon',
      );

      expect(results.length, 3);
      final mid = results[1];
      expect(mid.isManual, false);
      expect(mid.quality, InterpolationQuality.high);
      expect((mid.geometry['x'] as num).toDouble(), closeTo(50, 0.01));
      expect((mid.geometry['y'] as num).toDouble(), closeTo(100, 0.01));
    });
  });

  // -----------------------------------------------------------------------
  // PolygonGeometry helpers
  // -----------------------------------------------------------------------

  group('PolygonGeometry helpers', () {
    test('perimeter of unit square', () {
      final poly = PolygonGeometry(vertices: [
        const Point2D(0, 0),
        const Point2D(1, 0),
        const Point2D(1, 1),
        const Point2D(0, 1),
      ]);
      expect(poly.perimeter, closeTo(4.0, 0.01));
    });

    test('isValid requires >= 3 vertices', () {
      expect(PolygonGeometry.empty.isValid, false);
      expect(
        PolygonGeometry(vertices: [const Point2D(0, 0), const Point2D(1, 1)]).isValid,
        false,
      );
      expect(
        PolygonGeometry(vertices: [
          const Point2D(0, 0),
          const Point2D(1, 0),
          const Point2D(0, 1),
        ]).isValid,
        true,
      );
    });

    test('equality', () {
      final a = PolygonGeometry(vertices: [const Point2D(1, 2), const Point2D(3, 4), const Point2D(5, 6)]);
      final b = PolygonGeometry(vertices: [const Point2D(1, 2), const Point2D(3, 4), const Point2D(5, 6)]);
      expect(a, b);
    });
  });
}
