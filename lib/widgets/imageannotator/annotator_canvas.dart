import 'dart:math';
import 'dart:ui' as ui;

import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/shape/shape.dart';
import 'canvas_painter.dart';
import 'user_action.dart';

class AnnotatorCanvas extends StatefulWidget {
  final UserAction userAction;
  final ui.Image image;
  final List<Label> labels;
  final List<Annotation>? annotations;
  final int resetZoomCount;
  final double opacity;

  final ValueChanged<double>? onZoomChanged;
  final ValueChanged<Annotation>? onAnnotationUpdated;

  const AnnotatorCanvas({
    required this.image,
    required this.labels,
    required this.annotations,
    required this.resetZoomCount,
    required this.opacity,
    required this.userAction,
    this.onZoomChanged,
    this.onAnnotationUpdated,
    super.key,
  });

  @override
  State<AnnotatorCanvas> createState() => _AnnotatorCanvasState();
}

class _AnnotatorCanvasState extends State<AnnotatorCanvas> {
  Offset? _middleButtonDragStart;
  Offset? _lastMiddleButtonPosition;
  
  Annotation? _selectedAnnotation;
  int _lastResetCount = 0;

  double prevScale = 1;
  Matrix4 matrix = Matrix4.identity()
    ..scale(0.9);
  Matrix4 inverse = Matrix4.identity();
  bool done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        matrix = setTransformToFit(widget.image);
      });
      notifyZoomChanged(matrix.getMaxScaleOnAxis());
    });
  }

  @override
  void didUpdateWidget(covariant AnnotatorCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.resetZoomCount != _lastResetCount) {
      _lastResetCount = widget.resetZoomCount;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          matrix = setTransformToFit(widget.image);
        });
        // notify parent
        widget.onZoomChanged?.call(matrix.getMaxScaleOnAxis());
      });
    }
  } 

  void notifyZoomChanged(double zoom) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onZoomChanged?.call(zoom);
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
    final scaledImageSize = Size(imageSize.width * scale, imageSize.height * scale);
    final offset = Offset(
      (canvasSize.width - scaledImageSize.width) / 2,
      (canvasSize.height - scaledImageSize.height) / 2,
    );

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

    notifyZoomChanged(matrix.getMaxScaleOnAxis());
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (event.buttons == kMiddleMouseButton) {
      setState(() {
        _lastMiddleButtonPosition = event.localPosition;
      });
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.buttons == kMiddleMouseButton && _lastMiddleButtonPosition != null) {
      final delta = event.localPosition - _lastMiddleButtonPosition!;
      setState(() {
        _lastMiddleButtonPosition = event.localPosition;
        final zoom = matrix.getMaxScaleOnAxis();
        matrix.translate(delta.dx / zoom, delta.dy / zoom);
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (event.buttons == kMiddleMouseButton) {
      setState(() => _lastMiddleButtonPosition = null);
    }
  }
    
    void _handleTapDown(TapDownDetails details) {
    if (widget.userAction == UserAction.navigation) {
      final inverse = Matrix4.identity()..copyInverse(matrix);
      final transformed = MatrixUtils.transformPoint(inverse, details.localPosition);
      final tapped = _findAnnotationAtPosition(transformed);

      if (_selectedAnnotation?.id != tapped?.id) {
        setState(() {
          _selectedAnnotation = tapped;
        });
      } 
    }
  }

  Annotation? _findAnnotationAtPosition(Offset position) {
    final annotations = widget.annotations?.reversed ?? [];
    for (final annotation in annotations) {
      final shape = Shape.fromAnnotation(annotation);
      if (shape == null) continue;
      if (shape.boundingBox.contains(position) && shape.containsPoint(position)) {
        return annotation;
      }
    }
    return null;
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
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: _handlePointerDown,
              onPointerMove: _handlePointerMove,
              onPointerUp: _handlePointerUp,
              onPointerSignal: (p) {
                if (p is PointerScrollEvent) {
                  final scale = p.scrollDelta.dy > 0 ? 0.95 : 1.05;
                  scaleCanvas(Vector3(p.localPosition.dx, p.localPosition.dy, 0), scale);
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: _handleTapDown,
                onScaleStart: (_) => prevScale = 1,
                onDoubleTap: () {
                  setState(() => matrix = setTransformToFit(widget.image));
                  notifyZoomChanged(matrix.getMaxScaleOnAxis());
                },
                onScaleUpdate: (ScaleUpdateDetails d) {
                  final scale = 1 - (prevScale - d.scale);
                  prevScale = d.scale;
                  scaleCanvas(Vector3(d.localFocalPoint.dx, d.localFocalPoint.dy, 0), scale);
                },
                child: Transform(
                  transform: matrix,
                  child: CustomPaint(
                    painter: CanvasPainter(
                      image: widget.image,
                      annotations: widget.annotations,
                      selectedAnnotation: _selectedAnnotation,
                      scale: matrix.getMaxScaleOnAxis(),
                      opacity: widget.opacity,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}