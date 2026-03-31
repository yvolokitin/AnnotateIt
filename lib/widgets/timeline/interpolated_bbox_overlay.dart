import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../usecases/track_usecases.dart';
import '../../utils/theme.dart';

/// Paints interpolated and manual bbox annotations over the video frame.
///
/// Manual keyframes are drawn with solid borders, interpolated in-betweens
/// with dashed borders and lower opacity to visually distinguish them.
class InterpolatedBboxOverlay extends StatelessWidget {
  final List<InterpolatedFrame> frames;
  final Size imageSize;
  final bool showInterpolated;

  const InterpolatedBboxOverlay({
    super.key,
    required this.frames,
    required this.imageSize,
    this.showInterpolated = true,
  });

  @override
  Widget build(BuildContext context) {
    if (frames.isEmpty) return const SizedBox.shrink();

    final visible = showInterpolated
        ? frames
        : frames.where((f) => f.isManual).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return CustomPaint(
      size: imageSize,
      painter: _BboxOverlayPainter(
        frames: visible,
        imageSize: imageSize,
      ),
    );
  }
}

class _BboxOverlayPainter extends CustomPainter {
  final List<InterpolatedFrame> frames;
  final Size imageSize;

  _BboxOverlayPainter({
    required this.frames,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (final frame in frames) {
      final bbox = frame.bbox;
      if (!bbox.isValid) continue;

      final rect = Rect.fromLTWH(
        bbox.x * scaleX,
        bbox.y * scaleY,
        bbox.width * scaleX,
        bbox.height * scaleY,
      );

      if (bbox.rotation != 0.0) {
        canvas.save();
        final center = rect.center;
        canvas.translate(center.dx, center.dy);
        canvas.rotate(bbox.rotation);
        canvas.translate(-center.dx, -center.dy);
      }

      if (frame.isManual) {
        _drawManualBbox(canvas, rect);
      } else {
        _drawInterpolatedBbox(canvas, rect);
      }

      if (bbox.rotation != 0.0) {
        canvas.restore();
      }
    }
  }

  void _drawManualBbox(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRect(rect, paint);

    final fillPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    _drawCornerMarkers(canvas, rect, AppColors.accent);
  }

  void _drawInterpolatedBbox(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = AppColors.accentOrange.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    _drawDashedRect(canvas, rect, paint, dashWidth: 6, gapWidth: 4);

    final fillPaint = Paint()
      ..color = AppColors.accentOrange.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);
  }

  void _drawDashedRect(
    Canvas canvas,
    Rect rect,
    Paint paint, {
    double dashWidth = 6,
    double gapWidth = 4,
  }) {
    final edges = [
      [rect.topLeft, rect.topRight],
      [rect.topRight, rect.bottomRight],
      [rect.bottomRight, rect.bottomLeft],
      [rect.bottomLeft, rect.topLeft],
    ];

    for (final edge in edges) {
      _drawDashedLine(canvas, edge[0], edge[1], paint, dashWidth, gapWidth);
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
    double dashWidth,
    double gapWidth,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final ux = dx / length;
    final uy = dy / length;

    double drawn = 0;
    bool drawing = true;
    while (drawn < length) {
      final segLen = drawing ? dashWidth : gapWidth;
      final end2 = math.min(drawn + segLen, length);
      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + ux * drawn, start.dy + uy * drawn),
          Offset(start.dx + ux * end2, start.dy + uy * end2),
          paint,
        );
      }
      drawn = end2;
      drawing = !drawing;
    }
  }

  void _drawCornerMarkers(Canvas canvas, Rect rect, Color color) {
    const size = 6.0;
    final markerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final corner in [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      final r = Rect.fromCenter(center: corner, width: size, height: size);
      canvas.drawRect(r, markerPaint);
      canvas.drawRect(r, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_BboxOverlayPainter old) =>
      frames != old.frames || imageSize != old.imageSize;
}
