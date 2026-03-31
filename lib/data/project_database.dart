import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'database_path_helper.dart';

import '../models/project.dart';
import '../models/dataset.dart';
import '../models/label.dart';
import '../models/annotation_review.dart';

import 'create_initial_schema.dart';

const String kDatabaseFileName = 'projects.db';

class ProjectDatabase {
  static final ProjectDatabase instance = ProjectDatabase._init();
  static Database? _database;

  ProjectDatabase._init();

  final _log = Logger('ProjectDatabase');
  final uuid = Uuid();

  Future<void> _migrateAddProjectOrder(Database db) async {
    try {
      final columns = await db.rawQuery("PRAGMA table_info(projects)");
      final hasOrder = columns.any((row) => row['name'] == 'project_order');
      if (!hasOrder) {
        await db.execute(
          'ALTER TABLE projects ADD COLUMN project_order INTEGER NOT NULL DEFAULT 0',
        );
        final ids = await db.rawQuery(
          'SELECT id FROM projects ORDER BY id ASC',
        );
        final batch = db.batch();
        int idx = 0;
        for (final row in ids) {
          final id = row['id'] as int;
          batch.update(
            'projects',
            {'project_order': idx++},
            where: 'id = ?',
            whereArgs: [id],
          );
        }
        await batch.commit(noResult: true);
        _log.info('Migration: project_order column added and initialized.');
      }
    } catch (e, stack) {
      _log.severe('Migration _migrateAddProjectOrder failed', e, stack);
    }
  }

  Future<void> _migrateAddMediaItemImageData(Database db) async {
    try {
      final columns = await db.rawQuery('PRAGMA table_info(media_items)');
      final hasImageData = columns.any((row) => row['name'] == 'imageData');
      if (!hasImageData) {
        await db.execute(
          'ALTER TABLE media_items ADD COLUMN imageData BLOB',
        );
        _log.info('Migration: imageData BLOB column added to media_items.');
      }
    } catch (e, stack) {
      _log.severe('Migration _migrateAddMediaItemImageData failed', e, stack);
    }
  }

  Future<void> _migrateEnsureIndexes(Database db) async {
    try {
      final statements = <String>[
        'CREATE INDEX IF NOT EXISTS idx_projects_owner_id ON projects(ownerId)',
        'CREATE INDEX IF NOT EXISTS idx_datasets_project_id_order ON datasets(projectId, dataset_order)',
        'CREATE INDEX IF NOT EXISTS idx_media_items_dataset_id ON media_items(datasetId)',
        'CREATE INDEX IF NOT EXISTS idx_annotations_media_item_id ON annotations(media_item_id)',
        'CREATE INDEX IF NOT EXISTS idx_annotations_label_id ON annotations(label_id)',
        'CREATE INDEX IF NOT EXISTS idx_annotations_review_status ON annotations(review_status)',
        'CREATE INDEX IF NOT EXISTS idx_labels_project_id ON labels(project_id)',
        'CREATE INDEX IF NOT EXISTS idx_dataset_media_folders_dataset_id ON dataset_media_folders(datasetId)',
        'CREATE INDEX IF NOT EXISTS idx_dataset_media_folders_folder_id ON dataset_media_folders(folderId)',
      ];
      for (final sql in statements) {
        await db.execute(sql);
      }
    } catch (e, stack) {
      _log.severe('Migration _migrateEnsureIndexes failed', e, stack);
    }
  }

