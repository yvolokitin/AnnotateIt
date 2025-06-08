import 'dart:ui';
import 'shape.dart';

class CircleShape extends Shape {
  final double centerX;
  final double centerY;
  final double radius;

  CircleShape(this.centerX, this.centerY, this.radius);

  static CircleShape? fromJson(Map<String, dynamic> json) {
    final missing = <String>[];
    if (!json.containsKey('cx')) missing.add('cx');
    if (!json.containsKey('cy')) missing.add('cy');
    if (!json.containsKey('r')) missing.add('r');

    if (missing.isNotEmpty) {
      print('[CircleShape] Warning: Missing fields: ${missing.join(', ')}. Skipping shape. Raw: $json');
      return null;
    }

    try {
      return CircleShape(
        (json['cx'] as num).toDouble(),
        (json['cy'] as num).toDouble(),
        (json['r'] as num).toDouble(),
      );
    } catch (e) {
      print('[CircleShape] Failed to parse fields. Error: $e. Raw: $json');
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'cx': centerX,
        'cy': centerY,
        'r': radius,
      };

  Offset get center => Offset(centerX, centerY);

  Rect toRect() => Rect.fromCircle(center: center, radius: radius);

  @override
  void paint(Canvas canvas, Paint paint) {
    canvas.drawCircle(center, radius, paint);
  }
}
