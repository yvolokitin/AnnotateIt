import 'package:flutter/material.dart';

import '../../models/annotation.dart';
import '../../models/label.dart';

import 'label_dropdown.dart';

class AnnotatedListItem extends StatelessWidget {
  final Annotation annotation;
  final bool isSelected;
  final bool isHovered;
  final VoidCallback onTap;
  final Function(Label) onLabelChanged;
  final Function(Annotation) onDelete;
  final ThemeData theme;
  final List<Label> availableLabels;

  const AnnotatedListItem({
    super.key,
    required this.annotation,
    required this.isSelected,
    required this.isHovered,
    required this.onTap,
    required this.onLabelChanged,
    required this.onDelete,
    required this.theme,
    required this.availableLabels,
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Row(
              children: [
                // Color indicator
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: annotation.color ?? Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                    // shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                // Annotation label
                Expanded(
                  child: Text(
                    annotation.name ?? 'Unknown',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Action buttons - now only shown when isSelected is true
                if (isSelected)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LabelDropdown(
                        key: ValueKey('label_dropdown_${annotation.id}'),
                        currentLabel: availableLabels.firstWhere(
                          (label) => label.id == annotation.labelId,
                          orElse: () => Label(
                            labelOrder: 0,
                            projectId: 0,
                            name: 'No label selected',
                            color: '#000000',
                          ),
                        ),
                        availableLabels: availableLabels,
                        onLabelSelected: (newLabel) {
                          onLabelChanged(newLabel);
                        },
                        theme: theme,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        color: Colors.white70,
                        onPressed: () => onDelete(annotation),
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
