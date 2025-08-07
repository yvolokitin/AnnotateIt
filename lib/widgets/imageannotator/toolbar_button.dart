import 'package:flutter/material.dart';
import 'constants.dart';

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
        : (widget.isActive ? Colors.white : Constants.iconColor);

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
            width: Constants.buttonSize,
            height: Constants.buttonSize,
            margin: Constants.buttonMargin,
            decoration: BoxDecoration(
              color: _isPressed
                  ? Constants.activeBackgroundColor
                  : widget.isActive
                      ? Colors.grey[850]
                      : _isHovered
                          ? Colors.grey[850]
                          : Colors.transparent,
              borderRadius: Constants.buttonBorderRadius,
            ),
            child: Center(
              child: widget.child ?? (widget.icon is Icon 
                ? Icon(
                    (widget.icon as Icon).icon,
                    color: iconColor,
                    size: Constants.iconSize,
                  )
                : widget.icon),
            ),
          ),
        ),
      ),
    );
  }
}