import 'dart:ui';
import 'shape.dart';

/// A simple rectangle shape with top-left origin and size (width, height).
class RectShape extends Shape {
  final double x;
  final double y;
  final double width;
  final double height;

  RectShape(this.x, this.y, this.width, this.height);

  /// Parses shape from JSON map.
  static RectShape? fromJson(Map<String, dynamic> json) {
    try {
      // Format 1: { "bbox": [x, y, width, height] }
      if (json.containsKey('bbox') && json['bbox'] is List) {
        final list = json['bbox'] as List;
        if (list.length >= 4) {
          return RectShape(
            (list[0] as num).toDouble(),
            (list[1] as num).toDouble(),
            (list[2] as num).toDouble(),
            (list[3] as num).toDouble(),
          );
        } else {
          print('[RectShape] Warning: bbox list too short: $json');
          return null;
        }
      }

      // Format 2: { x: ..., y: ..., width: ..., height: ... }
      final missing = <String>[];
      if (!json.containsKey('x')) missing.add('x');
      if (!json.containsKey('y')) missing.add('y');
      if (!json.containsKey('width')) missing.add('width');
      if (!json.containsKey('height')) missing.add('height');

      if (missing.isNotEmpty) {
        print('[RectShape] Warning: Missing fields: ${missing.join(', ')}. Skipping shape. Raw: $json');
        return null;
      }

      return RectShape(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
        (json['width'] as num).toDouble(),
        (json['height'] as num).toDouble(),
      );
    } catch (e) {
      print('[RectShape] Failed to parse shape: $e. Raw: $json');
      return null;
    }
  }

  /// Converts the shape to a JSON-serializable map.
  @override
  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };

  /// Draws the rectangle on the canvas.
  @override
  void paint(Canvas canvas, Paint paint) {
    final rect = Rect.fromLTWH(x, y, width, height);
    canvas.drawRect(rect, paint);
  }

  /// Returns the top-left position.
  @override
  Offset getPosition() => Offset(x, y);

  /// Moves the rectangle to a new top-left position (absolute).
  @override
  RectShape moveTo(Offset newPosition) {
    return RectShape(
      newPosition.dx,
      newPosition.dy,
      width,
      height,
    );
  }

  /// Moves the rectangle by a delta (relative).
  @override
  RectShape move(Offset delta) {
    return RectShape(
      x + delta.dx,
      y + delta.dy,
      width,
      height,
    );
  }

  /// Resizes the rectangle based on which handle is being dragged.
  @override
  RectShape resize({
    required int handleIndex,
    required Offset newPosition,
    required List<Offset> originalCorners,
  }) {
    switch (handleIndex) {
      case 0: // top-left
        return RectShape(
          newPosition.dx,
          newPosition.dy,
          (x + width - newPosition.dx).abs(),
          (y + height - newPosition.dy).abs(),
        );
      case 1: // top-right
        return RectShape(
          x,
          newPosition.dy,
          (newPosition.dx - x).abs(),
          (y + height - newPosition.dy).abs(),
        );
      case 2: // bottom-right
        return RectShape(
          x,
          y,
          (newPosition.dx - x).abs(),
          (newPosition.dy - y).abs(),
        );
      case 3: // bottom-left
        return RectShape(
          newPosition.dx,
          y,
          (x + width - newPosition.dx).abs(),
          (newPosition.dy - y).abs(),
        );
      default:
        return this;
    }
  }

  /// Returns the corners: [top-left, top-right, bottom-right, bottom-left].
  @override
  List<Offset> getCorners() {
    return [
      Offset(x, y),
      Offset(x + width, y),
      Offset(x + width, y + height),
      Offset(x, y + height),
    ];
  }

  /// Label offset to the right of the top-left corner.
  @override
  Offset get labelOffset => Offset(x + 15, y);

  /// Optional label line connection point (not used here).
  @override
  Offset? get labelConnectionPoint => null;

  /// Bounding box equals the rectangle itself.
  @override
  Rect get boundingBox => Rect.fromLTWH(x, y, width, height);

  /// Checks if a point is inside the rectangle.
  @override
  bool containsPoint(Offset point) => boundingBox.contains(point);
}
