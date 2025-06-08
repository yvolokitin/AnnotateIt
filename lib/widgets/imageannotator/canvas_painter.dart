// import 'dart:math';
import 'dart:ui' as ui;
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../../models/annotation.dart';
import '../../models/label.dart';

import '../../models/shape/rect_shape.dart';
import '../../models/shape/polygon_shape.dart';
import '../../models/shape/rotated_rect_shape.dart';
import '../../models/shape/shape.dart';
import '../../models/shape/circle_shape.dart';

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

Color getAnnotationColorByLabelId(int labelId, List<Label> labels) {
  final label = labels.firstWhereOrNull((b) => b.id == labelId);
  if (label == null) {
    print("Label not found: $labelId");
    return Colors.red;
  }
  return HexColor.fromHex(label.color.substring(0, 7));
}

String getAnnotationNameByLabelId(int labelId, List<Label> labels) {
  final label = labels.firstWhereOrNull((b) => b.id == labelId);
  if (label == null) {
    print("Unknown label id: $labelId");
    return "Unknown Name";
  }
  return label.name;
}

class CanvasPainter extends CustomPainter {
  final ui.Image image;
  final List<Annotation>? annotations;
  final List<Label> labels;
  final Map<String, Label> labelById;
  final double scale;

  CanvasPainter(
    this.image,
    this.labels,
    this.annotations,
    this.scale
  ): labelById = { for (var v in labels) v.id.toString() : v };

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
        final color = getAnnotationColorByLabelId(annotation.labelId, labels);
        final paint = Paint()
          ..color = color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        final fillPaint = Paint()
          ..color = color.withOpacity(0.4)
          ..style = PaintingStyle.fill;

        // label line
        shape.paint(canvas, paint);
        // label transparent background
        shape.paint(canvas, fillPaint);

        final name = getAnnotationNameByLabelId(annotation.labelId, labels);
        final offset = _labelOffsetFromShape(shape); // adaptive position
        drawLabel(canvas, size, name, color, offset);
      }
    }
  }

  Offset _labelOffsetFromShape(Shape shape) {
    if (shape is RectShape) return Offset(shape.x, shape.y - 20);
    if (shape is PolygonShape) return shape.boundingRect.topCenter - const Offset(0, 20);
    if (shape is RotatedRectShape) return Offset(shape.centerX, shape.centerY - shape.height / 2 - 20);
    if (shape is CircleShape) return Offset(shape.centerX, shape.centerY - shape.radius - 20);
    return Offset.zero;
  }

  Color foregroundColorByLuminance(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Size drawLabel(Canvas canvas, Size size, String name, Color color, Offset position) {
    Paint paint = Paint()
      ..color = color;
    final textStyle = TextStyle(
      color: foregroundColorByLuminance(color),
      fontFamily: 'JetBrainsMono',
      fontSize: 14 / scale,
    );
    final textSpan = TextSpan(
      text: name,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    canvas.drawRect(ui.Rect.fromLTWH(position.dx - 1, position.dy - textPainter.height - 1, textPainter.width + 2, textPainter.height), paint);
    textPainter.paint(canvas, position - Offset(0, textPainter.height));
    return textPainter.size + const Offset(3, 0);
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return false;
  }
  @override
  bool shouldRebuildSemantics(CanvasPainter oldDelegate) => false;
}