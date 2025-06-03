import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'annotation_rect.dart';
import 'canvas.dart'; // Assuming this is your main Canvas widget
import '../../models/annotation.dart'; // Import Annotation model
import '../../models/label.dart';     // Import Label model (already in your Canvas)
import '../../models/shape/rect_shape.dart'; // Import RectShape

class AnnotationCanvasFromFile extends StatefulWidget {
  final File file;
  final List<AnnotationRect> annotations; // These are for display from DB
  final List<Label> labelDefinitions;
  final String? activeTool;
  final Function(Annotation) onAnnotationCreated;

  const AnnotationCanvasFromFile({
    super.key,
    required this.file,
    this.annotations = const [],
    this.labelDefinitions = const [],
    required this.activeTool,
    required this.onAnnotationCreated,
  });

  @override
  State<AnnotationCanvasFromFile> createState() => _AnnotationCanvasFromFileState();
}

class _AnnotationCanvasFromFileState extends State<AnnotationCanvasFromFile> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImageFromFile(widget.file);
  }

  Future<void> _loadImageFromFile(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Convert AnnotationRect to Annotation for the Canvas widget
    final canvasAnnotations = widget.annotations.map((annoRect) {
      // Create a simple Annotation object.
      // ID, labelId, etc., might need to be sourced if AnnotationRect has more info.
      // For now, focusing on the shape for display.
      return Annotation(
        id: DateTime.now().millisecondsSinceEpoch + annoRect.rect.hashCode, // Placeholder ID
        mediaItemId: 0, // Placeholder, Canvas might not need this for drawing
        labelId: null, // Placeholder
        shape: RectShape.fromRect(annoRect.rect),
        createdAt: DateTime.now(), // Placeholder
        updatedAt: DateTime.now(), // Placeholder
      );
    }).toList();

    return Canvas(
      image: _image!,
      // annotations: widget.annotations, // This was List<AnnotationRect>, Canvas expects List<Annotation>
      annotations: canvasAnnotations, // Pass converted annotations
      labelDefinitions: widget.labelDefinitions, // Pass through
      activeTool: widget.activeTool, // Pass through
      onAnnotationCreated: widget.onAnnotationCreated, // Pass through
    );
  }
}
