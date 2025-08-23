import 'dart:math';
import 'package:flutter/material.dart';

/// An overlay that reveals the underlying UI using randomly-sized "puzzle" tiles.
///
/// It covers the full screen with a tiling of rectangles and then animates
/// them out (fade + slight scale) in a staggered order to reveal the content.
class PuzzleRevealOverlay extends StatefulWidget {
  const PuzzleRevealOverlay({super.key,
    this.overallDuration = const Duration(milliseconds: 1300),
    this.minCols = 5,
    this.maxCols = 9,
    this.minRows = 3,
    this.maxRows = 6,
    this.tileColor,
    this.curve = Curves.easeOutCubic,
  });

  /// Total duration of the reveal animation.
  final Duration overallDuration;

  /// Min/max number of columns and rows. Actual tiling will be random in range.
  final int minCols;
  final int maxCols;
  final int minRows;
  final int maxRows;

  /// Optional tile color. If null, uses Theme.of(context).colorScheme.background
  /// fallback to Colors.black.
  final Color? tileColor;

  final Curve curve;

  @override
  State<PuzzleRevealOverlay> createState() => _PuzzleRevealOverlayState();
}

class _PuzzleRevealOverlayState extends State<PuzzleRevealOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Random _rnd;

  // Computed once per layout size
  List<_TileDesc>? _tiles;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.overallDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          // Mark done so we stop building overlay entirely
          if (mounted) {
            setState(() => _done = true);
          }
        }
      });
    _rnd = Random();

    // Defer starting the animation until after first layout so tiles can be generated.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Start after a tiny delay to avoid jank on very first frame
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) _controller.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();

    return IgnorePointer(
      // Let interactions pass through during the animation to avoid blocking tests/user
      ignoring: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          if (w.isInfinite || h.isInfinite || w == 0 || h == 0) {
            return const SizedBox.shrink();
          }

          // Generate tiles once for this size
          _tiles ??= _generateTiles(w, h);

          final color = widget.tileColor ?? Theme.of(context).colorScheme.background;
          final effectiveColor = color == Colors.transparent ? Colors.black : color;

          return Stack(
            fit: StackFit.expand,
            children: [
              ..._tiles!.map((t) {
                // Create a curved, staggered animation per tile
                final start = t.intervalStart;
                final end = t.intervalEnd;
                final anim = CurvedAnimation(
                  parent: _controller,
                  curve: Interval(start, end, curve: widget.curve),
                );
                // Opacity goes from 1 to 0; scale from 1 to ~0.9 for a subtle effect
                final opacity = Tween<double>(begin: 1.0, end: 0.0).animate(anim);
                final scale = Tween<double>(begin: 1.0, end: 0.92).animate(anim);

                return Positioned(
                  left: t.left,
                  top: t.top,
                  width: t.width,
                  height: t.height,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return Opacity(
                        opacity: opacity.value.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: scale.value,
                          alignment: Alignment.center,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: effectiveColor,
                              border: Border.all(
                                color: effectiveColor.withOpacity(0.9),
                                width: 0.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  List<_TileDesc> _generateTiles(double totalW, double totalH) {
    // Choose random counts within bounds
    final cols = _rnd.nextInt(widget.maxCols - widget.minCols + 1) + widget.minCols; // [minCols, maxCols]
    final rows = _rnd.nextInt(widget.maxRows - widget.minRows + 1) + widget.minRows; // [minRows, maxRows]

    // Random weights for columns and rows, then normalize to full size
    final colWeights = List<double>.generate(cols, (_) => 0.65 + _rnd.nextDouble());
    final rowWeights = List<double>.generate(rows, (_) => 0.65 + _rnd.nextDouble());

    final colSum = colWeights.fold<double>(0.0, (s, v) => s + v);
    final rowSum = rowWeights.fold<double>(0.0, (s, v) => s + v);

    final colWidths = colWeights.map((w) => totalW * (w / colSum)).toList();
    final rowHeights = rowWeights.map((w) => totalH * (w / rowSum)).toList();

    // Compute edges
    final colLefts = <double>[];
    double x = 0;
    for (final cw in colWidths) {
      colLefts.add(x);
      x += cw;
    }

    final rowTops = <double>[];
    double y = 0;
    for (final rh in rowHeights) {
      rowTops.add(y);
      y += rh;
    }

    // Create tile descriptors for each grid cell with randomized intervals
    final tiles = <_TileDesc>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final left = colLefts[c];
        final top = rowTops[r];
        final width = colWidths[c];
        final height = rowHeights[r];

        // Stagger intervals: start anywhere in [0.0, 0.7], last ~30% reserved for finishing
        final start = _rnd.nextDouble() * 0.7;
        final span = 0.2 + _rnd.nextDouble() * 0.2; // 0.2..0.4 of total duration
        final end = (start + span).clamp(0.0, 0.98);

        tiles.add(_TileDesc(
          left: left,
          top: top,
          width: width,
          height: height,
          intervalStart: start,
          intervalEnd: end,
        ));
      }
    }

    // Optional: randomize order to avoid row/col pattern
    tiles.shuffle(_rnd);

    return tiles;
  }
}

class _TileDesc {
  final double left;
  final double top;
  final double width;
  final double height;
  final double intervalStart;
  final double intervalEnd;

  _TileDesc({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.intervalStart,
    required this.intervalEnd,
  });
}
