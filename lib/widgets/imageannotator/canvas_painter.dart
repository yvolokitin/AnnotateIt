// import 'dart:math';
import 'dart:ui' as ui;
// import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
// import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../../models/annotation.dart';
import '../../models/shape/rect_shape.dart';
import '../../models/shape/polygon_shape.dart';
import '../../models/shape/rotated_rect_shape.dart';
import '../../models/shape/shape.dart';
import '../../models/shape/circle_shape.dart';

class CanvasPainter extends CustomPainter {
  final ui.Image image;
  final List<Annotation>? annotations;
  final double scale, opacity;

  CanvasPainter({
    required this.image,
    required this.annotations,
    required this.scale,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    paintImage(
      alignment: Alignment.topLeft,
      canvas: canvas,
      rect: Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      fit: BoxFit.scaleDown,
      image: image,
    );

    for (final annotation in annotations ?? []) {
      final shape = Shape.fromAnnotation(annotation);
      if (shape != null) {
        final color = annotation.color ?? Colors.grey;
        final paint = Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        final fillPaint = Paint()
          ..color = color.withOpacity(opacity)
          ..style = PaintingStyle.fill;

        // label line
        shape.paint(canvas, paint);
        // label transparent background
        shape.paint(canvas, fillPaint);

        final name = annotation.name ?? 'Unknown';
        final offset = _labelOffsetFromShape(shape); // adaptive position
        drawLabel(canvas, size, name, color, offset);
      }
    }
  }

  Offset _labelOffsetFromShape(Shape shape) {
    if (shape is RectShape) return Offset(shape.x, shape.y);
    if (shape is PolygonShape) return shape.boundingRect.topCenter - const Offset(0, 20);
    if (shape is RotatedRectShape) return Offset(shape.centerX, shape.centerY - shape.height / 2 - 20);
    if (shape is CircleShape) return Offset(shape.centerX, shape.centerY - shape.radius - 20);
    return Offset.zero;
  }

  Color foregroundColorByLuminance(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Size drawLabel(Canvas canvas, Size size, String name, Color color, Offset topLeftOfBox) {
    final paint = Paint()..color = color;

    final textStyle = TextStyle(
      color: foregroundColorByLuminance(color),
      fontFamily: 'JetBrainsMono',
      fontSize: 16 / scale,
      height: 1.0, // Avoid vertical padding
    );

    final textSpan = TextSpan(text: name, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // This is the critical line: align label's bottom to box's top
    final labelBottomY = topLeftOfBox.dy;
    final labelTopY = labelBottomY - textPainter.height;

    // Optional: Align horizontally to the box's left
    final labelX = topLeftOfBox.dx;

    final labelRect = Rect.fromLTWH(
      labelX,
      labelTopY,
      textPainter.width,
      textPainter.height,
    );

    canvas.drawRect(labelRect, paint);
    textPainter.paint(canvas, Offset(labelX, labelTopY));

    return textPainter.size;
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return false;
  }
  @override
  bool shouldRebuildSemantics(CanvasPainter oldDelegate) => false;
}