import 'package:flutter/material.dart';

import '../../models/label.dart';

class LabelList extends StatelessWidget {
  final List<Label> labels;
  final String projectName;
  final String iconPath;
  final double fontLabelSize;

  final Color chipBackgroundColor;

  const LabelList({
    super.key,
    required this.labels,
    required this.projectName,
    required this.iconPath,
    required this.fontLabelSize,
    this.chipBackgroundColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const spacing = 8.0;
        const runSpacing = 4.0;

        double usedWidth = 0;
        final moreChipWidth = _measureTextWidth('+ more...', size: fontLabelSize) + 24;
        final List<Widget> visibleChips = [];

        for (int i = 0; i < labels.length; i++) {
          final label = labels[i];
          final chipWidth = _estimateChipWidth(label, size: fontLabelSize);

          final remaining = labels.length - i;
          final shouldReserveForMore = remaining > 1;
          final projectedUsed = usedWidth + chipWidth + spacing;
          final projectedWithMore = projectedUsed + (shouldReserveForMore ? moreChipWidth + spacing : 0);

          if (projectedWithMore < availableWidth) {
            visibleChips.add(_buildChip(label));
            usedWidth = projectedUsed;
          } else {
            break;
          }
        }

        if (visibleChips.length < labels.length) {
          visibleChips.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: chipBackgroundColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '+ more...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: fontLabelSize,
                  fontFamily: 'CascadiaCode',
                ),
              ),
            ),
          );
        }

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: visibleChips,
        );
      },
    );
  }

  Widget _buildChip(Label label) {
    final isLong = label.name.length > 15;
    final displayName = isLong ? '${label.name.substring(0, 15)}…' : label.name;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: chipBackgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
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
              style: TextStyle(
                color: Colors.white,
                fontSize: fontLabelSize,
                fontFamily: 'CascadiaCode',
              ),
            ),
          ),
        ],
      ),
    );
  }

  static double _estimateChipWidth(Label label, {required double size}) {
    final isLong = label.name.length > 15;
    final truncated = isLong ? '${label.name.substring(0, 15)}…' : label.name;
    final textWidth = _measureTextWidth(truncated, size: size);

    return 40 + 16 + 6 + textWidth + 2;
  }

  static double _measureTextWidth(String text, {required double size}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size, fontFamily: 'CascadiaCode',)),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}
