import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/theme.dart';

import '../../models/project.dart';
import '../../widgets/dialogs/alert_error_dialog.dart';
import '../../widgets/project_type_change/project_type_change_step_1_task_selection.dart';
import '../../widgets/project_type_change/project_type_change_step_2_confirmation.dart';

import '../../utils/project_type_migrator.dart';
import '../../gen_l10n/app_localizations.dart';

class ChangeProjectTypeDialog extends StatefulWidget {
  final Project project;

  const ChangeProjectTypeDialog({
    super.key,
    required this.project,
  });

  @override
  ChangeProjectTypeDialogState createState() => ChangeProjectTypeDialogState();
}

class ChangeProjectTypeDialogState extends State<ChangeProjectTypeDialog> with SingleTickerProviderStateMixin {
  String currentProjectType = '';
  int currentStep = 1;
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    currentProjectType = widget.project.type;
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1600;
    final isTablet = screenWidth >= 800 && screenWidth < 1600;
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {

        final dialogPadding = isLargeScreen
            ? const EdgeInsets.all(60)
            : isTablet
                ? const EdgeInsets.all(24)
                : const EdgeInsets.all(12);

        final dialogWidth = constraints.maxWidth * (isLargeScreen ? 0.9 : 1.0);
        final dialogHeight = constraints.maxHeight * (isLargeScreen ? 0.9 : 1.0);

        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.grey[850],
          shape: (screenWidth > 1600)
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).colorScheme.warning, width: 1),
                )
              : RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Padding(
              padding: dialogPadding,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth>1400 ? 40 : 10),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [                              
                                  Icon(
                                    Icons.build_circle_outlined,
                                    size: isLargeScreen ? 34 : 30,
                                    color: Theme.of(context).colorScheme.warning,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n.changeProjectTypeTitle,
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 26 : 22,
                                      fontFamily: 'CascadiaCode',
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.warning,
                                    ),
                                  ),
                                ]
                              ),
                              const SizedBox(height: 4),
                              if (screenWidth > 700)...[
                                Row(
                                  children: [                              
                                    Text(
                                      currentStep == 1
                                        ? l10n.changeProjectTypeStepOneSubtitle
                                        : l10n.changeProjectTypeStepTwoSubtitle,
                                      style: TextStyle(
                                        fontSize: screenWidth > 1200 ? 22 : 18,
                                        fontFamily: 'CascadiaCode',
                                        fontWeight: FontWeight.normal,
                                        color: Theme.of(context).colorScheme.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: screenWidth > 700 ? 12 : 6),
                        Divider(color: Theme.of(context).colorScheme.warning),

                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth > 700 ? 15 : 5),
                            child: _buildCurrentStep(),
                          ),
                        ),

                        SizedBox(height: screenWidth > 700 ? 12 : 4),
                        _buildBottomButtons(),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.muted),
                      tooltip: l10n.buttonClose,
                      onPressed: () => {
                        if (currentStep != 3) {
                          Navigator.of(context).pop()
                        }
                      }
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStep() {
    final l10n = AppLocalizations.of(context)!;
    switch (currentStep) {
      case 1:
        return StepProjectTypeSelection(
          projectType: widget.project.type,
          onSelectionChanged: (newProjectType) {
            setState(() {
              currentProjectType = newProjectType;
            });
          },
        );
      case 2:
        return StepProjectTypeSelectionConfirmation(
          currentProjectType: widget.project.type,
          newProjectType: currentProjectType,
        );
      case 3:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: _SpotCloud(
                  animation: _rotationController,
                  color: Theme.of(context).colorScheme.warning,
                ),
              ),
              SizedBox(height: 20),
              Text(
                l10n.changeProjectTypeMigrating,
                style: TextStyle(color: Theme.of(context).colorScheme.muted, fontSize: 18),
              ),
            ],
          ),
        );
      default:
        // Fallback for safety
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => {
            if (currentStep != 3) {
              Navigator.pop(context)
            }
          },
          child: Text(
            l10n.buttonCancel,
            style: TextStyle(
              color: Theme.of(context).colorScheme.muted,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ),
        Row(
          children: [
            if (currentStep == 2)
              TextButton(
                onPressed: () => setState(() => currentStep--),
                child: Text(
                  l10n.buttonBack,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.muted,
                    fontFamily: 'CascadiaCode',
                  ),
                ),
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: currentStep == 3 ? null : _handleStepButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Theme.of(context).colorScheme.warning, width: 2),
                ),
              ),
              child: Text(
                currentStep == 1 ? l10n.buttonNext : l10n.buttonConfirm,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleStepButtonPressed() async {
    final l10n = AppLocalizations.of(context)!;
    if (currentStep == 1) {
      if (currentProjectType != widget.project.type) {
        setState(() => currentStep = 2);
      }
    } else if (currentStep == 2) {
      // Step 2 confirmed – proceed to step 3: show mutation animation and start migration
      setState(() => currentStep = 3);
      _rotationController.repeat();

      try {
        final migrationFuture = ProjectTypeMigrator.migrateProjectType(
          project: widget.project,
          newProjectType: currentProjectType,
        );
        // Ensure the animation is visible at least 3 seconds
        final minDelay = Future.delayed(const Duration(seconds: 3));
        await Future.wait([migrationFuture, minDelay]);

        if (mounted) {
          _rotationController.stop();
          Navigator.of(context).pop('refresh');
        }

      } catch (e, stack) {
        debugPrint('Error during project type migration: $e');
        debugPrint(stack.toString());

        if (mounted) {
          _rotationController.stop();
          setState(() => currentStep = 2);
          Future.microtask(() {
            AlertErrorDialog.show(
              context,
              l10n.changeProjectTypeErrorTitle,
              l10n.changeProjectTypeErrorMessage,
              tips: l10n.changeProjectTypeErrorTips,
            );
          });
        }
      }
    }
  }
}


