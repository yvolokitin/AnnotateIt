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
  final double rotationAngle;
  final double flipScaleX;
  final double flipScaleY;
  final bool isModified;
  
  // Highlighted crop edge (5=top, 6=right, 7=bottom, 8=left)
  final int? highlightEdge;

  EditorPainter({
    required this.image,
    required this.scale,
    this.cropRect,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.rotationAngle = 0.0,
    this.flipScaleX = 1.0,
    this.flipScaleY = 1.0,
    this.isModified = false,
    this.highlightEdge,
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
    
    // Apply rotation if needed (animated value in degrees)
    if (rotationAngle != 0.0) {
      // Translate to the center of the image
      canvas.translate(centerX, centerY);
      // Rotate around the center
      canvas.rotate(rotationAngle * (pi / 180));
      // Translate back
      canvas.translate(-centerX, -centerY);
    }
    
    // Apply flips/scales if needed (combine logical flip with animated scale)
    final combinedScaleX = (flipHorizontal ? -1.0 : 1.0) * flipScaleX;
    final combinedScaleY = (flipVertical ? -1.0 : 1.0) * flipScaleY;
    if (combinedScaleX != 1.0 || combinedScaleY != 1.0) {
      // Translate to the center of the image
      canvas.translate(centerX, centerY);
      // Apply scaling (flipping/animation)
      canvas.scale(combinedScaleX, combinedScaleY);
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
    
    // Draw crop overlay if needed (no visible rectangle or handles)
    if (cropRect != null) {
      // Draw semi-transparent overlay outside the crop area only
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

      // Highlight targeted edge in red if specified
      if (highlightEdge != null) {
        final edge = highlightEdge!;
        final redPaint = Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        switch (edge) {
          case 5: // top
            canvas.drawLine(
              Offset(cropRect!.left, cropRect!.top),
              Offset(cropRect!.right, cropRect!.top),
              redPaint,
            );
            break;
          case 6: // right
            canvas.drawLine(
              Offset(cropRect!.right, cropRect!.top),
              Offset(cropRect!.right, cropRect!.bottom),
              redPaint,
            );
            break;
          case 7: // bottom
            canvas.drawLine(
              Offset(cropRect!.left, cropRect!.bottom),
              Offset(cropRect!.right, cropRect!.bottom),
              redPaint,
            );
            break;
          case 8: // left
            canvas.drawLine(
              Offset(cropRect!.left, cropRect!.top),
              Offset(cropRect!.left, cropRect!.bottom),
              redPaint,
            );
            break;
        }
      }
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
           oldDelegate.flipScaleX != flipScaleX ||
           oldDelegate.flipScaleY != flipScaleY ||
           oldDelegate.isModified != isModified ||
           oldDelegate.highlightEdge != highlightEdge;
  }
}
