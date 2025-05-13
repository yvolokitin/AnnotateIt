import 'package:flutter/material.dart';

import '../../../widgets/project_creation/dataset_task_type_grid.dart';

class ClassificationTab extends StatelessWidget {
  final String selectedTaskType;
  final ValueChanged<String> onSelected;

  const ClassificationTab({
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
          'title': 'Binary Classification',
          'description': 'Assign one of two possible labels to each input (e.g., spam or not spam, positive or negative).',
          'image': 'assets/images/classification_binary.jpg',
        },
        {
          'title': 'Multi-class Classification',
          'description': 'Assign exactly one label from a set of mutually exclusive classes (e.g., cat, dog, or bird).',
          'image': 'assets/images/classification_multi_class.jpg',
        },
        {
          'title': 'Multi-label Classification',
          'description': 'Assign one or more labels from a set of classes — multiple labels can apply at the same time (e.g., an image tagged as both "cat" and "dog")',
          'image': 'assets/images/anomaly_detection.jpg', // 'assets/images/classification_multi_label.jpg',
        },
        {
          'title': 'Hierarchical Classification',
          'description': 'Assign labels from a hierarchy of classes, where categories are organized in multiple levels (e.g., Animal → Mammal → Dog).',
          'image': 'assets/images/classification_hierarchical.png',
        },
      ],
    );
  }
}
