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

  @override
  Rect get boundingBox => toRect();

  @override
  bool containsPoint(Offset point) {
    final dx = point.dx - centerX;
    final dy = point.dy - centerY;
    return dx * dx + dy * dy <= radius * radius;
  }

  @override
  CircleShape move(Offset delta) {
    return CircleShape(
      centerX + delta.dx,
      centerY + delta.dy,
      radius,
    );
  }

  @override
  CircleShape resize({
    required int handleIndex,
    required Offset newPosition,
    required List<Offset> originalCorners,
  }) {
    // For circles, we'll use the distance from center to new position as the radius
    final newRadius = (newPosition - center).distance;
    
    // Ensure minimum radius
    final minRadius = 4.0;
    final clampedRadius = newRadius > minRadius ? newRadius : minRadius;

    return CircleShape(
      centerX,
      centerY,
      clampedRadius,
    );
  }

  // For circles, we'll provide 4 handles at cardinal directions
  List<Offset> getCorners() {
    return [
      Offset(centerX, centerY - radius), // top
      Offset(centerX + radius, centerY), // right
      Offset(centerX, centerY + radius), // bottom
      Offset(centerX - radius, centerY), // left
    ];
  }

  @override
  Offset get labelOffset => Offset(
    centerX, 
    centerY - radius - (radius * 0.3) // 30% of radius as offset
  );

  @override
  Offset? get labelConnectionPoint => Offset(centerX, centerY);
}
