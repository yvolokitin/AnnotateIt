import 'dart:ui';
import 'dart:math' as math;
import 'shape.dart';

class RotatedRectShape extends Shape {
  final double centerX;
  final double centerY;
  final double width;
  final double height;
  final double angle; // in radians

  RotatedRectShape(this.centerX, this.centerY, this.width, this.height, this.angle);

  static RotatedRectShape? fromJson(Map<String, dynamic> json) {
    final missing = <String>[];
    if (!json.containsKey('cx')) missing.add('cx');
    if (!json.containsKey('cy')) missing.add('cy');
    if (!json.containsKey('width')) missing.add('width');
    if (!json.containsKey('height')) missing.add('height');
    if (!json.containsKey('angle')) missing.add('angle');

    if (missing.isNotEmpty) {
      print('[RotatedRectShape] Warning: Missing fields: ${missing.join(', ')}. Skipping shape. Raw: $json');
      return null;
    }

    try {
      return RotatedRectShape(
        (json['cx'] as num).toDouble(),
        (json['cy'] as num).toDouble(),
        (json['width'] as num).toDouble(),
        (json['height'] as num).toDouble(),
        (json['angle'] as num).toDouble(),
      );
    } catch (e) {
      print('[RotatedRectShape] Failed to parse fields. Error: $e. Raw: $json');
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'cx': centerX,
        'cy': centerY,
        'width': width,
        'height': height,
        'angle': angle,
      };

  List<Offset> toCorners() {
    final hw = width / 2;
    final hh = height / 2;
    final sinA = math.sin(angle);
    final cosA = math.cos(angle);

    return [
      Offset(-hw, -hh),
      Offset(hw, -hh),
      Offset(hw, hh),
      Offset(-hw, hh),
    ].map((p) {
      final x = cosA * p.dx - sinA * p.dy + centerX;
      final y = sinA * p.dx + cosA * p.dy + centerY;
      return Offset(x, y);
    }).toList();
  }

  @override
  void paint(Canvas canvas, Paint paint) {
    final corners = toCorners();
    final path = Path()
      ..moveTo(corners[0].dx, corners[0].dy)
      ..lineTo(corners[1].dx, corners[1].dy)
      ..lineTo(corners[2].dx, corners[2].dy)
      ..lineTo(corners[3].dx, corners[3].dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  Rect get boundingBox {
    final corners = toCorners();
    double minX = corners.first.dx;
    double maxX = corners.first.dx;
    double minY = corners.first.dy;
    double maxY = corners.first.dy;

    for (final corner in corners) {
      if (corner.dx < minX) minX = corner.dx;
      if (corner.dx > maxX) maxX = corner.dx;
      if (corner.dy < minY) minY = corner.dy;
      if (corner.dy > maxY) maxY = corner.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  bool containsPoint(Offset point) {
    final translated = point - Offset(centerX, centerY);

    // Reverse rotate the point
    final cosA = math.cos(-angle);
    final sinA = math.sin(-angle);
    final rotated = Offset(
      cosA * translated.dx - sinA * translated.dy,
      sinA * translated.dx + cosA * translated.dy,
    );

    // Simple AABB check in unrotated space
    return rotated.dx >= -width / 2 &&
         rotated.dx <= width / 2 &&
         rotated.dy >= -height / 2 &&
         rotated.dy <= height / 2;
  }
}
