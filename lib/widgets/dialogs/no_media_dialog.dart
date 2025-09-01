import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

import 'alert_error_dialog.dart';

class NoMediaDialog extends StatefulWidget {
  final int projectId;
  final String datasetId;

  const NoMediaDialog({
    required this.projectId,
    required this.datasetId,
    super.key,
  });

  @override
  NoMediaDialogState createState() => NoMediaDialogState();
}

class NoMediaDialogState extends State<NoMediaDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final smallScreen = (screenWidth < 700) || (screenHeight < 750);

        final double padding = smallScreen ? 8 : 24;
        final bool showImage = screenWidth >= 600;
        final double imageHeight = showImage
            ? math.min(360, math.max(120, screenHeight * 0.35))
            : 0;

        final double titleSize = smallScreen ? 20 : 24;
        final double textSize = smallScreen ? 14 : 18;
        final double gapLarge = smallScreen ? 8 : 24;
        final double gapSmall = smallScreen ? 4 : 12;

        return Stack(
          children: [
            // Animated background with floating shapes
            const Positioned.fill(
              child: _FlyingBackground(count: 26),
            ),

            // Foreground content
            Positioned.fill(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - padding * 2,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: gapLarge),
                          Text(
                            screenWidth > 600
                                ? l10n.noMediaDialogUploadPrompt
                                : l10n.noMediaDialogUploadPromptShort,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'CascadiaCode',
                              fontSize: titleSize,
                            ),
                          ),
                          if (showImage) ...[
                            SizedBox(height: gapLarge),
                            SizedBox(
                              height: imageHeight,
                              child: Image.asset(
                                'assets/images/media_upload.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                          SizedBox(height: gapLarge),
                          Text(
                            l10n.noMediaDialogSupportedImageTypesTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'CascadiaCode',
                              fontSize: textSize,
                            ),
                          ),
                          SizedBox(height: gapSmall),
                          Text(
                            l10n.noMediaDialogSupportedImageTypesList,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'CascadiaCode',
                              fontSize: textSize,
                            ),
                          ),
                          SizedBox(height: gapLarge),
                          GestureDetector(
                            onTap: _showSupportedVideoDialog,
                            child: Text(
                              l10n.noMediaDialogSupportedVideoFormatsLink,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white54,
                                decoration: TextDecoration.underline,
                                fontFamily: 'CascadiaCode',
                                fontSize: textSize,
                              ),
                            ),
                          ),
                          SizedBox(height: gapLarge),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSupportedVideoDialog() {
    final l10n = AppLocalizations.of(context)!;
    AlertErrorDialog.show(
      context,
      l10n.noMediaDialogSupportedVideoFormatsTitle,
      l10n.noMediaDialogSupportedVideoFormatsList,
      tips: l10n.noMediaDialogSupportedVideoFormatsWarning,
    );
  }
}

class _FlyingBackground extends StatefulWidget {
  final int count;
  const _FlyingBackground({super.key, this.count = 24});

  @override
  State<_FlyingBackground> createState() => _FlyingBackgroundState();
}

class _FlyingBackgroundState extends State<_FlyingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = <_Particle>[];
  Size _size = Size.zero;
  late DateTime _lastTick;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..addListener(_onTick)
     ..repeat();
    _lastTick = DateTime.now();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  void _ensureParticles(Size size) {
    if (_size == size && _particles.isNotEmpty) return;
    _size = size;
    _particles
      ..clear()
      ..addAll(List.generate(widget.count, (_) => _Particle.random(size)));
  }

  void _onTick() {
    if (_size == Size.zero) return;
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;

    for (final p in _particles) {
      p.update(dt, _size);
    }
    // repaint only this widget
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _ensureParticles(size);
        return IgnorePointer(
          child: CustomPaint(
            painter: _FlyingBackgroundPainter(_particles),
            size: Size.infinite,
            isComplex: true,
            willChange: true,
          ),
        );
      },
    );
  }
}

class _FlyingBackgroundPainter extends CustomPainter {
  final List<_Particle> particles;
  _FlyingBackgroundPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      p.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant _FlyingBackgroundPainter oldDelegate) => true;
}

