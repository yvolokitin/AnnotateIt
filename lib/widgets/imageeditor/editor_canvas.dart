import 'dart:math';
import 'dart:ui' as ui;

import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

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

  // Static method to get crop rect in original image coordinates
  static Rect? getCropRectInImageCoordinates() {
    try {
      final state = _editorCanvasKey.currentState;
      if (state == null) return null;
      return (state as dynamic).getCropRectInImageCoordinates();
    } catch (e) {
      print('Error getting crop rect: $e');
      return null;
    }
  }

  // Static methods to trigger rotation immediately from outside
  static void rotateLeft() {
    try {
      final state = _editorCanvasKey.currentState;
      if (state == null) return;
      (state as dynamic).rotateLeft();
    } catch (e) {
      print('Error rotating left: $e');
    }
  }

  static void rotateRight() {
    try {
      final state = _editorCanvasKey.currentState;
      if (state == null) return;
      (state as dynamic).rotateRight();
    } catch (e) {
      print('Error rotating right: $e');
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
  // Exposes the current crop rectangle in original image coordinates (null if not cropping or if rotation/flips applied)
  Rect? getCropRectInImageCoordinates() {
    if (_cropRect == null) return null;
    // Only support pure crop (no rotation/flips), same constraint as getCroppedImage
    if (_rotationAngle % 360 != 0 || _flipHorizontal || _flipVertical) return null;

    final scale = matrix.getMaxScaleOnAxis();
    final offset = matrix.getTranslation();

    final relativeLeft = (_cropRect!.left - offset.x) / scale;
    final relativeTop = (_cropRect!.top - offset.y) / scale;
    final relativeWidth = _cropRect!.width / scale;
    final relativeHeight = _cropRect!.height / scale;

    return Rect.fromLTWH(relativeLeft, relativeTop, relativeWidth, relativeHeight);
  }
  int _lastResetCount = 0;
  double prevScale = 1;

  Matrix4 matrix = Matrix4.identity()..scale(0.9);
  Matrix4 inverse = Matrix4.identity();

  // Resize handle indices: 0=top-left, 1=top-right, 2=bottom-right, 3=bottom-left
  int? _activeResizeHandle;
  Offset? _dragStartPosition;
  Rect? _originalCropRect;
  double? _aspectAtDragStart;
  
  // Hovered resize handle (for cursor/highlight)
  int? _hoverResizeHandle;
  
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

  // Keyboard modifiers for crop behavior
  final FocusNode _focusNode = FocusNode();
  bool _shiftPressed = false;
  bool _altPressed = false;

  static const double _minCropSize = 16.0; // px
  
  // Method to get the edited image (supports crop, rotation, flips, brightness/contrast)
  Future<ui.Image?> getCroppedImage() async {
    if (!_isModified) return null;

    final ui.Image sourceImage = _modifiedImage ?? widget.image;

    // Helper to build paint with color filter for brightness/contrast
    Paint _buildAdjustPaint() {
      final paint = Paint();
      if (_brightness != 0.0 || _contrast != 1.0) {
        final List<double> m = List<double>.filled(20, 0.0);
        // R
        m[0] = _contrast;
        m[4] = _brightness * 255.0;
        // G
        m[6] = _contrast;
        m[9] = _brightness * 255.0;
        // B
        m[12] = _contrast;
        m[14] = _brightness * 255.0;
        // A
        m[18] = 1.0;
        paint.colorFilter = ColorFilter.matrix(m);
      }
      return paint;
    }

    // Helper to render the full edited image (rotation, flips, brightness/contrast)
    Future<ui.Image> _renderFullEditedImage() async {
      final origW = sourceImage.width.toDouble();
      final origH = sourceImage.height.toDouble();
      final int rot = ((_rotationAngle % 360) + 360) % 360;
      final bool swap = rot % 180 != 0;
      final double finalW = swap ? origH : origW;
      final double finalH = swap ? origW : origH;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Apply rotation with appropriate translation to keep image in view
      if (rot == 90) {
        canvas.translate(finalW, 0);
        canvas.rotate(3.141592653589793 / 2);
      } else if (rot == 180) {
        canvas.translate(finalW, finalH);
        canvas.rotate(3.141592653589793);
      } else if (rot == 270) {
        canvas.translate(0, finalH);
        canvas.rotate(3 * 3.141592653589793 / 2);
      }

      // Apply flips relative to final orientation
      if (_flipHorizontal) {
        canvas.translate(finalW, 0);
        canvas.scale(-1, 1);
      }
      if (_flipVertical) {
        canvas.translate(0, finalH);
        canvas.scale(1, -1);
      }

      // Draw original image with adjustments
      final paint = _buildAdjustPaint();
      canvas.drawImage(sourceImage, Offset.zero, paint);

      final picture = recorder.endRecording();
      return picture.toImage(finalW.round(), finalH.round());
    }

    // If no crop rect, return full edited image (so Save works for non-crop edits)
    if (_cropRect == null) {
      return _renderFullEditedImage();
    }

    // If rotation or flips are active, fall back to saving full edited image (to avoid complex crop mapping)
    if (_rotationAngle % 360 != 0 || _flipHorizontal || _flipVertical) {
      return _renderFullEditedImage();
    }

    // Crop only (apply brightness/contrast to the cropped area)
    // Calculate the crop rect relative to the original image using the current view matrix
    final scale = matrix.getMaxScaleOnAxis();
    final offset = matrix.getTranslation();

    final relativeLeft = (_cropRect!.left - offset.x) / scale;
    final relativeTop = (_cropRect!.top - offset.y) / scale;
    final relativeWidth = _cropRect!.width / scale;
    final relativeHeight = _cropRect!.height / scale;

    final cropRectInImage = Rect.fromLTWH(
      relativeLeft,
      relativeTop,
      relativeWidth,
      relativeHeight,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw only the cropped portion with adjustments
    canvas.drawImageRect(
      sourceImage,
      cropRectInImage,
      Rect.fromLTWH(0, 0, relativeWidth, relativeHeight),
      _buildAdjustPaint(),
    );

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
          matrix = setTransformToFit(_modifiedImage ?? widget.image);
        });
        widget.onZoomChanged?.call(matrix.getMaxScaleOnAxis());
      });
    }
    
    // Initialize crop rect when crop action is selected
    if (oldWidget.editorAction != widget.editorAction && 
        widget.editorAction == EditorAction.crop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          // Initialize crop rect to the entire image
          _cropRect = _getImageRect();
          _activeResizeHandle = null;
          _dragStartPosition = null;
          _originalCropRect = null;
        });
        // ensure we can capture keyboard modifiers
        _focusNode.requestFocus();
      });
    }

    // Clear hover/active when leaving crop mode
    if (oldWidget.editorAction == EditorAction.crop &&
        widget.editorAction != EditorAction.crop) {
      setState(() {
        _hoverResizeHandle = null;
        _activeResizeHandle = null;
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
    
    // Do not allow moving the entire rect; only edges/corners are interactive
    return null;
  }
  
  bool _isEdgeHandle(int? h) => h == 5 || h == 6 || h == 7 || h == 8;
  
  MouseCursor _currentMouseCursor() {
    if (widget.editorAction != EditorAction.crop || _cropRect == null) {
      return SystemMouseCursors.basic;
    }
    final int? h = _activeResizeHandle ?? _hoverResizeHandle;
    if (h == 5 || h == 7) return SystemMouseCursors.resizeUpDown;
    if (h == 6 || h == 8) return SystemMouseCursors.resizeLeftRight;
    return SystemMouseCursors.basic;
  }
  
  int? _currentHighlightEdge() {
    final int? h = _activeResizeHandle ?? _hoverResizeHandle;
    return _isEdgeHandle(h) ? h : null;
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
          _aspectAtDragStart = _originalCropRect == null || _originalCropRect!.height == 0
              ? null
              : _originalCropRect!.width / _originalCropRect!.height;
        });
      } else {
        // Edge-based cropping: do not create a new inner rectangle or move the rect
        // Simply ignore clicks that are not on handles.
      }
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (widget.editorAction == EditorAction.navigation) {
      // Navigation mode - do nothing special
      return;
    }
    
    if (widget.editorAction == EditorAction.crop && _cropRect != null && _activeResizeHandle != null && _originalCropRect != null) {
      final imageRect = _getImageRect();
      
      // Constrain the position to the image bounds
      final constrainedPosition = Offset(
        event.localPosition.dx.clamp(imageRect.left, imageRect.right),
        event.localPosition.dy.clamp(imageRect.top, imageRect.bottom)
      );

      Rect newRect = _originalCropRect!;
      final orig = _originalCropRect!;

      // Helper to clamp rect within image and min size
      Rect _clampRect(Rect r) {
        double left = r.left.clamp(imageRect.left, imageRect.right);
        double top = r.top.clamp(imageRect.top, imageRect.bottom);
        double right = r.right.clamp(imageRect.left, imageRect.right);
        double bottom = r.bottom.clamp(imageRect.top, imageRect.bottom);
        // enforce min size
        if (right - left < _minCropSize) {
          final cx = (left + right) / 2;
          left = cx - _minCropSize / 2;
          right = cx + _minCropSize / 2;
        }
        if (bottom - top < _minCropSize) {
          final cy = (top + bottom) / 2;
          top = cy - _minCropSize / 2;
          bottom = cy + _minCropSize / 2;
        }
        // clamp again to imageRect after min size adjust
        left = left.clamp(imageRect.left, imageRect.right - _minCropSize);
        top = top.clamp(imageRect.top, imageRect.bottom - _minCropSize);
        right = right.clamp(imageRect.left + _minCropSize, imageRect.right);
        bottom = bottom.clamp(imageRect.top + _minCropSize, imageRect.bottom);
        return Rect.fromLTRB(left, top, right, bottom);
      }

      double left = orig.left;
      double top = orig.top;
      double right = orig.right;
      double bottom = orig.bottom;

      switch (_activeResizeHandle) {
        case 0: // Top-left corner
          left = constrainedPosition.dx;
          top = constrainedPosition.dy;
          if (_altPressed) {
            final dx = left - orig.left;
            final dy = top - orig.top;
            right = orig.right - dx;
            bottom = orig.bottom - dy;
          }
          if (_shiftPressed && _aspectAtDragStart != null) {
            final aspect = _aspectAtDragStart!;
            // anchor bottom-right
            final width = right - left;
            final height = width / aspect;
            top = bottom - height;
          }
          break;
        case 1: // Top-right corner
          right = constrainedPosition.dx;
          top = constrainedPosition.dy;
          if (_altPressed) {
            final dx = right - orig.right;
            final dy = top - orig.top;
            left = orig.left - dx;
            bottom = orig.bottom - dy;
          }
          if (_shiftPressed && _aspectAtDragStart != null) {
            final aspect = _aspectAtDragStart!;
            final width = right - left;
            final height = width / aspect;
            top = bottom - height;
          }
          break;
        case 2: // Bottom-right corner
          right = constrainedPosition.dx;
          bottom = constrainedPosition.dy;
          if (_altPressed) {
            final dx = right - orig.right;
            final dy = bottom - orig.bottom;
            left = orig.left - dx;
            top = orig.top - dy;
          }
          if (_shiftPressed && _aspectAtDragStart != null) {
            final aspect = _aspectAtDragStart!;
            final width = right - left;
            final height = width / aspect;
            bottom = top + height;
          }
          break;
        case 3: // Bottom-left corner
          left = constrainedPosition.dx;
          bottom = constrainedPosition.dy;
          if (_altPressed) {
            final dx = left - orig.left;
            final dy = bottom - orig.bottom;
            right = orig.right - dx;
            top = orig.top - dy;
          }
          if (_shiftPressed && _aspectAtDragStart != null) {
            final aspect = _aspectAtDragStart!;
            final width = right - left;
            final height = width / aspect;
            bottom = top + height;
          }
          break;
        case 5: // Top edge
          top = constrainedPosition.dy;
          if (_altPressed) {
            final dy = top - orig.top;
            bottom = orig.bottom - dy;
          }
          break;
        case 6: // Right edge
          right = constrainedPosition.dx;
          if (_altPressed) {
            final dx = right - orig.right;
            left = orig.left - dx;
          }
          break;
        case 7: // Bottom edge
          bottom = constrainedPosition.dy;
          if (_altPressed) {
            final dy = bottom - orig.bottom;
            top = orig.top - dy;
          }
          break;
        case 8: // Left edge
          left = constrainedPosition.dx;
          if (_altPressed) {
            final dx = left - orig.left;
            right = orig.right - dx;
          }
          break;
      }

      newRect = Rect.fromLTRB(left, top, right, bottom);
      newRect = _clampRect(newRect);

      setState(() {
        _cropRect = newRect;
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
      // Finalize crop rectangle and release handle
      final imageRect = _getImageRect();
      final normalizedCropRect = _normalizeCropRect(_cropRect!, imageRect);
      
      setState(() {
        _cropRect = normalizedCropRect;
        _activeResizeHandle = null;
        _dragStartPosition = null;
        _originalCropRect = null;
      });
      _setModified(true);
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

  // Public methods to allow external triggers via the static wrapper
  void rotateLeft() => _rotateLeft();
  void rotateRight() => _rotateRight();
  
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
    final ui.Image img = _modifiedImage ?? widget.image;
    final imageSize = Size(img.width.toDouble(), img.height.toDouble());
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

  Rect? _cropRectInImageSpace() {
    if (_cropRect == null) return null;
    final scale = matrix.getMaxScaleOnAxis();
    final offset = matrix.getTranslation();
    final left = (_cropRect!.left - offset.x) / scale;
    final top = (_cropRect!.top - offset.y) / scale;
    final width = _cropRect!.width / scale;
    final height = _cropRect!.height / scale;
    return Rect.fromLTWH(left, top, width, height);
  }

  Future<void> _applyCrop() async {
    if (_cropRect == null) return;
    final Rect? cropInImg = _cropRectInImageSpace();
    if (cropInImg == null) return;
    final ui.Image src = _modifiedImage ?? widget.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImageRect(
      src,
      Rect.fromLTWH(
        cropInImg.left.clamp(0, src.width.toDouble()),
        cropInImg.top.clamp(0, src.height.toDouble()),
        cropInImg.width.clamp(1, src.width.toDouble()),
        cropInImg.height.clamp(1, src.height.toDouble()),
      ),
      Rect.fromLTWH(0, 0, cropInImg.width, cropInImg.height),
      Paint(),
    );
    final picture = recorder.endRecording();
    final ui.Image newImg = await picture.toImage(cropInImg.width.round(), cropInImg.height.round());

    if (!mounted) return;
    setState(() {
      _modifiedImage = newImg;
      matrix = setTransformToFit(newImg);
      _cropRect = _getImageRect(); // reset to full image after trim
      _setModified(true);
    });
  }

  void _cancelCrop() {
    setState(() {
      _cropRect = _getImageRect();
      _activeResizeHandle = null;
      _hoverResizeHandle = null;
      _dragStartPosition = null;
      _originalCropRect = null;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
      child: RawKeyboardListener(
        focusNode: _focusNode,
        onKey: (RawKeyEvent e) {
          final keys = RawKeyboard.instance.keysPressed;
          final shift = keys.contains(LogicalKeyboardKey.shiftLeft) || keys.contains(LogicalKeyboardKey.shiftRight);
          final alt = keys.contains(LogicalKeyboardKey.altLeft) || keys.contains(LogicalKeyboardKey.altRight);
          setState(() {
            _shiftPressed = shift;
            _altPressed = alt;
          });
        },
        child: SizeChangedLayoutNotifier(
          child: Stack(
          children: <Widget>[
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
                  child: MouseRegion(
                    cursor: _currentMouseCursor(),
                    onHover: (event) {
                      if (widget.editorAction == EditorAction.crop && _cropRect != null && _activeResizeHandle == null) {
                        final h = _getResizeHandleAtPosition(event.localPosition);
                        final edge = _isEdgeHandle(h) ? h : null;
                        if (edge != _hoverResizeHandle) {
                          setState(() => _hoverResizeHandle = edge);
                        }
                      }
                    },
                    onExit: (_) {
                      if (_hoverResizeHandle != null) {
                        setState(() => _hoverResizeHandle = null);
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
                            image: _modifiedImage ?? widget.image,
                            scale: matrix.getMaxScaleOnAxis(),
                            cropRect: widget.editorAction == EditorAction.crop ? _cropRectInImageSpace() : null,
                            brightness: _brightness,
                            contrast: _contrast,
                            flipHorizontal: _flipHorizontal,
                            flipVertical: _flipVertical,
                            rotationAngle: _rotationAngle,
                            isModified: _isModified,
                            highlightEdge: widget.editorAction == EditorAction.crop ? _currentHighlightEdge() : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
            
            // Crop numeric overlay and actions
            if (widget.editorAction == EditorAction.crop && _cropRect != null)
              Positioned(
                top: 12,
                right: 12,
                child: _CropOverlay(
                  cropRectInImage: _cropRectInImageSpace(),
                  onApply: _applyCrop,
                  onCancel: _cancelCrop,
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
    ),
  );
  }
}


class _CropOverlay extends StatelessWidget {
  final Rect? cropRectInImage;
  final Future<void> Function()? onApply;
  final VoidCallback? onCancel;

  const _CropOverlay({
    Key? key,
    required this.cropRectInImage,
    this.onApply,
    this.onCancel,
  }) : super(key: key);

  String _fmt(double v) => v.isFinite ? v.toStringAsFixed(0) : '0';

  @override
  Widget build(BuildContext context) {
    final r = cropRectInImage;
    final x = r?.left ?? 0;
    final y = r?.top ?? 0;
    final w = r?.width ?? 0;
    final h = r?.height ?? 0;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Stat(label: 'x', value: _fmt(x)),
                const SizedBox(width: 8),
                _Stat(label: 'y', value: _fmt(y)),
                const SizedBox(width: 12),
                _Stat(label: 'w', value: _fmt(w)),
                const SizedBox(width: 8),
                _Stat(label: 'h', value: _fmt(h)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 18),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  onPressed: onApply,
                  label: const Text('Apply'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.close, size: 18),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  onPressed: onCancel,
                  label: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
