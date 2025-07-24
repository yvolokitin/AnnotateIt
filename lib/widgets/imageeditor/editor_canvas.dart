import 'dart:math';
import 'dart:ui' as ui;

import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../session/user_session.dart';
import '../../data/annotation_database.dart';

import 'editor_painter.dart';
import 'editor_action.dart';
import 'adjustment_panel.dart';

class EditorCanvas extends StatefulWidget {
  final ui.Image image;
  final int mediaItemId;

  final EditorAction editorAction;
  final int resetZoomCount;

  final ValueChanged<double>? onZoomChanged;
  final ValueChanged<bool>? onModifiedChanged;

  const EditorCanvas({
    required this.image,
    required this.mediaItemId,
    required this.resetZoomCount,
    required this.editorAction,
    this.onZoomChanged,
    this.onModifiedChanged,
    super.key,
  });
  
  // Static method to access the state's getCroppedImage method
  static Future<ui.Image?> getCroppedImage() async {
    if (_editorCanvasKey.currentState == null) return null;
    
    // Use dynamic to avoid type casting issues
    final state = _editorCanvasKey.currentState;
    // Use reflection to call the method
    try {
      // This is a workaround to access the private method
      return await (state as dynamic).getCroppedImage();
    } catch (e) {
      print('Error getting cropped image: $e');
      return null;
    }
  }
  
  // Global key to access the state
  static final GlobalKey<State<EditorCanvas>> _editorCanvasKey = GlobalKey<State<EditorCanvas>>();
  
  // Getter for the key
  static GlobalKey<State<EditorCanvas>> get editorCanvasKey => _editorCanvasKey;

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  int _lastResetCount = 0;
  double prevScale = 1;

  Matrix4 matrix = Matrix4.identity()..scale(0.9);
  Matrix4 inverse = Matrix4.identity();

  // Resize handle indices: 0=top-left, 1=top-right, 2=bottom-right, 3=bottom-left
  int? _activeResizeHandle;
  Offset? _dragStartPosition;
  Rect? _originalCropRect;
  
  // Image modification state
  bool _isModified = false;
  ui.Image? _modifiedImage;
  Rect? _cropRect;
  double _brightness = 0.0;
  double _contrast = 1.0;
  bool _flipHorizontal = false;
  bool _flipVertical = false;
  int _rotationAngle = 0; // in degrees, multiple of 90
  
  // Adjustment panel state
  bool _showAdjustmentPanel = false;
  bool _isBrightnessMode = true; // true for brightness, false for contrast
  
  // Method to get the cropped image
  Future<ui.Image?> getCroppedImage() async {
    if (_cropRect == null || !_isModified) return null;
    
    // Get the image rect in local coordinates
    final imageRect = _getImageRect();
    
    // Calculate the crop rect relative to the original image
    final scale = matrix.getMaxScaleOnAxis();
    final offset = matrix.getTranslation();
    
    // Convert crop rect from screen coordinates to image coordinates
    final relativeLeft = (_cropRect!.left - offset.x) / scale;
    final relativeTop = (_cropRect!.top - offset.y) / scale;
    final relativeWidth = _cropRect!.width / scale;
    final relativeHeight = _cropRect!.height / scale;
    
    // Create a rect in the original image's coordinate space
    final cropRectInImage = Rect.fromLTWH(
      relativeLeft,
      relativeTop,
      relativeWidth,
      relativeHeight
    );
    
    // Create a picture recorder
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Draw only the cropped portion of the image
    canvas.drawImageRect(
      widget.image,
      cropRectInImage,
      Rect.fromLTWH(0, 0, relativeWidth, relativeHeight),
      Paint()
    );
    
    // Apply other modifications (brightness, contrast, flip, rotation) if needed
    // Note: For simplicity, we're only implementing cropping for now
    
    // Convert to an image
    final picture = recorder.endRecording();
    return picture.toImage(relativeWidth.round(), relativeHeight.round());
  }
  
