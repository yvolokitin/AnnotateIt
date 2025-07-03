import 'dart:math' as math;
import 'dart:ui';

import 'shape.dart';

/// A shape representing a rotated rectangle.
class RotatedRectShape extends Shape {
  final double centerX;
  final double centerY;
  final double width;
  final double height;
  final double angle; // in radians

  RotatedRectShape(this.centerX, this.centerY, this.width, this.height, this.angle);

  /// Parses shape data from a JSON map.
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

  /// Converts the shape to a JSON-serializable map.
  @override
  Map<String, dynamic> toJson() => {
        'cx': centerX,
        'cy': centerY,
        'width': width,
        'height': height,
        'angle': angle,
      };

  /// Draws the rotated rectangle on the canvas.
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

  /// Returns the 4 corners of the rotated rectangle.
  @override
  List<Offset> getCorners() => toCorners();

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

  /// Returns the shape’s center as its main position.
  @override
  Offset getPosition() => Offset(centerX, centerY);

  /// Absolute movement — creates a shape at a new center.
  @override
  RotatedRectShape moveTo(Offset newPosition) {
    return RotatedRectShape(
      newPosition.dx,
      newPosition.dy,
      width,
      height,
      angle,
    );
  }

  /// Relative movement — shifts center by delta.
  @override
  RotatedRectShape move(Offset delta) {
    return RotatedRectShape(
      centerX + delta.dx,
      centerY + delta.dy,
      width,
      height,
      angle,
    );
  }

  /// Resizes the shape by changing width and height relative to [handleIndex].
  @override
  RotatedRectShape resize({
    required int handleIndex,
    required Offset newPosition,
    required List<Offset> originalCorners,
  }) {
    // Convert new position to unrotated local coordinates
    final localPoint = newPosition - Offset(centerX, centerY);
    final cosA = math.cos(-angle);
    final sinA = math.sin(-angle);
    final unrotatedPoint = Offset(
      cosA * localPoint.dx - sinA * localPoint.dy,
      sinA * localPoint.dx + cosA * localPoint.dy,
    );

    double newWidth = width;
    double newHeight = height;

    switch (handleIndex) {
      case 0: // top-left
        newWidth = (width / 2 - unrotatedPoint.dx).abs() * 2;
        newHeight = (height / 2 - unrotatedPoint.dy).abs() * 2;
        break;
      case 1: // top-right
        newWidth = (width / 2 + unrotatedPoint.dx).abs() * 2;
        newHeight = (height / 2 - unrotatedPoint.dy).abs() * 2;
        break;
      case 2: // bottom-right
        newWidth = (width / 2 + unrotatedPoint.dx).abs() * 2;
        newHeight = (height / 2 + unrotatedPoint.dy).abs() * 2;
        break;
      case 3: // bottom-left
        newWidth = (width / 2 - unrotatedPoint.dx).abs() * 2;
        newHeight = (height / 2 + unrotatedPoint.dy).abs() * 2;
        break;
    }

    final minSize = 8.0;
    newWidth = math.max(newWidth, minSize);
    newHeight = math.max(newHeight, minSize);

    return RotatedRectShape(centerX, centerY, newWidth, newHeight, angle);
  }

  /// Returns the bounding box (AABB) around the rotated corners.
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

  /// Checks if a point is inside the rotated rectangle.
  @override
  bool containsPoint(Offset point) {
    final translated = point - Offset(centerX, centerY);
    final cosA = math.cos(-angle);
    final sinA = math.sin(-angle);

    final rotated = Offset(
      cosA * translated.dx - sinA * translated.dy,
      sinA * translated.dx + cosA * translated.dy,
    );

    return rotated.dx >= -width / 2 &&
           rotated.dx <= width / 2 &&
           rotated.dy >= -height / 2 &&
           rotated.dy <= height / 2;
  }

  /// Returns a label offset above the top edge.
  @override
  Offset get labelOffset {
    final unrotatedTop = Offset(centerX, centerY - height / 2);

    final rotatedX = centerX + math.cos(angle) * (unrotatedTop.dx - centerX) -
                             math.sin(angle) * (unrotatedTop.dy - centerY);
    final rotatedY = centerY + math.sin(angle) * (unrotatedTop.dx - centerX) +
                             math.cos(angle) * (unrotatedTop.dy - centerY);

    return Offset(
      rotatedX - math.sin(angle) * 20,
      rotatedY - math.cos(angle) * 20,
    );
  }

  /// Connection point for label lines (center of shape).
  @override
  Offset? get labelConnectionPoint => Offset(centerX, centerY);

  @override
  Shape clampToBounds(Size imageSize) {
    final corners = toCorners();

    final minX = corners.map((c) => c.dx).reduce(math.min);
    final maxX = corners.map((c) => c.dx).reduce(math.max);
    final minY = corners.map((c) => c.dy).reduce(math.min);
    final maxY = corners.map((c) => c.dy).reduce(math.max);

    // Вычисляем на сколько углы выходят за границы
    double dx = 0;
    double dy = 0;

    if (minX < 0) dx = -minX;
    if (maxX > imageSize.width) dx = imageSize.width - maxX;

    if (minY < 0) dy = -minY;
    if (maxY > imageSize.height) dy = imageSize.height - maxY;

    return RotatedRectShape(
      centerX + dx,
      centerY + dy,
      width,
      height,
      angle,
    );
  }
}
