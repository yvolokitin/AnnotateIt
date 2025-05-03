import 'package:flutter/material.dart';

class DatasetStepLabel extends StatelessWidget {
  final int number;
  final String title;
  final bool active;

  const DatasetStepLabel({
    super.key,
    required this.number,
    required this.title,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: active ? Colors.white : Colors.white38,
          child: Text(
            number.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: active ? Colors.black : Colors.white70,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : Colors.white54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
