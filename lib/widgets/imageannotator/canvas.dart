import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'canvas_painter.dart';

import '../../models/annotation.dart';
import '../../models/label.dart';
import 'annotation_tool.dart';
import 'dart:math'; // For min/max
import '../../models/shape/rect_shape.dart';

class Canvas extends StatefulWidget {

  final ui.Image image;
  final List<Annotation>? annotations;
  final List<Label> labelDefinitions;
  final AnnotationTool currentTool;
  final int currentMediaItemId;
  final int? selectedLabelId;
  final ValueChanged<Annotation> onAnnotationCreated;

  const Canvas({
    required this.image,
    this.annotations,
    required this.labelDefinitions,
    required this.currentTool,
    required this.currentMediaItemId,
    this.selectedLabelId,
    required this.onAnnotationCreated,
    super.key
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

  Offset? _drawStartPoint; // In image coordinates
  Rect? _currentDrawingRect; // In image coordinates, for preview

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((_) {
      setState(() {
          matrix = setTransformToFit(widget.image);
      });
    });
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
              onScaleStart: (details) {
                if (widget.currentTool == AnnotationTool.bbox && details.pointerCount == 1) return; // If bbox tool is active and it's a single pointer, might be start of a pan for drawing. Let onPanStart handle it.
                // If multi-touch or not bbox tool, proceed with scaling.
                prevScale = 1; // prevScale must be a member of _CanvasState
              },
              onDoubleTap: () {
                setState(() {
                  matrix = setTransformToFit(widget.image); // matrix must be a member
                });
              },
              onScaleUpdate: (ScaleUpdateDetails d) {
                if (widget.currentTool == AnnotationTool.bbox && d.pointerCount == 1) return; // Ignore single pointer scale updates if bbox tool is active

                final scale = 1 - (prevScale - d.scale);
                prevScale = d.scale;
                final zoom = matrix.getMaxScaleOnAxis();
                scaleCanvas(Vector3(d.localFocalPoint.dx, d.localFocalPoint.dy, 0), scale); // scaleCanvas and other vars must be members
                setState(() {
                    matrix.translate(d.focalPointDelta.dx / zoom, d.focalPointDelta.dy / zoom, 0.0);
                });
              },
              onPanStart: (DragStartDetails details) {
                if (widget.currentTool != AnnotationTool.bbox) return;
                if (matrix == null) return; // Ensure matrix is initialized

                final Offset localPosition = details.localPosition;
                final Matrix4 currentInverse = Matrix4.inverted(matrix); // Calculate inverse if not already up-to-date member
                final Offset imagePosition = currentInverse.transformPoint(localPosition);

                setState(() {
                  _drawStartPoint = imagePosition;
                  _currentDrawingRect = Rect.fromPoints(imagePosition, imagePosition);
                });
              },
              onPanUpdate: (DragUpdateDetails details) {
                if (widget.currentTool != AnnotationTool.bbox || _drawStartPoint == null) return;
                if (matrix == null) return;

                final Offset localPosition = details.localPosition;
                final Matrix4 currentInverse = Matrix4.inverted(matrix);
                final Offset imagePosition = currentInverse.transformPoint(localPosition);

                setState(() {
                  _currentDrawingRect = Rect.fromPoints(_drawStartPoint!, imagePosition);
                });
              },
              onPanEnd: (DragEndDetails details) {
                if (widget.currentTool != AnnotationTool.bbox || _drawStartPoint == null || _currentDrawingRect == null) return;

                // Normalize the rectangle
                final Rect normalizedRect = Rect.fromLTRB(
                  min(_drawStartPoint!.dx, _currentDrawingRect!.left), // Corrected: use _currentDrawingRect!.left
                  min(_drawStartPoint!.dy, _currentDrawingRect!.top),  // Corrected: use _currentDrawingRect!.top
                  max(_drawStartPoint!.dx, _currentDrawingRect!.right), // Corrected: use _currentDrawingRect!.right
                  max(_drawStartPoint!.dy, _currentDrawingRect!.bottom) // Corrected: use _currentDrawingRect!.bottom
                );

                // Check for significant size
                // This threshold (5) is in image pixels.
                if (normalizedRect.width < 5 || normalizedRect.height < 5) {
                  setState(() {
                    _drawStartPoint = null;
                    _currentDrawingRect = null;
                  });
                  return;
                }

                final newAnnotation = Annotation(
                  mediaItemId: widget.currentMediaItemId,
                  labelId: widget.selectedLabelId,
                  annotationType: 'bbox',
                  data: RectShape(
                    normalizedRect.left,
                    normalizedRect.top,
                    normalizedRect.width,
                    normalizedRect.height,
                  ).toJson(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  // annotatorId and confidence can be set later by ImageAnnotatorPage if needed
                );

                widget.onAnnotationCreated(newAnnotation);

                setState(() {
                  _drawStartPoint = null;
                  _currentDrawingRect = null;
                });
              },
              // Keep existing Listener for PointerScrollEvent for mouse wheel zoom
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerSignal: (p) {
                  if (p is PointerScrollEvent) {
                    final scale = p.scrollDelta.dy > 0 ? 0.95 : 1.05; // lazy solution, perhaps an animation depending on the scrollDelta?
                    scaleCanvas(Vector3(p.localPosition.dx, p.localPosition.dy, 0.0), scale);
                  }
                },
                child: Transform(
                  transform: matrix, // Ensure matrix is a state variable
                  alignment: FractionalOffset.topLeft,
                  child: Builder(
                    builder: (context) {
                      // Pass _currentDrawingRect to CanvasPainter in the next step
                      return CustomPaint(
                        painter: CanvasPainter(
                          widget.image,
                          widget.annotations,
                          widget.labelDefinitions,
                          matrix.getMaxScaleOnAxis(), // Assuming matrix is a state variable
                          previewRect: _currentDrawingRect, // Pass the new parameter
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