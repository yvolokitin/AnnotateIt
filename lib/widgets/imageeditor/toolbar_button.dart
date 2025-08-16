import 'package:flutter/material.dart';

class ToolbarButton extends StatefulWidget {
  final Widget? icon;
  final Widget? child;
  final VoidCallback? onTap;
  final bool isActive;
  final bool showActiveState;
  final String? tooltip;
  final bool isDisabled;

  const ToolbarButton({
    super.key,
    this.icon,
    this.child,
    this.onTap,
    this.isActive = false,
    this.showActiveState = true,
    this.tooltip,
    this.isDisabled = false,
  }) : assert(icon != null || child != null, 'Either icon or child must be provided');

  @override
  State<ToolbarButton> createState() => _ToolbarButtonState();
}

class _ToolbarButtonState extends State<ToolbarButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.onTap != null && !widget.isDisabled;
    final Color iconColor = widget.isDisabled 
        ? Colors.white38 
        : (widget.isActive ? Colors.white : Colors.white70);

    return MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => isInteractive ? setState(() => _isHovered = true) : null,
      onExit: (_) => isInteractive ? setState(() {
        _isHovered = false;
        _isPressed = false;
      }) : null,
      child: GestureDetector(
        onTapDown: isInteractive ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isInteractive ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isInteractive ? () => setState(() => _isPressed = false) : null,
        onTap: isInteractive ? widget.onTap : null,
        child: Tooltip(
          message: widget.tooltip ?? '',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 48,
            height: 48,
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _isPressed
                  ? Colors.brown[900] // Color(0xFF424242)
                  : widget.isActive
                      ? Colors.brown[900]
                      : _isHovered
                          ? Colors.brown[900]
                          : Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
            child: Center(
              child: widget.child ?? _buildVisual(iconColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisual(Color iconColor) {
    // If child is provided, build method won't call this.
    final w = widget.icon;
    if (w == null) {
      return const SizedBox.shrink();
    }

    if (w is Icon) {
      // Rebuild Icon to enforce consistent color/size styling for toolbar
      return Icon(
        w.icon,
        color: w.color ?? iconColor,
        size: w.size ?? 28,
      );
    }

    // For arbitrary widgets (e.g., progress indicator), just apply IconTheme so it can
    // pick up size/color if it respects IconTheme; otherwise keep its own visuals.
    return IconTheme(
      data: IconThemeData(color: iconColor, size: 28),
      child: w,
    );
  }
}