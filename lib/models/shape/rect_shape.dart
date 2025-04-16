import 'dart:ui';
import 'shape.dart';

class RectShape extends Shape {
  final double x;
  final double y;
  final double width;
  final double height;

  RectShape(this.x, this.y, this.width, this.height);

  factory RectShape.fromJson(Map<String, dynamic> json) {
    return RectShape(
      (json['x'] as num).toDouble(),
      (json['y'] as num).toDouble(),
      (json['width'] as num).toDouble(),
      (json['height'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };

  Rect toRect() => Rect.fromLTWH(x, y, width, height);
}
