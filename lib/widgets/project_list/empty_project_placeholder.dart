import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';

import 'project_action_buttons.dart';

class _FlyingPolygonsBackground extends StatefulWidget {
  const _FlyingPolygonsBackground({Key? key}) : super(key: key);

  @override
  State<_FlyingPolygonsBackground> createState() => _FlyingPolygonsBackgroundState();
}

class _FlyingPolygonsBackgroundState extends State<_FlyingPolygonsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Shape> _shapes = <_Shape>[];
  Size? _lastSize;

  static const double _minSizeNorm = 0.02;
  static const double _maxSizeNorm = 0.10;
  static const double _minSpeedNorm = 0.02;
  static const double _maxSpeedNorm = 0.08;
  static const int _durationSec = 20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _durationSec),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _ensureShapes(Size size) {
    if (_lastSize == size && _shapes.isNotEmpty) return;
    _lastSize = size;
    _shapes.clear();

    final minSide = size.shortestSide;
    final count = minSide < 400
        ? 14
        : (minSide < 800 ? 20 : 28);

    final rng = math.Random(42);
    for (int i = 0; i < count; i++) {
      final isPolygon = rng.nextDouble() < 0.6;
      final sides = isPolygon ? (3 + rng.nextInt(4)) : 4;
      final sizeN = _minSizeNorm + rng.nextDouble() * (_maxSizeNorm - _minSizeNorm);
      final speedMag = _minSpeedNorm + rng.nextDouble() * (_maxSpeedNorm - _minSpeedNorm);
      final angle = rng.nextDouble() * math.pi * 2;
      final dx = math.cos(angle) * speedMag;
      final dy = math.sin(angle) * speedMag;
      final rotSpeed = (rng.nextDouble() * 1.2 - 0.6);
      final startX = rng.nextDouble();
      final startY = rng.nextDouble();
      _shapes.add(
        _Shape(
          isPolygon: isPolygon,
          sides: sides,
          sizeNorm: sizeN,
          vx: dx,
          vy: dy,
          rotSpeed: rotSpeed,
          x0: startX,
          y0: startY,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final polyFill = AppColors.accentPurple.withOpacity(0.06);
    final polyStroke = AppColors.accentPurple.withOpacity(0.18);
    final boxStroke = AppColors.accentOrange.withOpacity(0.15);
    final boxFill = AppColors.accentOrange.withOpacity(0.04);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (size.isEmpty) {
          return const SizedBox.shrink();
        }
        _ensureShapes(size);
        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final tSec = _controller.value * _durationSec;
              return CustomPaint(
                painter: _FlyingPolygonsPainter(
                  shapes: _shapes,
                  t: tSec,
                  polyFill: polyFill,
                  polyStroke: polyStroke,
                  boxFill: boxFill,
                  boxStroke: boxStroke,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FlyingPolygonsPainter extends CustomPainter {
  final List<_Shape> shapes;
  final double t;
  final Color polyFill;
  final Color polyStroke;
  final Color boxFill;
  final Color boxStroke;

  _FlyingPolygonsPainter({
    required this.shapes,
    required this.t,
    required this.polyFill,
    required this.polyStroke,
    required this.boxFill,
    required this.boxStroke,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minSide = size.shortestSide;

    final fillPaintPoly = Paint()
      ..style = PaintingStyle.fill
      ..color = polyFill;
    final strokePaintPoly = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = polyStroke;
    final fillPaintBox = Paint()
      ..style = PaintingStyle.fill
      ..color = boxFill;
    final strokePaintBox = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = boxStroke;

    for (final s in shapes) {
      double nx = s.x0 + s.vx * t;
      double ny = s.y0 + s.vy * t;
      nx = (nx % 1.0 + 1.0) % 1.0;
      ny = (ny % 1.0 + 1.0) % 1.0;

      final center = Offset(nx * size.width, ny * size.height);
      final radius = s.sizeNorm * minSide;

      if (s.isPolygon) {
        final path = _regularPolygonPath(center, radius, s.sides, s.rotSpeed * t);
        canvas.drawPath(path, fillPaintPoly);
        canvas.drawPath(path, strokePaintPoly);
      } else {
        final rect = Rect.fromCenter(center: center, width: radius * 2.0, height: radius * (1.2 + 0.6 * (s.sides % 3)));
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(s.rotSpeed * 0.5 * t);
        canvas.translate(-center.dx, -center.dy);
        final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius * 0.18));
        canvas.drawRRect(rrect, fillPaintBox);
        canvas.drawRRect(rrect, strokePaintBox);
        canvas.restore();
      }
    }
  }

  Path _regularPolygonPath(Offset center, double radius, int sides, double rotation) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = rotation + (2 * math.pi * i / sides);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _FlyingPolygonsPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.shapes.length != shapes.length ||
        oldDelegate.polyFill != polyFill ||
        oldDelegate.polyStroke != polyStroke ||
        oldDelegate.boxFill != boxFill ||
        oldDelegate.boxStroke != boxStroke;
  }
}

class _Shape {
  final bool isPolygon;
  final int sides;
  final double sizeNorm;
  final double vx;
  final double vy;
  final double rotSpeed;
  final double x0;
  final double y0;

  const _Shape({
    required this.isPolygon,
    required this.sides,
    required this.sizeNorm,
    required this.vx,
    required this.vy,
    required this.rotSpeed,
    required this.x0,
    required this.y0,
  });
}

class EmptyProjectPlaceholder extends StatelessWidget {
  final VoidCallback onCreateNewProject;
  final VoidCallback onImportFromDataset;

  const EmptyProjectPlaceholder({
    super.key,
    required this.onCreateNewProject,
    required this.onImportFromDataset,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final l10n = AppLocalizations.of(context)!;
            final screenSize = MediaQuery.of(context).size;
            final screenWidth = screenSize.width;
            final isPortrait = orientation == Orientation.portrait;
            
            final isSmallDevice = screenWidth < 360;
            final isMediumDevice = screenWidth >= 360 && screenWidth < 600;
            final isTablet = screenWidth >= 600 && screenWidth < 900;
            final isDesktop = screenWidth >= 900;
            
            final double leftImageSize = isDesktop 
                ? (screenWidth > 1200 ? 350 : 250)
                : isTablet 
                    ? 200
                    : isMediumDevice 
                        ? 150
                        : 120;
            
            final titleFontSize = isDesktop ? 24.0 : isTablet ? 20.0 : 17.0;
            final descriptionFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
            
            final shouldShowImage = !isSmallDevice || !isPortrait;
            final showButtonsInCard = isDesktop || (!isPortrait && isTablet);
            final useColumnLayout = isSmallDevice && isPortrait;
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isDesktop && !isTablet)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        l10n.emptyProjectTitle,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
            
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: _FlyingPolygonsBackground(),
                            ),
                          ),
                          useColumnLayout
                              ? _buildColumnLayout(
                                  context,
                                  l10n,
                                  leftImageSize,
                                  shouldShowImage,
                                  titleFontSize,
                                  descriptionFontSize,
                                  showButtonsInCard,
                                  screenWidth,
                                )
                              : _buildRowLayout(
                                  context,
                                  l10n,
                                  leftImageSize,
                                  shouldShowImage,
                                  titleFontSize,
                                  descriptionFontSize,
                                  showButtonsInCard,
                                  isDesktop,
                                  isTablet,
                                  screenWidth,
                                ),
                        ],
                      ),
                    ),
                  ),
            
                  if (!showButtonsInCard)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: ProjectActionButtons(
                        onCreate: onCreateNewProject,
                        onImport: onImportFromDataset,
                        screenWidth: screenWidth,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildRowLayout(
    BuildContext context,
    AppLocalizations l10n,
    double leftImageSize,
    bool shouldShowImage,
    double titleFontSize,
    double descriptionFontSize,
    bool showButtonsInCard,
    bool isDesktop,
    bool isTablet,
    double screenWidth,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (shouldShowImage)
            Container(
              width: leftImageSize,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.asset(
                  'assets/images/start_first_project.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 28 : isTablet ? 20 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop || isTablet)
                    Text(
                      l10n.emptyProjectTitle,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  
                  if (isDesktop || isTablet) 
                    const SizedBox(height: 14),
                  
                  Text(
                    l10n.emptyProjectDescription,
                    style: TextStyle(
                      fontSize: descriptionFontSize,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.55),
                      height: 1.5,
                    ),
                  ),
                  
                  if (showButtonsInCard) ...[
                    const Spacer(),
                    ProjectActionButtons(
                      onCreate: onCreateNewProject,
                      onImport: onImportFromDataset,
                      screenWidth: screenWidth,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildColumnLayout(
    BuildContext context,
    AppLocalizations l10n,
    double imageSize,
    bool shouldShowImage,
    double titleFontSize,
    double descriptionFontSize,
    bool showButtonsInCard,
    double screenWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (shouldShowImage)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.asset(
              'assets/images/start_first_project.png',
              height: imageSize,
              fit: BoxFit.cover,
            ),
          ),
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.emptyProjectDescription,
                style: TextStyle(
                  fontSize: descriptionFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.55),
                  height: 1.5,
                ),
              ),
              
              if (showButtonsInCard) ...[
                const SizedBox(height: 16),
                ProjectActionButtons(
                  onCreate: onCreateNewProject,
                  onImport: onImportFromDataset,
                  screenWidth: screenWidth,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
