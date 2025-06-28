import 'package:flutter/material.dart';
import '../../models/annotation.dart';

class AnnotatedListItem extends StatelessWidget {
  final Annotation annotation;
  final bool isSelected;
  final bool isHovered;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ThemeData theme;

  const AnnotatedListItem({
    super.key,
    required this.annotation,
    required this.isSelected,
    required this.isHovered,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final textColor = isSelected ? colorScheme.primary : colorScheme.onSurface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.1)
            : isHovered
                ? theme.hoverColor
                : Colors.transparent,
        border: isSelected
            ? Border(
                left: BorderSide(
                  color: colorScheme.primary,
                  width: 3,
                ),
              )
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Color indicator
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: annotation.color ?? colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                // Annotation label
                Expanded(
                  child: Text(
                    annotation.name ?? 'Unnamed Annotation',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Action buttons
                if (isHovered || isSelected)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        color: theme.hintColor,
                        onPressed: onEdit,
                        tooltip: 'Edit annotation',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: theme.colorScheme.error,
                        onPressed: onDelete,
                        tooltip: 'Delete annotation',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}