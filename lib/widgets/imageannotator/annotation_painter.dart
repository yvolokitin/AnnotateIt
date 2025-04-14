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

  // AnnotationPainter(this.annotations, this.labels);

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final ann in annotations) {
      final color = _getColorForLabel(ann.label) ?? Colors.red;

      final fillPaint = Paint()
        ..color = color.withOpacity(ann.opacity)
        ..style = PaintingStyle.fill;

      borderPaint.color = color;

      canvas.drawRect(ann.rect, fillPaint);
      canvas.drawRect(ann.rect, borderPaint);
    }
  }

  Color? _getColorForLabel(String labelName) {
    final label = labels.firstWhere(
      (l) => l.name == labelName,
      orElse: () => model.Label(projectId: 0, name: '', color: ''),
    );

    if (label.color.isEmpty) return null;

    final hex = label.color.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