  // Helper method to set modified state and notify parent
  void _setModified(bool modified) {
    if (_isModified != modified) {
      setState(() {
        _isModified = modified;
      });
      widget.onModifiedChanged?.call(modified);
    }
  }

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
  void didUpdateWidget(covariant EditorCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.resetZoomCount != _lastResetCount) {
      _lastResetCount = widget.resetZoomCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          matrix = setTransformToFit(widget.image);
        });
        widget.onZoomChanged?.call(matrix.getMaxScaleOnAxis());
      });
    }
    
    // Initialize crop rect when crop action is selected
    if (oldWidget.editorAction != widget.editorAction && 
        widget.editorAction == EditorAction.crop && 
        _cropRect == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          // Initialize crop rect to the entire image
          _cropRect = _getImageRect();
          _setModified(true);
        });
      });
    }
  }

  void notifyZoomChanged(double zoom) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onZoomChanged?.call(zoom);
    });
  }

  Matrix4 setTransformToFit(ui.Image imageParam) {
    if (context.size == null) return Matrix4.identity();

    final imageSize = Size(imageParam.width.toDouble(), imageParam.height.toDouble());
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
      matrix *= Matrix4(
        scale, 0, 0, 0,
        0, scale, 0, 0,
        0, 0, scale, 0,
        mScale * position.x, mScale * position.y, 0, 1);
    });
    notifyZoomChanged(matrix.getMaxScaleOnAxis());
  }

  // Helper method to check if a point is near a corner or edge of the crop rect
  // Returns:
  // 0-3: corners (top-left, top-right, bottom-right, bottom-left)
  // 4: inside the rect (for moving)
  // 5-8: edges (top, right, bottom, left)
  // null: not near any handle
  int? _getResizeHandleAtPosition(Offset position) {
    if (_cropRect == null) return null;
    
    final handleSize = 20.0; // Larger hit area than visual size
    final edgeThreshold = 10.0; // Distance from edge to detect edge drag
    
    // Check each corner: 0=top-left, 1=top-right, 2=bottom-right, 3=bottom-left
    final corners = [
      _cropRect!.topLeft,
      _cropRect!.topRight,
      _cropRect!.bottomRight,
      _cropRect!.bottomLeft,
    ];
    
    for (int i = 0; i < corners.length; i++) {
      if ((corners[i] - position).distance < handleSize) {
        return i;
      }
    }
    
    // Check edges: 5=top, 6=right, 7=bottom, 8=left
    // Top edge
    if (position.dy >= _cropRect!.top - edgeThreshold && 
        position.dy <= _cropRect!.top + edgeThreshold &&
        position.dx >= _cropRect!.left + handleSize &&
        position.dx <= _cropRect!.right - handleSize) {
      return 5;
    }
    
    // Right edge
    if (position.dx >= _cropRect!.right - edgeThreshold && 
        position.dx <= _cropRect!.right + edgeThreshold &&
        position.dy >= _cropRect!.top + handleSize &&
        position.dy <= _cropRect!.bottom - handleSize) {
      return 6;
    }
    
    // Bottom edge
    if (position.dy >= _cropRect!.bottom - edgeThreshold && 
        position.dy <= _cropRect!.bottom + edgeThreshold &&
        position.dx >= _cropRect!.left + handleSize &&
        position.dx <= _cropRect!.right - handleSize) {
      return 7;
    }
    
    // Left edge
    if (position.dx >= _cropRect!.left - edgeThreshold && 
        position.dx <= _cropRect!.left + edgeThreshold &&
        position.dy >= _cropRect!.top + handleSize &&
        position.dy <= _cropRect!.bottom - handleSize) {
      return 8;
    }
    
    // Check if inside the crop rect (for moving)
    if (_cropRect!.contains(position)) {
      return 4; // Special value for moving the entire rect
    }
    
    return null;
  }
  
  void _handlePointerDown(PointerDownEvent event) {
    if (widget.editorAction == EditorAction.navigation) {
      // Navigation mode - do nothing special
      return;
    }
    
    if (widget.editorAction == EditorAction.crop) {
      // Check if we're clicking on a resize handle
      final handleIndex = _getResizeHandleAtPosition(event.localPosition);
      
      if (handleIndex != null) {
        // Store the active handle and starting position
        setState(() {
          _activeResizeHandle = handleIndex;
          _dragStartPosition = event.localPosition;
          _originalCropRect = _cropRect;
        });
      } else {
        // Start a new crop operation if not on a handle
        final imageRect = _getImageRect();
        if (imageRect.contains(event.localPosition)) {
          setState(() {
            _cropRect = Rect.fromPoints(event.localPosition, event.localPosition);
            _activeResizeHandle = 2; // Bottom-right corner
            _dragStartPosition = event.localPosition;
          });
        }
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (widget.editorAction == EditorAction.navigation) {
      // Navigation mode - do nothing special
      return;
    }
    
    if (widget.editorAction == EditorAction.crop && _cropRect != null && _activeResizeHandle != null) {
      final imageRect = _getImageRect();
      
      // Constrain the position to the image bounds
      final constrainedPosition = Offset(
        event.localPosition.dx.clamp(imageRect.left, imageRect.right),
        event.localPosition.dy.clamp(imageRect.top, imageRect.bottom)
      );
      
      setState(() {
        if (_activeResizeHandle == 4) {
          // Moving the entire crop rect
          if (_dragStartPosition != null && _originalCropRect != null) {
            final delta = constrainedPosition - _dragStartPosition!;
            
            // Calculate new rect position, ensuring it stays within image bounds
            final newLeft = (_originalCropRect!.left + delta.dx).clamp(imageRect.left, imageRect.right - _originalCropRect!.width);
            final newTop = (_originalCropRect!.top + delta.dy).clamp(imageRect.top, imageRect.bottom - _originalCropRect!.height);
            
            _cropRect = Rect.fromLTWH(
              newLeft,
              newTop,
              _originalCropRect!.width,
              _originalCropRect!.height
            );
          }
        } else {
          // Resizing the crop rect
          Offset topLeft = _cropRect!.topLeft;
          Offset bottomRight = _cropRect!.bottomRight;
          
          switch (_activeResizeHandle) {
            case 0: // Top-left
              topLeft = constrainedPosition;
              break;
            case 1: // Top-right
              topLeft = Offset(topLeft.dx, constrainedPosition.dy);
              bottomRight = Offset(constrainedPosition.dx, bottomRight.dy);
              break;
            case 2: // Bottom-right
              bottomRight = constrainedPosition;
              break;
            case 3: // Bottom-left
              topLeft = Offset(constrainedPosition.dx, topLeft.dy);
              bottomRight = Offset(bottomRight.dx, constrainedPosition.dy);
              break;
            case 5: // Top edge
              topLeft = Offset(topLeft.dx, constrainedPosition.dy);
              break;
            case 6: // Right edge
              bottomRight = Offset(constrainedPosition.dx, bottomRight.dy);
              break;
            case 7: // Bottom edge
              bottomRight = Offset(bottomRight.dx, constrainedPosition.dy);
              break;
            case 8: // Left edge
              topLeft = Offset(constrainedPosition.dx, topLeft.dy);
              break;
          }
          
          // Ensure minimum size and correct orientation
          if (bottomRight.dx - topLeft.dx < 20) {
            if (_activeResizeHandle == 0 || _activeResizeHandle == 3 || _activeResizeHandle == 8) {
              // Left side is being dragged
              topLeft = Offset(bottomRight.dx - 20, topLeft.dy);
            } else if (_activeResizeHandle == 1 || _activeResizeHandle == 2 || _activeResizeHandle == 6) {
              // Right side is being dragged
              bottomRight = Offset(topLeft.dx + 20, bottomRight.dy);
            }
          }
          
          if (bottomRight.dy - topLeft.dy < 20) {
            if (_activeResizeHandle == 0 || _activeResizeHandle == 1 || _activeResizeHandle == 5) {
              // Top side is being dragged
              topLeft = Offset(topLeft.dx, bottomRight.dy - 20);
            } else if (_activeResizeHandle == 2 || _activeResizeHandle == 3 || _activeResizeHandle == 7) {
              // Bottom side is being dragged
              bottomRight = Offset(bottomRight.dx, topLeft.dy + 20);
            }
          }
          
          _cropRect = Rect.fromPoints(topLeft, bottomRight);
        }
        
        _setModified(true);
      });
    }
  }


  void _handlePointerUp(PointerUpEvent event) {
    if (widget.editorAction == EditorAction.navigation) {
      // Navigation mode - do nothing special
      return;
    }
    
    if (widget.editorAction == EditorAction.crop && _cropRect != null) {
      // Finalize crop rectangle
      final imageRect = _getImageRect();
      final normalizedCropRect = _normalizeCropRect(_cropRect!, imageRect);
      
      if (normalizedCropRect.width > 20 && normalizedCropRect.height > 20) {
        setState(() {
          _cropRect = normalizedCropRect;
          _activeResizeHandle = null;
          _dragStartPosition = null;
          _originalCropRect = null;
        });
        _setModified(true);
      } else {
        // Crop area too small, cancel crop
        setState(() {
          _cropRect = null;
          _activeResizeHandle = null;
          _dragStartPosition = null;
          _originalCropRect = null;
        });
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.editorAction == EditorAction.navigation) {
      // Navigation mode - do nothing special
      return;
    }
    
    // Handle one-tap actions
    if (widget.editorAction == EditorAction.rotate_left) {
      _rotateLeft();
    } else if (widget.editorAction == EditorAction.rotate_right) {
      _rotateRight();
    } else if (widget.editorAction == EditorAction.flip_horizontal) {
      _flipHorizontally();
    } else if (widget.editorAction == EditorAction.flip_vertical) {
      _flipVertically();
    } else if (widget.editorAction == EditorAction.brightness) {
      setState(() {
        _showAdjustmentPanel = true;
        _isBrightnessMode = true;
      });
    } else if (widget.editorAction == EditorAction.contrast) {
      setState(() {
        _showAdjustmentPanel = true;
        _isBrightnessMode = false;
      });
    }
  }
  
  // Handle applying brightness/contrast adjustments
  void _handleApplyAdjustment(double brightness, double contrast) {
    setState(() {
      _brightness = brightness;
      _contrast = contrast;
      _showAdjustmentPanel = false;
      _setModified(true);
    });
  }
  
  // Handle canceling brightness/contrast adjustments
  void _handleCancelAdjustment() {
    setState(() {
      _showAdjustmentPanel = false;
    });
  }
  
  // Helper methods for image modifications
  void _rotateLeft() {
    setState(() {
      _rotationAngle = (_rotationAngle - 90) % 360;
    });
    _setModified(true);
  }
  
  void _rotateRight() {
    setState(() {
      _rotationAngle = (_rotationAngle + 90) % 360;
    });
    _setModified(true);
  }
  
  void _flipHorizontally() {
    setState(() {
      _flipHorizontal = !_flipHorizontal;
    });
    _setModified(true);
  }
  
  void _flipVertically() {
    setState(() {
      _flipVertical = !_flipVertical;
    });
    _setModified(true);
  }
  
  // Helper method to get the current image rectangle in local coordinates
  Rect _getImageRect() {
    final imageSize = Size(widget.image.width.toDouble(), widget.image.height.toDouble());
    final canvasSize = context.size!;
    
    // Calculate the scaled image size
    final scale = matrix.getMaxScaleOnAxis();
    final scaledWidth = imageSize.width * scale;
    final scaledHeight = imageSize.height * scale;
    
    // Calculate the position of the image
    final offset = matrix.getTranslation();
    final x = offset.x;
    final y = offset.y;
    
    return Rect.fromLTWH(x, y, scaledWidth, scaledHeight);
  }
  
  // Helper method to normalize crop rectangle to image bounds
  Rect _normalizeCropRect(Rect rect, Rect imageRect) {
    final left = rect.left.clamp(imageRect.left, imageRect.right);
    final top = rect.top.clamp(imageRect.top, imageRect.bottom);
    final right = rect.right.clamp(imageRect.left, imageRect.right);
    final bottom = rect.bottom.clamp(imageRect.top, imageRect.bottom);
    
    return Rect.fromLTRB(left, top, right, bottom);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (f) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => matrix = setTransformToFit(widget.image));
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: Stack(
          children: [
            SizedBox.expand(
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
                    onScaleUpdate: (d) {
                      final scale = 1 - (prevScale - d.scale);
                      prevScale = d.scale;
                      scaleCanvas(Vector3(d.localFocalPoint.dx, d.localFocalPoint.dy, 0), scale);
                    },
                    child: RepaintBoundary(
                      child: Transform(
                        transform: matrix,
                        child: CustomPaint(
                          painter: EditorPainter(
                            image: widget.image,
                            scale: matrix.getMaxScaleOnAxis(),
                            cropRect: _cropRect,
                            brightness: _brightness,
                            contrast: _contrast,
                            flipHorizontal: _flipHorizontal,
                            flipVertical: _flipVertical,
                            rotationAngle: _rotationAngle,
                            isModified: _isModified,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Show adjustment panel when needed
            if (_showAdjustmentPanel)
              Positioned(
                top: 50,
                right: 50,
                child: AdjustmentPanel(
                  initialBrightness: _brightness,
                  initialContrast: _contrast,
                  isBrightnessMode: _isBrightnessMode,
                  onApply: _handleApplyAdjustment,
                  onCancel: _handleCancelAdjustment,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
