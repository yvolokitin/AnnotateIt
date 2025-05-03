import 'package:flutter/material.dart';
import 'dataset_step_label.dart';

class DatasetStepProgressBar extends StatelessWidget {
  const DatasetStepProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: const [
          DatasetStepLabel(number: 1, title: "Dataset selection", active: true),
          Expanded(child: Divider(color: Colors.white38)),
          DatasetStepLabel(number: 2, title: "Domain"),
          Expanded(child: Divider(color: Colors.white38)),
          DatasetStepLabel(number: 3, title: "Labels"),
        ],
      ),
    );
  }
}
