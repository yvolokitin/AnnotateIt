import 'dart:ui' as ui;
import 'package:flutter/material.dart';

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
  final Annotation? selectedAnnotation;
  
  CanvasPainter({
    required this.image,
    required this.annotations,
    required this.scale,
    required this.opacity,
    this.selectedAnnotation,
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
   
    // the selected annotation’s red outline is always drawn on top
    if (selectedAnnotation != null) {
      final shape = Shape.fromAnnotation(selectedAnnotation!);
      if (shape != null) {
        final highlightPaint = Paint()
          ..color = Colors.red
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;
        shape.paint(canvas, highlightPaint);

        // Get shape corners and draw handles
        final corners = shapeCorners(shape);
        drawCornerHandles(canvas, corners);
      }
    }

  }

void drawCornerHandles(Canvas canvas, List<Offset> corners) {
  const handleSize = 12.0;
  const halfSize = handleSize / 2;
  const borderWidth = 4.0;

  final fillPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  final borderPaint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = borderWidth;

  for (final corner in corners) {
    final rect = Rect.fromCenter(center: corner, width: handleSize, height: handleSize);
    canvas.drawRect(rect, fillPaint);    // white background
    canvas.drawRect(rect, borderPaint);  // red border
  }
}

  List<Offset> shapeCorners(Shape shape) {
    if (shape is RectShape) {
      return [
        Offset(shape.x, shape.y),
        Offset(shape.x + shape.width, shape.y),
        Offset(shape.x + shape.width, shape.y + shape.height),
        Offset(shape.x, shape.y + shape.height),
      ];
    } else if (shape is RotatedRectShape) {
      return shape.toCorners(); // already defined
    } else if (shape is PolygonShape) {
      return shape.points;
    } else if (shape is CircleShape) {
      // corners of the bounding square
      return [
        Offset(shape.centerX - shape.radius, shape.centerY - shape.radius),
        Offset(shape.centerX + shape.radius, shape.centerY - shape.radius),
        Offset(shape.centerX + shape.radius, shape.centerY + shape.radius),
        Offset(shape.centerX - shape.radius, shape.centerY + shape.radius),
      ];
    }
    return [];
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
    return oldDelegate.annotations != annotations ||
         oldDelegate.selectedAnnotation?.id != selectedAnnotation?.id ||
         oldDelegate.opacity != opacity ||
         oldDelegate.scale != scale;
  }

  @override
  bool shouldRebuildSemantics(CanvasPainter oldDelegate) => false;
}