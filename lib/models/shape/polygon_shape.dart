import 'dart:ui';
import 'shape.dart';

class PolygonShape extends Shape {
  final List<Offset> points;

  PolygonShape(this.points);

  factory PolygonShape.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List;
    return PolygonShape(
      rawPoints.map((p) => Offset((p[0] as num).toDouble(), (p[1] as num).toDouble())).toList(),
    );
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
}