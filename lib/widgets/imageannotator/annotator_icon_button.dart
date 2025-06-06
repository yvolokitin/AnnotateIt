import 'package:flutter/material.dart';

class AnnotatorIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final double size;

  const AnnotatorIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 42,
  });

  @override
  State<AnnotatorIconButton> createState() => _AnnotatorIconButtonState();
}

class _AnnotatorIconButtonState extends State<AnnotatorIconButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: widget.size,
            height: widget.size,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _hovered ? Colors.grey[850] : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: widget.icon,
          ),
        ),
      ),
    );
  }
}
