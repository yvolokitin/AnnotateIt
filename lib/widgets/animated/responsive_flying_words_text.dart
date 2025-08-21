import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// A responsive text widget that animates each word flying in from
/// random directions when it first appears.
class ResponsiveFlyingWordsText extends StatefulWidget {
  final String text;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final double? maxSize;
  final double? minSize;
  final double? breakpoint;
  final double? height;
  final Color? color;
  final TextStyle? style; // custom style override (same behavior as ResponsiveText)
  final String? themeStyle; // e.g. 'bodySmall', 'titleMedium', etc.

  // Animation config
  final Duration duration;
  final Duration initialDelay;
  final Duration perWordStagger;
  final Curve curve;

  const ResponsiveFlyingWordsText(
    this.text, {
    super.key,
    this.textAlign,
    this.fontWeight,
    this.maxSize = 20,
    this.minSize = 14,
    this.breakpoint = 1600,
    this.height,
    this.color,
    this.style,
    this.themeStyle = 'bodySmall',
    this.duration = const Duration(milliseconds: 650),
    this.initialDelay = const Duration(milliseconds: 80),
    this.perWordStagger = const Duration(milliseconds: 28),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<ResponsiveFlyingWordsText> createState() => _ResponsiveFlyingWordsTextState();
}

class _ResponsiveFlyingWordsTextState extends State<ResponsiveFlyingWordsText> {
  late final List<String> _words;
  late final List<Offset> _initialOffsets;
  late final List<bool> _visible;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _words = _tokenize(widget.text);

    // Create deterministic randomness so rebuilds keep the same directions.
    final rnd = Random(widget.text.hashCode);
    _initialOffsets = List.generate(_words.length, (i) {
      // Pick a base direction (left, right, up, down)
      final dir = rnd.nextInt(4);
      // Base magnitude between 30 and 80 logical pixels
      final mag = 30.0 + rnd.nextDouble() * 50.0;
      switch (dir) {
        case 0:
          return Offset(-mag, (rnd.nextDouble() - 0.5) * mag * 0.6);
        case 1:
          return Offset(mag, (rnd.nextDouble() - 0.5) * mag * 0.6);
        case 2:
          return Offset((rnd.nextDouble() - 0.5) * mag * 0.6, -mag);
        default:
          return Offset((rnd.nextDouble() - 0.5) * mag * 0.6, mag);
      }
    });
    _visible = List<bool>.filled(_words.length, false);

    // Schedule staggered reveals
    for (int i = 0; i < _words.length; i++) {
      final delay = widget.initialDelay + widget.perWordStagger * i;
      _timers.add(Timer(delay, () {
        if (!mounted) return;
        setState(() => _visible[i] = true);
      }));
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    super.dispose();
  }

  // Split text into words by whitespace.
  List<String> _tokenize(String input) {
    // Keep simple: split by whitespace; empty tokens removed.
    return input.split(RegExp(r"\s+")).where((w) => w.isNotEmpty).toList();
  }

  TextStyle _computeEffectiveStyle(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width >= (widget.breakpoint ?? 1600) ? (widget.maxSize ?? 20) : (widget.minSize ?? 14);

    // Base style from theme, mirroring ResponsiveText
    TextStyle baseStyle = switch (widget.themeStyle) {
      'bodyLarge' => Theme.of(context).textTheme.bodyLarge!,
      'bodyMedium' => Theme.of(context).textTheme.bodyMedium!,
      'bodySmall' => Theme.of(context).textTheme.bodySmall!,
      'titleLarge' => Theme.of(context).textTheme.titleLarge!,
      'titleMedium' => Theme.of(context).textTheme.titleMedium!,
      'titleSmall' => Theme.of(context).textTheme.titleSmall!,
      'labelSmall' => Theme.of(context).textTheme.labelSmall!,
      _ => Theme.of(context).textTheme.bodySmall!,
    };

    final effectiveStyle = baseStyle.copyWith(
      fontSize: fontSize,
      fontWeight: widget.fontWeight ?? baseStyle.fontWeight,
      color: widget.color ?? baseStyle.color,
      height: widget.height ?? baseStyle.height,
    );

    // If style override provided, use it directly to mirror ResponsiveText behavior
    return widget.style ?? effectiveStyle;
  }

  WrapAlignment _wrapAlignmentFromTextAlign(TextAlign? align) {
    switch (align) {
      case TextAlign.center:
        return WrapAlignment.center;
      case TextAlign.right:
      case TextAlign.end:
        return WrapAlignment.end;
      case TextAlign.left:
      case TextAlign.start:
      default:
        return WrapAlignment.start;
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _computeEffectiveStyle(context);

    return Semantics(
      label: widget.text,
      child: Wrap(
        alignment: _wrapAlignmentFromTextAlign(widget.textAlign),
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 8,
        children: List.generate(_words.length, (i) {
          final visible = _visible[i];
          final initialOffset = _initialOffsets[i];
          // AnimatedSlide expects offsets in fraction of self size, but we want pixel-based.
          // Use Transform.translate instead to move by pixels.
          return AnimatedOpacity(
            opacity: visible ? 1.0 : 0.0,
            duration: widget.duration,
            curve: widget.curve,
            child: _AnimatedTranslate(
              begin: initialOffset,
              end: Offset.zero,
              duration: widget.duration,
              curve: widget.curve,
              child: Text(
                _words[i],
                style: style,
              ),
              animate: visible,
            ),
          );
        }),
      ),
    );
  }
}

/// Lightweight animated translation by pixels using AnimatedWidget pattern.
class _AnimatedTranslate extends ImplicitlyAnimatedWidget {
  final Offset begin;
  final Offset end;
  final Widget child;
  final bool animate;

  const _AnimatedTranslate({
    required this.begin,
    required this.end,
    required this.child,
    required super.duration,
    required super.curve,
    required this.animate,
  });

  @override
  ImplicitlyAnimatedWidgetState<_AnimatedTranslate> createState() => _AnimatedTranslateState();
}

class _AnimatedTranslateState extends AnimatedWidgetBaseState<_AnimatedTranslate> {
  Tween<Offset>? _offsetTween;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    final target = widget.animate ? widget.end : widget.begin;
    _offsetTween = visitor(
      _offsetTween,
      target,
      (value) => Tween<Offset>(begin: value as Offset, end: target),
    ) as Tween<Offset>?;
  }

  @override
  Widget build(BuildContext context) {
    final offset = _offsetTween?.evaluate(animation) ?? widget.begin;
    return Transform.translate(
      offset: offset,
      child: widget.child,
    );
  }
}
