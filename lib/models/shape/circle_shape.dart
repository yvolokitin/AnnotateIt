import 'dart:ui';
import 'shape.dart';

/// A circle shape defined by a center point and radius.
class CircleShape extends Shape {
  final double centerX;
  final double centerY;
  final double radius;

  CircleShape(this.centerX, this.centerY, this.radius);

  /// Parses a CircleShape from JSON format.
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

  /// Converts the shape to a JSON-serializable map.
  @override
  Map<String, dynamic> toJson() => {
        'cx': centerX,
        'cy': centerY,
        'r': radius,
      };

  /// Returns the center point of the circle.
  Offset get center => Offset(centerX, centerY);

  /// Returns the top-left origin of bounding box.
  @override
  Offset getPosition() => center;

  /// Moves the shape's center to the given position.
  @override
  Shape moveTo(Offset newPosition) {
    return CircleShape(newPosition.dx, newPosition.dy, radius);
  }

  /// Moves the circle by a delta offset.
  @override
  CircleShape move(Offset delta) {
    return CircleShape(centerX + delta.dx, centerY + delta.dy, radius);
  }

  /// Resizes the circle by setting radius = distance to newPosition.
  @override
  CircleShape resize({
    required int handleIndex,
    required Offset newPosition,
    required List<Offset> originalCorners,
  }) {
    final newRadius = (newPosition - center).distance;
    const minRadius = 4.0;
    return CircleShape(centerX, centerY, newRadius.clamp(minRadius, double.infinity));
  }

  /// Returns bounding rectangle of the circle.
  @override
  Rect get boundingBox => Rect.fromCircle(center: center, radius: radius);

  /// Checks if a point lies inside the circle.
  @override
  bool containsPoint(Offset point) {
    final dx = point.dx - centerX;
    final dy = point.dy - centerY;
    return dx * dx + dy * dy <= radius * radius;
  }

  /// Draws the circle on the canvas.
  @override
  void paint(Canvas canvas, Paint paint) {
    canvas.drawCircle(center, radius, paint);
  }

  /// Returns 4 handle positions: top, right, bottom, left.
  @override
  List<Offset> getCorners() => [
        Offset(centerX, centerY - radius),
        Offset(centerX + radius, centerY),
        Offset(centerX, centerY + radius),
        Offset(centerX - radius, centerY),
      ];

  /// Suggested label position above the circle.
  @override
  Offset get labelOffset => Offset(centerX, centerY - radius - (radius * 0.3));

  /// Optional point where label line connects to shape center.
  @override
  Offset? get labelConnectionPoint => center;
}
