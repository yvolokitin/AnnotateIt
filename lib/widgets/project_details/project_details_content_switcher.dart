import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../models/project.dart';

import 'project_view_media_galery.dart';
import 'project_view_datasets_overview.dart';
import 'project_view_labels.dart';

class ProjectDetailsContentSwitcher extends StatelessWidget {
  final int selectedIndex;
  final Project project;
  final Function(List<Label>) onLabelsUpdated;

  const ProjectDetailsContentSwitcher({
    super.key,
    required this.selectedIndex,
    required this.project,
    required this.onLabelsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentPadding = (screenWidth > 1600) ? 30.0 : (screenWidth > 900) ? 15.0 : 2.0;

    return Expanded(
      flex: 8,
      child: Container(
        padding: EdgeInsets.all(contentPadding),
        color: Colors.grey[900],
        child: _getSelectedWidget(),
      ),
    );
  }

  Widget _getSelectedWidget() {
    switch (selectedIndex) {
      case 0:
        return ProjectViewMediaGalery(
          project: project,
          datasetId: project.defaultDatasetId!,
        );
      case 1:
        return ProjectViewLabels(
          project: project,
          onLabelsUpdated: onLabelsUpdated,
        );
      case 2:
        return ProjectViewDatasetsOverview(
          project: project,
        );
      default:
        return ProjectViewMediaGalery(
          project: project,
          datasetId: project.defaultDatasetId!,
        );
    }
  }
}