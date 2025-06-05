import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../models/annotation.dart';

import 'canvas.dart';

class AnnotationCanvasFromFile extends StatefulWidget {
  final File file;
  final List<Label> labels;
  final List<Annotation>? annotations;

  const AnnotationCanvasFromFile({
    super.key,
    required this.file,
    this.labels = const [],
    this.annotations = const [],
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
      labels: [], // widget.labelDefinitions,
      annotations: [], // widget.annotations,
    );
  }
}
