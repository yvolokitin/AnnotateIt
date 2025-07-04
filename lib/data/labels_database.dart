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
  
  /// Replaces all labels for a given project
  Future<void> updateProjectLabels(int projectId, List<Label> newLabels) async {
    final db = await database;

    await db.transaction((txn) async {
      // Delete existing labels for the project
      await txn.delete(
        'labels',
        where: 'project_id = ?',
        whereArgs: [projectId],
      );

      // Insert new labels
      for (final label in newLabels) {
        await txn.insert('labels', label.toMap());
      }

      // Optionally update project's lastUpdated timestamp
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
    if (label.projectId == null) {
      throw ArgumentError('Label must be associated with a project (projectId cannot be null).');
    }

    // Verify project exists
    final projectExists = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM projects WHERE id = ?',
      [label.projectId],
    )) == 1;

    if (!projectExists) {
      throw Exception('Cannot insert label: project with ID ${label.projectId} does not exist.');
    }

    return await db.insert('labels', label.toMap());
  }

  Future<int> updateLabel(Label label) async {
    final db = await database;
    if (label.id == null) {
      throw ArgumentError("Cannot update label without ID.");
    }

    if (label.projectId == null) {
      throw ArgumentError('Label must be associated with a project (projectId cannot be null).');
    }

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
