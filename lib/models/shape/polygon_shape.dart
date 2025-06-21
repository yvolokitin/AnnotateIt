import 'dart:ui';
import 'shape.dart';

class PolygonShape extends Shape {
  final List<Offset> points;

  PolygonShape(this.points);

  static PolygonShape? fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('points') || json['points'] is! List) {
      print('[PolygonShape] Warning: Missing or invalid "points" key. Data: $json');
      return null;
    }

    final rawPoints = json['points'] as List;
    final parsedPoints = <Offset>[];

    try {
      // Try nested format: [[x, y], [x, y], ...]
      if (rawPoints.isNotEmpty && rawPoints.first is List) {
        for (final p in rawPoints) {
          if (p is List && p.length >= 2 && p[0] is num && p[1] is num) {
            parsedPoints.add(Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()));
          } 
        }
      }
      // Try flat format: [x1, y1, x2, y2, ...]
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
  
  @override
  Map<String, dynamic> toJson() => {
        'points': points.map((p) => [p.dx, p.dy]).toList(),
      };

  Path toPath() {
    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      path.close();
    }
    return path;
  }

  Rect get boundingRect {
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

  @override
  void paint(Canvas canvas, Paint paint) {
    final path = toPath();
    canvas.drawPath(path, paint);
  }

  @override
  Rect get boundingBox => boundingRect;

  @override
  bool containsPoint(Offset point) {
    final path = toPath();
    return path.contains(point);
  }

  @override
  PolygonShape move(Offset delta) {
    return PolygonShape(
      points.map((point) => Offset(point.dx + delta.dx, point.dy + delta.dy)).toList(),
    );
  }

  @override
  PolygonShape resize({
    required int handleIndex,
    required Offset newPosition,
    required List<Offset> originalCorners,
  }) {
    if (handleIndex < 0 || handleIndex >= points.length) return this;

    // Calculate scale factors based on bounding box changes
    final oldBounds = boundingRect;
    final newPoints = List<Offset>.from(points);

    // Move the selected point directly to the new position
    newPoints[handleIndex] = newPosition;

    return PolygonShape(newPoints);
  }

  // Helper method to get corner points (same as all polygon points)
  List<Offset> getCorners() {
    return List<Offset>.from(points);
  }

  @override
  Offset get labelOffset {
    final heightOffset = boundingBox.height * 0.3; // 30% of height
    // return boundingBox.topCenter - Offset(0, 20 + heightOffset);
    return boundingBox.topCenter;// - Offset(0, heightOffset);
  }

  @override
  Offset? get labelConnectionPoint {
    if (points.isEmpty) return null;
    double sumX = 0, sumY = 0;
    for (final point in points) {
      sumX += point.dx;
      sumY += point.dy;
    }
    return Offset(sumX / points.length, sumY / points.length);
  }
}