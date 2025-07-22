import "package:flutter/material.dart";

import "../models/project.dart";

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
  int selectedIndex = 0;

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