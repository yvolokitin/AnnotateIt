import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';

import 'project_action_buttons.dart';

// Animated background with flying polygons and bounding boxes
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

  static const double _minSizeNorm = 0.02; // relative to shortest side
  static const double _maxSizeNorm = 0.10;
  static const double _minSpeedNorm = 0.02; // fraction of canvas per second
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

    // Determine count based on canvas size
    final minSide = size.shortestSide;
    final count = minSide < 400
        ? 14
        : (minSide < 800 ? 20 : 28);

    final rng = math.Random(42);
    for (int i = 0; i < count; i++) {
      final isPolygon = rng.nextDouble() < 0.6; // 60% polygons, 40% boxes
      final sides = isPolygon ? (3 + rng.nextInt(4)) : 4; // 3..6 for polygons
      final sizeN = _minSizeNorm + rng.nextDouble() * (_maxSizeNorm - _minSizeNorm);
      final speedMag = _minSpeedNorm + rng.nextDouble() * (_maxSpeedNorm - _minSpeedNorm);
      final angle = rng.nextDouble() * math.pi * 2;
      final dx = math.cos(angle) * speedMag;
      final dy = math.sin(angle) * speedMag;
      final rotSpeed = (rng.nextDouble() * 1.2 - 0.6); // -0.6..0.6 rad/s
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
    final scheme = Theme.of(context).colorScheme;
    final polyFill = scheme.info.withOpacity(0.08);
    final polyStroke = scheme.info.withOpacity(0.25);
    final boxStroke = scheme.muted.withOpacity(0.25);
    final boxFill = scheme.muted.withOpacity(0.04);

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
  final double t; // seconds
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
      // wrap-around
      nx = (nx % 1.0 + 1.0) % 1.0;
      ny = (ny % 1.0 + 1.0) % 1.0;

      final center = Offset(nx * size.width, ny * size.height);
      final radius = s.sizeNorm * minSide;

      if (s.isPolygon) {
        final path = _regularPolygonPath(center, radius, s.sides, s.rotSpeed * t);
        canvas.drawPath(path, fillPaintPoly);
        canvas.drawPath(path, strokePaintPoly);
      } else {
        // bounding box (rounded rectangle) with slight rotation
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
  final double sizeNorm; // relative to shortest side
  final double vx; // normalized units per second (relative to width)
  final double vy; // normalized units per second (relative to height)
  final double rotSpeed; // radians per second
  final double x0; // normalized start position (0..1)
  final double y0; // normalized start position (0..1)

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
            final screenHeight = screenSize.height;
            final isPortrait = orientation == Orientation.portrait;
            
            // Determine if we're on a small device
            final isSmallDevice = screenWidth < 360;
            // Determine if we're on a medium device
            final isMediumDevice = screenWidth >= 360 && screenWidth < 600;
            // Determine if we're on a tablet
            final isTablet = screenWidth >= 600 && screenWidth < 900;
            // Determine if we're on a desktop
            final isDesktop = screenWidth >= 900;
            
            // Calculate image size based on available space and device type
            final double leftImageSize = isDesktop 
                ? (screenWidth > 1200 ? 350 : 250)
                : isTablet 
                    ? 200
                    : isMediumDevice 
                        ? 150
                        : 120;
            
            // Calculate font sizes that are readable on all devices
            final titleFontSize = isDesktop 
                ? 26.0
                : isTablet 
                    ? 22.0
                    : 18.0;
            
            final descriptionFontSize = isDesktop 
                ? 18.0
                : isTablet 
                    ? 16.0
                    : 14.0;
            
            // Determine if we should show the image based on available space
            final shouldShowImage = !isSmallDevice || !isPortrait;
            
            // Determine if we should show buttons inside the card
            final showButtonsInCard = isDesktop || (!isPortrait && isTablet);
            
            // Determine if we should use a column layout instead of row for very small screens
            final useColumnLayout = isSmallDevice && isPortrait;
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title for smaller screens (outside the card)
                  if (!isDesktop && !isTablet)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        l10n.emptyProjectTitle,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontFamily: 'CascadiaCode',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            
                  // Main card
                  Card(
                    color: Colors.grey.shade800,
                    margin: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: 16,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Animated background layer
                          Positioned.fill(
                            child: IgnorePointer(
                              child: _FlyingPolygonsBackground(),
                            ),
                          ),
                          // Foreground content layer (non-positioned to give Stack a finite size)
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
            
                  // Buttons for smaller screens (outside the card)
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
          // Left: Image (only if we should show it)
          if (shouldShowImage)
            Container(
              width: leftImageSize,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.asset(
                  'assets/images/start_first_project.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          
          // Right: Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (only for larger screens)
                  if (isDesktop || isTablet)
                    Text(
                      l10n.emptyProjectTitle,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontFamily: 'CascadiaCode',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  
                  if (isDesktop || isTablet) 
                    const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    l10n.emptyProjectDescription,
                    style: TextStyle(
                      fontSize: descriptionFontSize,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.normal,
                      color: Colors.white70,
                    ),
                  ),
                  
                  // Buttons (only for larger screens)
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
        // Image at the top (if we should show it)
        if (shouldShowImage)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              'assets/images/start_first_project.png',
              height: imageSize,
              fit: BoxFit.cover,
            ),
          ),
        
        // Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Text(
                l10n.emptyProjectDescription,
                style: TextStyle(
                  fontSize: descriptionFontSize,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
              
              // Buttons (if they should be inside the card)
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
