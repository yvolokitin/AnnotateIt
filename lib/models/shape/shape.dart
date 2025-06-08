import 'dart:ui' as ui;

import '../annotation.dart';

import 'rect_shape.dart';
import 'polygon_shape.dart';
import 'rotated_rect_shape.dart';
import 'circle_shape.dart';

abstract class Shape {
  void paint(ui.Canvas canvas, ui.Paint paint);
  Map<String, dynamic> toJson();

  static Shape? fromAnnotation(Annotation annotation) {
    final json = annotation.data;

    try {
      switch (annotation.annotationType) {
        case 'bbox':
          return RectShape.fromJson(json);
        case 'polygon':
          return PolygonShape.fromJson(json);
        case 'rotated_bbox':
          return RotatedRectShape.fromJson(json);
        case 'circle':
          return CircleShape.fromJson(json);
        default:
          print('[Shape] Unknown annotation type: ${annotation.annotationType}');
          return null;
      }
    } catch (e) {
      print('[Shape] Failed to parse annotation: $e');
      return null;
    }
  }
}
