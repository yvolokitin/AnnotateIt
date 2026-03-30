import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../data/project_database.dart';
import '../../data/user_database.dart';
import '../../session/user_session.dart';
import '../../utils/theme.dart';
import '../app_snackbar.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:in_app_review/in_app_review.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({
    super.key,
  });

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  void _showBoltOverlay() {
    final overlay = Overlay.of(context);
    if (overlay == null) return;
    final entry = OverlayEntry(
      builder: (ctx) => Positioned.fill(
        child: IgnorePointer(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              builder: (ctx, value, child) => Opacity(
                opacity: 1.0 - (value * 0.8),
                child: Transform.scale(
                  scale: 0.8 + value * 0.7,
                  child: Icon(
                    Icons.bolt,
                    size: 120,
                    color: Theme.of(ctx).colorScheme.info,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 700)).then((_) {
      try { entry.remove(); } catch (_) {}
    });
  }

  Future<void> _requestInAppReview() async {
    try {
      final inAppReview = InAppReview.instance;
      final available = await inAppReview.isAvailable();
      if (available) {
        await inAppReview.requestReview();
      } else {
        // Fallback: On Android we can open the Play Store listing without specifying the ID.
        if (defaultTargetPlatform == TargetPlatform.android) {
          await inAppReview.openStoreListing();
        } else {
          AppSnackbar.show(
            context,
            'Reviews are not available right now.',
            backgroundColor: AppColors.accent,
            textColor: Colors.white,
          );
        }
      }
    } catch (_) {
      AppSnackbar.show(
        context,
        'Could not open the review dialog.',
        backgroundColor: AppColors.accent,
        textColor: Colors.white,
      );
    }
  }

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
                    (() {
                      try {
                        if (UserSession.instance.isInitialized) {
                          final u = UserSession.instance.getUser();
                          final name = '${u.firstName} ${u.lastName}'.trim();
                          return name.isEmpty ? 'Captain Annotator' : name;
                        }
                      } catch (_) {}
                      return 'Captain Annotator';
                    })(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth > 1200 ? 24 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () async {
                          if (kIsWeb) {
                            AppSnackbar.show(
                              context,
                              'In-app reviews are not supported on web.',
                              backgroundColor: AppColors.accent,
                              textColor: Colors.white,
                            );
                            return;
                          }

                          if (defaultTargetPlatform == TargetPlatform.windows) {
                            final uri = Uri.parse('https://apps.microsoft.com/detail/9N640T6RLT89?hl=en-us&gl=NL&ocid=pdpshare');
                            final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
                            if (!ok) {
                              AppSnackbar.show(
                                context,
                                'Could not open Microsoft Store.',
                                backgroundColor: AppColors.accent,
                                textColor: Colors.white,
                              );
                            }
                            return;
                          }

                          if (defaultTargetPlatform == TargetPlatform.iOS ||
                              defaultTargetPlatform == TargetPlatform.android ||
                              defaultTargetPlatform == TargetPlatform.macOS) {
                            await _requestInAppReview();
                            return;
                          }

                          AppSnackbar.show(
                            context,
                            'In-app reviews are not supported on this platform.',
                            backgroundColor: AppColors.accent,
                            textColor: Colors.white,
                          );
                        },
                        elevation: 0,
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        label: Text(
                          fdbkButton,
                          style: TextStyle(
                            fontSize: screenWidth > 1200 ? 22 : 16,
                          ),
                        ),
                        icon: const Icon(Icons.feedback_outlined),
                      ),
                      const SizedBox(width: 16.0),
                      FloatingActionButton.extended(
                        onPressed: () async {
                          final existingUser = await UserDatabase.instance.getUser();
                          if (existingUser == null) {
                            AppSnackbar.show(
                              context,
                              'No user found to edit.',
                              backgroundColor: AppColors.accent,
                              textColor: Colors.white,
                            );
                            return;
                          }

                          final firstController = TextEditingController(text: existingUser.firstName);
                          final lastController = TextEditingController(text: existingUser.lastName);

                          final screenWidth = MediaQuery.of(context).size.width;

                          final saved = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    backgroundColor: AppColors.darkSurface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline,
                                          size: (screenWidth > 1200) ? 34 : 26,
                                          color: Theme.of(context).colorScheme.info,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          AppLocalizations.of(context)!.userProfileEditProfileButton,
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.info,
                                            fontWeight: FontWeight.bold,
                                            fontSize: (screenWidth > 1200) ? 26 : 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Divider(color: Theme.of(context).colorScheme.info),
                                        Padding(
                                          padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
                                          child: TextField(
                                            controller: firstController,
                                            inputFormatters: [LengthLimitingTextInputFormatter(32)],
                                            decoration: InputDecoration(
                                              hintText: 'First name',
                                              hintStyle: TextStyle(
                                                color: Theme.of(context).colorScheme.muted,
                                                fontWeight: FontWeight.normal,
                                                fontSize: screenWidth > 1200 ? 22 : 18,
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                              filled: false,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
                                          child: TextField(
                                            controller: lastController,
                                            inputFormatters: [LengthLimitingTextInputFormatter(32)],
                                            decoration: InputDecoration(
                                              hintText: 'Last name',
                                              hintStyle: TextStyle(
                                                color: Theme.of(context).colorScheme.muted,
                                                fontWeight: FontWeight.normal,
                                                fontSize: screenWidth > 1200 ? 22 : 18,
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                              filled: false,
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(dialogContext, false),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.darkSurface,
                                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!.buttonClose,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.muted,
                                                fontWeight: FontWeight.normal,
                                                fontSize: (screenWidth > 1200) ? 22 : 20,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final firstRaw = firstController.text.trim();
                                              final lastRaw = lastController.text.trim();
                                              final first = firstRaw.length > 32 ? firstRaw.substring(0, 32) : firstRaw;
                                              final last = lastRaw.length > 32 ? lastRaw.substring(0, 32) : lastRaw;
                                              if (first.isEmpty || last.isEmpty) {
                                                AppSnackbar.show(
                                                  context,
                                                  'Please enter both first and last name.',
                                                  backgroundColor: AppColors.accent,
                                                  textColor: Colors.white,
                                                );
                                                return;
                                              }
                                              final updated = existingUser.copyWith(
                                                firstName: first,
                                                lastName: last,
                                                updatedAt: DateTime.now(),
                                              );
                                              _showBoltOverlay();
                                              await UserDatabase.instance.update(updated);
                                              UserSession.instance.setUser(updated);
                                              if (context.mounted) {
                                                Navigator.pop(dialogContext, true);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.darkSurface,
                                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                side: BorderSide(color: Theme.of(context).colorScheme.info, width: 2),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)!.buttonSave,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: (screenWidth > 1200) ? 22 : 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );

                          firstController.dispose();
                          lastController.dispose();

                          if (saved == true && context.mounted) {
                            setState(() {});
                            AppSnackbar.show(
                              context,
                              'Profile updated.',
                              backgroundColor: Colors.greenAccent,
                              textColor: Colors.black,
                            );
                          }
                        },
                        elevation: 0,
                        backgroundColor: AppColors.accent,
                        label: Text(
                          editButton,
                          style: TextStyle(
                            fontSize: screenWidth > 1200 ? 22 : 16,
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
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Expanded(
                child: Row(
                  children: [
                    if (index != 0) const VerticalDivider(),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeOut,
                        builder: (context, value, child) => Opacity(opacity: value, child: child),
                        child: _singleItem(context, item),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
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
                fontSize: 20,
              ),
            ),
        ),

        Text(
            item.title,
            style: TextStyle(
              fontSize: screenWidth > 1200 ? 16 : 12,
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
