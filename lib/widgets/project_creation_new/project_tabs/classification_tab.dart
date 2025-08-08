import 'package:flutter/material.dart';

import '../../../gen_l10n/app_localizations.dart';
import '../../project_creation_from_dataset/dataset_task_type_grid.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    return DatasetTaskTypeGrid(
      selectedTaskType: selectedTaskType,
      onTaskSelected: onSelected,
      tasks: [
        {
          'title': l10n.projectTypeBinaryClassification,
          'description': l10n.projectTypeBinaryClassificationDescription,
          'image': 'assets/images/classification_binary.jpg',
        },
        {
          'title': l10n.projectTypeMultiClassClassification,
          'description': l10n.projectTypeMultiClassClassificationDescription,
          'image': 'assets/images/classification_multi_class.jpg',
        },
        {
          'title': l10n.projectTypeMultiLabelClassification,
          'description': l10n.projectTypeMultiLabelClassificationDescription,
          'image': 'assets/images/anomaly_detection.jpg', // 'assets/images/classification_multi_label.jpg',
        },
        /*
        not implemented yet
        {
          'title': 'Hierarchical Classification',
          'description': 'Assign labels from a hierarchy of classes, where categories are organized in multiple levels (e.g., Animal → Mammal → Dog).',
          'image': 'assets/images/classification_hierarchical.png',
        },*/
      ],
    );
  }
}
