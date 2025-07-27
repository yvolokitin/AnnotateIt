import "package:flutter/material.dart";

import "../models/project.dart";

import '../widgets/project_details/project_details_app_bar.dart';
import '../widgets/project_details/project_details_navigation.dart';
import '../widgets/project_details/project_details_content_switcher.dart';

import '../../gen_l10n/app_localizations.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;

  const ProjectDetailsPage(this.project, {super.key});

  @override
  ProjectDetailsPageState createState() => ProjectDetailsPageState();
}

class ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late Project project;
  int selectedIndex = 0;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    project = widget.project;
    print('ProjectDetailsPage: project: ${project.name} - ${project.labels!.length}');
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
  
  /// Handles upload status changes from child components
  /// 
  /// This method is called by ProjectDetailsContentSwitcher when the upload status changes.
  /// It updates the local state, which is used by _confirmNavigationDuringUpload to determine
  /// whether to show a confirmation dialog when the user tries to navigate away.
  /// 
  /// @param isUploading Whether there's an active upload in progress
  void _handleUploadStatusChanged(bool isUploading) {
    setState(() {
      _isUploading = isUploading;
    });
  }
  
  /// Shows a confirmation dialog when trying to navigate away during an active upload
  /// 
  /// This method is called when the user tries to navigate away from the project details page.
  /// If there's an active upload in progress, it shows a confirmation dialog asking the user
  /// if they want to leave and cancel the upload, or stay and let the upload complete.
  /// 
  /// Returns true if the user confirms they want to leave, false otherwise.
  Future<bool> _confirmNavigationDuringUpload() async {
    // If there's no active upload, allow navigation without confirmation
    if (!_isUploading) return true;
    
    // Get localized strings
    final l10n = AppLocalizations.of(context)!;
    
    // Show a confirmation dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.uploadInProgressTitle),
        content: Text(l10n.uploadInProgressMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.uploadInProgressStay),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.uploadInProgressLeave),
          ),
        ],
      ),
    );
    
    // Return the result, defaulting to false (stay) if the dialog is dismissed
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[850],
        body: Column(
          children: [
            // In ProjectDetailsPage
            ProjectDetailsAppBar(
              onBackPressed: () async {
                final canNavigate = await _confirmNavigationDuringUpload();
                if (!canNavigate) return;
                
                setState(() {
                });
                Navigator.pop(context, 'refresh');
              },
            ),
            Expanded(
              child: Row(
                children: [
                  ProjectDetailsNavigation(
                    selectedIndex: selectedIndex,
                    onItemSelected: _onItemTapped,
                    project: project,
                  ),
                  ProjectDetailsContentSwitcher(
                    selectedIndex: selectedIndex,
                    project: project,
                    onLabelsUpdated: (updatedLabels) {
                      setState(() {
                        project = project.copyWith(labels: updatedLabels);
                      });
                    },
                    onUploadStatusChanged: _handleUploadStatusChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}