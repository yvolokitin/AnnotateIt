import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'annotation_rect.dart';
import 'canvas.dart';

class AnnotationCanvasFromFile extends StatefulWidget {
  final File file;
  final List<AnnotationRect> annotations;
  final List<Label> labelDefinitions;

  const AnnotationCanvasFromFile({
    super.key,
    required this.file,
    this.annotations = const [],
    this.labelDefinitions = const [],
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
      annotations: [], // widget.annotations,
      labelDefinitions: [], // widget.labelDefinitions,
    );
  }
}
