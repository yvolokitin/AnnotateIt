import 'dart:math';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../utils/theme.dart';

import '../../repositories/annotation_repository.dart';
import '../../repositories/sqlite_annotation_repository.dart';
import '../../session/user_session.dart';

import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/shape/shape.dart';

import 'canvas_painter.dart';
import 'user_action.dart';
import 'constants.dart';

class AnnotatorCanvas extends StatefulWidget {
  final ui.Image image;
  final int mediaItemId;

  final List<Annotation>? annotations;
  final Annotation? selectedAnnotation;
  final UserAction userAction;
  final List<Label> labels;
  final Label selectedLabel;
  final int resetZoomCount;
  final double opacity;
  final double strokeWidth;
  final double cornerSize;
  final bool showAnnotationNames;

  // Optional: allow parent to request a specific zoom level (1.0 = 100%)
  final double? requestedZoom;

  // Image-coordinate point where a SAM click is pending (shown as crosshair)
  final Offset? samPendingPoint;

  final ValueChanged<double>? onZoomChanged;
  final ValueChanged<Annotation>? onAnnotationUpdated;
  final ValueChanged<Annotation?>? onAnnotationSelected;
  final ValueChanged<Offset>? onSamTap;

  // New optional callbacks to mirror sidebar actions
  final void Function(Annotation, Label)? onAnnotationLabelChanged;
  final void Function(Annotation)? onAnnotationDelete;

  const AnnotatorCanvas({
    required this.image,
    required this.mediaItemId,
    required this.labels,
    required this.annotations,
    required this.resetZoomCount,
    required this.opacity,
    required this.cornerSize,
    required this.strokeWidth,
    required this.userAction,
    required this.showAnnotationNames,
    required this.selectedLabel,
    this.selectedAnnotation,
    this.requestedZoom,
    this.samPendingPoint,
    this.onZoomChanged,
    this.onAnnotationUpdated,
    this.onAnnotationSelected,
    this.onSamTap,
    this.onAnnotationLabelChanged,
    this.onAnnotationDelete,
    super.key,
  });

  @override
  State<AnnotatorCanvas> createState() => _AnnotatorCanvasState();
}

class _AnnotatorCanvasState extends State<AnnotatorCanvas> {
  final AnnotationRepository _annotationRepository =
      const SqliteAnnotationRepository();
  late List<Annotation> _localAnnotations;

  Offset? _lastMiddleButtonPosition;
  int _lastResetCount = 0;
  double prevScale = 1;

  // The transform is stored in a ValueNotifier so zoom/pan updates only
  // rebuild the lightweight Transform widget, not the expensive CustomPaint.
  final ValueNotifier<Matrix4> _transformNotifier =
      ValueNotifier(Matrix4.identity()..scale(0.9));
  Matrix4 get matrix => _transformNotifier.value;
  set matrix(Matrix4 m) => _transformNotifier.value = m;
  Matrix4 inverse = Matrix4.identity();

  // Scale value the painter uses for handle/text sizing. Updated on a
  // debounce so continuous scroll doesn't force expensive repaints.
  double _lastPaintedScale = 0.9;
  Timer? _scaleUpdateTimer;

  Timer? _zoomNotifyTimer;
  double? _queuedZoom;
  static const Duration _zoomNotifyInterval = Duration(milliseconds: 16);

  Annotation? _draggingAnnotation;
  Offset? _dragStartPosition;

  Offset? _drawingStart;
  Offset? _drawingCurrent;

  // For polygon annotation
  List<Offset> _polygonPoints = [];
  Offset? _currentPolygonPoint;
  bool _isPolygonComplete = false;

  int? _activeResizeHandle;
  List<Offset>? _originalCorners;

  // Clamp a point (in image coordinates) to the image bounds
  Offset _clampToImage(Offset p) {
    final double w = widget.image.width.toDouble();
    final double h = widget.image.height.toDouble();
    final double x = p.dx.clamp(0.0, w);
    final double y = p.dy.clamp(0.0, h);
    return Offset(x, y);
  }

