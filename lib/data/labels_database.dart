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
  
  /// Merge labels for a given project and keep annotations consistent.
  ///
  /// Behavior:
  /// - Existing labels are preserved; newly provided [newLabels] are merged in by name (case-insensitive).
  /// - If multiple labels share the same name ignoring case (e.g., "Car", "car", "CAR"), they are merged into one.
  ///   The surviving label is the first by label_order among existing labels; annotations pointing to duplicates
  ///   are re-linked to the surviving label, and duplicate label rows are removed.
  /// - No annotations are deleted.
  Future<void> updateProjectLabels(int projectId, List<Label> newLabels) async {
    final db = await database;

    await db.transaction((txn) async {
      // 1) Load existing labels ordered by label_order so the first one is stable.
      final existingRows = await txn.query(
        'labels',
        where: 'project_id = ?',
        whereArgs: [projectId],
        orderBy: 'label_order ASC',
      );

      // 2) Build keep map by lowercased name -> kept row, detect duplicates to merge
      final Map<String, Map<String, Object?>> keptByName = {};
      final Map<int, int> remapOldIdToKeptId = {}; // old dup id -> kept id
      final Set<int> duplicateIdsToDelete = {};
      final Set<int> keptIdsToSetDefault = {}; // if any duplicate had default, propagate to kept
      int maxOrder = -1;

      for (final row in existingRows) {
        final int id = row['id'] as int;
        final int order = row['label_order'] as int;
        final int isDefault = (row['is_default'] as int? ?? 0);
        final String nameLower = (row['name'] as String).toLowerCase();
        if (order > maxOrder) maxOrder = order;

        if (!keptByName.containsKey(nameLower)) {
          keptByName[nameLower] = row;
          // Keep as-is; if later a duplicate had default, we will set it
        } else {
          final kept = keptByName[nameLower]!;
          final int keptId = kept['id'] as int;
          // Remap annotations from duplicate to kept
          remapOldIdToKeptId[id] = keptId;
          duplicateIdsToDelete.add(id);
          if (isDefault == 1) {
            keptIdsToSetDefault.add(keptId);
          }
        }
      }

      // 3) Insert missing labels from newLabels (case-insensitive), appending at the end.
      //    Deduplicate incoming new labels by name (case-insensitive) as well.
      final Set<String> seenNewNames = {};
      for (final label in newLabels) {
        final String lower = label.name.toLowerCase();
        if (seenNewNames.contains(lower)) {
          continue; // skip duplicates within new list
        }
        seenNewNames.add(lower);

        if (!keptByName.containsKey(lower)) {
          // Insert new label, append order after existing maxOrder
          maxOrder += 1;
          final Label toInsert = label.copyWith(
            id: -1,
            projectId: projectId,
            labelOrder: maxOrder,
          );
          final int insertedId = await txn.insert('labels', toInsert.toMap());

          // Emulate a DB row map for the newly inserted label (only needed fields)
          keptByName[lower] = {
            'id': insertedId,
            'label_order': maxOrder,
            'project_id': projectId,
            'name': toInsert.name,
            'color': toInsert.color,
            'is_default': toInsert.isDefault ? 1 : 0,
            'description': toInsert.description,
            'createdAt': toInsert.createdAt.toIso8601String(),
          };
        }
      }

      // 4) Remap annotations from duplicate labels to the kept label
      for (final entry in remapOldIdToKeptId.entries) {
        await txn.update(
          'annotations',
          {'label_id': entry.value},
          where: 'label_id = ?',
          whereArgs: [entry.key],
        );
      }

      // 5) If any duplicate carried default flag, set it on kept label as well (do not unset others here)
      for (final keptId in keptIdsToSetDefault) {
        await txn.update(
          'labels',
          {'is_default': 1},
          where: 'id = ? AND project_id = ?',
          whereArgs: [keptId, projectId],
        );
      }

      // 6) Delete duplicate label rows
      for (final dupId in duplicateIdsToDelete) {
        await txn.delete('labels', where: 'id = ?', whereArgs: [dupId]);
      }

      // 7) Update project's lastUpdated timestamp
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
