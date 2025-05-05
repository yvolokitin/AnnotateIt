import 'package:flutter/material.dart';
import '../../../widgets/project_creation/task_type_grid.dart';

class DetectionTab extends StatelessWidget {
  final String selectedTaskType;
  final ValueChanged<String> onSelected;

  const DetectionTab({
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
          'title': 'Detection bounding box',
          'description': 'Draw a rectangle around an object in an image.',
          'image': 'assets/images/detection_bounding_box.jpg',
        },
        {
          'title': 'Detection oriented',
          'description': 'Draw and enclose an object within a minimal rectangle.',
          'image': 'assets/images/detection_oriented.jpg',
        },
      ],
    );
  }
}
