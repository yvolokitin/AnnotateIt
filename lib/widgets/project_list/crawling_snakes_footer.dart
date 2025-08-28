import 'dart:math';
import 'package:flutter/material.dart';

/// Animated footer with colorful snake-like lines crawling horizontally.
class CrawlingSnakesFooter extends StatefulWidget {
  final double height;
  final int snakeCount;
  final Duration period;

  const CrawlingSnakesFooter({
    super.key,
    this.height = 80,
    this.snakeCount = 6,
    this.period = const Duration(seconds: 12),
  });

  @override
  State<CrawlingSnakesFooter> createState() => _CrawlingSnakesFooterState();
}

class _CrawlingSnakesFooterState extends State<CrawlingSnakesFooter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_SnakeSpec> _snakes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
    _snakes = _generateSnakes(widget.snakeCount);
  }

  @override
  void didUpdateWidget(covariant CrawlingSnakesFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _controller.duration = widget.period;
      if (!_controller.isAnimating) _controller.repeat();
    }
    if (oldWidget.snakeCount != widget.snakeCount) {
      _snakes = _generateSnakes(widget.snakeCount);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_SnakeSpec> _generateSnakes(int count) {
    final rand = Random();
    return List.generate(count, (i) {
      final hue = rand.nextDouble() * 360.0;
      final color = HSVColor.fromAHSV(0.9, hue, 0.8, 1.0).toColor();
      final amplitude = 8.0 + rand.nextDouble() * 18.0; // 8..26 px
      final thickness = 1.2 + rand.nextDouble() * 2.4; // 1.2..3.6 px
      final speed = 0.6 + rand.nextDouble() * 1.4; // 0.6x..2.0x
      final frequency = 0.8 + rand.nextDouble() * 1.6; // cycles across width (relative)
      final baseY = rand.nextDouble(); // relative 0..1 of available height
      final phase = rand.nextDouble() * 2 * pi;
      return _SnakeSpec(
        color: color,
        amplitude: amplitude,
        thickness: thickness,
        speed: speed,
        frequency: frequency,
        baseY: baseY,
        phase: phase,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _SnakesPainter(
                progress: _controller.value,
                snakes: _snakes,
                background: Theme.of(context).colorScheme.background,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SnakeSpec {
  final Color color;
  final double amplitude;
  final double thickness;
  final double speed; // multiplier of time
  final double frequency; // cycles across width (relative)
  final double baseY; // 0..1 relative vertical position within footer
  final double phase; // initial phase offset

  const _SnakeSpec({
    required this.color,
    required this.amplitude,
    required this.thickness,
    required this.speed,
    required this.frequency,
    required this.baseY,
    required this.phase,
  });
}

class _SnakesPainter extends CustomPainter {
  final double progress; // 0..1 of controller
  final List<_SnakeSpec> snakes;
  final Color background;

  _SnakesPainter({
    required this.progress,
    required this.snakes,
    required this.background,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Optional subtle gradient background overlay for contrast
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          background.withOpacity(0.0),
          background.withOpacity(0.04),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Draw each snake
    for (final s in snakes) {
      final paint = Paint()
        ..color = s.color.withOpacity(0.85)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s.thickness;

      final path = Path();
      final baseYpx = s.baseY * size.height; // base vertical position

      // Number of steps - balance between smoothness and performance
      final steps = max(24, (size.width / 12).round());
      final dx = size.width / steps;

      // Time offset to move the snakes horizontally
      final t = progress * 2 * pi * s.speed;

      for (int i = 0; i <= steps; i++) {
        final x = i * dx;
        final k = (x / size.width) * 2 * pi * s.frequency;
        final y = baseYpx + sin(k + t + s.phase) * s.amplitude;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      // Slight outer glow
      final glow = paint
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawPath(path, glow);

      // Main line
      final solid = Paint()
        ..color = s.color.withOpacity(0.95)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = s.thickness;
      canvas.drawPath(path, solid);
    }
  }

  @override
  bool shouldRepaint(covariant _SnakesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.snakes != snakes;
  }
}