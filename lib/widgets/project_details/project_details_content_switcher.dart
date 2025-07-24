import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../models/project.dart';

import 'project_view_media_galery.dart';
import 'project_view_datasets_overview.dart';
import 'project_view_labels.dart';

class ProjectDetailsContentSwitcher extends StatefulWidget {
  final int selectedIndex;
  final Project project;
  final Function(List<Label>) onLabelsUpdated;
  
  /// Callback to notify when upload status changes
  final Function(bool isUploading)? onUploadStatusChanged;

  const ProjectDetailsContentSwitcher({
    super.key,
    required this.selectedIndex,
    required this.project,
    required this.onLabelsUpdated,
    this.onUploadStatusChanged,
  });
  
  @override
  State<ProjectDetailsContentSwitcher> createState() => _ProjectDetailsContentSwitcherState();
}

class _ProjectDetailsContentSwitcherState extends State<ProjectDetailsContentSwitcher> {
  /// Tracks whether there's an active upload in progress
  bool _isUploading = false;
  
  /// Handles upload status changes from child components
  /// 
  /// This method is called by ProjectViewMediaGalery when the upload status changes.
  /// It updates the local state and notifies the parent component (ProjectDetailsPage)
  /// about the change, allowing it to show a confirmation dialog when the user tries
  /// to navigate away during an active upload.
  /// 
  /// @param isUploading Whether there's an active upload in progress
  void _handleUploadStatusChanged(bool isUploading) {
    setState(() {
      _isUploading = isUploading;
    });
    
    // Notify parent component about upload status change
    widget.onUploadStatusChanged?.call(isUploading);
  }

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
    switch (widget.selectedIndex) {
      case 0:
        return ProjectViewMediaGalery(
          project: widget.project,
          datasetId: widget.project.defaultDatasetId!,
          onUploadStatusChanged: _handleUploadStatusChanged,
        );
      case 1:
        return ProjectViewLabels(
          project: widget.project,
          onLabelsUpdated: widget.onLabelsUpdated,
        );
      case 2:
        return ProjectViewDatasetsOverview(
          project: widget.project,
        );
      default:
        return ProjectViewMediaGalery(
          project: widget.project,
          datasetId: widget.project.defaultDatasetId!,
          onUploadStatusChanged: _handleUploadStatusChanged,
        );
    }
  }
}