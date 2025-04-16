import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'annotation_rect.dart';
import 'annotation_painter.dart';
import '../../models/label.dart' as model;

class AnnotationCanvas extends StatefulWidget {
  final File imageFile;
  final List<AnnotationRect> annotations;
  final String label;
  final double fillOpacity;
  final List<model.Label> labels;
  final double scale;
  final void Function(AnnotationRect, String) onLabelSelected;
  final void Function(double newScale) onScaleChanged;
  final void Function(AnnotationRect) onNewAnnotation;

  const AnnotationCanvas({
    super.key,
    required this.imageFile,
    required this.annotations,
    required this.label,
    required this.fillOpacity,
    required this.labels,
    required this.scale,
    required this.onLabelSelected,
    required this.onScaleChanged,
    required this.onNewAnnotation,
  });

  @override
  State<AnnotationCanvas> createState() => _AnnotationCanvasState();
}

class _AnnotationCanvasState extends State<AnnotationCanvas> {
  final TransformationController _transformationController = TransformationController();
  Offset? _startPoint;
  Offset? _currentPoint;
  bool _isDrawing = false;
  Size? _imageSize;
  bool _zoomInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadImageSize();
  }

  Future<void> _loadImageSize() async {
    final completer = Completer<Size>();
    final image = Image.file(widget.imageFile);
    final imageStream = image.image.resolve(const ImageConfiguration());
    imageStream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
    }));
    final size = await completer.future;
    setState(() {
      _imageSize = size;
    });
  }

  Offset _transformToCanvas(Offset localPosition) {
    final inverted = Matrix4.tryInvert(_transformationController.value);
    if (inverted == null) return localPosition;
    return MatrixUtils.transformPoint(inverted, localPosition);
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final zoomFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
      final matrix = _transformationController.value.clone();
      final inverted = Matrix4.tryInvert(matrix);
      if (inverted == null) return;

      final focal = MatrixUtils.transformPoint(inverted, event.localPosition);
      matrix.translate(focal.dx, focal.dy);
      matrix.scale(zoomFactor);
      matrix.translate(-focal.dx, -focal.dy);

      _transformationController.value = matrix;
      widget.onScaleChanged(matrix.getMaxScaleOnAxis());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageSize == null) return const Center(child: CircularProgressIndicator());

    return LayoutBuilder(
  builder: (context, constraints) {
    if (!_zoomInitialized && _imageSize != null) {
      final scaleX = constraints.maxWidth / _imageSize!.width;
      final scaleY = constraints.maxHeight / _imageSize!.height;
      final fittedScale = math.min(scaleX, scaleY);

      final dx = (constraints.maxWidth - _imageSize!.width * fittedScale) / 2;
      final dy = (constraints.maxHeight - _imageSize!.height * fittedScale) / 2;

      final matrix = Matrix4.identity()
        ..translate(dx, dy)
        ..scale(fittedScale);

      _transformationController.value = matrix;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onScaleChanged(fittedScale);
      });

      _zoomInitialized = true;
    }

    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDrawing = true;
            _startPoint = _transformToCanvas(details.localPosition);
            _currentPoint = _startPoint;
          });
        },
        onPanUpdate: (details) {
          if (_isDrawing) {
            setState(() {
              _currentPoint = _transformToCanvas(details.localPosition);
            });
          }
        },
        onPanEnd: (_) {
          if (_isDrawing && _startPoint != null && _currentPoint != null) {
            final rect = Rect.fromPoints(_startPoint!, _currentPoint!);
            final newAnnotation = AnnotationRect(rect: rect, label: widget.label);
            widget.onNewAnnotation(newAnnotation);
          }
          setState(() {
            _isDrawing = false;
            _startPoint = null;
            _currentPoint = null;
          });
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Transform(
                transform: _transformationController.value,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: _imageSize?.width ?? 0,
                  height: _imageSize?.height ?? 0,
                  child: Stack(
                    children: [
                      Image.file(
                        widget.imageFile,
                        width: _imageSize!.width,
                        height: _imageSize!.height,
                        fit: BoxFit.fill, // не contain
                      ),
                      CustomPaint(
                        size: _imageSize!,
                        painter: AnnotationPainter(
                          annotations: widget.annotations,
                          start: _startPoint,
                          current: _currentPoint,
                          isDrawing: _isDrawing,
                          label: widget.label,
                          labels: widget.labels,
                          fillOpacity: widget.fillOpacity,
                        ),
                      ),
                      ...widget.annotations.map((ann) {
                        final color = _getColorForLabel(ann.label);
                        final pos = ann.rect.topLeft;
                        return Positioned(
                          left: pos.dx,
                          top: pos.dy - 28,
                          child: ann.label.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: color?.withOpacity(0.8) ?? Colors.black87,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    ann.label,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);

  }

  Color? _getColorForLabel(String name) {
    final match = widget.labels.firstWhere(
      (l) => l.name == name,
      orElse: () => model.Label(projectId: 0, name: '', color: ''),
    );
    final hex = match.color.replaceAll('#', '');
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    if (hex.length == 8) return Color(int.parse(hex, radix: 16));
    return null;
  }
}
