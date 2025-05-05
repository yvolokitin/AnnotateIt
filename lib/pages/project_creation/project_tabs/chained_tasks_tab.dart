import 'package:flutter/material.dart';
import '../../../widgets/create_project_dialog_task.dart';

class ChainedTasksTab extends StatelessWidget {
  final String selectedTaskType;
  final ValueChanged<String> onSelected;

  const ChainedTasksTab({
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
          'title': 'Detection -> Classification',
          'description': 'Detect objects using bounding boxes followed by classification.',
          'image': 'assets/images/detection_to_classification.png',
        },
        {
          'title': 'Detection -> Segmentation',
          'description': 'Detect objects using bounding boxes followed by segmentation.',
          'image': 'assets/images/detection_to_segmentation.png',
        },
      ],
    );
  }
}
