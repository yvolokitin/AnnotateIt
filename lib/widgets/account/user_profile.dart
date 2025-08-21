import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../data/project_database.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;

    String editButton = screenWidth>500 ? l10n.userProfileEditProfileButton : l10n.buttonEdit;
    String fdbkButton = screenWidth>500 ? l10n.userProfileFeedbackButton : l10n.buttonFeedbackShort;

    return Scaffold(
      body: Column(
        children: [
          const Expanded(flex: 2, child: _TopPortion()),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Captain Annotator",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth > 1200 ? 24 : 18,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () {},
                        elevation: 0,
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        label: Text(
                          fdbkButton,
                          style: TextStyle(
                            fontSize: screenWidth > 1200 ? 22 : 16,
                            fontFamily: 'CascadiaCode',
                          ),
                        ),
                        icon: const Icon(Icons.feedback_outlined),
                      ),
                      const SizedBox(width: 16.0),
                      FloatingActionButton.extended(
                        onPressed: () {},
                        elevation: 0,
                        backgroundColor: Colors.redAccent,
                        label: Text(
                          editButton,
                          style: TextStyle(
                            fontSize: screenWidth > 1200 ? 22 : 16,
                            fontFamily: 'CascadiaCode',
                          ),
                        ),
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _ProfileInfoRow()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopPortion extends StatelessWidget {
  const _TopPortion({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 50),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Color.fromARGB(255, 66, 66, 66), Color.fromARGB(255, 66, 66, 66)],

            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.only(bottom: 50),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
              child: _FlyingBoxesBackground(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/avataaars.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoRow extends StatefulWidget {
  const _ProfileInfoRow({Key? key}) : super(key: key);

  @override
  State<_ProfileInfoRow> createState() => _ProfileInfoRowState();
}

class _ProfileInfoRowState extends State<_ProfileInfoRow> {
  int? projectCount;
  int? mediaCount;
  int? annotationCount;
  int? labelCount;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    final db = ProjectDatabase.instance;
    final projects = await db.getProjectCount();
    final media = await db.getMediaCount();
    final annotations = await db.getAnnotationCount();
    final labels = await db.getLabelCount();

    setState(() {
      projectCount = projects;
      mediaCount = media;
      annotationCount = annotations;
      labelCount = labels;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;

    final items = [
      ProfileInfoItem(screenWidth>500 ? l10n.userProfileProjects : l10n.userProfileProjects[0], projectCount),
      ProfileInfoItem(screenWidth>500 ? l10n.userProfileLabels : l10n.userProfileLabels[0], labelCount),
      ProfileInfoItem(screenWidth>500 ? l10n.userProfileMedia : l10n.userProfileMedia[0], mediaCount),
      ProfileInfoItem(screenWidth>500 ? l10n.userProfileAnnotations : l10n.userProfileAnnotations[0], annotationCount),
    ];

    return Container(
      height: 100,
      constraints: const BoxConstraints(maxWidth: 600),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items
            .map((item) => Expanded(
                  child: Row(
                    children: [
                      if (items.indexOf(item) != 0) const VerticalDivider(),
                      Expanded(child: _singleItem(context, item)),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, ProfileInfoItem item) {
    final isLoading = item.value == null;
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading
            ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
            : Text(
              item.value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'CascadiaCode',
                fontSize: 20,
              ),
            ),
        ),

        Text(
            item.title,
            style: TextStyle(
              fontSize: screenWidth > 1200 ? 16 : 12,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class ProfileInfoItem {
  final String title;
  final int? value;
  const ProfileInfoItem(this.title, this.value);
}

// Animated flying bounding boxes background for the top portion
class _FlyingBoxesBackground extends StatefulWidget {
  const _FlyingBoxesBackground({Key? key}) : super(key: key);

  @override
  State<_FlyingBoxesBackground> createState() => _FlyingBoxesBackgroundState();
}

class _FlyingBoxesBackgroundState extends State<_FlyingBoxesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_BoxSpec> _boxes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat();

    // Deterministic random for stable layout across rebuilds
    final rnd = math.Random(42);
    final count = 16; // keep it light for performance
    _boxes = List.generate(count, (i) {
      final fx = rnd.nextDouble();
      final fy = rnd.nextDouble();
      final angle = rnd.nextDouble() * math.pi * 2;
      final speed = 0.05 + rnd.nextDouble() * 0.25; // units per second fraction of width/height
      final base = 18.0 + rnd.nextDouble() * 48.0; // px
      final phase = rnd.nextDouble();
      final stroke = 1.0 + rnd.nextDouble() * 1.5;
      final radius = 4.0 + rnd.nextDouble() * 10.0;
      final opacity = 0.06 + rnd.nextDouble() * 0.08; // subtle
      return _BoxSpec(
        fx: fx,
        fy: fy,
        dirAngle: angle,
        speed: speed,
        baseSize: base,
        phase: phase,
        stroke: stroke,
        corner: radius,
        opacity: opacity,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final elapsedSec = (_controller.lastElapsedDuration?.inMilliseconds ?? 0) / 1000.0;
          return CustomPaint(
            painter: _BoxesPainter(_boxes, elapsedSec),
            isComplex: true,
            willChange: true,
          );
        },
      ),
    );
  }
}

class _BoxSpec {
  final double fx; // base x in [0,1]
  final double fy; // base y in [0,1]
  final double dirAngle; // movement direction in radians
  final double speed; // fraction per second
  final double baseSize; // px
  final double phase; // [0,1]
  final double stroke;
  final double corner;
  final double opacity; // 0..1

  const _BoxSpec({
    required this.fx,
    required this.fy,
    required this.dirAngle,
    required this.speed,
    required this.baseSize,
    required this.phase,
    required this.stroke,
    required this.corner,
    required this.opacity,
  });
}

class _BoxesPainter extends CustomPainter {
  final List<_BoxSpec> boxes;
  final double t; // elapsed seconds

  _BoxesPainter(this.boxes, this.t);

  double _fract(double v) => v - v.floorToDouble();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final minSide = math.min(size.width, size.height);
    for (final b in boxes) {
      // Smooth size oscillation between 0.8x and 1.2x base
      final scale = 1.0 + 0.2 * math.sin((t + b.phase) * math.pi * 2.0);
      final boxSize = (b.baseSize * scale).clamp(10.0, minSide * 0.35);

      // Movement across the area with wrap-around
      final dirX = math.cos(b.dirAngle);
      final dirY = math.sin(b.dirAngle);
      final travel = b.speed * t; // fraction of canvas per second
      // add slight curved drift using sin/cos for organic motion
      final driftX = 0.03 * math.sin((t + b.phase) * 0.7 * math.pi * 2.0);
      final driftY = 0.03 * math.cos((t + b.phase) * 0.6 * math.pi * 2.0);
      final fx = _fract(b.fx + dirX * travel + driftX);
      final fy = _fract(b.fy + dirY * travel + driftY);

      final cx = fx * size.width;
      final cy = fy * size.height;

      final rect = Rect.fromCenter(center: Offset(cx, cy), width: boxSize, height: boxSize);

      // Pulsing opacity for subtle breathing
      final alphaPulse = 0.5 + 0.5 * math.sin((t + b.phase) * math.pi * 2.0);
      final color = Colors.white.withOpacity((b.opacity * (0.7 + 0.3 * alphaPulse)).clamp(0.02, 0.16));

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = b.stroke;

      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(b.corner));
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BoxesPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.boxes != boxes;
  }
}
