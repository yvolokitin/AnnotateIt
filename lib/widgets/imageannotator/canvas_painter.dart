import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../models/shape/shape.dart';
import '../../models/annotation.dart';
//import '../../models/shape/rect_shape.dart';
//import '../../models/shape/polygon_shape.dart';
//import '../../models/shape/rotated_rect_shape.dart';
//import '../../models/shape/circle_shape.dart';

class CanvasPainter extends CustomPainter {
  final ui.Image image;
  final List<Annotation>? annotations;
  final double scale, opacity;
  final Annotation? selectedAnnotation;
  final bool showAnnotationNames;

  final bool show_classifications = false;

  CanvasPainter({
    required this.image,
    required this.annotations,
    required this.scale,
    required this.opacity,
    required this.showAnnotationNames,
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
      // print('annotation.annotationType ${annotation.annotationType}');
      // Datumaro and CVAT use type = "label" for classification.
      if (annotation.annotationType == 'classification' || annotation.annotationType == 'label') {
        // Handle classification annotations differently
        if (show_classifications) {
          _paintClassificationAnnotation(canvas, size, annotation);
        }
        
      } else {
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

          if (showAnnotationNames) {
            drawLabel(
              canvas,
              size,
              annotation.name ?? 'Unknown',
              paint.color,
              shape.labelOffset,
              shapeConnectionPoint: shape.labelConnectionPoint,
            );
          }
        } else {
          debugPrint('Shape is null for annotation: ${annotation.id}');
        }
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
        final corners = shape.getCorners();
        drawCornerHandles(canvas, corners);
      }
    }
  }


void _paintClassificationAnnotation(Canvas canvas, Size size, Annotation annotation) {
  const padding = 8.0;
  const boxHeight = 32.0;
  const boxSpacing = 4.0;
  const verticalOffset = 0.0; // 20px above the image
  
  // Calculate box width based on text length
  final text = annotation.name ?? 'Unknown';
  final textStyle = TextStyle(
    color: foregroundColorByLuminance(annotation.color ?? Colors.grey),
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: textStyle),
    textDirection: TextDirection.ltr,
  )..layout();
  
  final boxWidth = textPainter.width + padding * 2;
  
  // Get all classification annotations
  final classificationAnnotations = annotations?.where(
    (a) => (a.annotationType == 'classification' || a.annotationType == 'label')
  ).toList() ?? [];

  // Calculate position based on index
  final index = classificationAnnotations.indexOf(annotation);
  if (index == -1) return;

  // Calculate total width needed for all boxes up to this one
  double totalWidth = 0;
  for (int i = 0; i < index; i++) {
    final otherText = classificationAnnotations[i].name ?? 'Unknown';
    final otherTextPainter = TextPainter(
      text: TextSpan(text: otherText, style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    totalWidth += (otherTextPainter.width + padding * 2) + boxSpacing;
  }

  // Draw 20px above the image (0,0) position
  final boxRect = Rect.fromLTWH(
    padding + totalWidth, // x position
    -boxHeight - verticalOffset, // y position (negative to go above)
    boxWidth,
    boxHeight,
  );
  
  // Draw filled box
  final fillPaint = Paint()
    ..color = (annotation.color ?? Colors.grey).withOpacity(opacity)
    ..style = PaintingStyle.fill;
  canvas.drawRRect(
    RRect.fromRectAndRadius(boxRect, const Radius.circular(4.0)),
    fillPaint,
  );
  
  // Draw border if selected
  if (annotation.id == selectedAnnotation?.id) {
    final borderPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(4.0)),
      borderPaint,
    );
  }
  
  // Draw text centered in box
  textPainter.paint(
    canvas,
    Offset(
      padding + totalWidth + (boxWidth - textPainter.width) / 2,
      -boxHeight - verticalOffset + (boxHeight - textPainter.height) / 2,
    ),
  );
}

  void drawCornerHandles(Canvas canvas, List<Offset> corners) {
    const handleSize = 12.0;
    const borderWidth = 5.0;

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

  Color foregroundColorByLuminance(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

Size drawLabel(
  Canvas canvas,
  Size size,
  String name,
  Color color,
  Offset labelPosition, {
  Offset? shapeConnectionPoint,
}) {
  // Text styling
  final textStyle = TextStyle(
    color: foregroundColorByLuminance(color),
    fontFamily: 'Arial',
    fontSize: 20 / scale,
    height: 1.0,
    fontWeight: FontWeight.bold,
  );

  final textSpan = TextSpan(text: name, style: textStyle);
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();

  // Padding calculations
  final horizontalPadding = 8.0 / scale;
  final verticalPadding = 4.0 / scale;

  // Label box positioning
  final labelBottomY = labelPosition.dy;
  final labelTopY = labelBottomY - textPainter.height - (2 * verticalPadding);
  final labelX = labelPosition.dx - horizontalPadding;

  // Label background rectangle
  final labelRect = Rect.fromLTWH(
    labelX,
    labelTopY,
    textPainter.width + (2 * horizontalPadding),
    textPainter.height + (2 * verticalPadding),
  );

  // Draw connecting line from shape center to label bottom center
  if (shapeConnectionPoint != null) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0 / scale
      ..style = PaintingStyle.stroke;

    final labelConnectionPoint = Offset(
      labelRect.center.dx,
      labelRect.bottom,
    );

    canvas.drawLine(
      shapeConnectionPoint,
      labelConnectionPoint,
      linePaint,
    );
  }

  // Draw label background
  canvas.drawRRect(
    RRect.fromRectAndRadius(labelRect, Radius.circular(4.0 / scale)),
    Paint()..color = color,
  );

  // Draw text
  textPainter.paint(
    canvas,
    Offset(
      labelX + horizontalPadding,
      labelTopY + verticalPadding,
    ),
  );

  return labelRect.size;
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