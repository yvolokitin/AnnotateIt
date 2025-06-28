import 'package:flutter/material.dart';
import '../../models/label.dart';

class LabelDropdown extends StatefulWidget {
  final Label currentLabel;
  final List<Label> availableLabels;
  final Function(Label) onLabelSelected;
  final ThemeData theme;

  const LabelDropdown({
    super.key,
    required this.currentLabel,
    required this.availableLabels,
    required this.onLabelSelected,
    required this.theme,
  });

  @override
  State<LabelDropdown> createState() => _LabelDropdownState();
}

class _LabelDropdownState extends State<LabelDropdown> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Label>(
      icon: Icon(
        Icons.label_outline,
        size: 18,
        color: widget.theme.hintColor,
      ),
      tooltip: 'Change label',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      position: PopupMenuPosition.over,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: widget.theme.dividerColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.grey[850],
      onSelected: (label) {
        if (mounted) {
          widget.onLabelSelected(label);
        }
      },
      itemBuilder: (context) {
        if (!mounted) return const [];
        
        return widget.availableLabels.map((label) {
          return PopupMenuItem<Label>(
            value: label,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: label.toColor(),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: widget.theme.dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                Text(
                  label.name,
                  style: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
