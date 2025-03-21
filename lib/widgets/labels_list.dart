import 'package:flutter/material.dart';

class LabelList extends StatefulWidget {
  final List<String> labels;
  final List<String> labelColors;

  // const LabelList({required this.labels, required this.labelColors});
  LabelList({
    required this.labels,
    required this.labelColors,
    super.key,
  }) {
    if (labels.length != labelColors.length) {
      debugPrint("Warning: labels and labelColors have different lengths! Adjusting...");
      // debugPrint('🔹 labels (${labels.length} items): $labels');
      // debugPrint('🔸 labelColors (${labelColors.length} items): $labelColors');
    }
  }
  
  @override
  _LabelListState createState() => _LabelListState();
}

class _LabelListState extends State<LabelList> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final labelsToShow = _showAll ? widget.labels : widget.labels.take(13).toList();

    // If somehow labelColors has less size then labels -> fix it to make app more rubost
    final adjustedLabelColors = List<String>.generate(
      widget.labels.length,
      (index) =>
          index < widget.labelColors.length ? widget.labelColors[index] : '#AAAAAA', // Серый цвет по умолчанию
    );

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...labelsToShow.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final color = adjustedLabelColors[index]; // widget.labelColors[index];
          return _buildLabel(label, color);
        }),

        if (!_showAll && widget.labels.length > 13)
          GestureDetector(
            onTap: () {
              setState(() {
                _showAll = true;
              });
            },
            child: Chip(
              label: Text('+ more...'),
              // backgroundColor: Colors.grey[700],
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(String label, String color) {
    return Chip(
      // backgroundColor: Colors.grey[700],
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: _fromHex(color),
              shape: BoxShape.circle,
            ),
          ),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }

  Color _fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('FF'); // default alpha
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
