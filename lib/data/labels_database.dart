import 'package:sqflite/sqflite.dart';

import '../models/label.dart';

class LabelsDatabase {
  static final LabelsDatabase instance = LabelsDatabase._init();
  static Database? _db;

  LabelsDatabase._init();

  void setDatabase(Database db) {
    _db = db;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    throw Exception("Database not set.");
  }
  
  /// Replaces all labels for a given project and keeps annotations consistent.
  ///
  /// Behavior:
  /// - Existing labels are replaced with [newLabels].
  /// - Annotations that referenced labels with the same name are re-linked to the newly inserted label IDs.
  /// - Annotations that referenced labels removed (name no longer present) are deleted.
  Future<void> updateProjectLabels(int projectId, List<Label> newLabels) async {
    final db = await database;

    await db.transaction((txn) async {
      // 1) Snapshot existing labels for the project (name -> id)
      final existingRows = await txn.query(
        'labels',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );
      final Map<String, int> oldIdByName = {
        for (final row in existingRows)
          (row['name'] as String).toLowerCase(): row['id'] as int,
      };

      // 2) Remove existing labels
      await txn.delete(
        'labels',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );

      // 3) Insert new labels and keep a mapping name -> newId
      final Map<String, int> newIdByName = {};
      for (final label in newLabels) {
        final insertedId = await txn.insert('labels', label.toMap());
        newIdByName[label.name.toLowerCase()] = insertedId;
      }

      // 4) Re-link or remove annotations based on label name match
      for (final entry in oldIdByName.entries) {
        final name = entry.key;
        final oldId = entry.value;
        final newId = newIdByName[name];
        if (newId != null) {
          // Update annotations to new label id
          await txn.update(
            'annotations',
            {'label_id': newId},
            where: 'label_id = ?',
            whereArgs: [oldId],
          );
        } else {
          // Label removed -> delete its annotations
          await txn.delete(
            'annotations',
            where: 'label_id = ?',
            whereArgs: [oldId],
          );
        }
      }

      // 5) Update project's lastUpdated timestamp
      await txn.update(
        'projects',
        {'lastUpdated': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [projectId],
      );
    });
  }

  /// Fetch all labels for a given project, ordered by the `order` field
  Future<List<Label>> fetchLabelsByProject(int projectId) async {
    final db = await database;
    final result = await db.query(
      'labels',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'label_order ASC', // sort by order field
    );

    return result.map((map) => Label.fromMap(map)).toList();
  }

  Future<Label?> fetchDefaultLabel(int projectId) async {
    final db = await database;
    final result = await db.query(
      'labels',
      where: 'project_id = ? AND is_default = 1',
      whereArgs: [projectId],
      limit: 1,
    );
    return result.isNotEmpty ? Label.fromMap(result.first) : null;
  }

  /// Insert a label for a specific project.
  /// Throws if projectId is null or project does not exist.
  Future<int> insertLabel(Label label) async {
    final db = await database;
    // Verify project exists
    final projectExists = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM projects WHERE id = ?',
      [label.projectId],
    )) == 1;

    if (!projectExists) {
      throw Exception('Cannot insert label: project with ID ${label.projectId} does not exist.');
    }

    // If a new label inserted -> update project's lastUpdated timestamp
    await db.update(
      'projects',
      {
        // Update project lastUpdated column with current time
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [label.projectId],
    );

    return await db.insert('labels', label.toMap());
  }

  Future<int> updateLabel(Label label) async {
    final db = await database;

    // If label upadted -> update project's lastUpdated timestamp
    await db.update(
      'projects',
      {
        // Update project lastUpdated column with current time
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [label.projectId],
    );

    return db.update(
      'labels',
      label.toMap(),
      where: 'id = ?',
      whereArgs: [label.id],
    );
  }

  /// Set the given label as default, unsetting any others in the same project.
  Future<void> setLabelAsDefault(int labelId, int projectId) async {
    final db = await database;
    await db.transaction((txn) async {
      // First, unset all labels in the project
      await txn.update(
        'labels',
        {'is_default': 0},
        where: 'project_id = ?',
        whereArgs: [projectId],
      );

      // Then, set the given label as default
      final count = await txn.update(
        'labels',
        {'is_default': 1},
        where: 'id = ? AND project_id = ?',
        whereArgs: [labelId, projectId],
      );

      if (count == 0) {
        throw Exception('Label with ID $labelId not found in project $projectId.');
      }
    });
  }

  /// Unset a label's default status by ID.
  Future<void> unsetLabelAsDefault(int labelId) async {
    final db = await database;
    final count = await db.update(
      'labels',
      {'is_default': 0},
      where: 'id = ?',
      whereArgs: [labelId],
    );

    if (count == 0) {
      throw Exception('Label with ID $labelId does not exist.');
    }
  }

  /// Unset all default labels for a project.
  Future<void> unsetAllDefaultLabels(int projectId) async {
    final db = await database;
    await db.update(
      'labels',
      {'is_default': 0},
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
  }

  /// Delete a label by ID, but ensure it belongs to an existing project.
  Future<int> deleteLabel(int labelId) async {
    final db = await database;
    // check if label exists first
    final labelExists = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM labels WHERE id = ?',
      [labelId],
    )) == 1;

    if (!labelExists) {
      throw Exception('Label with ID $labelId does not exist.');
    }

    return await db.delete('labels', where: 'id = ?', whereArgs: [labelId]);
  }

  /// Delete all labels for a project
  Future<int> deleteLabelsForProject(int projectId) async {
    final db = await database;
    return await db.delete('labels', where: 'project_id = ?', whereArgs: [projectId]);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
