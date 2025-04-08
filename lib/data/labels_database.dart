import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/label.dart';

class LabelsDatabase {
  static final LabelsDatabase instance = LabelsDatabase._init();
  static Database? _database;

  LabelsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'projects.db'); // uses the same DB as ProjectDatabase
    _database = await openDatabase(path);
    return _database!;
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

  /// Fetch all labels for a given project
  Future<List<Label>> fetchLabelsByProject(int projectId) async {
    final db = await database;
    final result = await db.query(
      'labels',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );

    return result.map((map) => Label.fromMap(map)).toList();
  }

  /// Insert a single label
  Future<int> insertLabel(Label label) async {
    final db = await database;
    return await db.insert('labels', label.toMap());
  }

  /// Delete a specific label
  Future<int> deleteLabel(int labelId) async {
    final db = await database;
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
    _database = null;
  }
}
