import 'package:flutter/material.dart';

import '../../../gen_l10n/app_localizations.dart';
import '../../project_creation_from_dataset/dataset_task_type_grid.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    return DatasetTaskTypeGrid(
      selectedTaskType: selectedTaskType,
      onTaskSelected: onSelected,
      tasks: [
        {
          'title': l10n.projectTypeInstanceSegmentation,
          'description': l10n.projectTypeInstanceSegmentationDescription,
          'image': 'assets/images/instance_segmentation.jpg',
        },
        {
          'title': l10n.projectTypeSemanticSegmentation,
          'description': l10n.projectTypeSemanticSegmentationDescription,
          'image': 'assets/images/semantic_segmentation.jpg',
        },
      ],
    );
  }
}