  Future<void> _migrateAnnotationsSchemaAndReview(Database db) async {
    try {
      final columns = await db.rawQuery('PRAGMA table_info(annotations)');
      bool hasColumn(String name) => columns.any((row) => row['name'] == name);

      if (!hasColumn('annotation_schema_version')) {
        await db.execute(
          'ALTER TABLE annotations ADD COLUMN annotation_schema_version INTEGER NOT NULL DEFAULT 1',
        );
      }
      if (!hasColumn('provenance')) {
        await db.execute('ALTER TABLE annotations ADD COLUMN provenance TEXT');
      }
      if (!hasColumn('review_status')) {
        await db.execute(
          "ALTER TABLE annotations ADD COLUMN review_status TEXT NOT NULL DEFAULT '${AnnotationReviewStatus.draft}'",
        );
      }
      if (!hasColumn('reviewed_by')) {
        await db.execute(
          'ALTER TABLE annotations ADD COLUMN reviewed_by INTEGER',
        );
      }
      if (!hasColumn('reviewed_at')) {
        await db.execute('ALTER TABLE annotations ADD COLUMN reviewed_at TEXT');
      }
      if (!hasColumn('review_comment')) {
        await db.execute(
          'ALTER TABLE annotations ADD COLUMN review_comment TEXT',
        );
      }

      await db.execute('''
        UPDATE annotations
        SET annotation_schema_version = ${AnnotationSchema.currentVersion}
        WHERE annotation_schema_version IS NULL OR annotation_schema_version < 1
      ''');

      await db.execute('''
        UPDATE annotations
        SET review_status = '${AnnotationReviewStatus.draft}'
        WHERE review_status IS NULL
           OR TRIM(review_status) = ''
           OR LOWER(review_status) NOT IN ('draft', 'proposed', 'accepted', 'rejected')
      ''');
    } catch (e, stack) {
      _log.severe(
        'Migration _migrateAnnotationsSchemaAndReview failed',
        e,
        stack,
      );
    }
  }

