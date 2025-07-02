import 'dart:ui';
import 'shape.dart';

/// A polygon shape represented by a list of points (Offset).
class PolygonShape extends Shape {
  final List<Offset> points;

  PolygonShape(this.points);

  /// Parses a PolygonShape from a JSON map.
  static PolygonShape? fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('points') || json['points'] is! List) {
      print('[PolygonShape] Warning: Missing or invalid "points" key. Data: $json');
      return null;
    }

    final rawPoints = json['points'] as List;
    final parsedPoints = <Offset>[];

    try {
      // Nested format: [[x, y], [x, y], ...]
      if (rawPoints.isNotEmpty && rawPoints.first is List) {
        for (final p in rawPoints) {
          if (p is List && p.length >= 2 && p[0] is num && p[1] is num) {
            parsedPoints.add(Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()));
          }
        }
      }
      // Flat format: [x1, y1, x2, y2, ...]
      else {
        for (int i = 0; i < rawPoints.length - 1; i += 2) {
          final x = rawPoints[i];
          final y = rawPoints[i + 1];
          if (x is num && y is num) {
            parsedPoints.add(Offset(x.toDouble(), y.toDouble()));
          }
        }
      }

      if (parsedPoints.isEmpty) {
        print('[PolygonShape] Warning: No valid points found. Raw points: $rawPoints');
        return null;
      }

      return PolygonShape(parsedPoints);
    } catch (e) {
      print('[PolygonShape] Failed to parse points. Error: $e. Raw: $rawPoints');
      return null;
    }
  }

  /// Converts the shape to a JSON-serializable map.
  @override
  Map<String, dynamic> toJson() => {
        'points': points.map((p) => [p.dx, p.dy]).toList(),
      };

  /// Returns the top-left corner (first point) or Offset.zero if empty.
  @override
  Offset getPosition() {
    return points.isNotEmpty ? points.first : Offset.zero;
  }

  /// Moves the entire polygon to a new position, aligning its first point.
  @override
  Shape moveTo(Offset newPosition) {
    if (points.isEmpty) return this;
    final delta = newPosition - points.first;
    final movedPoints = points.map((p) => p + delta).toList();
    return PolygonShape(movedPoints);
  }

  /// Moves the polygon by a delta offset.
  @override
  PolygonShape move(Offset delta) {
    return PolygonShape(
      points.map((p) => p + delta).toList(),
    );
  }

  /// Resizes the polygon by moving a single corner.
  @override
  PolygonShape resize({
    required int handleIndex,
    required Offset newPosition,
    required List<Offset> originalCorners,
  }) {
    if (handleIndex < 0 || handleIndex >= points.length) return this;
    final newPoints = List<Offset>.from(points);
    newPoints[handleIndex] = newPosition;
    return PolygonShape(newPoints);
  }

  /// Draws the polygon using Path.
  @override
  void paint(Canvas canvas, Paint paint) {
    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  /// Checks if a point is inside the polygon.
  @override
  bool containsPoint(Offset point) {
    final path = Path();
    if (points.isEmpty) return false;
    path.moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    return path.contains(point);
  }

  /// Bounding rectangle of the polygon.
  @override
  Rect get boundingBox {
    if (points.isEmpty) return Rect.zero;
    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Returns all points of the polygon (for resize handles).
  @override
  List<Offset> getCorners() => List<Offset>.from(points);

  /// Offset for placing the label (top center of bounding box).
  @override
  Offset get labelOffset => boundingBox.topCenter;

  /// Optional connection point for label line — uses centroid.
  @override
  Offset? get labelConnectionPoint {
    if (points.isEmpty) return null;
    double sumX = 0, sumY = 0;
    for (final p in points) {
      sumX += p.dx;
      sumY += p.dy;
    }
    return Offset(sumX / points.length, sumY / points.length);
  }
}
