import 'package:flutter/material.dart';

import '../../../widgets/project_creation/dataset_task_type_grid.dart';

class SegmentationTab extends StatelessWidget {
  final String selectedTaskType;
  final ValueChanged<String> onSelected;

  const SegmentationTab({
    super.key,
    required this.selectedTaskType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return TaskTypeGrid(
      selectedTaskType: selectedTaskType,
      onTaskSelected: onSelected,
      tasks: const [
        {
          'title': 'Instance Segmentation',
          'description': 'Detect and distinguish each individual object based on its unique features.',
          'image': 'assets/images/instance_segmentation.jpg',
        },
        {
          'title': 'Semantic Segmentation',
          'description': 'Detect and classify all similar objects as a single entity.',
          'image': 'assets/images/semantic_segmentation.jpg',
        },
      ],
    );
  }
}
