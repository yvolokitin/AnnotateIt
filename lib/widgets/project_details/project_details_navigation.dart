import 'package:flutter/material.dart';

import 'project_details_sidebar.dart';
import 'project_details_app_drawer.dart';
import 'project_details_navigation_rail_menu.dart';

import '../../models/project.dart';

class ProjectDetailsNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final Project project;

  const ProjectDetailsNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth >= 1600 && screenHeight >= 785) {
      return Expanded(
        flex: 2,
        child: Column(
          children: [
            ProjectDetailsSidebar(
              project: project,
              selectedIndex: selectedIndex,
              onItemSelected: onItemSelected,
            ),
            Expanded(
              child: SizedBox.expand(
                child: ProjectDetailsAppDrawer(
                  fullMode: true,
                  selectedIndex: selectedIndex,
                  onItemSelected: onItemSelected,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return ProjectDetailsNavigationRailMenu(
        selectedIndex: selectedIndex,
        onItemSelected: onItemSelected,
      );
    }
  }
}