import 'dart:math';
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

Color getColorByLabelID(String labelId, List<Label> labelDefinitions) {
  final label = labelDefinitions.firstWhereOrNull((Label b) => b.id == labelId);
  if (label == null) {
    throw "Label not found";
  }
  return HexColor.fromHex(label.color.substring(0, 7));
}

class CanvasPainter extends CustomPainter {
  final ui.Image image;
  final List<Annotation>? annotations;
  final List<Label> labels;
  final Map<String, Label> labelById;
  final double scale;
  final String? activeTool;
  final List<Offset> currentPoints;

  CanvasPainter(
    this.image,
    this.annotations,
    this.labels,
    this.scale, {
    this.activeTool,
    this.currentPoints = const [],
  }) : labelById = {for (var v in labels) v.id.toString(): v};

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
      // final firstLabelColor = getColorByLabelID(annotation.labels[0].id, labels);

      // THIS IS WORKAROUND
      final firstLabelColor = Colors.red;

      Paint paint = Paint()
        ..color = firstLabelColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      Paint transparent = Paint()
        ..color = Color.fromARGB(102, firstLabelColor.red, firstLabelColor.green, firstLabelColor.blue);

      final shape = annotation.shape;
      if (shape != null) {
        if (shape is RectShape) {
          drawRectangle(canvas, size, paint, transparent, annotation);
        } else if (shape is PolygonShape) {
          drawPolygon(canvas, size, paint, transparent, annotation);
        } else if (shape is RotatedRectShape) {
          drawRotatedRectangle(canvas, size, paint, transparent, annotation);
        } /*else if (shape is CircleShape) {
          // drawCircle(canvas, size, paint, transparent, annotation);
        }*/
      }
    }

    // Draw the temporary bounding box if it's being created
    if (activeTool == "bounding_box" && currentPoints.length == 2) {
      final tempRectPaint = Paint()
        ..color = Colors.blueAccent.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 / scale; // Adjust stroke width based on zoom

      final rectToDraw = Rect.fromPoints(currentPoints[0], currentPoints[1]);
      canvas.drawRect(rectToDraw, tempRectPaint);
    }
  }

  void drawRectangle(Canvas canvas, Size size, Paint paint, Paint transparent, Annotation annotation){
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    // final rect = (annotation.shape as Rectangle).toRect();
    final rect = (annotation.shape as RectShape).toRect();
    canvas.drawRect(rect, paint);
    if (rect.size != imageSize) {
      canvas.drawRect(rect, transparent);
    }
    var position = rect.topLeft;
    for (final label in labels) {
      final labelSize = drawLabel(canvas, size, label, position);
      position += Offset(labelSize.width, 0);
    }
  }

  void drawPolygon(Canvas canvas, Size size, Paint paint, Paint transparent, Annotation annotation) {
    // final path = ui.Path();
    // final shape = (annotation.shape as PolygonShape);
    // path.addPolygon(shape.points, true);
    final shape = annotation.shape as PolygonShape;
    final path = Path()..addPolygon(shape.points, true);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, transparent);

    // final rect = shape.rectangle.toRect();
    final rect = shape.boundingRect;
    final topCenter = rect.topCenter - const Offset(0, 30.0);
    canvas.drawLine(rect.center, topCenter, paint);

    var position = topCenter;
    for (final label in labels) {
      final labelSize = drawLabel(canvas, size, label, position);
      position += Offset(labelSize.width, 0);
    }
  }

  void drawRotatedRectangle(Canvas canvas, Size size, Paint paint, Paint transparent, Annotation annotation) {
    // final shape = (annotation.shape as RotatedRectangle);
    final shape = (annotation.shape as RotatedRectShape);

    final path = ui.Path();
    final rect = ui.Rect.fromCenter(center: ui.Offset.zero, width: shape.width, height: shape.height);
    path.addRect(rect);
    final matrix = Matrix4.identity()
      ..rotateZ(shape.angle) // .angleInRadians)
      ..setTranslationRaw(shape.centerX, shape.centerY, 0.0);

    final corners = [rect.topLeft, rect.topRight, rect.bottomRight, rect. bottomLeft];

    final rotatedPath = path.transform(matrix.storage);
    canvas.drawPath(rotatedPath, paint);
    canvas.drawPath(rotatedPath, transparent);

    double labelPosition = double.infinity;
    for (final corner in corners) {
      final transformedCorner = (matrix * Vector3(corner.dx, corner.dy, 0)) as Vector3;
      labelPosition = min(transformedCorner.y, labelPosition);
    }

    var position = Offset(shape.centerX, labelPosition - 30);
    canvas.drawLine(Offset(shape.centerX, shape.centerY), position, paint);
    for (final label in labels) {
      final labelSize = drawLabel(canvas, size, label, position);
      position += Offset(labelSize.width, 0);
    }
  }

  Color foregroundColorByLuminance(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Size drawLabel(Canvas canvas, Size size, Label label, Offset position) {
    // final labelName = labelById[label.id]?.name ?? "Unknown object";
    final labelName = "Yura Label";
    final color = Colors.blue; // getColorByLabelID(label.id.toString(), labels);
    Paint paint = Paint()
      ..color = color;
    final textStyle = TextStyle(
      color: foregroundColorByLuminance(color),
      fontFamily: 'IntelOne',
      fontSize: 14 / scale,
    );
    final textSpan = TextSpan(
      text: "$labelName",
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
    // Repaint if annotations, active tool, or current points change, or scale.
    return oldDelegate.annotations != annotations ||
        oldDelegate.activeTool != activeTool ||
        oldDelegate.currentPoints != currentPoints ||
        oldDelegate.scale != scale ||
        oldDelegate.image != image ||
        oldDelegate.labels != labels;
  }
  @override
  bool shouldRebuildSemantics(CanvasPainter oldDelegate) => false;
}