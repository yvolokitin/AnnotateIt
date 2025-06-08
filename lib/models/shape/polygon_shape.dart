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

    try {
      final parsedPoints = rawPoints
          .whereType<List>() // Ensure each element is a List
          .where((p) => p.length >= 2 && p[0] is num && p[1] is num)
          .map((p) => Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()))
          .toList();

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
}
