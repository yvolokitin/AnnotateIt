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

  factory RotatedRectShape.fromJson(Map<String, dynamic> json) {
    return RotatedRectShape(
      (json['cx'] as num).toDouble(),
      (json['cy'] as num).toDouble(),
      (json['width'] as num).toDouble(),
      (json['height'] as num).toDouble(),
      (json['angle'] as num).toDouble(),
    );
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
}
