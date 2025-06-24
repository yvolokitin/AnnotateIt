import 'package:flutter/material.dart';
import '../../models/label.dart';

class AnnotatorLabels extends StatelessWidget {
  final List<Label> labels;
  final ValueChanged<Label>? onLabelSelected;

  const AnnotatorLabels({
    super.key,
    required this.labels,
    this.onLabelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const spacing = 8.0;
        const runSpacing = 4.0;

        double usedWidth = 0;
        final moreChipWidth = _measureTextWidth('More', size: 20) + 40;
        final List<Widget> visibleChips = [];
        final List<Label> overflowLabels = [];

        for (int i = 0; i < labels.length; i++) {
          final label = labels[i];
          final chipWidth = _estimateChipWidth(label, size: 20);

          final remaining = labels.length - i;
          final shouldReserveForMore = remaining > 1;
          final projectedUsed = usedWidth + chipWidth + spacing;
          final projectedWithMore = projectedUsed + (shouldReserveForMore ? moreChipWidth + spacing : 0);

          if (projectedWithMore < availableWidth) {
            visibleChips.add(_buildChip(context, label));
            usedWidth = projectedUsed;
          } else {
            overflowLabels.addAll(labels.sublist(i));
            break;
          }
        }

        if (overflowLabels.isNotEmpty) {
          visibleChips.add(_buildMoreDropdown(context, overflowLabels));
        }

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: visibleChips,
        );
      },
    );
  }

Widget _buildChip(BuildContext context, Label label) {
  final isLong = label.name.length > 15;
  final displayName = isLong ? '${label.name.substring(0, 15)}…' : label.name;

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () {
        if (onLabelSelected != null) {
          onLabelSelected!(label);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.white24,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (onLabelSelected != null) {
              onLabelSelected!(label);
            }
          },
          splashColor: Colors.white24,
          borderRadius: BorderRadius.circular(6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: label.toColor(),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Tooltip(
                message: label.name,
                child: Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildMoreDropdown(BuildContext context, List<Label> hiddenLabels) {
  return PopupMenuButton<Label>(
    tooltip: 'More',
    color: Colors.grey[850],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: Colors.white24, width: 1),
    ),
    itemBuilder: (context) {
      final List<PopupMenuEntry<Label>> items = [];

      for (int i = 0; i < hiddenLabels.length; i++) {
        final label = hiddenLabels[i];

        items.add(
          PopupMenuItem<Label>(
            value: label,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: label.toColor(),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Tooltip(
                  message: label.name,
                  child: SizedBox(
                    width: 160,
                    child: Text(
                      label.name.length > 15
                          ? '${label.name.substring(0, 15)}…'
                          : label.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        if (i != hiddenLabels.length - 1) {
          items.add(const PopupMenuDivider(height: 1));
        }
      }

      return items;
    },
    onSelected: (Label label) {
      if (onLabelSelected != null) {
        onLabelSelected!(label);
      }
    },
    child: Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('More', style: TextStyle(color: Colors.white, fontSize: 20)),
          SizedBox(width: 6),
          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
        ],
      ),
    ),
  );
}

  static double _estimateChipWidth(Label label, {required double size}) {
    final isLong = label.name.length > 15;
    final truncated = isLong ? '${label.name.substring(0, 15)}…' : label.name;

    final textWidth = _measureTextWidth(truncated, size: size);

    // 40 (padding) + 16 (color) + 6 (margin) + text + 2 (border)
    return 40 + 16 + 6 + textWidth + 2;
  }

  static double _measureTextWidth(String text, {required double size}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}
