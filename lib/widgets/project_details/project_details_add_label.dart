import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../labels/add_label_row.dart';

/// Thin wrapper that delegates to the shared [AddLabelRow].
/// Kept for backward compatibility with [ProjectViewLabels].
class ProjectDetailsAddLabel extends StatelessWidget {
  final int projectId;
  final String projectType;
  final List<Label> labels;
  final void Function(String name, String color) onAddNewLabel;

  const ProjectDetailsAddLabel({
    super.key,
    required this.labels,
    required this.projectId,
    required this.projectType,
    required this.onAddNewLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AddLabelRow(
      existingLabels: labels,
      projectType: projectType,
      onAdd: onAddNewLabel,
    );
  }
}
