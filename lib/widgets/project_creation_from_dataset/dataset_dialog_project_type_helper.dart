import 'package:flutter/material.dart';

class DatasetImportProjectTypeHelper extends StatelessWidget {
  const DatasetImportProjectTypeHelper({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text(
        'Project Type Selection Help',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Why are some project types disabled?',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'When you import a dataset, the system analyzes the provided annotations and tries to detect the most suitable project type for you automatically.\n\n'
              'For example, if your dataset contains bounding box annotations, the suggested project type will be "Detection". If it contains masks, "Segmentation" will be suggested, and so on.\n\n'
              'To protect your data, only compatible project types are enabled by default.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              'What happens if I enable project type change?',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'If you toggle "Allow Project Type Change", you can manually select ANY project type, even if it does not match the detected annotations.\n\n'
              '⚠️ WARNING: All existing annotations from the import will be deleted when switching to an incompatible project type.\n'
              'You will have to re-annotate or import a dataset suitable for the newly selected project type.',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            Text(
              'When should I use this option?',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'You should only enable this option if:\n\n'
              '- You accidentally imported the wrong dataset.\n'
              '- You want to start a new annotation project with a different type.\n'
              '- Your dataset structure changed after import.\n\n'
              'If you are unsure, we strongly recommend keeping the default selection to avoid data loss.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Close', style: TextStyle(color: Colors.redAccent)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
