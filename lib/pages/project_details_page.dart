import "package:flutter/material.dart";

import "../models/label.dart";
import "../models/project.dart";

import '../data/labels_database.dart';
import "../widgets/buttons/hover_icon_button.dart";

import "../widgets/project_details/project_view_media_galery.dart";
import '../widgets/project_details/project_view_datasets_overview.dart';
import '../widgets/project_details/project_view_labels.dart';
import '../widgets/project_details/project_details_sidebar.dart';

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
      print("ProjectDetailsScreen: No labels, loading ${widget.project.name} project labels .... ");

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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double contentPadding = (screenWidth > 1600) ? 30.0 : (screenWidth > 900) ? 15.0 : 2.0;

    print("screenWidth: $screenWidth");

    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Column(
        children: [
          // title bar
          Container(
            height: screenWidth >= 1600 ? 80 : 45,
            width: double.infinity,
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HoverIconButton(
                  icon: Icons.arrow_back,
                  margin: EdgeInsets.only(left: 20.0),
                  onPressed: () => Navigator.pop(context, 'refresh'),
                ),
                
                HoverIconButton(
                  icon: Icons.help_outline,
                  margin: EdgeInsets.only(right: 20.0),
                  onPressed: () {
                    print("Help is not implemented yet");
                  },
                ),
              ],
            ),
          ),

          // body
          Expanded(
            child : Row(
              children: [
                if (screenWidth >= 1600 && screenHeight >= 785)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        ProjectDetailsSidebar(
                          project: project,
                          selectedIndex: selectedIndex,
                          onItemSelected: _onItemTapped,
                        ),

                        Expanded(
                          child: SizedBox.expand(
                            child: AppDrawer(
                              fullMode: true,
                              selectedIndex: selectedIndex,
                              onItemSelected: _onItemTapped,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (screenWidth < 1600 || screenHeight < 785)
                  NavigationRailMenu(
                    selectedIndex: selectedIndex,
                    onItemSelected: _onItemTapped,
                  ),

                Expanded(
                  flex: 8,
                  child: Container(
                    padding: EdgeInsets.all(contentPadding),
                    color: Colors.grey[900],
                    child: getSelectedWidget(selectedIndex),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return ProjectViewMediaGalery(
          project: project,
          datasetId: project.defaultDatasetId!,
          labels: labels,
        );

      case 1:
        return ProjectViewLabels(
          project: project,
          labels: labels,
          onLabelsUpdated: (updatedLabels) {
            setState(() {
              labels = updatedLabels;
            });
            // You may also persist to DB here
          },
        );

      case 2:
        return ProjectViewDatasetsOverview(
          project: project,
        );

      default:
        return ProjectViewMediaGalery(
          project: project,
          datasetId: project.defaultDatasetId!,
          labels: labels,
        );
      }
    }
  }

// Full Sidebar Drawer
class AppDrawer extends StatelessWidget {
  final bool fullMode;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({super.key, 
    this.fullMode = false,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer items
          DrawerItem(
            icon: Icons.wallpaper_rounded,
            title: "Media",
            fullMode: fullMode,
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          DrawerItem(
            icon: Icons.label_outline_rounded,
            title: "Labels",
            fullMode: fullMode,
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          DrawerItem(
            icon: Icons.library_books_outlined,
            title: "Overview",
            fullMode: fullMode,
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),
        ],
      ),
    );
  }
}

// Compact NavigationRail (for medium screens)
class NavigationRailMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const NavigationRailMenu({super.key, 
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      
      selectedIconTheme: const IconThemeData(color: Colors.red),
      selectedLabelTextStyle: const TextStyle(color: Colors.red),
      unselectedIconTheme: const IconThemeData(color: Colors.white70),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
      backgroundColor: Colors.grey[850],
      
      destinations: [
        NavigationRailDestination(
          icon: Icon(
            size: 28,
            Icons.wallpaper_rounded,
          ),
          label: Text(
            'Media',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        NavigationRailDestination(
          icon: Icon(
            size: 28,
            Icons.label_outline_rounded,
          ),
          label: Text(
            'Labels',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        NavigationRailDestination(
          icon: Icon(
            size: 28,
            Icons.library_books_outlined,
          ),
          label: Text(
            'Overview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ],
    );
  }
}

// Drawer List Item
class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool fullMode;
  final bool isSelected;
  final double textSize;

  final VoidCallback onTap;

  const DrawerItem({
    super.key, 
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.fullMode = false,
    this.textSize = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    // Base red color
    final Color baseRed = Colors.red;
    // Compute a 20% lighter color for the background
    // final Color lighterRed = baseRed.withOpacity(0.1); // 80% opacity for a lighter effect
    final Color lighterRed = baseRed.withAlpha(26); // 10% of 255
    
    return Stack(
      children: [
        Container(
          height: 100,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isSelected ? lighterRed : Colors.transparent, // 20% lighter red when selected
          ),
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 40, right: 16),
            title: SizedBox(
              height: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 28,
                    color: isSelected ? Colors.red : null,
                  ), // Red icon if selected

                  if (fullMode) SizedBox(width: 16),
                  if (fullMode)
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: textSize,
                        color: isSelected ? Colors.white : Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                ],
              ),
            ),
            selected: isSelected,
            onTap: onTap,
          ),
        ),
      
        if (isSelected)
          Positioned(
            right: 0, // Align to the right
            top: 0,
            bottom: 0,
            child: Container(
              width: 10, // 10px width
              color: Colors.red, // Red color for the selection indicator
            ),
          ),
      ],
    );
  }
}
