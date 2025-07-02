 import 'dart:ui';

import '../annotation.dart';

import 'rect_shape.dart';
import 'polygon_shape.dart';
import 'rotated_rect_shape.dart';
import 'circle_shape.dart';

/// Abstract base class for all annotation shapes
abstract class Shape {
  /// Draws the shape on a canvas using the provided paint.
  void paint(Canvas canvas, Paint paint);

  /// Returns the shape’s bounding rectangle (used for hit-testing and selection).
  Rect get boundingBox;

  /// Returns true if the given point lies inside the shape.
  bool containsPoint(Offset point);

  /// Absolute move: sets shape’s position to [newPosition].
  Shape moveTo(Offset newPosition);

  /// Relative move: shifts shape’s position by [delta] (dx, dy).
  Shape move(Offset delta);

  /// Resizes the shape by dragging one of its corners.
  /// [handleIndex] identifies the dragged corner (0–3), [originalCorners] are the shape’s initial corners.
  Shape resize({
    required int handleIndex,
    required Offset newPosition,
    required List<Offset> originalCorners,
  });

  /// Returns top-left position or main reference point for the shape.
  Offset getPosition();

  /// Returns all corner points for rendering resize handles.
  List<Offset> getCorners();

  /// Returns the position where the label text should be displayed.
  Offset get labelOffset;

  /// Optionally provides a visual connection point from label to shape.
  Offset? get labelConnectionPoint => null;

  /// Converts the shape to a JSON-serializable map.
  Map<String, dynamic> toJson();

  /// Converts the shape to a map compatible with sqflite storage.
  Map<String, dynamic> toMap() => toJson();

  /// Factory method to create shape instances from an annotation.
  static Shape? fromAnnotation(Annotation annotation) {
    final json = annotation.data;

    try {
      switch (annotation.annotationType) {
        case 'bbox':
          return RectShape.fromJson(json);
        case 'polygon':
          return PolygonShape.fromJson(json);
        case 'rotated_bbox':
          return RotatedRectShape.fromJson(json);
        case 'circle':
          return CircleShape.fromJson(json);
        default:
          print('[Shape] Unknown annotation type: ${annotation.annotationType}');
          return null;
      }
    } catch (e) {
      print('[Shape] Failed to parse annotation: $e');
      return null;
    }
  }
}
