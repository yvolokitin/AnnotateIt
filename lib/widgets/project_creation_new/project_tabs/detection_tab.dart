import 'package:flutter/material.dart';

import '../../project_creation_from_dataset/dataset_task_type_grid.dart';

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
        /*
        need to think if this is needed since binary classification probably doing exactly the same
        {
          'title': 'Anomaly Detection',
          'description': 'Categorize images as normal or anomalous.',
          'image': 'assets/images/anomaly_detection.jpg',
        },*/
      ],
    );
  }
}
