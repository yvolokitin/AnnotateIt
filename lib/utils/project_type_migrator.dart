import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

import '../data/annotation_database.dart';
import '../data/labels_database.dart';

import '../models/annotation.dart';
import '../models/label.dart';
import '../models/project.dart';

class ProjectTypeMigrator {
  /// Main entry point to migrate a project's type and transform annotations accordingly.
  static Future<void> migrateProjectType({
    required Project project,
    required String newProjectType,
  }) async {
    final annotationDb = AnnotationDatabase.instance;
    final db = await annotationDb.database;

    final type = newProjectType.toLowerCase();

    // Load all current annotations for this project.
    final List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT * FROM annotations 
      WHERE media_item_id IN (
        SELECT id FROM media_items 
        WHERE datasetId IN (
          SELECT id FROM datasets 
          WHERE projectId = ?
        )
      )
    ''', [project.id]);

    final oldAnnotations = rows.map((e) => Annotation.fromMap(e)).toList();
    final List<Annotation> newAnnotations;

    // Convert annotations based on the selected new type.
    if (type.contains('binary')) {
      // Binary classification requires label cleanup first
      await _pruneToBinaryLabels(project, db);
      newAnnotations = _convertToBinaryClassification(oldAnnotations);

    } else if (type.contains('multi-class')) {
      newAnnotations = _convertToMultiClassClassification(oldAnnotations);

    } else if (type.contains('multi-label')) {
      newAnnotations = _convertToMultiLabelClassification(oldAnnotations);

    } else {
      // Convert between detection <-> segmentation
      newAnnotations = oldAnnotations
          .where((ann) =>
              ann.annotationType == 'bbox' || ann.annotationType == 'polygon')
          .map((ann) {
        if (type.contains('segmentation') && ann.annotationType == 'bbox') {
          return ann.copyWith(
            annotationType: 'polygon',
            data: _convertBboxToPolygon(ann.data),
          );
        } else if (type.contains('detection') && ann.annotationType == 'polygon') {
          return ann.copyWith(
            annotationType: 'bbox',
            data: _convertPolygonToBbox(ann.data),
          );
        } else {
          return ann;
        }
      }).toList();
    }

    final deleted = await db.transaction((txn) async {
      final deletedCount = await txn.rawDelete('''
        DELETE FROM annotations 
        WHERE media_item_id IN (
          SELECT id FROM media_items 
          WHERE datasetId IN (
            SELECT id FROM datasets 
            WHERE projectId = ?
          )
        )
      ''', [project.id]);

      for (final ann in newAnnotations) {
        await txn.insert('annotations', ann.toMap());
      }

      await txn.update(
        'projects',
        {
          'type': newProjectType,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [project.id],
      );

      return deletedCount;
    });

    debugPrint('Deleted $deleted annotations');
  }

  /// Deletes all labels except the first two (by order), and removes annotations that refer to removed labels.
  static Future<void> _pruneToBinaryLabels(Project project, Database db) async {
    final labelsDb = LabelsDatabase.instance;
    labelsDb.setDatabase(db); // Make sure the database is set

    final allLabels = await labelsDb.fetchLabelsByProject(project.id!);
    List<Label> sortedLabels = List<Label>.from(allLabels)
      ..sort((a, b) => a.labelOrder.compareTo(b.labelOrder));

    final topTwo = sortedLabels.take(2).toList();
    final remainingIds = topTwo.map((l) => l.id!).toSet();

    await db.transaction((txn) async {
      // Delete annotations with labels that are not in topTwo
      await txn.delete(
        'annotations',
        where: '''
          label_id NOT IN (${remainingIds.join(',')}) 
          AND media_item_id IN (
            SELECT id FROM media_items 
            WHERE datasetId IN (
              SELECT id FROM datasets 
              WHERE projectId = ?
            )
          )
        ''',
        whereArgs: [project.id],
      );

      // Delete removed labels
      await txn.delete(
        'labels',
        where: 'project_id = ? AND id NOT IN (${remainingIds.join(',')})',
        whereArgs: [project.id],
      );
    });
  }

  /// Converts annotations to Binary Classification: one label per image using the dominant one.
  static List<Annotation> _convertToBinaryClassification(List<Annotation> anns) {
    final uniqueLabels = anns
        .map((a) => a.labelId)
        .whereType<int>()
        .toSet()
        .toList()
      ..sort();

    final validLabels = uniqueLabels.take(2).toSet();
    final result = <Annotation>[];
    final grouped = <int, List<Annotation>>{};
    for (final a in anns) {
      if (validLabels.contains(a.labelId)) {
        grouped.putIfAbsent(a.mediaItemId, () => []).add(a);
      }
    }

    for (final entry in grouped.entries) {
      final counts = <int, int>{};
      for (final a in entry.value) {
        counts[a.labelId!] = (counts[a.labelId!] ?? 0) + 1;
      }
      final mainLabel = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      result.add(
        Annotation(
          mediaItemId: entry.key,
          labelId: mainLabel,
          annotationType: 'classification',
          data: {},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          annotatorId: entry.value.first.annotatorId,
        ),
      );
    }

    return result;
  }

  /// Converts to Multi-class Classification: one label per image based on lowest label ID.
  static List<Annotation> _convertToMultiClassClassification(List<Annotation> anns) {
    final result = <Annotation>[];
    final grouped = <int, List<Annotation>>{};
    for (final a in anns) {
      grouped.putIfAbsent(a.mediaItemId, () => []).add(a);
    }

    for (final entry in grouped.entries) {
      final sorted = entry.value.where((e) => e.labelId != null).toList()
        ..sort((a, b) => (a.labelId ?? 0).compareTo(b.labelId ?? 0));

      if (sorted.isNotEmpty) {
        result.add(
          Annotation(
            mediaItemId: entry.key,
            labelId: sorted.first.labelId,
            annotationType: 'classification',
            data: {},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            annotatorId: sorted.first.annotatorId,
          ),
        );
      }
    }

    return result;
  }

  /// Converts to Multi-label Classification: one annotation per label per image.
  static List<Annotation> _convertToMultiLabelClassification(List<Annotation> anns) {
    final grouped = <int, Map<int, Annotation>>{};
    for (final a in anns) {
      if (a.labelId != null) {
        grouped.putIfAbsent(a.mediaItemId, () => {})[a.labelId!] = a;
      }
    }

    final result = <Annotation>[];
    for (final entry in grouped.entries) {
      for (final ann in entry.value.values) {
        result.add(
          Annotation(
            mediaItemId: entry.key,
            labelId: ann.labelId,
            annotationType: 'classification',
            data: {},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            annotatorId: ann.annotatorId,
          ),
        );
      }
    }
    return result;
  }

  /// Converts bbox shape to polygon shape data.
  static Map<String, dynamic> _convertBboxToPolygon(Map<String, dynamic> data) {
    try {
      double? x, y, w, h;

      // Format: bbox: [x, y, width, height]
      if (data.containsKey('bbox') && data['bbox'] is List && data['bbox'].length == 4) {
        final List bbox = data['bbox'];
        x = (bbox[0] as num).toDouble();
        y = (bbox[1] as num).toDouble();
        w = (bbox[2] as num).toDouble();
        h = (bbox[3] as num).toDouble();
      
      // Format: x, y, width, height
      } else if (data.containsKey('x') && data.containsKey('y') &&
             data.containsKey('width') && data.containsKey('height')) {
        x = (data['x'] as num?)?.toDouble();
        y = (data['y'] as num?)?.toDouble();
        w = (data['width'] as num?)?.toDouble();
        h = (data['height'] as num?)?.toDouble();

      // Format: x_center, y_center, width, height
      } else if (data.containsKey('x_center') && data.containsKey('y_center') &&
             data.containsKey('width') && data.containsKey('height')) {
        final xc = (data['x_center'] as num?)?.toDouble();
        final yc = (data['y_center'] as num?)?.toDouble();
        w = (data['width'] as num?)?.toDouble();
        h = (data['height'] as num?)?.toDouble();
        if (xc != null && yc != null && w != null && h != null) {
          x = xc - w / 2;
          y = yc - h / 2;
        }
      }

      if (x == null || y == null || w == null || h == null) {
        debugPrint('Skipping invalid bbox (missing values): $data');
        return {};
      }

      return {
        'points': [
          {'x': x,       'y': y},
          {'x': x + w,   'y': y},
          {'x': x + w,   'y': y + h},
          {'x': x,       'y': y + h},
        ]
      };
    } catch (e) {
      debugPrint('Exception in _convertBboxToPolygon: $e\nData: $data');
      return {};
    }
  }

  /// Converts polygon shape to bounding box shape data.
static Map<String, dynamic> _convertPolygonToBbox(Map<String, dynamic> data) {
  try {
    final rawPoints = data['points'];
    if (rawPoints == null || rawPoints.isEmpty) return {};

    List<double> xs = [];
    List<double> ys = [];

    if (rawPoints.first is Map) {
      // Format: [{"x": x1, "y": y1}, {"x": x2, "y": y2}, ...]
      for (final p in rawPoints) {
        final x = (p['x'] as num?)?.toDouble();
        final y = (p['y'] as num?)?.toDouble();
        if (x != null && y != null) {
          xs.add(x);
          ys.add(y);
        }
      }
    } else if (rawPoints.first is num && rawPoints.length % 2 == 0) {
      // Format: [x1, y1, x2, y2, ...]
      for (int i = 0; i < rawPoints.length; i += 2) {
        final x = (rawPoints[i] as num?)?.toDouble();
        final y = (rawPoints[i + 1] as num?)?.toDouble();
        if (x != null && y != null) {
          xs.add(x);
          ys.add(y);
        }
      }
    } else {
      debugPrint('⚠️ Unknown point format: $rawPoints');
      return {};
    }

    if (xs.isEmpty || ys.isEmpty) return {};

    final xMin = xs.reduce((a, b) => a < b ? a : b);
    final yMin = ys.reduce((a, b) => a < b ? a : b);
    final xMax = xs.reduce((a, b) => a > b ? a : b);
    final yMax = ys.reduce((a, b) => a > b ? a : b);

    return {
      'x': xMin,
      'y': yMin,
      'width': xMax - xMin,
      'height': yMax - yMin,
    };
  } catch (e) {
    debugPrint('⚠️ Exception in _convertPolygonToBbox: $e\nData: $data');
    return {};
  }
}
}
