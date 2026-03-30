import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Shared toolbar button used by both the annotator and image editor.
///
/// Replaces the duplicate `ToolbarButton` widgets that existed in
/// `imageannotator/toolbar_button.dart` and `imageeditor/toolbar_button.dart`.
class AppToolbarButton extends StatefulWidget {
  final Widget? icon;
  final Widget? child;
  final VoidCallback? onTap;
  final bool isActive;
  final bool showActiveState;
  final String? tooltip;
  final bool isDisabled;
  final Color? activeColor;
  final BorderRadius borderRadius;

  const AppToolbarButton({
    super.key,
    this.icon,
    this.child,
    this.onTap,
    this.isActive = false,
    this.showActiveState = true,
    this.tooltip,
    this.isDisabled = false,
    this.activeColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
  }) : assert(icon != null || child != null, 'Either icon or child must be provided');

  @override
  State<AppToolbarButton> createState() => _AppToolbarButtonState();
}

class _AppToolbarButtonState extends State<AppToolbarButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = widget.onTap != null && !widget.isDisabled;
    final Color iconColor = widget.isDisabled
        ? Colors.white38
        : (widget.isActive ? Colors.white : Colors.white70);
    final Color fillColor = widget.activeColor ?? AppColors.darkCard;

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
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _isPressed || widget.isActive || _isHovered
                  ? fillColor
                  : Colors.transparent,
              borderRadius: widget.borderRadius,
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
    final w = widget.icon;
    if (w == null) return const SizedBox.shrink();

    if (w is Icon) {
      return Icon(
        w.icon,
        color: w.color ?? iconColor,
        size: w.size ?? 28,
      );
    }

    return IconTheme(
      data: IconThemeData(color: iconColor, size: 28),
      child: w,
    );
  }
}