class _SpotCloud extends StatelessWidget {
  final Animation<double> animation;
  final Color color;

  const _SpotCloud({
    super.key,
    required this.animation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _SpotCloudPainter(
            t: animation.value,
            color: color,
          ),
        );
      },
    );
  }
}

class _SpotCloudPainter extends CustomPainter {
  final double t;
  final Color color;

  _SpotCloudPainter({
    required this.t,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;

    // Base parameters
    final baseRadius = s * 0.08;
    final globalScale = 0.95 + 0.15 * math.sin(2 * math.pi * t);

    // Shared paint with varying opacity per spot
    final paint = Paint()
      ..color = color.withOpacity(0.55)
      ..style = PaintingStyle.fill;

    // Center spot (breathes)
    final centerR = baseRadius * (1.2 + 0.4 * math.sin(2 * math.pi * (t + 0.07)));
    canvas.drawCircle(center, centerR * globalScale, paint);

    // Outer ring spots (mutate in size and orbit slightly)
    const int count = 10;
    for (int i = 0; i < count; i++) {
      final angle = i * (2 * math.pi / count) + (t * 0.6) * 2 * math.pi; // slow rotation
      final phase = t + i * 0.17;
      final ringR = s * (0.22 + 0.05 * math.sin(2 * math.pi * phase));
      final spotR = baseRadius * (0.7 + 0.6 * math.sin(2 * math.pi * (phase + 0.33)));
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * ringR * globalScale;

      final localOpacity = 0.35 + 0.25 * (0.5 + 0.5 * math.sin(2 * math.pi * (phase + 0.5)));
      final p = paint..color = color.withOpacity(localOpacity.clamp(0.2, 0.9));
      canvas.drawCircle(pos, spotR.abs() * globalScale, p);
    }

    // Inner orbiters for richness
    const int innerCount = 6;
    for (int i = 0; i < innerCount; i++) {
      final angle = i * (2 * math.pi / innerCount) - (t * 1.0) * 2 * math.pi; // counter-rotation
      final phase = t + i * 0.29 + 0.13;
      final ringR = s * (0.12 + 0.03 * math.sin(2 * math.pi * phase));
      final spotR = baseRadius * (0.5 + 0.45 * math.sin(2 * math.pi * (phase + 0.2)));
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * ringR * globalScale;

      final localOpacity = 0.3 + 0.3 * (0.5 + 0.5 * math.sin(2 * math.pi * phase));
      final p = paint..color = color.withOpacity(localOpacity.clamp(0.2, 0.8));
      canvas.drawCircle(pos, spotR.abs() * globalScale, p);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotCloudPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.color != color;
  }
}
