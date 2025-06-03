import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'canvas_painter.dart';

import '../../models/annotation.dart';
import '../../models/label.dart';
import '../../models/shape/rect_shape.dart'; // Added import

class Canvas extends StatefulWidget {
  final ui.Image image;
  final List<Annotation> annotations; // Made non-nullable, assuming it's initialized
  final List<Label> labelDefinitions;
  final Function(Annotation) onAnnotationCreated; // Callback for new annotations
  // activeTool will be passed from parent (ImageAnnotator)
  final String? activeTool;

  const Canvas({
    required this.image,
    required this.annotations,
    required this.labelDefinitions,
    required this.onAnnotationCreated,
    this.activeTool,
    super.key,
  });

  @override
  State<Canvas> createState() => _CanvasState();
}

class _CanvasState extends State<Canvas> {

  double prevScale = 1;
  Matrix4 matrix = Matrix4.identity()
    ..scale(0.9);
  Matrix4 inverse = Matrix4.identity();
  bool done = false;

  // To store points of the bounding box being drawn
  List<Offset> _currentPoints = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((_) {
      setState(() {
        matrix = setTransformToFit(widget.image);
      });
    });
  }

  // Helper to transform screen coordinates to image coordinates
  Offset _screenToImageSpace(Offset screenOffset) {
    inverse.copyInverse(matrix);
    final Vector3 transformed = inverse * Vector3(screenOffset.dx, screenOffset.dy, 0);
    return Offset(transformed.x, transformed.y);
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.activeTool == "bounding_box") {
      final imagePoint = _screenToImageSpace(details.localPosition);
      setState(() {
        _currentPoints = [imagePoint, imagePoint];
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.activeTool == "bounding_box" && _currentPoints.isNotEmpty) {
      final imagePoint = _screenToImageSpace(details.localPosition);
      setState(() {
        _currentPoints[1] = imagePoint;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.activeTool == "bounding_box" && _currentPoints.length == 2) {
      final Rect rect = Rect.fromPoints(_currentPoints[0], _currentPoints[1]);
      // Ensure width and height are positive
      final normalizedRect = Rect.fromLTRB(
        min(rect.left, rect.right),
        min(rect.top, rect.bottom),
        max(rect.left, rect.right),
        max(rect.top, rect.bottom),
      );

      if (normalizedRect.width > 0 && normalizedRect.height > 0) {
        // TODO: mediaItemId needs to be passed to this Canvas widget to be correctly set.
        // Using a placeholder value for now.
        final newAnnotation = Annotation(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
          mediaItemId: 0, // Placeholder - Actual mediaItemId is needed here
          labelId: null, // No label selected at point of creation by default
          shape: RectShape(normalizedRect.left, normalizedRect.top, normalizedRect.width, normalizedRect.height),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          // confidence, annotatorId can be set later or if available
        );
        widget.onAnnotationCreated(newAnnotation);
      }
      setState(() {
        _currentPoints = [];
      });
    }
  }

  Matrix4 setTransformToFit(ui.Image image) {
    if (context.size == null) {
      return Matrix4.identity();
    }
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final canvasSize = context.size!;

    final ratio = Size(imageSize.width / canvasSize.width, imageSize.height / canvasSize.height);

    final scale = 1 / max(ratio.width, ratio.height) * 0.9;
    final offset = (canvasSize - imageSize * scale as Offset) / 2;

    return matrix = Matrix4.identity()
      ..translate(offset.dx, offset.dy, 0.0)
      ..scale(scale);
  }

  void scaleCanvas(Vector3 localPosition, double scale) {
      inverse.copyInverse(matrix);
      final position = inverse * localPosition;
      final mScale = 1 - scale;
      setState(() {
          matrix *= Matrix4( // row major or column major
              scale, 0, 0, 0,
              0, scale, 0, 0,
              0, 0, scale, 0,
              mScale * position.x, mScale * position.y, 0, 1);
      });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (f) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            matrix = setTransformToFit(widget.image);
          });
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: SizedBox.expand(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(shape: BoxShape.rectangle),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onScaleStart: (_) {
                prevScale = 1;
              },
              onDoubleTap: () {
                setState(() {
                  matrix = setTransformToFit(widget.image);
                });
              },
              onScaleUpdate: (ScaleUpdateDetails d) {
                final scale = 1 - (prevScale - d.scale);
                prevScale = d.scale;
                final zoom = matrix.getMaxScaleOnAxis();
                scaleCanvas(Vector3(d.localFocalPoint.dx, d.localFocalPoint.dy, 0), scale);
                setState(() {
                    matrix.translate(d.focalPointDelta.dx / zoom, d.focalPointDelta.dy / zoom, 0.0);
                });
              },
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerSignal: (p) {
                  if (p is PointerScrollEvent) {
                    final scale = p.scrollDelta.dy > 0 ? 0.95 : 1.05; // lazy solution, perhaps an animation depending on the scrollDelta?
                    scaleCanvas(Vector3(p.localPosition.dx, p.localPosition.dy, 0.0), scale);
                  }
                },
                child: Transform(
                  transform: matrix,
                  alignment: FractionalOffset.topLeft,
                  child: Builder(
                    builder: (context) {
                      return CustomPaint(
                        painter: CanvasPainter(
                          widget.image,
                          widget.annotations,
                          widget.labelDefinitions,
                          matrix.getMaxScaleOnAxis(),
                          activeTool: widget.activeTool, // Pass active tool
                          currentPoints: _currentPoints, // Pass current points
                        ),
                        child: Container(),
                      );
                    }
                  )
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}