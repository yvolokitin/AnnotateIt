import 'package:flutter/material.dart';

import '../../models/label.dart';
import 'labels_details.dart';

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
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => AllLabelsDialog(
                  labels: labels ?? [],
                  projectTitle: projectName,
                  iconPath: iconPath,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+ more...',
                    style: TextStyle(color: Colors.white70, fontSize: fontLabelSize),
                  ),
                ],
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
              shape: BoxShape.circle,
            ),
          ),
          Text(
            label.name,
            style: TextStyle(color: Colors.white, fontSize: fontLabelSize),
          ),
        ],
      ),
    );
  } 

  static double _estimateChipWidth(Label label, {required double size}) {
    final labelWidth = _measureTextWidth(label.name, size: size);
    // return labelWidth + 42; // 16px color circle + 6 margin + ~20 padding
    return labelWidth + 16 + 6 + 8; // circle + margin + spacing
  }

  static double _measureTextWidth(String text, {required double size}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: size)),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }
}
