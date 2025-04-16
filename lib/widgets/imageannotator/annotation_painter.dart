import 'package:flutter/material.dart';
import 'annotation_rect.dart';
import '../../models/label.dart' as model;

class AnnotationPainter extends CustomPainter {
  final List<AnnotationRect> annotations;
  final Offset? start;
  final Offset? current;
  final bool isDrawing;
  final String label;
  final List<model.Label> labels;
  final double fillOpacity;

  AnnotationPainter({
    required this.annotations,
    required this.start,
    required this.current,
    required this.isDrawing,
    required this.label,
    required this.labels,
    this.fillOpacity = 0.1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final ann in annotations) {
      final color = _getColorForLabel(ann.label) ?? Colors.red;

      final fillPaint = Paint()
        ..color = color.withOpacity(fillOpacity)
        ..style = PaintingStyle.fill;

      borderPaint.color = color;

      canvas.drawRect(ann.rect, fillPaint);
      canvas.drawRect(ann.rect, borderPaint);
    }

    // 🔧 Draw the in-progress rectangle (while drawing)
    if (isDrawing && start != null && current != null) {
      final drawRect = Rect.fromPoints(start!, current!);
      final color = _getColorForLabel(label) ?? Colors.blueAccent;

      final fillPaint = Paint()
        ..color = color.withOpacity(fillOpacity)
        ..style = PaintingStyle.fill;

      borderPaint.color = color;

      canvas.drawRect(drawRect, fillPaint);
      canvas.drawRect(drawRect, borderPaint);
    }
  }

  Color? _getColorForLabel(String labelName) {
    final label = labels.firstWhere(
      (l) => l.name == labelName,
      orElse: () => model.Label(projectId: 0, name: '', color: ''),
    );

    if (label.color.isEmpty) return null;

    final hex = label.color.replaceAll('#', '');
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    return null;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
