import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../controllers/timeline_controller.dart';
import '../../utils/theme.dart';

/// A horizontal timeline scrubber for frame-by-frame video navigation.
///
/// Shows the current frame position, keyframe markers, frame index,
/// and prev/next keyframe jump buttons. Integrates with [TimelineController].
///
/// Wrapped in a [RepaintBoundary] so scrubber repaints don't dirty the
/// parent annotation canvas or vice-versa.
class TimelineScrubber extends StatelessWidget {
  final TimelineController controller;

  const TimelineScrubber({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (!controller.hasFrames) return const SizedBox.shrink();
          return _TimelineBar(controller: controller);
        },
      ),
    );
  }
}

class _TimelineBar extends StatelessWidget {
  final TimelineController controller;

  const _TimelineBar({required this.controller});

  String _formatTime(double seconds) {
    final m = (seconds / 60).floor();
    final s = (seconds % 60).floor();
    final ms = ((seconds % 1) * 100).floor();
    return '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}.'
        '${ms.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final current = controller.currentFrame;
    final total = controller.totalFrames;
    final progress = total > 1 ? current / (total - 1) : 0.0;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: const Border(
          top: BorderSide(color: Colors.black, width: 1),
          bottom: BorderSide(color: Colors.black, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Prev keyframe
          _NavButton(
            icon: Icons.skip_previous_rounded,
            tooltip: 'Previous keyframe',
            onPressed: controller.jumpToPreviousKeyframe,
            enabled: !controller.isAtStart,
          ),
          // Prev frame
          _NavButton(
            icon: Icons.chevron_left_rounded,
            tooltip: 'Previous frame',
            onPressed: () => controller.previousFrame(),
            enabled: !controller.isAtStart,
          ),

          const SizedBox(width: 8),

          // Frame counter
          _FrameLabel(
            text: '${current + 1} / $total',
            isKeyframe: controller.isCurrentKeyframe,
          ),

          const SizedBox(width: 8),

          // Scrubber track
          Expanded(
            child: _ScrubberTrack(
              progress: progress,
              keyframeIndices: controller.keyframeIndices,
              totalFrames: total,
              onScrub: (value) {
                final idx = (value * (total - 1)).round();
                controller.jumpToFrame(idx);
              },
            ),
          ),

          const SizedBox(width: 8),

          // Timestamp
          Text(
            '${_formatTime(controller.currentTimestampSec)} / ${_formatTime(controller.durationSec)}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),

          const SizedBox(width: 8),

          // Next frame
          _NavButton(
            icon: Icons.chevron_right_rounded,
            tooltip: 'Next frame',
            onPressed: () => controller.nextFrame(),
            enabled: !controller.isAtEnd,
          ),
          // Next keyframe
          _NavButton(
            icon: Icons.skip_next_rounded,
            tooltip: 'Next keyframe',
            onPressed: controller.jumpToNextKeyframe,
            enabled: !controller.isAtEnd,
          ),

          const SizedBox(width: 4),

          // Show/hide interpolated toggle
          _InterpolatedToggle(
            active: controller.showInterpolated,
            onToggle: controller.toggleShowInterpolated,
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool enabled;

  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 24),
      color: enabled ? Colors.white70 : Colors.white24,
      tooltip: tooltip,
      onPressed: enabled ? onPressed : null,
      splashRadius: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

class _InterpolatedToggle extends StatelessWidget {
  final bool active;
  final VoidCallback onToggle;

  const _InterpolatedToggle({required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: active ? 'Hide interpolated' : 'Show interpolated',
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: active
                ? AppColors.accentOrange.withValues(alpha: 0.2)
                : Colors.white10,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: active
                  ? AppColors.accentOrange.withValues(alpha: 0.6)
                  : Colors.white24,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                active ? Icons.visibility : Icons.visibility_off,
                size: 14,
                color: active ? AppColors.accentOrange : Colors.white38,
              ),
              const SizedBox(width: 4),
              Text(
                'Interp',
                style: TextStyle(
                  fontSize: 11,
                  color: active ? AppColors.accentOrange : Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FrameLabel extends StatelessWidget {
  final String text;
  final bool isKeyframe;

  const _FrameLabel({required this.text, required this.isKeyframe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isKeyframe
            ? AppColors.accent.withValues(alpha: 0.25)
            : AppColors.darkCard,
        borderRadius: BorderRadius.circular(4),
        border: isKeyframe
            ? Border.all(color: AppColors.accent.withValues(alpha: 0.6), width: 1)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isKeyframe) ...[
            Icon(Icons.diamond_outlined, size: 12, color: AppColors.accent),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: isKeyframe ? AppColors.accent : Colors.white70,
              fontSize: 13,
              fontWeight: isKeyframe ? FontWeight.w600 : FontWeight.normal,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrubberTrack extends StatelessWidget {
  final double progress;
  final Set<int> keyframeIndices;
  final int totalFrames;
  final ValueChanged<double> onScrub;

  const _ScrubberTrack({
    required this.progress,
    required this.keyframeIndices,
    required this.totalFrames,
    required this.onScrub,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (details) {
            final value = (details.localPosition.dx / trackWidth).clamp(0.0, 1.0);
            onScrub(value);
          },
          onTapDown: (details) {
            final value = (details.localPosition.dx / trackWidth).clamp(0.0, 1.0);
            onScrub(value);
          },
          child: SizedBox(
            height: 28,
            width: trackWidth,
            child: CustomPaint(
              painter: _ScrubberPainter(
                progress: progress,
                keyframePositions: totalFrames > 1
                    ? keyframeIndices
                        .map((i) => i / (totalFrames - 1))
                        .toList()
                    : [],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScrubberPainter extends CustomPainter {
  final double progress;
  final List<double> keyframePositions;

  static final Paint _bgPaint = Paint()
    ..color = Colors.white12
    ..style = PaintingStyle.fill;

  static final Paint _fillPaint = Paint()
    ..color = AppColors.accent.withValues(alpha: 0.7)
    ..style = PaintingStyle.fill;

  static final Paint _kfPaint = Paint()
    ..color = AppColors.accentOrange
    ..style = PaintingStyle.fill;

  static final Paint _headOuterPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.fill;

  static final Paint _headInnerPaint = Paint()
    ..color = AppColors.accent
    ..style = PaintingStyle.fill;

  _ScrubberPainter({
    required this.progress,
    required this.keyframePositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final trackY = size.height / 2;
    const trackHeight = 4.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, trackY),
          width: size.width,
          height: trackHeight,
        ),
        const Radius.circular(2),
      ),
      _bgPaint,
    );

    final fillWidth = size.width * progress;
    if (fillWidth > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, trackY - trackHeight / 2, fillWidth, trackHeight),
          const Radius.circular(2),
        ),
        _fillPaint,
      );
    }

    for (final pos in keyframePositions) {
      final x = pos * size.width;
      const halfSize = 4.0;
      final path = Path()
        ..moveTo(x, trackY - halfSize)
        ..lineTo(x + halfSize, trackY)
        ..lineTo(x, trackY + halfSize)
        ..lineTo(x - halfSize, trackY)
        ..close();
      canvas.drawPath(path, _kfPaint);
    }

    final headX = size.width * progress;
    canvas.drawCircle(Offset(headX, trackY), 7, _headOuterPaint);
    canvas.drawCircle(Offset(headX, trackY), 4, _headInnerPaint);
  }

  @override
  bool shouldRepaint(_ScrubberPainter old) =>
      progress != old.progress ||
      !listEquals(keyframePositions, old.keyframePositions);
}
