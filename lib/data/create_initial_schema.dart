import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart' as path;
import 'database_path_helper.dart';

/// Creates all tables and initializes folders.
Future<void> createInitialSchema(Database db, int version) async {
  await db.execute('PRAGMA foreign_keys = ON');
  await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL,
        iconPath TEXT,
        datasetImportFolder TEXT,
        datasetExportFolder TEXT,
        thumbnailFolder TEXT,
        modelsFolder TEXT,
        themeMode TEXT NOT NULL,
        language TEXT NOT NULL,
        autoSave INTEGER NOT NULL,
        showTips INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        projectShowNoLabels INTEGER NOT NULL DEFAULT 1,
        datasetEnableDuplicate INTEGER NOT NULL DEFAULT 1,
        datasetEnableDelete INTEGER NOT NULL DEFAULT 1,
        labelsDeleteAnnotations INTEGER NOT NULL DEFAULT 0,
        labelsSetFirstAsDefault INTEGER NOT NULL DEFAULT 1,
        autoSaveAnnotations INTEGER NOT NULL DEFAULT 1,
        projectSkipDeleteConfirm INTEGER NOT NULL DEFAULT 0,
        projectShowImportWarning INTEGER NOT NULL DEFAULT 1,
        annotationAllowImageCopy INTEGER NOT NULL DEFAULT 1,
        askConfirmationOnAnnotationRemoval INTEGER NOT NULL DEFAULT 1,
        showExportLabelsButton INTEGER NOT NULL DEFAULT 1,
        annotationOpacity REAL NOT NULL DEFAULT 0.35,
        preferredSamModelKey TEXT NOT NULL DEFAULT 'sam2_hiera_base_plus',
        samRememberChoice INTEGER NOT NULL DEFAULT 0,
        saveApplicationLogInFile INTEGER NOT NULL DEFAULT 1,
        ffmpegPath TEXT
      )
    ''');

  final datasetImportFolder = 'datasets';
  final datasetExportFolder = 'exports';
  final thumbnailFolder = 'thumbnails';
  final modelsFolder = 'models';

  if (!kIsWeb) {
    final rootPath = await getDefaultAnnotationRootPath();
    for (final folder in [datasetImportFolder, datasetExportFolder, thumbnailFolder, modelsFolder]) {
      try {
        await ensureDirectoryExists(path.join(rootPath, folder));
      } catch (e) {
        if (kDebugMode) print('Warning: Could not create $folder directory: $e');
      }
    }
  }

  final now = DateTime.now().toIso8601String();
  await db.insert('users', {
    'firstName': 'Captain',
    'lastName': 'Annotator',
    'email': 'captain@labelship.local',
    'iconPath': '',
    'datasetImportFolder': datasetImportFolder,
    'datasetExportFolder': datasetExportFolder,
    'thumbnailFolder': thumbnailFolder,
    'modelsFolder': modelsFolder,
    'themeMode': 'dark',
    'language': 'en',
    'autoSave': 1,
    'showTips': 1,
    'createdAt': now,
    'updatedAt': now,
    'projectShowNoLabels': 0,
    'datasetEnableDuplicate': 1,
    'datasetEnableDelete': 1,
    'labelsDeleteAnnotations': 0,
    'labelsSetFirstAsDefault': 1,
    'autoSaveAnnotations': 1,
    'projectSkipDeleteConfirm': 0,
    'projectShowImportWarning': 1,
    'annotationAllowImageCopy': 1,
    'askConfirmationOnAnnotationRemoval': 1,
    'showExportLabelsButton': 1,
    'annotationOpacity': 0.35,
  });

  await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        creationDate TEXT NOT NULL,
        lastUpdated TEXT NOT NULL,
        defaultDatasetId TEXT,
        ownerId INTEGER NOT NULL,
        project_order INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (ownerId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

  await db.execute('''
      CREATE TABLE datasets (
        id TEXT PRIMARY KEY,
        projectId INTEGER NOT NULL,
        dataset_order INTEGER DEFAULT 0,
        name TEXT NOT NULL,
        description TEXT,
        type TEXT NOT NULL,
        source TEXT DEFAULT 'manual',
        format TEXT DEFAULT 'custom',
        version TEXT DEFAULT '1.0.0',
        mediaCount INTEGER DEFAULT 0,
        annotationCount INTEGER DEFAULT 0,
        defaultDataset INTEGER DEFAULT 0 CHECK (defaultDataset IN (0, 1)),
        license TEXT,
        metadata TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        FOREIGN KEY (projectId) REFERENCES projects(id) ON DELETE CASCADE
      );
    ''');

  await db.execute('''
      CREATE TABLE media_folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      );
    ''');

  await db.execute('''
      CREATE TABLE dataset_media_folders (
        datasetId TEXT NOT NULL,
        folderId INTEGER NOT NULL,
        PRIMARY KEY (datasetId, folderId),
        FOREIGN KEY (datasetId) REFERENCES datasets(id) ON DELETE CASCADE,
        FOREIGN KEY (folderId) REFERENCES media_folders(id) ON DELETE CASCADE
      );
    ''');

  await db.execute('''
      CREATE TABLE media_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,          -- Internal DB ID
        uuid TEXT UNIQUE,                              -- Unique UUID for external reference
        datasetId TEXT,                                -- Foreign key to datasets table
        filePath TEXT,                                 -- Absolute or relative path to file
        extension TEXT,                                -- File extension (e.g., .jpg, .mp4)
        type TEXT,                                     -- "image" or "video"

        width INTEGER,                                 -- Media width (in pixels)
        height INTEGER,                                -- Media height (in pixels)
        duration REAL,                                 -- Duration in seconds (only for videos)
        fps REAL,                                      -- Frames per second (only for videos)
        source TEXT,                                   -- Source of media: "uploaded", "imported", or "url"

        uploadDate TEXT,                               -- ISO 8601 date-time string
        owner_id INTEGER NOT NULL,                     -- Foreign key to users (owner of the media)

        lastAnnotator TEXT,                            -- Name or ID of last annotator (nullable)
        lastAnnotatedDate TEXT,                        -- ISO date-time string of last annotation
        numberOfFrames INTEGER,                        -- Total frames (useful for videos)

        FOREIGN KEY(datasetId) REFERENCES datasets(id) ON DELETE CASCADE,
        FOREIGN KEY(owner_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

  // Labels table (per project)
  await db.execute('''
      CREATE TABLE labels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label_order INTEGER NOT NULL,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        color TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        description TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE
      );
    ''');

  // Annotations table
  // annotation_type TEXT NOT NULL,        -- "bbox", "classification", "segmentation", "keypoints", etc.
  // data TEXT NOT NULL,                   -- JSON-string with coordinates, masks, or key poinrts etc.
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
        annotation_schema_version INTEGER NOT NULL DEFAULT 1 CHECK (annotation_schema_version >= 1),
        provenance TEXT,
        review_status TEXT NOT NULL DEFAULT 'draft' CHECK (review_status IN ('draft', 'proposed', 'accepted', 'rejected')),
        reviewed_by INTEGER,
        reviewed_at TEXT,
        review_comment TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(media_item_id) REFERENCES media_items(id) ON DELETE CASCADE,
        FOREIGN KEY(label_id) REFERENCES labels(id) ON DELETE CASCADE,
        FOREIGN KEY(annotator_id) REFERENCES users(id) ON DELETE SET NULL,
        FOREIGN KEY(reviewed_by) REFERENCES users(id) ON DELETE SET NULL
      );
    ''');

  // Notifications table
  await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT NOT NULL,
        type TEXT NOT NULL,
        backgroundColor TEXT NOT NULL,
        textColor TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0
      );
    ''');

  // -- Video temporal tables (Step 6) -------------------------------------------

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

  // -- Indexes -----------------------------------------------------------------

  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_projects_owner_id ON projects(ownerId)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_datasets_project_id_order ON datasets(projectId, dataset_order)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_media_items_dataset_id ON media_items(datasetId)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_annotations_media_item_id ON annotations(media_item_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_annotations_label_id ON annotations(label_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_annotations_review_status ON annotations(review_status)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_labels_project_id ON labels(project_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_dataset_media_folders_dataset_id ON dataset_media_folders(datasetId)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_dataset_media_folders_folder_id ON dataset_media_folders(folderId)',
  );

  // Video temporal indexes
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_video_assets_project ON video_assets(project_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_video_assets_media_item ON video_assets(media_item_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_video_frames_video_asset ON video_frames(video_asset_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_video_frames_asset_index ON video_frames(video_asset_id, frame_index)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_video_frames_run ON video_frames(extraction_run_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_annotation_tracks_video ON annotation_tracks(video_asset_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_annotation_tracks_label ON annotation_tracks(label_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_track_keyframes_track ON track_keyframes(track_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_track_keyframes_frame ON track_keyframes(frame_id)',
  );
  await db.execute(
    'CREATE INDEX IF NOT EXISTS idx_annotation_tracks_review ON annotation_tracks(review_status)',
  );

  // -- AI jobs table (Step 13) -------------------------------------------------

  await db.execute('''
      CREATE TABLE ai_jobs (
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
}

Future<String> getDefaultAnnotationRootPath() async {
  final dbDir = await getAppDatabaseDirectory();
  final basePath = path.dirname(dbDir);
  await ensureDirectoryExists(basePath);
  return basePath;
}
