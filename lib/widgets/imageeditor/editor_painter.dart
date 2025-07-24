import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';

class EditorPainter extends CustomPainter {
  final ui.Image image;
  final double scale;
  
  // Image modification parameters
  final Rect? cropRect;
  final double brightness;
  final double contrast;
  final bool flipHorizontal;
  final bool flipVertical;
  final int rotationAngle;
  final bool isModified;

  EditorPainter({
    required this.image,
    required this.scale,
    this.cropRect,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.rotationAngle = 0,
    this.isModified = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Save the canvas state before applying transformations
    canvas.save();
    
    // Get the image dimensions
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();
    
    // Calculate the center of the image
    final centerX = imageWidth / 2;
    final centerY = imageHeight / 2;
    
    // Apply rotation if needed
    if (rotationAngle != 0) {
      // Translate to the center of the image
      canvas.translate(centerX, centerY);
      // Rotate around the center
      canvas.rotate(rotationAngle * (pi / 180));
      // Translate back
      canvas.translate(-centerX, -centerY);
    }
    
    // Apply flips if needed
    if (flipHorizontal || flipVertical) {
      final scaleX = flipHorizontal ? -1.0 : 1.0;
      final scaleY = flipVertical ? -1.0 : 1.0;
      
      // Translate to the center of the image
      canvas.translate(centerX, centerY);
      // Apply scaling (flipping)
      canvas.scale(scaleX, scaleY);
      // Translate back
      canvas.translate(-centerX, -centerY);
    }
    
    // Create a paint object for brightness and contrast
    final paint = Paint();
    if (brightness != 0.0 || contrast != 1.0) {
      // Create a color filter for brightness and contrast
      final List<double> matrix = List<double>.filled(20, 0.0);
      
      // First row
      matrix[0] = contrast;
      matrix[4] = brightness * 255.0;
      
      // Second row
      matrix[6] = contrast;
      matrix[9] = brightness * 255.0;
      
      // Third row
      matrix[12] = contrast;
      matrix[14] = brightness * 255.0;
      
      // Fourth row
      matrix[18] = 1.0;
      
      paint.colorFilter = ColorFilter.matrix(matrix);
    }
    
    // Draw the image
    canvas.drawImage(image, Offset.zero, paint);
    
    // Draw crop rectangle if needed
    if (cropRect != null) {
      final cropPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawRect(cropRect!, cropPaint);
      
      // Draw semi-transparent overlay outside the crop area
      final overlayPaint = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      
      // Top overlay
      canvas.drawRect(
        Rect.fromLTRB(0, 0, imageWidth, cropRect!.top),
        overlayPaint
      );
      
      // Bottom overlay
      canvas.drawRect(
        Rect.fromLTRB(0, cropRect!.bottom, imageWidth, imageHeight),
        overlayPaint
      );
      
      // Left overlay
      canvas.drawRect(
        Rect.fromLTRB(0, cropRect!.top, cropRect!.left, cropRect!.bottom),
        overlayPaint
      );
      
      // Right overlay
      canvas.drawRect(
        Rect.fromLTRB(cropRect!.right, cropRect!.top, imageWidth, cropRect!.bottom),
        overlayPaint
      );
      
      // Draw corner handles for resizing
      final handleSize = 10.0;
      final handlePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      final handleBorderPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      // Top-left handle
      canvas.drawRect(
        Rect.fromCenter(
          center: cropRect!.topLeft,
          width: handleSize,
          height: handleSize
        ),
        handlePaint
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: cropRect!.topLeft,
          width: handleSize,
          height: handleSize
        ),
        handleBorderPaint
      );
      
      // Top-right handle
      canvas.drawRect(
        Rect.fromCenter(
          center: cropRect!.topRight,
          width: handleSize,
          height: handleSize
        ),
        handlePaint
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: cropRect!.topRight,
          width: handleSize,
          height: handleSize
        ),
        handleBorderPaint
      );
      
      // Bottom-right handle
      canvas.drawRect(
        Rect.fromCenter(
          center: cropRect!.bottomRight,
          width: handleSize,
          height: handleSize
        ),
        handlePaint
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: cropRect!.bottomRight,
          width: handleSize,
          height: handleSize
        ),
        handleBorderPaint
      );
      
      // Bottom-left handle
      canvas.drawRect(
        Rect.fromCenter(
          center: cropRect!.bottomLeft,
          width: handleSize,
          height: handleSize
        ),
        handlePaint
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: cropRect!.bottomLeft,
          width: handleSize,
          height: handleSize
        ),
        handleBorderPaint
      );
      
      // Edge handles
      // Top edge handle
      final topCenter = Offset(cropRect!.left + cropRect!.width / 2, cropRect!.top);
      canvas.drawRect(
        Rect.fromCenter(
          center: topCenter,
          width: handleSize * 1.5,
          height: handleSize
        ),
        handlePaint
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: topCenter,
          width: handleSize * 1.5,
          height: handleSize
        ),
        handleBorderPaint
      );
      
      // Right edge handle
      final rightCenter = Offset(cropRect!.right, cropRect!.top + cropRect!.height / 2);
      canvas.drawRect(
        Rect.fromCenter(
          center: rightCenter,
          width: handleSize,
          height: handleSize * 1.5
        ),
        handlePaint
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: rightCenter,
          width: handleSize,
          height: handleSize * 1.5
        ),
        handleBorderPaint
      );
      
      // Bottom edge handle
      final bottomCenter = Offset(cropRect!.left + cropRect!.width / 2, cropRect!.bottom);
      canvas.drawRect(
        Rect.fromCenter(
          center: bottomCenter,
          width: handleSize * 1.5,
          height: handleSize
        ),
        handlePaint
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: bottomCenter,
          width: handleSize * 1.5,
          height: handleSize
        ),
        handleBorderPaint
      );
      
      // Left edge handle
      final leftCenter = Offset(cropRect!.left, cropRect!.top + cropRect!.height / 2);
      canvas.drawRect(
        Rect.fromCenter(
          center: leftCenter,
          width: handleSize,
          height: handleSize * 1.5
        ),
        handlePaint
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: leftCenter,
          width: handleSize,
          height: handleSize * 1.5
        ),
        handleBorderPaint
      );
    }
    
    // Restore the canvas state
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(EditorPainter oldDelegate) {
    return oldDelegate.image != image ||
           oldDelegate.scale != scale ||
           oldDelegate.cropRect != cropRect ||
           oldDelegate.brightness != brightness ||
           oldDelegate.contrast != contrast ||
           oldDelegate.flipHorizontal != flipHorizontal ||
           oldDelegate.flipVertical != flipVertical ||
           oldDelegate.rotationAngle != rotationAngle ||
           oldDelegate.isModified != isModified;
  }
}