  @override
  void initState() {
    super.initState();

    _localAnnotations = List<Annotation>.from(widget.annotations ?? []);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      matrix = setTransformToFit(widget.image);
      setState(() => _lastPaintedScale = matrix.getMaxScaleOnAxis());
      notifyZoomChanged(matrix.getMaxScaleOnAxis());
    });
  }

  @override
  void didUpdateWidget(covariant AnnotatorCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.annotations != oldWidget.annotations) {
      _localAnnotations = List<Annotation>.from(widget.annotations ?? []);
    }

    if (widget.resetZoomCount != _lastResetCount) {
      _lastResetCount = widget.resetZoomCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        matrix = setTransformToFit(widget.image);
        setState(() => _lastPaintedScale = matrix.getMaxScaleOnAxis());
        notifyZoomChanged(matrix.getMaxScaleOnAxis());
      });
    }

    // Apply externally requested zoom, if provided
    if (widget.requestedZoom != null &&
        widget.requestedZoom != oldWidget.requestedZoom) {
      final desired = widget.requestedZoom!;
      // Defer to next frame to ensure size is available (avoid accessing context.size during build)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final current = matrix.getMaxScaleOnAxis();
        if ((desired - current).abs() > 1e-6) {
          final size = context.size;
          final center =
              size == null
                  ? const Offset(0, 0)
                  : Offset(size.width / 2, size.height / 2);
          final factor = desired / current;
          scaleCanvas(Vector3(center.dx, center.dy, 0), factor);
        }
      });
    }
  }

  void notifyZoomChanged(double zoom) {
    _queuedZoom = zoom;
    // If a timer is already running, we just update the queued value
    if (_zoomNotifyTimer?.isActive ?? false) return;
    // Start a timer to coalesce multiple zoom updates into one notification
    _zoomNotifyTimer = Timer(_zoomNotifyInterval, () {
      final z = _queuedZoom;
      _queuedZoom = null;
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onZoomChanged?.call(z ?? zoom);
      });
    });
  }

  Matrix4 setTransformToFit(ui.Image image) {
    if (context.size == null) return Matrix4.identity();

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final canvasSize = context.size!;
    final ratio = Size(
      imageSize.width / canvasSize.width,
      imageSize.height / canvasSize.height,
    );
    final scale = 1 / max(ratio.width, ratio.height) * 0.9;
    final scaledImageSize = Size(
      imageSize.width * scale,
      imageSize.height * scale,
    );
    final offset = Offset(
      (canvasSize.width - scaledImageSize.width) / 2,
      (canvasSize.height - scaledImageSize.height) / 2,
    );

    return matrix =
        Matrix4.identity()
          ..translate(offset.dx, offset.dy, 0.0)
          ..scale(scale);
  }

  void scaleCanvas(Vector3 localPosition, double scale) {
    inverse.copyInverse(matrix);
    final position = inverse * localPosition;
    final mScale = 1 - scale;
    matrix = matrix * Matrix4(
      scale,
      0,
      0,
      0,
      0,
      scale,
      0,
      0,
      0,
      0,
      scale,
      0,
      mScale * position.x,
      mScale * position.y,
      0,
      1,
    );
    notifyZoomChanged(matrix.getMaxScaleOnAxis());
    _scheduleScaleUpdate();
  }

  void _scheduleScaleUpdate() {
    _scaleUpdateTimer?.cancel();
    _scaleUpdateTimer = Timer(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() => _lastPaintedScale = matrix.getMaxScaleOnAxis());
      }
    });
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (event.buttons == kMiddleMouseButton) {
      _lastMiddleButtonPosition = event.localPosition;
      return;
    }

    // Right-click to cancel polygon drawing
    if (event.buttons == kSecondaryButton &&
        widget.userAction == UserAction.polygon_annotation &&
        _polygonPoints.isNotEmpty) {
      setState(() {
        _polygonPoints = [];
        _currentPolygonPoint = null;
        _isPolygonComplete = false;
      });
      return;
    }

    if (event.buttons == kPrimaryButton &&
        widget.userAction == UserAction.navigation) {
      inverse.copyInverse(matrix);
      final transformed = MatrixUtils.transformPoint(
        inverse,
        event.localPosition,
      );
      final tapped = _findAnnotationAtPosition(transformed);
      if (tapped != null) {
        _draggingAnnotation = tapped;
        _dragStartPosition = transformed;
        widget.onAnnotationSelected?.call(tapped);
      }

      if (_draggingAnnotation != null) {
        final shape = Shape.fromAnnotation(_draggingAnnotation!);
        if (shape != null) {
          final corners = shape.getCorners();
          final handleRadius = Constants.handleRadius;
          for (int i = 0; i < corners.length; i++) {
            if ((transformed - corners[i]).distance <= handleRadius) {
              _activeResizeHandle = i;
              _originalCorners = corners;
              return;
            }
          }
        }
      }
    } else if (event.buttons == kPrimaryButton &&
        widget.userAction == UserAction.bbox_annotation) {
      inverse.copyInverse(matrix);
      final transformed = MatrixUtils.transformPoint(
        inverse,
        event.localPosition,
      );
      final clamped = _clampToImage(transformed);
      setState(() {
        _drawingStart = clamped;
        _drawingCurrent = clamped;
      });
    } else if (event.buttons == kPrimaryButton &&
        widget.userAction == UserAction.sam_annotation) {
      // In SAM mode: on click, emit the image-space coordinate to parent for processing
      inverse.copyInverse(matrix);
      final transformed = MatrixUtils.transformPoint(
        inverse,
        event.localPosition,
      );
      final clamped = _clampToImage(transformed);
      widget.onSamTap?.call(clamped);
      return;
    } else if (event.buttons == kPrimaryButton &&
        widget.userAction == UserAction.polygon_annotation) {
      inverse.copyInverse(matrix);
      final transformed = MatrixUtils.transformPoint(
        inverse,
        event.localPosition,
      );
      final clampedPoint = _clampToImage(transformed);

      // If we have at least 3 points and clicked near the first point, complete the polygon
      // Use a larger threshold to make it easier to close the polygon
      if (_polygonPoints.length >= 3) {
        final distanceToFirst = (_polygonPoints.first - clampedPoint).distance;
        final closeThreshold =
            25.0 / matrix.getMaxScaleOnAxis(); // Increased from 20 to 25

        if (distanceToFirst < closeThreshold) {
          // Use the exact position of the first point to ensure perfect closure
          setState(() {
            _isPolygonComplete = true;
          });
          _createPolygonAnnotation();
          return; // Exit early to prevent adding another point
        }
      }

      // Add the point to the polygon
      setState(() {
        _polygonPoints.add(clampedPoint);
        _currentPolygonPoint = clampedPoint;
      });
    }
  }

  void _createPolygonAnnotation() async {
    if (_polygonPoints.length < 3) return;

    if ((widget.selectedLabel.id ?? -1) <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a label before drawing')),
        );
      }
      _polygonPoints.clear();
      return;
    }

    List<Offset> finalPoints = List<Offset>.from(_polygonPoints);

    if ((finalPoints.last - finalPoints.first).distance > 0.1) {
      finalPoints.add(finalPoints.first);
    }

    final now = DateTime.now();
    var newAnnotation =
        Annotation(
            id: null,
            mediaItemId: widget.mediaItemId,
            labelId: widget.selectedLabel.id!,
            annotationType: 'polygon',
            data: {
              'points': finalPoints.map((p) => [p.dx, p.dy]).toList(),
            },
            createdAt: now,
            updatedAt: now,
          )
          ..name = widget.selectedLabel.name
          ..color = widget.selectedLabel.toColor();

    if (UserSession.instance.autoSaveAnnotations) {
      try {
        final insertedId = await _annotationRepository.insertAnnotation(
          newAnnotation,
        );
        newAnnotation = newAnnotation.copyWith()..name = newAnnotation.name..color = newAnnotation.color;
        newAnnotation = Annotation(
          id: insertedId,
          mediaItemId: newAnnotation.mediaItemId,
          labelId: newAnnotation.labelId,
          annotationType: newAnnotation.annotationType,
          data: newAnnotation.data,
          confidence: newAnnotation.confidence,
          annotatorId: newAnnotation.annotatorId,
          comment: newAnnotation.comment,
          status: newAnnotation.status,
          version: newAnnotation.version,
          createdAt: newAnnotation.createdAt,
          updatedAt: newAnnotation.updatedAt,
        )..name = newAnnotation.name..color = newAnnotation.color;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save polygon annotation: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _localAnnotations = List.of(_localAnnotations)..add(newAnnotation);
      widget.onAnnotationSelected?.call(newAnnotation);

      _polygonPoints = [];
      _currentPolygonPoint = null;
      _isPolygonComplete = false;
    });

    widget.onAnnotationUpdated?.call(newAnnotation);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    // Pan the canvas with the middle mouse button
    if (event.buttons == kMiddleMouseButton &&
        _lastMiddleButtonPosition != null) {
      final delta = event.localPosition - _lastMiddleButtonPosition!;
      _lastMiddleButtonPosition = event.localPosition;
      final zoom = matrix.getMaxScaleOnAxis();
      final m = matrix.clone();
      m.translate(delta.dx / zoom, delta.dy / zoom);
      matrix = m;
      return;
    }

    // Left mouse button drag: either resize or move the annotation
    if (event.buttons == kPrimaryButton &&
        widget.userAction == UserAction.navigation &&
        _draggingAnnotation != null &&
        _dragStartPosition != null) {
      inverse.copyInverse(matrix);
      final currentPosition = MatrixUtils.transformPoint(
        inverse,
        event.localPosition,
      );
      final delta = currentPosition - _dragStartPosition!;
      final shape = Shape.fromAnnotation(_draggingAnnotation!);
      final imageSize = Size(
        widget.image.width.toDouble(),
        widget.image.height.toDouble(),
      );

      if (shape != null) {
        Shape newShape;

        // === RESIZE ===
        if (_activeResizeHandle != null && _originalCorners != null) {
          newShape = shape.resize(
            handleIndex: _activeResizeHandle!,
            newPosition: currentPosition,
            originalCorners: _originalCorners!,
          );
        }
        // === MOVE ===
        else {
          newShape = shape.move(delta);
          _dragStartPosition = currentPosition;
        }

        // Clamp shape within image bounds
        final clampedShape = newShape.clampToBounds(imageSize);

        // Create updated annotation
        final updated = _draggingAnnotation!.copyWith(
          data: clampedShape.toJson(),
          updatedAt: DateTime.now(),
        );

        final index = _localAnnotations.indexWhere((a) => a.id == updated.id);
        if (index != -1) {
          setState(() {
            _localAnnotations = List<Annotation>.from(_localAnnotations)
              ..[index] = updated;
          });
        }

        _draggingAnnotation = updated;

        widget.onAnnotationUpdated?.call(updated);
        widget.onAnnotationSelected?.call(updated);
      }
    }

    if (event.buttons == kPrimaryButton &&
        widget.userAction == UserAction.bbox_annotation &&
        _drawingStart != null) {
      inverse.copyInverse(matrix);
      final current = MatrixUtils.transformPoint(inverse, event.localPosition);
      final clamped = _clampToImage(current);
      setState(() {
        _drawingCurrent = clamped;
      });
    }

    // Update current point for polygon annotation
    if (widget.userAction == UserAction.polygon_annotation &&
        !_isPolygonComplete) {
      inverse.copyInverse(matrix);
      final current = MatrixUtils.transformPoint(inverse, event.localPosition);
      final clamped = _clampToImage(current);

      // Only update if the point has moved significantly to reduce unnecessary repaints
      if (_currentPolygonPoint == null ||
          (_currentPolygonPoint! - clamped).distance > 1.0) {
        // Check if we're near the first point for closing the polygon
        bool nearFirstPoint = false;
        if (_polygonPoints.length >= 3) {
          final distanceToFirst = (_polygonPoints.first - clamped).distance;
          final closeThreshold = 20.0 / matrix.getMaxScaleOnAxis();
          nearFirstPoint = distanceToFirst < closeThreshold;
        }

        // Use markNeedsPaint instead of setState for more efficient updates
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _currentPolygonPoint = clamped;
            });
          }
        });
      }
    }
  }

  void _handlePointerUp(PointerUpEvent event) async {
    if (event.buttons == kMiddleMouseButton) {
      _lastMiddleButtonPosition = null;
    }

    if (event.kind == PointerDeviceKind.mouse && event.buttons == 0) {
      final shouldSave = UserSession.instance.autoSaveAnnotations;

      if (_draggingAnnotation != null && shouldSave) {
        final updatedRows = await _annotationRepository.updateAnnotation(
          _draggingAnnotation!,
        );
        if (updatedRows > 0) {
          final persisted = _draggingAnnotation!.copyWith(
            version: _draggingAnnotation!.version + 1,
          );
          final index = _localAnnotations.indexWhere(
            (a) => a.id == persisted.id,
          );
          if (index != -1) {
            setState(() {
              _localAnnotations = List<Annotation>.from(_localAnnotations)
                ..[index] = persisted;
            });
          }
          widget.onAnnotationUpdated?.call(persisted);
          widget.onAnnotationSelected?.call(persisted);
          _draggingAnnotation = persisted;
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Annotation update conflict. Reload item and retry.',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      _draggingAnnotation = null;
      _dragStartPosition = null;
      _activeResizeHandle = null;
      _originalCorners = null;
    }

    if (widget.userAction == UserAction.bbox_annotation &&
        _drawingStart != null &&
        _drawingCurrent != null) {
      final rect = Rect.fromPoints(_drawingStart!, _drawingCurrent!);

      if (rect.width > 4 && rect.height > 4) {
        if ((widget.selectedLabel.id ?? -1) <= 0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select a label before drawing')),
            );
          }
          _drawingStart = null;
          _drawingCurrent = null;
          return;
        }
        final now = DateTime.now();
        var newAnnotation =
            Annotation(
                id: null,
                mediaItemId: widget.mediaItemId,
                labelId: widget.selectedLabel.id!,
                annotationType: 'bbox',
                data: {
                  'x': rect.left,
                  'y': rect.top,
                  'width': rect.width,
                  'height': rect.height,
                },
                createdAt: now,
                updatedAt: now,
              )
              ..name = widget.selectedLabel.name
              ..color = widget.selectedLabel.toColor();

        if (UserSession.instance.autoSaveAnnotations) {
          try {
            final insertedId = await _annotationRepository.insertAnnotation(
              newAnnotation,
            );
            newAnnotation = Annotation(
              id: insertedId,
              mediaItemId: newAnnotation.mediaItemId,
              labelId: newAnnotation.labelId,
              annotationType: newAnnotation.annotationType,
              data: newAnnotation.data,
              confidence: newAnnotation.confidence,
              annotatorId: newAnnotation.annotatorId,
              comment: newAnnotation.comment,
              status: newAnnotation.status,
              version: newAnnotation.version,
              createdAt: newAnnotation.createdAt,
              updatedAt: newAnnotation.updatedAt,
            )..name = newAnnotation.name..color = newAnnotation.color;
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to save bbox annotation: $e'),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        }

        setState(() {
          _localAnnotations = List.of(_localAnnotations)..add(newAnnotation);
          widget.onAnnotationSelected?.call(newAnnotation);
        });

        widget.onAnnotationUpdated?.call(newAnnotation);
      }

      _drawingStart = null;
      _drawingCurrent = null;
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.userAction == UserAction.navigation) {
      inverse.copyInverse(matrix);
      final transformed = MatrixUtils.transformPoint(
        inverse,
        details.localPosition,
      );
      final tapped = _findAnnotationAtPosition(transformed);
      widget.onAnnotationSelected?.call(tapped);
    }
  }

  void _handleSecondaryTapDown(TapDownDetails details) async {
    // Only allow context menu in navigation mode
    if (widget.userAction != UserAction.navigation) return;

    // Determine which annotation (if any) was right-clicked
    inverse.copyInverse(matrix);
    final transformed = MatrixUtils.transformPoint(
      inverse,
      details.localPosition,
    );
    final tapped = _findAnnotationAtPosition(transformed);

    // Show context menu only if right-clicked on the currently selected annotation
    if (tapped == null) return;
    final selectedId = widget.selectedAnnotation?.id;
    if (selectedId == null || tapped.id != selectedId) return;

    final global = details.globalPosition;
    final selectedAction = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        global.dx,
        global.dy,
        global.dx,
        global.dy,
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      color: AppColors.darkCard,
      items: [
        PopupMenuItem<String>(
          value: 'change',
          child: Row(
            children: const [
              Icon(Icons.label_outline, size: 18, color: Colors.white70),
              SizedBox(width: 8),
              Text('Change label', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.delete_outline, size: 18, color: Colors.white70),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );

    if (!mounted || selectedAction == null) return;

    if (selectedAction == 'delete') {
      // Delegate deletion to page-level handler if provided
      if (widget.onAnnotationDelete != null) {
        widget.onAnnotationDelete!(tapped);
      }
      return;
    }

    if (selectedAction == 'change') {
      // Show a second-level menu with labels
      final chosenLabel = await showMenu<Label>(
        context: context,
        position: RelativeRect.fromLTRB(
          global.dx,
          global.dy,
          global.dx,
          global.dy,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        color: AppColors.darkCard,
        items:
            widget.labels
                .map(
                  (label) => PopupMenuItem<Label>(
                    value: label,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: label.toColor(),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        Text(
                          label.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
      );

      if (!mounted || chosenLabel == null) return;

      // Delegate label change to page-level handler if provided
      if (widget.onAnnotationLabelChanged != null) {
        widget.onAnnotationLabelChanged!(tapped, chosenLabel);
      } else if (widget.onAnnotationUpdated != null) {
        // Fallback: update locally and notify updated
        final updated = tapped.copyWith(
          labelId: chosenLabel.id,
          name: chosenLabel.name,
          color: chosenLabel.toColor(),
          updatedAt: DateTime.now(),
        );
        widget.onAnnotationUpdated!(updated);
      }
    }
  }

  Annotation? _findAnnotationAtPosition(Offset position) {
    final annotations = widget.annotations?.reversed ?? [];
    for (final annotation in annotations) {
      final shape = Shape.fromAnnotation(annotation);
      if (shape != null &&
          shape.boundingBox.contains(position) &&
          shape.containsPoint(position)) {
        return annotation;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _zoomNotifyTimer?.cancel();
    _scaleUpdateTimer?.cancel();
    _transformNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (f) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          matrix = setTransformToFit(widget.image);
          setState(() => _lastPaintedScale = matrix.getMaxScaleOnAxis());
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
                  scaleCanvas(
                    Vector3(p.localPosition.dx, p.localPosition.dy, 0),
                    scale,
                  );
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: _handleTapDown,
                onSecondaryTapDown: _handleSecondaryTapDown,
                onScaleStart: (_) => prevScale = 1,
                onDoubleTap: () {
                  if (widget.userAction != UserAction.bbox_annotation &&
                      widget.userAction != UserAction.sam_annotation &&
                      widget.userAction != UserAction.polygon_annotation) {
                    matrix = setTransformToFit(widget.image);
                    setState(() => _lastPaintedScale = matrix.getMaxScaleOnAxis());
                    notifyZoomChanged(matrix.getMaxScaleOnAxis());
                  }
                },
                onScaleUpdate: (d) {
                  final scale = 1 - (prevScale - d.scale);
                  prevScale = d.scale;
                  scaleCanvas(
                    Vector3(d.localFocalPoint.dx, d.localFocalPoint.dy, 0),
                    scale,
                  );
                },
                child: ValueListenableBuilder<Matrix4>(
                  valueListenable: _transformNotifier,
                  builder: (context, currentMatrix, child) {
                    return Transform(
                      transform: currentMatrix,
                      child: child,
                    );
                  },
                  child: RepaintBoundary(
                    child: CustomPaint(
                      isComplex: true,
                      willChange:
                          widget.userAction == UserAction.polygon_annotation,
                      painter: CanvasPainter(
                        image: widget.image,
                        annotations: _localAnnotations,
                        selectedAnnotation: widget.selectedAnnotation,
                        scale: _lastPaintedScale,
                        opacity: widget.opacity,
                        strokeWidth: widget.strokeWidth,
                        cornerSize: widget.cornerSize,
                        showAnnotationNames: widget.showAnnotationNames,
                        showClassifications: true,
                        samPendingPoint: widget.samPendingPoint,
                        drawingRect:
                            (_drawingStart != null && _drawingCurrent != null)
                                ? Rect.fromPoints(
                                  _drawingStart!,
                                  _drawingCurrent!,
                                )
                                : null,
                        drawingRectColor:
                            (_drawingStart != null)
                                ? (widget.selectedLabel.toColor() ??
                                    Colors.grey)
                                : Colors.grey,
                        polygonPoints:
                            widget.userAction == UserAction.polygon_annotation
                                ? _polygonPoints
                                : null,
                        currentPolygonPoint:
                            widget.userAction == UserAction.polygon_annotation
                                ? _currentPolygonPoint
                                : null,
                        polygonColor:
                            widget.selectedLabel.toColor() ?? Colors.red,
                      ),
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
