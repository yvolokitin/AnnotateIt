import 'dart:ui';
import 'shape.dart';

class CircleShape extends Shape {
  final double centerX;
  final double centerY;
  final double radius;

  CircleShape(this.centerX, this.centerY, this.radius);

  factory CircleShape.fromJson(Map<String, dynamic> json) {
    return CircleShape(
      (json['cx'] as num).toDouble(),
      (json['cy'] as num).toDouble(),
      (json['r'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'cx': centerX,
        'cy': centerY,
        'r': radius,
      };

  Offset get center => Offset(centerX, centerY);

  Rect toRect() => Rect.fromCircle(center: center, radius: radius);
}
