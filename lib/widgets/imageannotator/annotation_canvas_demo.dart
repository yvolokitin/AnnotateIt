import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'annotation_rect.dart';

class AnnotationCanvasDemo extends StatefulWidget {
  final ui.Image image;
  final List<AnnotationRect> annotations;
  final List<Label> labelDefinitions;

  const AnnotationCanvasDemo({
    super.key,
    required this.image,
    this.annotations = const [],
    this.labelDefinitions = const [],
  });

  @override
  State<AnnotationCanvasDemo> createState() => _AnnotationCanvasDemoState();
}

class _AnnotationCanvasDemoState extends State<AnnotationCanvasDemo> {
  double prevScale = 1;
  Matrix4 matrix = Matrix4.identity()..scale(0.9);
  Matrix4 inverse = Matrix4.identity();

  Matrix4 setTransformToFit(ui.Image image) {
    if (context.size == null) return Matrix4.identity();

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final canvasSize = context.size!;

    final ratio = Size(imageSize.width / canvasSize.width, imageSize.height / canvasSize.height);
    final scale = 1 / max(ratio.width, ratio.height) * 0.9;
    final offset = Offset((canvasSize.width - imageSize.width * scale) / 2,
                          (canvasSize.height - imageSize.height * scale) / 2);

    return Matrix4.identity()
      ..translate(offset.dx, offset.dy)
      ..scale(scale);
  }

  void scaleCanvas(vm.Vector3 localPosition, double scale) {
    inverse.copyInverse(matrix);
    final position = inverse.transform3(localPosition);
    final mScale = 1 - scale;
    setState(() {
      matrix *= Matrix4(
        scale, 0, 0, 0,
        0, scale, 0, 0,
        0, 0, scale, 0,
        mScale * position.x, mScale * position.y, 0, 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
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
            decoration: const BoxDecoration(),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onScaleStart: (_) => prevScale = 1,
              onDoubleTap: () {
                setState(() {
                  matrix = setTransformToFit(widget.image);
                });
              },
              onScaleUpdate: (d) {
                final scale = 1 - (prevScale - d.scale);
                prevScale = d.scale;
                final zoom = matrix.getMaxScaleOnAxis();
                scaleCanvas(vm.Vector3(d.localFocalPoint.dx, d.localFocalPoint.dy, 0), scale);
                setState(() {
                  matrix.translate(d.focalPointDelta.dx / zoom, d.focalPointDelta.dy / zoom);
                });
              },
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerSignal: (p) {
                  if (p is PointerScrollEvent) {
                    final scale = p.scrollDelta.dy > 0 ? 0.95 : 1.05;
                    scaleCanvas(vm.Vector3(p.localPosition.dx, p.localPosition.dy, 0), scale);
                  }
                },
                child: Transform(
                  transform: matrix,
                  alignment: Alignment.topLeft,
                  child: CustomPaint(
                    painter: _AnnotationPainter(
                      widget.image,
                      widget.annotations,
                      widget.labelDefinitions,
                      matrix.getMaxScaleOnAxis(),
                    ),
                    child: Container(),
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

class _AnnotationPainter extends CustomPainter {
  final ui.Image image;
  final List<AnnotationRect> annotations;
  final List<Label> labelDefinitions;
  final double zoom;

  _AnnotationPainter(this.image, this.annotations, this.labelDefinitions, this.zoom);

  Color _parseColor(String hexColor, double opacity) {
    hexColor = hexColor.replaceFirst('#', '');
    if (hexColor.length == 6) hexColor = 'FF$hexColor';
    return Color(int.parse(hexColor, radix: 16)).withOpacity(opacity);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);

    for (final annotation in annotations) {
      final label = labelDefinitions.firstWhere(
        (l) => l.name == annotation.label,
        orElse: () => Label(name: annotation.label, color: '#FF0000'),
      );

      final color = _parseColor(label.color, annotation.opacity);

      paint
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0 / zoom;

      canvas.drawRect(annotation.rect, paint);

      final textSpan = TextSpan(
        text: annotation.label,
        style: TextStyle(
          color: color,
          fontSize: 14 / zoom,
          backgroundColor: Colors.black54,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, annotation.rect.topLeft);
    }
  }

  @override
  bool shouldRepaint(covariant _AnnotationPainter oldDelegate) =>
      oldDelegate.image != image ||
      oldDelegate.annotations != annotations ||
      oldDelegate.zoom != zoom;
}
