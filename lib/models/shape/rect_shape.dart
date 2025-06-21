import 'dart:ui';
import 'shape.dart';

class RectShape extends Shape {
  final double x;
  final double y;
  final double width;
  final double height;

  RectShape(this.x, this.y, this.width, this.height);

  static RectShape? fromJson(Map<String, dynamic> json) {
    try {
      // support format: { bbox: [x, y, w, h] }
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

      // support format: { x: ..., y: ..., width: ..., height: ... }
      final missingFields = <String>[];
      if (!json.containsKey('x')) missingFields.add('x');
      if (!json.containsKey('y')) missingFields.add('y');
      if (!json.containsKey('width')) missingFields.add('width');
      if (!json.containsKey('height')) missingFields.add('height');

      if (missingFields.isNotEmpty) {
        print('[RectShape] Warning: Missing fields: ${missingFields.join(', ')}. Skipping shape. Raw: $json');
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

  @override
  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };

  @override
  Rect get boundingBox => Rect.fromLTWH(x, y, width, height);

  @override
  bool containsPoint(Offset point) {
    return boundingBox.contains(point);
  }

  @override
  void paint(Canvas canvas, Paint paint) {
    final rect = Rect.fromLTWH(x, y, width, height);
    canvas.drawRect(rect, paint);
  }

  @override
  List<Offset> getCorners() {
    return [
      Offset(x, y),
      Offset(x + width, y),
      Offset(x + width, y + height),
      Offset(x, y + height),
    ];
  }

  @override
  RectShape move(Offset delta) {
    return RectShape(
      x + delta.dx,
      y + delta.dy,
      width,
      height,
    );
  }

  @override
  RectShape resize({
    required int handleIndex,
    required Offset newPosition,
    required List<Offset> originalCorners,
  }) {
    // Ensure width and height are always positive
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
}