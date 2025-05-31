import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
// import 'annotation_rect.dart'; // No longer used
import 'canvas.dart';
import 'annotation_tool.dart';
import '../../models/annotation.dart';
import '../../models/label.dart'; // Ensure Label is imported

class AnnotationCanvasFromFile extends StatefulWidget {
  final File file;
  // final List<AnnotationRect> annotations; // Old
  final List<Annotation> annotations;    // New
  final List<Label> labelDefinitions;
  final AnnotationTool currentTool;
  final int currentMediaItemId;
  final int? selectedLabelId;
  final ValueChanged<Annotation> onAnnotationCreated;

  const AnnotationCanvasFromFile({
    super.key,
    required this.file,
    this.annotations = const [],
    this.labelDefinitions = const [],
    required this.currentTool,
    required this.currentMediaItemId,
    this.selectedLabelId,
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

    return Canvas(
      image: _image!,
      annotations: widget.annotations, // Pass the List<Annotation>
      labelDefinitions: widget.labelDefinitions, // Pass the List<Label>
      currentTool: widget.currentTool,
      currentMediaItemId: widget.currentMediaItemId,
      selectedLabelId: widget.selectedLabelId,
      onAnnotationCreated: widget.onAnnotationCreated,
    );
  }
}
