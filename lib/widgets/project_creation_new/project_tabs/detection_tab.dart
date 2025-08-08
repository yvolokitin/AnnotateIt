import 'package:flutter/material.dart';

import '../../../gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    
    return DatasetTaskTypeGrid(
      selectedTaskType: selectedTaskType,
      onTaskSelected: onSelected,
      tasks: [
        {
          'title': l10n.projectTypeDetectionBoundingBox,
          'description': l10n.projectTypeDetectionBoundingBoxDescription,
          'image': 'assets/images/detection_bounding_box.jpg',
        },
        {
          'title': l10n.projectTypeDetectionOriented,
          'description': l10n.projectTypeDetectionOrientedDescription,
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
