import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../usecases/track_usecases.dart';
import '../../utils/theme.dart';

/// Paints interpolated and manual polygon annotations over the video frame.
///
/// Manual keyframes use solid polygon borders; interpolated in-betweens use
/// dashed borders. A warning badge is shown for low-quality interpolations.
class InterpolatedPolygonOverlay extends StatelessWidget {
  final List<InterpolatedFrame> frames;
  final Size imageSize;
  final bool showInterpolated;

  const InterpolatedPolygonOverlay({
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
      painter: _PolygonOverlayPainter(
        frames: visible,
        imageSize: imageSize,
      ),
    );
  }
}

class _PolygonOverlayPainter extends CustomPainter {
  final List<InterpolatedFrame> frames;
  final Size imageSize;

  _PolygonOverlayPainter({
    required this.frames,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (final frame in frames) {
      final poly = frame.polygon;
      if (!poly.isValid) continue;

      final points = poly.vertices
          .map((v) => Offset(v.x * scaleX, v.y * scaleY))
          .toList();

      if (frame.isManual) {
        _drawManualPolygon(canvas, points);
      } else {
        _drawInterpolatedPolygon(canvas, points);
      }

      if (frame.showWarningBadge && points.isNotEmpty) {
        _drawWarningBadge(canvas, _centroid(points));
      }
    }
  }

  void _drawManualPolygon(Canvas canvas, List<Offset> points) {
    final path = _buildPath(points);

    final fillPaint = Paint()
      ..color = AppColors.accentPurple.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = AppColors.accentPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    _drawVertexMarkers(canvas, points, AppColors.accentPurple);
  }

  void _drawInterpolatedPolygon(Canvas canvas, List<Offset> points) {
    final path = _buildPath(points);

    final fillPaint = Paint()
      ..color = AppColors.accentOrange.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = AppColors.accentOrange.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeJoin = StrokeJoin.round;

    _drawDashedPath(canvas, points, strokePaint);
  }

  Path _buildPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();
    return path;
  }

  void _drawDashedPath(
    Canvas canvas,
    List<Offset> points,
    Paint paint, {
    double dashWidth = 6,
    double gapWidth = 4,
  }) {
    for (int i = 0; i < points.length; i++) {
      final start = points[i];
      final end = points[(i + 1) % points.length];
      _drawDashedLine(canvas, start, end, paint, dashWidth, gapWidth);
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
    if (length == 0) return;
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

  void _drawVertexMarkers(Canvas canvas, List<Offset> points, Color color) {
    const radius = 3.5;
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final p in points) {
      canvas.drawCircle(p, radius, fillPaint);
      canvas.drawCircle(p, radius, borderPaint);
    }
  }

  void _drawWarningBadge(Canvas canvas, Offset center) {
    const badgeSize = 16.0;
    final bgPaint = Paint()
      ..color = AppColors.accentOrange
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, badgeSize / 2, bgPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: '!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  Offset _centroid(List<Offset> points) {
    double cx = 0, cy = 0;
    for (final p in points) {
      cx += p.dx;
      cy += p.dy;
    }
    return Offset(cx / points.length, cy / points.length);
  }

  @override
  bool shouldRepaint(_PolygonOverlayPainter old) =>
      frames != old.frames || imageSize != old.imageSize;
}
