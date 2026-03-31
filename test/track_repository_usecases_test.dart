import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:annotateit/models/annotation_track.dart';
import 'package:annotateit/models/track_keyframe.dart';
import 'package:annotateit/models/video_asset.dart';
import 'package:annotateit/models/video_frame.dart';
import 'package:annotateit/models/frame_identity.dart';
import 'package:annotateit/repositories/sqlite_video_asset_repository.dart';
import 'package:annotateit/repositories/sqlite_video_frame_repository.dart';
import 'package:annotateit/repositories/sqlite_track_repository.dart';
import 'package:annotateit/usecases/track_usecases.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<Database> openTestDb() async {
    final db = await openDatabase(inMemoryDatabasePath, version: 1);
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
        FOREIGN KEY(ownerId) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE labels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        project_id INTEGER NOT NULL,
        FOREIGN KEY(project_id) REFERENCES projects(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE media_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE,
        type TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE video_assets (
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
      CREATE TABLE video_frames (
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
      CREATE TABLE annotation_tracks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE NOT NULL,
        video_asset_id INTEGER NOT NULL,
        label_id INTEGER,
        status TEXT NOT NULL DEFAULT 'active',
        annotation_type TEXT NOT NULL DEFAULT 'bbox',
        review_status TEXT NOT NULL DEFAULT 'draft',
        reviewed_by INTEGER,
        reviewed_at TEXT,
        review_comment TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(video_asset_id) REFERENCES video_assets(id) ON DELETE CASCADE,
        FOREIGN KEY(label_id) REFERENCES labels(id) ON DELETE SET NULL,
        FOREIGN KEY(reviewed_by) REFERENCES users(id) ON DELETE SET NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE track_keyframes (
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

    await db.execute('CREATE INDEX IF NOT EXISTS idx_video_frames_asset_index ON video_frames(video_asset_id, frame_index)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_track_keyframes_track ON track_keyframes(track_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_track_keyframes_frame ON track_keyframes(frame_id)');

    return db;
  }

  /// Seed user + project, return projectId.
  Future<int> seedProject(Database db) async {
    final now = DateTime.now().toIso8601String();
    final userId = await db.insert('users', {'firstName': 'T', 'createdAt': now});
    return await db.insert('projects', {'name': 'P', 'ownerId': userId});
  }

  /// Insert a video asset and return it with DB id.
  Future<VideoAsset> seedVideoAsset(
    SqliteVideoAssetRepository repo,
    int projectId,
  ) async {
    final now = DateTime.now();
    final asset = VideoAsset(
      uuid: 'va-${now.microsecondsSinceEpoch}',
      projectId: projectId,
      filePath: '/test.mp4',
      fileName: 'test.mp4',
      width: 1920,
      height: 1080,
      durationSec: 10.0,
      fpsNominal: 30.0,
      frameCountEstimate: 300,
      codec: 'h264',
      createdAt: now,
      updatedAt: now,
    );
    final id = await repo.insert(asset);
    return asset.copyWith(id: id);
  }

  /// Insert N video frames and return them with DB ids.
  Future<List<VideoFrame>> seedFrames(
    SqliteVideoFrameRepository repo,
    int videoAssetId,
    int count,
  ) async {
    final now = DateTime.now();
    final frames = <VideoFrame>[];
    for (int i = 0; i < count; i++) {
      final frame = VideoFrame(
        videoAssetId: videoAssetId,
        frameIndex: i,
        timestampMs: i * 33.33,
        sourceFps: 30.0,
        samplingPolicy: SamplingPolicy.fixedFps,
        extractionRunId: 'run-test',
        filePath: '/frames/f_$i.png',
        createdAt: now,
      );
      final id = await repo.insert(frame);
      frames.add(VideoFrame(
        id: id,
        videoAssetId: videoAssetId,
        frameIndex: i,
        timestampMs: i * 33.33,
        sourceFps: 30.0,
        samplingPolicy: SamplingPolicy.fixedFps,
        extractionRunId: 'run-test',
        filePath: '/frames/f_$i.png',
        createdAt: now,
      ));
    }
    return frames;
  }

  // ---------------------------------------------------------------------------
  // VideoAssetRepository
  // ---------------------------------------------------------------------------

  group('VideoAssetRepository', () {
    late Database db;
    late SqliteVideoAssetRepository repo;
    late int projectId;

    setUp(() async {
      db = await openTestDb();
      repo = SqliteVideoAssetRepository(db);
      projectId = await seedProject(db);
    });

    tearDown(() async => await db.close());

    test('insert and findById', () async {
      final asset = await seedVideoAsset(repo, projectId);
      final found = await repo.findById(asset.id!);
      expect(found, isNotNull);
      expect(found!.uuid, asset.uuid);
      expect(found.width, 1920);
    });

    test('findByUuid', () async {
      final asset = await seedVideoAsset(repo, projectId);
      final found = await repo.findByUuid(asset.uuid);
      expect(found, isNotNull);
      expect(found!.id, asset.id);
    });

    test('findByProject', () async {
      await seedVideoAsset(repo, projectId);
      await seedVideoAsset(repo, projectId);
      final list = await repo.findByProject(projectId);
      expect(list.length, 2);
    });

    test('update', () async {
      final asset = await seedVideoAsset(repo, projectId);
      await repo.update(asset.copyWith(codec: 'h265'));
      final updated = await repo.findById(asset.id!);
      expect(updated!.codec, 'h265');
    });

    test('delete', () async {
      final asset = await seedVideoAsset(repo, projectId);
      await repo.delete(asset.id!);
      expect(await repo.findById(asset.id!), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // VideoFrameRepository
  // ---------------------------------------------------------------------------

  group('VideoFrameRepository', () {
    late Database db;
    late SqliteVideoAssetRepository assetRepo;
    late SqliteVideoFrameRepository frameRepo;
    late int projectId;

    setUp(() async {
      db = await openTestDb();
      assetRepo = SqliteVideoAssetRepository(db);
      frameRepo = SqliteVideoFrameRepository(db);
      projectId = await seedProject(db);
    });

    tearDown(() async => await db.close());

    test('insert and findByVideoAsset', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 5);
      final found = await frameRepo.findByVideoAsset(asset.id!);
      expect(found.length, 5);
      expect(found.first.frameIndex, 0);
      expect(found.last.frameIndex, 4);
      expect(frames.length, 5);
    });

    test('findByAssetAndIndex', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      await seedFrames(frameRepo, asset.id!, 3);
      final found = await frameRepo.findByAssetAndIndex(asset.id!, 1);
      expect(found, isNotNull);
      expect(found!.frameIndex, 1);
    });

    test('insertBatch', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      final now = DateTime.now();
      final batch = List.generate(10, (i) => VideoFrame(
        videoAssetId: asset.id!,
        frameIndex: i,
        timestampMs: i * 33.33,
        sourceFps: 30.0,
        extractionRunId: 'run-batch',
        createdAt: now,
      ));
      await frameRepo.insertBatch(batch);
      final found = await frameRepo.findByExtractionRun('run-batch');
      expect(found.length, 10);
    });

    test('deleteByVideoAsset', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      await seedFrames(frameRepo, asset.id!, 5);
      await frameRepo.deleteByVideoAsset(asset.id!);
      expect(await frameRepo.findByVideoAsset(asset.id!), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // TrackRepository
  // ---------------------------------------------------------------------------

  group('TrackRepository', () {
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

    test('insertTrack and findTrackById', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      final now = DateTime.now();
      final id = await trackRepo.insertTrack(AnnotationTrack(
        uuid: 'track-1',
        videoAssetId: asset.id!,
        createdAt: now,
        updatedAt: now,
      ));
      final found = await trackRepo.findTrackById(id);
      expect(found, isNotNull);
      expect(found!.uuid, 'track-1');
      expect(found.status, 'active');
    });

    test('findTracksAtFrame', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 5);
      final now = DateTime.now();

      final trackId = await trackRepo.insertTrack(AnnotationTrack(
        uuid: 'track-at-frame',
        videoAssetId: asset.id!,
        createdAt: now,
        updatedAt: now,
      ));
      await trackRepo.insertKeyframe(TrackKeyframe(
        trackId: trackId,
        frameId: frames[2].id!,
        geometry: '{"x":10}',
        createdAt: now,
        updatedAt: now,
      ));

      final atFrame2 = await trackRepo.findTracksAtFrame(asset.id!, frames[2].id!);
      expect(atFrame2.length, 1);
      expect(atFrame2.first.uuid, 'track-at-frame');

      final atFrame0 = await trackRepo.findTracksAtFrame(asset.id!, frames[0].id!);
      expect(atFrame0, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Use Cases
  // ---------------------------------------------------------------------------

  group('CreateTrack use case', () {
    late Database db;
    late SqliteVideoAssetRepository assetRepo;
    late SqliteTrackRepository trackRepo;
    late int projectId;

    setUp(() async {
      db = await openTestDb();
      assetRepo = SqliteVideoAssetRepository(db);
      trackRepo = SqliteTrackRepository(db);
      projectId = await seedProject(db);
    });

    tearDown(() async => await db.close());

    test('creates a track with generated uuid and id', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      final useCase = CreateTrack(trackRepo);
      final track = await useCase(videoAssetId: asset.id!, labelId: null);
      expect(track.id, isNotNull);
      expect(track.uuid, isNotEmpty);
      expect(track.videoAssetId, asset.id);
      expect(track.status, 'active');
    });
  });

  group('AddKeyframe use case', () {
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

    test('inserts a new keyframe', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 3);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      final kf = await AddKeyframe(trackRepo)(
        trackId: track.id!,
        frameId: frames[0].id!,
        geometry: {'x': 10, 'y': 20, 'width': 100, 'height': 50},
      );
      expect(kf.id, isNotNull);
      expect(kf.trackId, track.id);
    });

    test('updates existing keyframe at same frame', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 3);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);
      final addKf = AddKeyframe(trackRepo);

      await addKf(
        trackId: track.id!,
        frameId: frames[0].id!,
        geometry: {'x': 10},
      );
      final updated = await addKf(
        trackId: track.id!,
        frameId: frames[0].id!,
        geometry: {'x': 99},
      );
      expect(updated.geometryMap['x'], 99);

      final allKfs = await trackRepo.findKeyframesByTrack(track.id!);
      expect(allKfs.length, 1, reason: 'should update, not duplicate');
    });
  });

  group('InterpolateTrackSegment use case', () {
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

    test('linearly interpolates bbox between two keyframes', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 5);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);
      final addKf = AddKeyframe(trackRepo);

      // Keyframe at frame 0: x=0
      await addKf(
        trackId: track.id!,
        frameId: frames[0].id!,
        geometry: {'x': 0.0, 'y': 0.0},
      );
      // Keyframe at frame 4: x=100
      await addKf(
        trackId: track.id!,
        frameId: frames[4].id!,
        geometry: {'x': 100.0, 'y': 200.0},
      );

      final interpolated = await InterpolateTrackSegment(trackRepo, frameRepo)(
        trackId: track.id!,
        videoAssetId: asset.id!,
      );

      expect(interpolated.length, 5);

      // Anchor at frame 0
      expect(interpolated[0].geometry['x'], 0.0);
      // Interpolated at frame 2 (midpoint): x=50
      final mid = interpolated.firstWhere((f) => f.frameId == frames[2].id!);
      expect((mid.geometry['x'] as double).round(), 50);
      expect((mid.geometry['y'] as double).round(), 100);
      // Anchor at frame 4
      expect(interpolated.last.geometry['x'], 100.0);
    });

    test('returns empty list for track with no keyframes', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      await seedFrames(frameRepo, asset.id!, 3);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      final result = await InterpolateTrackSegment(trackRepo, frameRepo)(
        trackId: track.id!,
        videoAssetId: asset.id!,
      );
      expect(result, isEmpty);
    });

    test('single keyframe returns one entry', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 3);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      await AddKeyframe(trackRepo)(
        trackId: track.id!,
        frameId: frames[1].id!,
        geometry: {'x': 42.0},
      );

      final result = await InterpolateTrackSegment(trackRepo, frameRepo)(
        trackId: track.id!,
        videoAssetId: asset.id!,
      );
      expect(result.length, 1);
      expect(result.first.geometry['x'], 42.0);
    });
  });

  group('ListTracksAtFrame use case', () {
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

    test('returns only tracks with keyframes at the given frame', () async {
      final asset = await seedVideoAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 5);
      final create = CreateTrack(trackRepo);
      final addKf = AddKeyframe(trackRepo);

      final track1 = await create(videoAssetId: asset.id!);
      final track2 = await create(videoAssetId: asset.id!);

      await addKf(trackId: track1.id!, frameId: frames[0].id!, geometry: {'a': 1});
      await addKf(trackId: track1.id!, frameId: frames[2].id!, geometry: {'a': 2});
      await addKf(trackId: track2.id!, frameId: frames[2].id!, geometry: {'b': 1});

      final listUseCase = ListTracksAtFrame(trackRepo);

      final atFrame0 = await listUseCase(videoAssetId: asset.id!, frameId: frames[0].id!);
      expect(atFrame0.length, 1);
      expect(atFrame0.first.uuid, track1.uuid);

      final atFrame2 = await listUseCase(videoAssetId: asset.id!, frameId: frames[2].id!);
      expect(atFrame2.length, 2);

      final atFrame4 = await listUseCase(videoAssetId: asset.id!, frameId: frames[4].id!);
      expect(atFrame4, isEmpty);
    });
  });
}
