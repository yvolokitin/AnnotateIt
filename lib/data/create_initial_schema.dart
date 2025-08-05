import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:path/path.dart' as path;

/// Creates all tables and initializes folders.
Future<void> createInitialSchema(Database db, int version) async {
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
        labelsSetFirstAsDefault INTEGER NOT NULL DEFAULT 0,
        autoSaveAnnotations INTEGER NOT NULL DEFAULT 1,
        projectSkipDeleteConfirm INTEGER NOT NULL DEFAULT 0,
        projectShowImportWarning INTEGER NOT NULL DEFAULT 1,
        annotationAllowImageCopy INTEGER NOT NULL DEFAULT 1,
        annotationOpacity REAL NOT NULL DEFAULT 0.35
      )
    ''');

    final datasetImportFolder = 'datasets';
    final datasetExportFolder = 'exports';
    final thumbnailFolder = 'thumbnails';

    final rootPath = await getDefaultAnnotationRootPath();
    try {
      await Directory(path.join(rootPath, datasetImportFolder)).create(recursive: true);
    } catch (e) {
      print('Warning: Could not create datasets directory: $e');
    }

    // Create folders if they don't exist - with error handling
    try {
      await Directory(path.join(rootPath, datasetExportFolder)).create(recursive: true);
    } catch (e) {
      print('Warning: Could not create exports directory: $e');
    }

    try {
      await Directory(path.join(rootPath, thumbnailFolder)).create(recursive: true);
    } catch (e) {
      print('Warning: Could not create thumbnails directory: $e');
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
      'labelsSetFirstAsDefault': 0,
      'autoSaveAnnotations': 1,
      'projectSkipDeleteConfirm': 0,
      'projectShowImportWarning': 1,
      'annotationAllowImageCopy': 1,
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
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(media_item_id) REFERENCES media_items(id) ON DELETE CASCADE,
        FOREIGN KEY(label_id) REFERENCES labels(id) ON DELETE CASCADE,
        FOREIGN KEY(annotator_id) REFERENCES users(id) ON DELETE SET NULL
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
}

Future<String> getDefaultAnnotationRootPath() async {
  final docsDir = await getApplicationDocumentsDirectory();
  final basePath = path.join(docsDir.path, 'AnnotateIt');

  await Directory(basePath).create(recursive: true);
  return basePath;
}
