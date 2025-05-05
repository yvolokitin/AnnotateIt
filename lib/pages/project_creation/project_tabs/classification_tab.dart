import 'package:flutter/material.dart';
import '../../../widgets/create_project_dialog_task.dart';

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
          'title': 'Classification single label',
          'description': 'Assign a label out of mutually exclusive labels.',
          'image': 'assets/images/classification_single.png',
        },
        {
          'title': 'Classification multi label',
          'description': 'Assign label(s) out of non-mutually exclusive labels.',
          'image': 'assets/images/classification_multi.png',
        },
        {
          'title': 'Classification hierarchical',
          'description': 'Assign label(s) with a hierarchical label structure.',
          'image': 'assets/images/classification_hierarchical.png',
        },
      ],
    );
  }
}
