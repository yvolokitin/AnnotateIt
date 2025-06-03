import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_annotator/models/shape/rect_shape.dart';

void main() {
  group('RectShape', () {
    test('fromJson creates a valid RectShape object', () {
      final json = {'x': 10.0, 'y': 20.0, 'width': 30.0, 'height': 40.0};
      final shape = RectShape.fromJson(json);

      expect(shape, isA<RectShape>());
      expect(shape.x, 10.0);
      expect(shape.y, 20.0);
      expect(shape.width, 30.0);
      expect(shape.height, 40.0);
    });

    test('toJson serializes RectShape to correct JSON', () {
      final shape = RectShape(10.0, 20.0, 30.0, 40.0);
      final json = shape.toJson();

      expect(json, {
        'x': 10.0,
        'y': 20.0,
        'width': 30.0,
        'height': 40.0,
      });
    });

    test('toRect returns the correct Rect object', () {
      final shape = RectShape(10.0, 20.0, 30.0, 40.0);
      final rect = shape.toRect();

      expect(rect, isA<Rect>());
      expect(rect.left, 10.0);
      expect(rect.top, 20.0);
      expect(rect.width, 30.0);
      expect(rect.height, 40.0);
    });
  });
}