enum _ParticleType { image, dataset }

class _Particle {
  _Particle(this.type, this.position, this.size, this.velocity, this.color,
      this.rotation, this.rotationSpeed, this.opacity);

  _ParticleType type;
  Offset position;
  Size size;
  Offset velocity;
  Color color;
  double rotation;
  double rotationSpeed;
  double opacity;

  static final math.Random _rng = math.Random();

  static _Particle random(Size bounds) {
    final type = _rng.nextBool() ? _ParticleType.image : _ParticleType.dataset;
    final base = math.max(12.0, math.min(bounds.shortestSide * 0.12, 64.0));
    final w = base * (0.6 + _rng.nextDouble() * 1.4);
    final h = type == _ParticleType.image ? w * (0.7 + _rng.nextDouble() * 0.6) : w * (0.4 + _rng.nextDouble() * 0.5);
    final x = _rng.nextDouble() * bounds.width;
    final y = _rng.nextDouble() * bounds.height;
    final speed = (20 + _rng.nextDouble() * 40) * (_rng.nextBool() ? 1 : -1);
    final dir = _rng.nextBool() ? Offset(speed, 0) : Offset(-speed, 0);
    final color = HSVColor.fromAHSV(
      1,
      _rng.nextDouble() * 360,
      0.6 + _rng.nextDouble() * 0.3,
      0.8,
    ).toColor();
    final rotation = _rng.nextDouble() * math.pi * 2;
    final rotationSpeed = (_rng.nextDouble() - 0.5) * 0.4; // radians/sec
    final opacity = 0.05 + _rng.nextDouble() * 0.08; // subtle
    return _Particle(
      type,
      Offset(x, y),
      Size(w, h),
      dir,
      color,
      rotation,
      rotationSpeed,
      opacity,
    );
  }

  void update(double dt, Size bounds) {
    position += velocity * dt;
    rotation += rotationSpeed * dt;
    const margin = 60.0;
    // wrap around or respawn on opposite side
    if (position.dx < -margin || position.dx > bounds.width + margin) {
      final fromLeft = position.dx > bounds.width;
      final newX = fromLeft ? -margin : bounds.width + margin;
      position = Offset(newX, _rng.nextDouble() * bounds.height);
      final speed = 20 + _rng.nextDouble() * 40;
      velocity = Offset(fromLeft ? -speed : speed, 0);
      // randomize other properties a bit on respawn
      final base = math.max(12.0, math.min(bounds.shortestSide * 0.12, 64.0));
      final w = base * (0.6 + _rng.nextDouble() * 1.4);
      final h = type == _ParticleType.image ? w * (0.7 + _rng.nextDouble() * 0.6) : w * (0.4 + _rng.nextDouble() * 0.5);
      size = Size(w, h);
      color = HSVColor.fromAHSV(
        1,
        _rng.nextDouble() * 360,
        0.6 + _rng.nextDouble() * 0.3,
        0.8,
      ).toColor();
      opacity = 0.05 + _rng.nextDouble() * 0.08;
    }

    if (position.dy < -margin) position = Offset(position.dx, bounds.height + margin);
    if (position.dy > bounds.height + margin) position = Offset(position.dx, -margin);
  }

  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(rotation);

    switch (type) {
      case _ParticleType.image:
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: size.width,
          height: size.height,
        );
        final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
        canvas.drawRRect(rrect, paint);
        break;
      case _ParticleType.dataset:
        // draw stacked bars representing dataset rows
        final barCount = 3;
        final barGap = size.height * 0.12;
        final barHeight = (size.height - (barGap * (barCount - 1))) / barCount;
        for (int i = 0; i < barCount; i++) {
          final widthScale = 0.6 + (i == 1 ? 0.3 : (i == 2 ? 0.15 : 0.0));
          final rect = Rect.fromCenter(
            center: Offset(0, -size.height / 2 + barHeight / 2 + i * (barHeight + barGap)),
            width: size.width * widthScale,
            height: barHeight,
          );
          final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
          canvas.drawRRect(rrect, paint);
        }
        break;
    }

    canvas.restore();
  }
}