  /// Migration: add video_assets, video_frames, annotation_tracks, and
  /// track_keyframes tables for temporal video annotation workflow.
  ///
  /// Rollback: DROP TABLE IF EXISTS track_keyframes, annotation_tracks,
  ///           video_frames, video_assets  (reverse dependency order).
  Future<void> _migrateVideoTemporalTables(Database db) async {
    try {
      // Check if migration already applied (video_assets is the anchor table).
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='video_assets'",
      );
      if (tables.isNotEmpty) return;

      _log.info('Migration: creating video temporal tables…');

      // -- 1. video_assets: source video file and its probed metadata.
      // Rollback: DROP TABLE IF EXISTS video_assets;
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

      // -- 2. video_frames: each extracted frame linked to a video_asset via
      //    the FrameIdentity contract (videoId, frameIndex, timestampMs, etc.).
      // Rollback: DROP TABLE IF EXISTS video_frames;
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

      // -- 3. annotation_tracks: temporal annotation tracks spanning frames.
      // Rollback: DROP TABLE IF EXISTS annotation_tracks;
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

      // -- 4. track_keyframes: user-set anchor points within a track; geometry
      //    is JSON (bbox, polygon, etc.) to be interpolated between keyframes.
      // Rollback: DROP TABLE IF EXISTS track_keyframes;
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

      // -- 5. Indexes for temporal query patterns.
      // Rollback: indexes are dropped automatically with their tables.
      await db.execute('CREATE INDEX IF NOT EXISTS idx_video_assets_project ON video_assets(project_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_video_assets_media_item ON video_assets(media_item_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_video_frames_video_asset ON video_frames(video_asset_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_video_frames_asset_index ON video_frames(video_asset_id, frame_index)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_video_frames_run ON video_frames(extraction_run_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_annotation_tracks_video ON annotation_tracks(video_asset_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_annotation_tracks_label ON annotation_tracks(label_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_track_keyframes_track ON track_keyframes(track_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_track_keyframes_frame ON track_keyframes(frame_id)');

      _log.info('Migration: video temporal tables created successfully.');
    } catch (e, stack) {
      _log.severe('Migration _migrateVideoTemporalTables failed', e, stack);
    }
  }

  /// Migration: add review workflow columns to annotation_tracks.
  ///
  /// Adds review_status, reviewed_by, reviewed_at, review_comment columns
  /// for the draft → proposed → accepted/rejected lifecycle.
  ///
  /// Rollback: these are nullable/defaulted columns; no data loss on rollback
  /// but the columns would remain (SQLite does not support DROP COLUMN < 3.35).
  Future<void> _migrateTrackReviewColumns(Database db) async {
    try {
      final columns = await db.rawQuery(
        'PRAGMA table_info(annotation_tracks)',
      );
      if (columns.isEmpty) return; // table doesn't exist yet

      bool hasColumn(String name) =>
          columns.any((row) => row['name'] == name);

      if (!hasColumn('review_status')) {
        await db.execute(
          "ALTER TABLE annotation_tracks ADD COLUMN review_status TEXT NOT NULL DEFAULT 'draft'",
        );
      }
      if (!hasColumn('reviewed_by')) {
        await db.execute(
          'ALTER TABLE annotation_tracks ADD COLUMN reviewed_by INTEGER',
        );
      }
      if (!hasColumn('reviewed_at')) {
        await db.execute(
          'ALTER TABLE annotation_tracks ADD COLUMN reviewed_at TEXT',
        );
      }
      if (!hasColumn('review_comment')) {
        await db.execute(
          'ALTER TABLE annotation_tracks ADD COLUMN review_comment TEXT',
        );
      }

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_annotation_tracks_review ON annotation_tracks(review_status)',
      );

      _log.info('Migration: track review columns ensured.');
    } catch (e, stack) {
      _log.severe('Migration _migrateTrackReviewColumns failed', e, stack);
    }
  }

  /// Migration: create the ai_jobs persistence table.
  ///
  /// Rollback: DROP TABLE IF EXISTS ai_jobs;
  Future<void> _migrateAiJobsTable(Database db) async {
    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='ai_jobs'",
      );
      if (tables.isNotEmpty) return;

      _log.info('Migration: creating ai_jobs table…');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS ai_jobs (
          id TEXT PRIMARY KEY NOT NULL,
          capability TEXT NOT NULL,
          idempotency_key TEXT,
          status TEXT NOT NULL DEFAULT 'queued',
          progress INTEGER NOT NULL DEFAULT -1,
          started_at TEXT,
          finished_at TEXT,
          error_code TEXT,
          error_message TEXT,
          payload TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_ai_jobs_status ON ai_jobs(status)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_ai_jobs_capability ON ai_jobs(capability)',
      );
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_ai_jobs_idempotency ON ai_jobs(idempotency_key) WHERE idempotency_key IS NOT NULL',
      );

      _log.info('Migration: ai_jobs table created successfully.');
    } catch (e, stack) {
      _log.severe('Migration _migrateAiJobsTable failed', e, stack);
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB(kDatabaseFileName);
    return _database!;
  }

  Future<String> get databasePath async {
    final dbDirPath = await getAppDatabaseDirectory();
    return path.join(dbDirPath, kDatabaseFileName);
  }

  Future<Database> _initDB(String fileName) async {
    final dbDirPath = await getAppDatabaseDirectory();
    await ensureDirectoryExists(dbDirPath);
    final returnPath = path.join(dbDirPath, fileName);
    _log.info('Opening database at: $returnPath');
    try {
      return await openDatabase(
        returnPath,
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: createInitialSchema,
        onOpen: (db) async {
          await _migrateAddProjectOrder(db);
          await _migrateAnnotationsSchemaAndReview(db);
          await _migrateAddMediaItemImageData(db);
          await _migrateEnsureIndexes(db);
          await _migrateVideoTemporalTables(db);
          await _migrateTrackReviewColumns(db);
          await _migrateAiJobsTable(db);
        },
        singleInstance: true,
      );
    } catch (e, stack) {
      _log.severe('Failed to open database at $returnPath', e, stack);
      rethrow;
    }
  }

  Future<Project> createProject(Project project) async {
    final db = await database;

    final String projectName =
        (project.name.trim().isEmpty) ? 'Project' : project.name.trim();

    final now = DateTime.now();

    return await db.transaction<Project>((txn) async {
      // Determine next order
      final List<Map<String, Object?>> maxRes = await txn.rawQuery(
        'SELECT COALESCE(MAX(project_order), -1) + 1 as nextOrder FROM projects',
      );
      final int nextOrder =
          (maxRes.isNotEmpty && maxRes.first['nextOrder'] is int)
              ? maxRes.first['nextOrder'] as int
              : 0;

      // Insert project without defaultDatasetId
      final projectId = await txn.insert('projects', {
        'name': projectName,
        'type': project.type,
        'icon': project.icon,
        'creationDate': now.toIso8601String(),
        'lastUpdated': now.toIso8601String(),
        'ownerId': project.ownerId,
        'project_order': nextOrder,
      });

      // Create default dataset
      final dataset = Dataset(
        id: uuid.v4(),
        projectId: projectId,
        datasetOrder: 0,
        name: 'Dataset',
        description: 'Default dataset for $projectName',
        type: project.type,
        source: 'manual',
        format: 'custom',
        version: '1.0.0',
        mediaCount: 0,
        annotationCount: 0,
        defaultDataset: true,
        license: null,
        metadata: null,
        createdAt: now,
        updatedAt: now,
      );

      await txn.insert('datasets', dataset.toMap());

      // Update project with defaultDatasetId
      await txn.update(
        'projects',
        {
          'defaultDatasetId': dataset.id,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [projectId],
      );

      if (kDebugMode) print('dataset.id ${dataset.id} for $projectName created');

      // Return a new complete Project object
      return project.copyWith(id: projectId, defaultDatasetId: dataset.id);
    });
  }

  Future<String?> getDefaultDatasetId(int projectId) async {
    final db = await database;

    final result = await db.query(
      'projects',
      columns: ['defaultDatasetId'],
      where: 'id = ?',
      whereArgs: [projectId],
    );

    if (result.isNotEmpty) {
      return result.first['defaultDatasetId'] as String?;
    }

    // project not found or no default dataset set
    return null;
  }

  Future<int> updateProjectName(int projectId, String projectName) async {
    final db = await database;

    // Fetch current project name from database
    List<Map<String, dynamic>> result = await db.query(
      'projects',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [projectId],
    );

    if (result.isNotEmpty) {
      String currentName = result.first['name'];
      // If the name has not changed, do nothing and return 0 (no update)
      if (currentName == projectName) {
        _log.info(
          'No changes detected for project "$projectName", skipping update.',
        );
        return 0; // No update performed
      }
    }

    // If name changed, update name + lastUpdated timestamp
    return await db.update(
      'projects',
      {
        'name': projectName,
        // Update project lastUpdated column with current time
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  Future<void> updateDefaultDataset({
    required int projectId,
    required String datasetId,
  }) async {
    final db = await database;

    await db.update(
      'projects',
      {
        'defaultDatasetId': datasetId,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [projectId],
    );

    _log.info('Set dataset $datasetId as default for project $projectId');
  }

  Future<Dataset> createDatasetForProject({
    required int projectId,
    required String projectType,
    String name = 'New Dataset',
    String description = '',
    bool isDefault = false,
  }) async {
    final db = await database;

    // Check if a default dataset already exists
    if (isDefault) {
      final List<Map<String, dynamic>> existing = await db.query(
        'projects',
        where: 'id = ? AND defaultDatasetId IS NOT NULL',
        whereArgs: [projectId],
      );
      if (existing.isNotEmpty) {
        throw Exception('Default dataset already exists for this project.');
      }
    }

    final countResult = await db.rawQuery(
      'SELECT COUNT(*) FROM datasets WHERE projectId = ?',
      [projectId],
    );
    final nextOrder = Sqflite.firstIntValue(countResult) ?? 0;

    final now = DateTime.now();
    // Create dataset
    final dataset = Dataset(
      id: uuid.v4(),
      projectId: projectId,
      datasetOrder: nextOrder,
      name: name.trim().isEmpty ? 'Dataset' : name.trim(),
      description: description,
      type: projectType,
      source: 'manual',
      format: 'custom',
      version: '1.0.0',
      mediaCount: 0,
      annotationCount: 0,
      defaultDataset: isDefault,
      license: null,
      metadata: null,
      createdAt: now,
      updatedAt: now,
    );
    await db.insert('datasets', dataset.toMap());

    // If it's a default dataset, update the project record
    if (isDefault) {
      await db.update(
        'projects',
        {
          'defaultDatasetId': dataset.id,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [projectId],
      );
    } else {
      // else update only lastUpdated timestamp
      await db.update(
        'projects',
        {'lastUpdated': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [projectId],
      );
    }
    return dataset;
  }

  Future<void> updateProjectLastUpdated(int projectId) async {
    final db = await database;

    await db.update(
      'projects',
      {'lastUpdated': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  Future<int> updateProjectIcon(int projectId, String newProjectIcon) async {
    final db = await database;

    return await db.update(
      'projects',
      {'icon': newProjectIcon, 'lastUpdated': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  Future<void> updateProjectTypeAndTimestamp({
    required int projectId,
    required String newType,
  }) async {
    final db = await database;
    await db.update(
      'projects',
      {'type': newType, 'lastUpdated': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [projectId],
    );
  }

  Future<int> deleteProject(int projectId) async {
    final db = await database;

    return await db.transaction((txn) async {
      // Step 1: Get all datasets linked to the project
      final datasets = await txn.query(
        'datasets',
        where: 'projectId = ?',
        whereArgs: [projectId],
      );

      for (var dataset in datasets) {
        final datasetId = dataset['id'] as String;

        // Step 2: Delete media items linked to the dataset
        await txn.delete(
          'media_items',
          where: 'datasetId = ?',
          whereArgs: [datasetId],
        );
      }

      // Step 3: Delete datasets linked to the project
      await txn.delete(
        'datasets',
        where: 'projectId = ?',
        whereArgs: [projectId],
      );

      // Step 4: Delete the project itself
      return await txn.delete(
        'projects',
        where: 'id = ?',
        whereArgs: [projectId],
      );
    });
  }

  Future<List<Project>> fetchProjects() async {
    final db = await database;
    final result = await db.query('projects', orderBy: 'project_order ASC');
    return result.map((map) => Project.fromMap(map)).toList();
  }

  Future<List<Project>> fetchProjectsWithLabels() async {
    final db = await database;
    final projectMaps = await db.query(
      'projects',
      orderBy: 'project_order ASC',
    );
    final projects = projectMaps.map((map) => Project.fromMap(map)).toList();

    final labelMaps = await db.query('labels');

    final labelsByProjectId = <int, List<Label>>{};
    for (final labelMap in labelMaps) {
      final label = Label.fromMap(labelMap);
      final projectId = labelMap['project_id'] as int;
      labelsByProjectId.putIfAbsent(projectId, () => []).add(label);
    }

    return projects.map((project) {
      final labels = labelsByProjectId[project.id] ?? [];
      return project.copyWith(labels: labels);
    }).toList();
  }

  Future<Project?> fetchProjectWithLabelsById(int projectId) async {
    final db = await database;
    final result = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [projectId],
    );

    if (result.isEmpty) return null;
    final project = Project.fromMap(result.first);
    final labelMaps = await db.query(
      'labels',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
    final labels = labelMaps.map((map) => Label.fromMap(map)).toList();

    return project.copyWith(labels: labels);
  }

  Future<List<Project>> fetchProjectsbyUser({required int userId}) async {
    final db = await database;
    final result = await db.query(
      'projects',
      where: 'ownerId = ?',
      whereArgs: [userId],
      orderBy: 'project_order ASC',
    );
    return result.map((map) => Project.fromMap(map)).toList();
  }

  Future<void> closeDB() async {
    final db = await database;
    db.close();
  }

  Future<Project?> fetchProjectById(int projectId) async {
    final db = await database;

    final result = await db.query(
      'projects',
      where: 'id = ?',
      whereArgs: [projectId],
    );

    if (result.isNotEmpty) {
      return Project.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<int> getProjectCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM projects');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> reorderProjects(List<int> orderedProjectIds) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (int i = 0; i < orderedProjectIds.length; i++) {
        batch.update(
          'projects',
          {'project_order': i, 'lastUpdated': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [orderedProjectIds[i]],
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<int> getLabelCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM labels');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getMediaCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM media_items');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getAnnotationCount() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM annotations');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
