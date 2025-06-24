import "package:flutter/material.dart";

import "../models/label.dart";
import "../models/project.dart";
import '../data/labels_database.dart';

import '../widgets/project_details/project_details_app_bar.dart';
import '../widgets/project_details/project_details_navigation.dart';
import '../widgets/project_details/project_details_content_switcher.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project project;

  const ProjectDetailsPage(this.project, {super.key});

  @override
  ProjectDetailsPageState createState() => ProjectDetailsPageState();
}

class ProjectDetailsPageState extends State<ProjectDetailsPage> {
  late Project project;
  List<Label> labels = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    project = widget.project;
    labels = List<Label>.from(widget.project.labels ?? []);
    _loadProjectLabels();
  }

  Future<void> _loadProjectLabels() async {
    if (widget.project.labels == null || widget.project.labels!.isEmpty) {
      if (widget.project.id != null) {
        final loadedLabels = await LabelsDatabase.instance.fetchLabelsByProject(widget.project.id!);
        setState(() {
          labels = loadedLabels;
          project = project.copyWith(labels: loadedLabels);
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Column(
        children: [
          ProjectDetailsAppBar(
            onBackPressed: () => Navigator.pop(context, 'refresh'),
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
                  labels: labels,
                  onLabelsUpdated: (updatedLabels) {
                    setState(() => labels = updatedLabels);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}