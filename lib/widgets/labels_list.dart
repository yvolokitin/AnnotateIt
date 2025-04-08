import 'package:flutter/material.dart';
import '../models/label.dart';

class LabelList extends StatefulWidget {
  final List<Label> labels;

  const LabelList({
    required this.labels,
    super.key,
  });

  @override
  LabelListState createState() => LabelListState();
}

class LabelListState extends State<LabelList> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final labelsToShow;
    final int toTake;

    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1600) {
      toTake = 13;
    } else if (screenWidth > 980) {
      toTake = 7;
    } else {
      toTake = 3;
    }

    labelsToShow = _showAll
        ? widget.labels
        : widget.labels.take(toTake).toList();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...labelsToShow.map((label) => _buildLabel(label)),

        if (!_showAll && widget.labels.length > toTake)
          GestureDetector(
            onTap: () {
              setState(() {
                _showAll = true;
              });
            },
            child: Chip(
              label: Text('+ more...'),
            ),
          ),
      ],
    );
  }

  Widget _buildLabel(Label label) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: _fromHex(label.color),
              shape: BoxShape.circle,
            ),
          ),
          Text(
            label.name,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Color _fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('FF');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
