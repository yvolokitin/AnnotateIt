import 'dart:io';
import 'package:flutter/material.dart';
import 'annotation_rect.dart';
import 'annotation_painter.dart';
import '../../models/label.dart' as model;

class AnnotationCanvas extends StatelessWidget {
  final File imageFile;
  final List<AnnotationRect> annotations;
  final Offset? startPoint;
  final Offset? currentPoint;
  final bool isDrawing;
  final String label;
  final double fillOpacity;

  final List<model.Label> labels;

  /// Called when a label is selected for a bounding box
  final void Function(AnnotationRect, String) onLabelSelected;

  const AnnotationCanvas({
    super.key,
    required this.imageFile,
    required this.annotations,
    required this.startPoint,
    required this.currentPoint,
    required this.isDrawing,
    required this.label,
    required this.fillOpacity,
    required this.labels,
    required this.onLabelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            scaleEnabled: false,
            child: imageFile.existsSync()
                ? Image.file(imageFile, fit: BoxFit.contain)
                : const Center(
                    child: Text("File not found",
                        style: TextStyle(color: Colors.white70)),
                  ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: AnnotationPainter(
              annotations: annotations,
              start: startPoint,
              current: currentPoint,
              isDrawing: isDrawing,
              label: label,
              labels: labels,
              fillOpacity: fillOpacity,
            ),
          ),
        ),

        // Overlay labels and dropdowns
        ...annotations.map((ann) {
          final labelColor = _getColorForLabel(ann.label);
          final top = ann.rect.top - 28;
          final left = ann.rect.left;

          return Positioned(
            top: top < 0 ? 0 : top,
            left: left,
            child: ann.label.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: labelColor?.withOpacity(0.8) ?? Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ann.label,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text("Select label", style: TextStyle(fontSize: 12)),
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      items: labels.map((l) {
                        return DropdownMenuItem(
                          value: l.name,
                          child: Text(l.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          onLabelSelected(ann, value);
                        }
                      },
                    ),
                  ),
          );
        }),
      ],
    );
  }

  Color? _getColorForLabel(String labelName) {
    final match = labels.firstWhere(
      (l) => l.name == labelName,
      orElse: () => model.Label(projectId: 0, name: '', color: ''),
    );

    final hex = match.color.replaceAll('#', '');
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    return null;
  }
}
