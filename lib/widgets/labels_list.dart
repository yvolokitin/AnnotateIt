import 'package:flutter/material.dart';
import '../models/label.dart';

class LabelList extends StatelessWidget {
  final List<Label> labels;

  const LabelList({Key? key, required this.labels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        const spacing = 8.0;
        const runSpacing = 4.0;
        const fontSize = 18.0;

        double usedWidth = 0;
        final moreChipWidth = _measureTextWidth('+ more...', fontSize: fontSize) + 24;
        final List<Widget> visibleChips = [];

        for (int i = 0; i < labels.length; i++) {
          final label = labels[i];
          final chipWidth = _estimateChipWidth(label, fontSize: fontSize);

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
              onTap: () => _showAllLabelsDialog(context, labels),
              child: Chip(
                label: const Text('+ more...'),
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
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: _fromHex(label.color),
              shape: BoxShape.circle,
            ),
          ),
          Text(
            label.name,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  void _showAllLabelsDialog(BuildContext context, List<Label> labels) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('All Labels'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: labels.map(_buildChip).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static double _estimateChipWidth(Label label, {required double fontSize}) {
    final labelWidth = _measureTextWidth(label.name, fontSize: fontSize);
    return labelWidth + 42; // 16px color circle + 6 margin + ~20 padding
  }

  static double _measureTextWidth(String text, {required double fontSize}) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  static Color _fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('FF');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
