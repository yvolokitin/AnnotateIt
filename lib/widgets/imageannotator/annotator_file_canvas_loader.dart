import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../models/annotation.dart';

import 'canvas.dart';

class AnnotatorFileCanvasLoader extends StatefulWidget {
  final File file;
  final MouseCursor cursor;
  final List<Label> labels;
  final List<Annotation>? annotations;
  final int resetZoomCount;
  final ValueChanged<double>? onZoomChanged;

  const AnnotatorFileCanvasLoader({
    super.key,
    required this.file,
    required this.cursor,
    required this.labels,
    required this.annotations,
    required this.resetZoomCount,
    required this.onZoomChanged,
  });

  @override
  State<AnnotatorFileCanvasLoader> createState() => _AnnotatorFileCanvasLoaderState();
}

class _AnnotatorFileCanvasLoaderState extends State<AnnotatorFileCanvasLoader> {
  ui.Image? _image;
  double _currentZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _loadImageFromFile(widget.file);
  }

  Future<void> _loadImageFromFile(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    await Future.delayed(const Duration(seconds: 3));
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
      labels: widget.labels,
      annotations: widget.annotations,
      resetZoomCount: widget.resetZoomCount,
      onZoomChanged: (zoom) {
        setState(() {
          _currentZoom = zoom;
        });

        if (widget.onZoomChanged != null) {
          widget.onZoomChanged!(zoom);
        }
      },    
    );
  }
}
