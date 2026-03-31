import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:annotateit/models/annotation_track.dart';
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
    await db.execute('CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, firstName TEXT NOT NULL, createdAt TEXT NOT NULL)');
    await db.execute('CREATE TABLE projects (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, ownerId INTEGER NOT NULL, FOREIGN KEY(ownerId) REFERENCES users(id))');
    await db.execute('CREATE TABLE labels (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, project_id INTEGER NOT NULL, FOREIGN KEY(project_id) REFERENCES projects(id))');
    await db.execute('CREATE TABLE media_items (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT UNIQUE, type TEXT)');
    await db.execute('''CREATE TABLE video_assets (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT UNIQUE NOT NULL, media_item_id INTEGER, project_id INTEGER NOT NULL, file_path TEXT NOT NULL, file_name TEXT NOT NULL, width INTEGER NOT NULL DEFAULT 0, height INTEGER NOT NULL DEFAULT 0, duration_sec REAL NOT NULL DEFAULT 0.0, fps_nominal REAL NOT NULL DEFAULT 0.0, frame_count_estimate INTEGER NOT NULL DEFAULT 0, codec TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY(media_item_id) REFERENCES media_items(id) ON DELETE SET NULL, FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE)''');
    await db.execute('''CREATE TABLE video_frames (id INTEGER PRIMARY KEY AUTOINCREMENT, video_asset_id INTEGER NOT NULL, media_item_id INTEGER, frame_index INTEGER NOT NULL, timestamp_ms REAL NOT NULL DEFAULT 0.0, source_fps REAL NOT NULL DEFAULT 0.0, sampling_policy TEXT NOT NULL DEFAULT 'fixedFps', extraction_run_id TEXT NOT NULL, file_path TEXT, created_at TEXT NOT NULL, FOREIGN KEY(video_asset_id) REFERENCES video_assets(id) ON DELETE CASCADE, FOREIGN KEY(media_item_id) REFERENCES media_items(id) ON DELETE SET NULL)''');
    await db.execute('''CREATE TABLE annotation_tracks (id INTEGER PRIMARY KEY AUTOINCREMENT, uuid TEXT UNIQUE NOT NULL, video_asset_id INTEGER NOT NULL, label_id INTEGER, status TEXT NOT NULL DEFAULT 'active', annotation_type TEXT NOT NULL DEFAULT 'bbox', review_status TEXT NOT NULL DEFAULT 'draft', reviewed_by INTEGER, reviewed_at TEXT, review_comment TEXT, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY(video_asset_id) REFERENCES video_assets(id) ON DELETE CASCADE, FOREIGN KEY(label_id) REFERENCES labels(id) ON DELETE SET NULL, FOREIGN KEY(reviewed_by) REFERENCES users(id) ON DELETE SET NULL)''');
    await db.execute('''CREATE TABLE track_keyframes (id INTEGER PRIMARY KEY AUTOINCREMENT, track_id INTEGER NOT NULL, frame_id INTEGER NOT NULL, geometry TEXT NOT NULL, confidence REAL DEFAULT 1.0, is_manual INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL, updated_at TEXT NOT NULL, FOREIGN KEY(track_id) REFERENCES annotation_tracks(id) ON DELETE CASCADE, FOREIGN KEY(frame_id) REFERENCES video_frames(id) ON DELETE CASCADE)''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_annotation_tracks_review ON annotation_tracks(review_status)');
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

  // -----------------------------------------------------------------------
  // TrackReviewStatus pure-logic tests
  // -----------------------------------------------------------------------

  group('TrackReviewStatus', () {
    test('normalize returns valid status unchanged', () {
      expect(TrackReviewStatus.normalize('draft'), 'draft');
      expect(TrackReviewStatus.normalize('proposed'), 'proposed');
      expect(TrackReviewStatus.normalize('accepted'), 'accepted');
      expect(TrackReviewStatus.normalize('rejected'), 'rejected');
    });

    test('normalize defaults invalid/null to draft', () {
      expect(TrackReviewStatus.normalize(null), 'draft');
      expect(TrackReviewStatus.normalize(''), 'draft');
      expect(TrackReviewStatus.normalize('invalid'), 'draft');
      expect(TrackReviewStatus.normalize('  DRAFT  '), 'draft');
    });

    test('isValid', () {
      expect(TrackReviewStatus.isValid('draft'), true);
      expect(TrackReviewStatus.isValid('proposed'), true);
      expect(TrackReviewStatus.isValid('accepted'), true);
      expect(TrackReviewStatus.isValid('rejected'), true);
      expect(TrackReviewStatus.isValid('unknown'), false);
    });

    test('canTransition: draft → proposed (allowed)', () {
      expect(TrackReviewStatus.canTransition('draft', 'proposed'), true);
    });

    test('canTransition: draft → accepted (not allowed)', () {
      expect(TrackReviewStatus.canTransition('draft', 'accepted'), false);
    });

    test('canTransition: proposed → accepted/rejected (allowed)', () {
      expect(TrackReviewStatus.canTransition('proposed', 'accepted'), true);
      expect(TrackReviewStatus.canTransition('proposed', 'rejected'), true);
    });

    test('canTransition: proposed → draft (allowed)', () {
      expect(TrackReviewStatus.canTransition('proposed', 'draft'), true);
    });

    test('canTransition: accepted → draft (re-open)', () {
      expect(TrackReviewStatus.canTransition('accepted', 'draft'), true);
    });

    test('canTransition: accepted → proposed (not allowed)', () {
      expect(TrackReviewStatus.canTransition('accepted', 'proposed'), false);
    });

    test('canTransition: rejected → draft/proposed (allowed)', () {
      expect(TrackReviewStatus.canTransition('rejected', 'draft'), true);
      expect(TrackReviewStatus.canTransition('rejected', 'proposed'), true);
    });

    test('canTransition: same status always ok', () {
      for (final s in TrackReviewStatus.values) {
        expect(TrackReviewStatus.canTransition(s, s), true);
      }
    });
  });

  // -----------------------------------------------------------------------
  // AnnotationTrack review fields serialisation
  // -----------------------------------------------------------------------

  group('AnnotationTrack review fields', () {
    test('defaults to draft review status', () {
      final now = DateTime.now();
      final track = AnnotationTrack(
        uuid: 'test',
        videoAssetId: 1,
        createdAt: now,
        updatedAt: now,
      );
      expect(track.reviewStatus, TrackReviewStatus.draft);
      expect(track.reviewedBy, isNull);
      expect(track.reviewedAt, isNull);
      expect(track.reviewComment, isNull);
    });

    test('toMap includes review fields', () {
      final now = DateTime.now();
      final track = AnnotationTrack(
        uuid: 'test',
        videoAssetId: 1,
        reviewStatus: TrackReviewStatus.accepted,
        reviewedBy: 42,
        reviewedAt: now,
        reviewComment: 'LGTM',
        createdAt: now,
        updatedAt: now,
      );
      final map = track.toMap();
      expect(map['review_status'], 'accepted');
      expect(map['reviewed_by'], 42);
      expect(map['reviewed_at'], now.toIso8601String());
      expect(map['review_comment'], 'LGTM');
    });

    test('fromMap parses review fields', () {
      final now = DateTime.now();
      final map = {
        'uuid': 'test',
        'video_asset_id': 1,
        'status': 'active',
        'annotation_type': 'bbox',
        'review_status': 'rejected',
        'reviewed_by': 7,
        'reviewed_at': now.toIso8601String(),
        'review_comment': 'Needs fix',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final track = AnnotationTrack.fromMap(map);
      expect(track.reviewStatus, 'rejected');
      expect(track.reviewedBy, 7);
      expect(track.reviewComment, 'Needs fix');
    });

    test('fromMap defaults missing review_status to draft', () {
      final now = DateTime.now();
      final map = {
        'uuid': 'test',
        'video_asset_id': 1,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };
      final track = AnnotationTrack.fromMap(map);
      expect(track.reviewStatus, 'draft');
    });

    test('copyWith preserves review fields', () {
      final now = DateTime.now();
      final track = AnnotationTrack(
        uuid: 'test',
        videoAssetId: 1,
        reviewStatus: 'proposed',
        reviewedBy: 5,
        reviewedAt: now,
        reviewComment: 'Check',
        createdAt: now,
        updatedAt: now,
      );
      final updated = track.copyWith(reviewStatus: 'accepted');
      expect(updated.reviewStatus, 'accepted');
      expect(updated.reviewedBy, 5);
      expect(updated.reviewComment, 'Check');
    });
  });

  // -----------------------------------------------------------------------
  // ReviewTrack use case (single track transition)
  // -----------------------------------------------------------------------

  group('ReviewTrack use case', () {
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

    test('transitions draft → proposed', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      final updated = await ReviewTrack(trackRepo)(
        trackId: track.id!,
        newStatus: TrackReviewStatus.proposed,
        reviewedBy: 1,
        comment: 'Ready for review',
      );

      expect(updated.reviewStatus, 'proposed');
      expect(updated.reviewedBy, 1);
      expect(updated.reviewComment, 'Ready for review');

      final fromDb = await trackRepo.findTrackById(track.id!);
      expect(fromDb!.reviewStatus, 'proposed');
    });

    test('transitions proposed → accepted', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      await ReviewTrack(trackRepo)(
        trackId: track.id!,
        newStatus: TrackReviewStatus.proposed,
      );
      final accepted = await ReviewTrack(trackRepo)(
        trackId: track.id!,
        newStatus: TrackReviewStatus.accepted,
        comment: 'Approved',
      );

      expect(accepted.reviewStatus, 'accepted');
    });

    test('rejects invalid transition draft → accepted', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      expect(
        () => ReviewTrack(trackRepo)(
          trackId: track.id!,
          newStatus: TrackReviewStatus.accepted,
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('rejects invalid status string', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      expect(
        () => ReviewTrack(trackRepo)(
          trackId: track.id!,
          newStatus: 'invalid_status',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when track not found', () async {
      expect(
        () => ReviewTrack(trackRepo)(
          trackId: 99999,
          newStatus: TrackReviewStatus.proposed,
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  // -----------------------------------------------------------------------
  // BulkReviewByFrameRange use case
  // -----------------------------------------------------------------------

  group('BulkReviewByFrameRange use case', () {
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

    test('bulk-updates tracks in frame range', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 10);
      final create = CreateTrack(trackRepo);
      final addKf = AddKeyframe(trackRepo);

      final track1 = await create(videoAssetId: asset.id!);
      final track2 = await create(videoAssetId: asset.id!);
      final track3 = await create(videoAssetId: asset.id!);

      await addKf(trackId: track1.id!, frameId: frames[1].id!, geometry: {'x': 0});
      await addKf(trackId: track1.id!, frameId: frames[3].id!, geometry: {'x': 0});
      await addKf(trackId: track2.id!, frameId: frames[5].id!, geometry: {'x': 0});
      await addKf(trackId: track3.id!, frameId: frames[8].id!, geometry: {'x': 0});

      final count = await BulkReviewByFrameRange(trackRepo)(
        videoAssetId: asset.id!,
        startFrameId: frames[0].id!,
        endFrameId: frames[5].id!,
        reviewStatus: TrackReviewStatus.accepted,
        reviewedBy: 1,
        comment: 'Bulk approved',
      );

      expect(count, 2);

      final t1 = await trackRepo.findTrackById(track1.id!);
      expect(t1!.reviewStatus, 'accepted');

      final t2 = await trackRepo.findTrackById(track2.id!);
      expect(t2!.reviewStatus, 'accepted');

      final t3 = await trackRepo.findTrackById(track3.id!);
      expect(t3!.reviewStatus, 'draft');
    });

    test('returns 0 when no tracks in range', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final frames = await seedFrames(frameRepo, asset.id!, 5);

      final count = await BulkReviewByFrameRange(trackRepo)(
        videoAssetId: asset.id!,
        startFrameId: frames[0].id!,
        endFrameId: frames[4].id!,
        reviewStatus: TrackReviewStatus.proposed,
      );

      expect(count, 0);
    });

    test('rejects invalid status', () async {
      expect(
        () => BulkReviewByFrameRange(trackRepo)(
          videoAssetId: 1,
          startFrameId: 1,
          endFrameId: 10,
          reviewStatus: 'bogus',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // -----------------------------------------------------------------------
  // ListTracksByReviewStatus use case
  // -----------------------------------------------------------------------

  group('ListTracksByReviewStatus use case', () {
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

    test('filters tracks by review status', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final create = CreateTrack(trackRepo);

      final t1 = await create(videoAssetId: asset.id!);
      final t2 = await create(videoAssetId: asset.id!);
      await create(videoAssetId: asset.id!);

      await ReviewTrack(trackRepo)(
        trackId: t1.id!,
        newStatus: TrackReviewStatus.proposed,
      );
      await ReviewTrack(trackRepo)(
        trackId: t2.id!,
        newStatus: TrackReviewStatus.proposed,
      );

      final proposed = await ListTracksByReviewStatus(trackRepo)(
        videoAssetId: asset.id!,
        reviewStatus: TrackReviewStatus.proposed,
      );
      expect(proposed.length, 2);

      final drafts = await ListTracksByReviewStatus(trackRepo)(
        videoAssetId: asset.id!,
        reviewStatus: TrackReviewStatus.draft,
      );
      expect(drafts.length, 1);
    });

    test('returns empty list when no match', () async {
      final asset = await seedAsset(assetRepo, projectId);
      await CreateTrack(trackRepo)(videoAssetId: asset.id!);

      final accepted = await ListTracksByReviewStatus(trackRepo)(
        videoAssetId: asset.id!,
        reviewStatus: TrackReviewStatus.accepted,
      );
      expect(accepted, isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // Full lifecycle: draft → proposed → rejected → draft → proposed → accepted
  // -----------------------------------------------------------------------

  group('Full review lifecycle', () {
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

    test('complete lifecycle round-trip', () async {
      final asset = await seedAsset(assetRepo, projectId);
      final track = await CreateTrack(trackRepo)(videoAssetId: asset.id!);
      final review = ReviewTrack(trackRepo);

      expect(track.reviewStatus, 'draft');

      await review(trackId: track.id!, newStatus: 'proposed');
      await review(trackId: track.id!, newStatus: 'rejected', comment: 'Fix bbox');
      await review(trackId: track.id!, newStatus: 'draft');
      await review(trackId: track.id!, newStatus: 'proposed');
      final final_ = await review(
        trackId: track.id!,
        newStatus: 'accepted',
        comment: 'All good',
      );

      expect(final_.reviewStatus, 'accepted');
      expect(final_.reviewComment, 'All good');
    });
  });
}
