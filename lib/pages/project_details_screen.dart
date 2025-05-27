// import "package:flutter_svg/flutter_svg.dart";
import "package:flutter/material.dart";

import "../models/label.dart";
import "../models/project.dart";

import '../widgets/dialogs/label_list_dialog.dart';
import '../widgets/dialogs/color_picker_dialog.dart';
import "../widgets/buttons/hover_icon_button.dart";
import "../widgets/project_details/dataset_view_page.dart";
import '../widgets/project_details/project_details_sidebar.dart';
import '../widgets/project_details/project_details_add_label.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailsScreen(this.project, {super.key});

  @override
  ProjectDetailsScreenState createState() => ProjectDetailsScreenState();
}

class ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Label> labels = [];

  @override
  void initState() {
    super.initState();
    _loadProjectDetails();
  }

  int selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> _loadProjectDetails() async {
    // print("ProjectDetailsScreen: Loading project details:\n${widget.project}");
    labels = List<Label>.from(widget.project.labels ?? []);

    if (widget.project.labels == null || widget.project.labels!.isEmpty) {
      // TODO: Fetch labels from database and update state
      print("ProjectDetailsScreen: Loading project labels .... ");
    }
  }

  void _showColorPicker(int index) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: labels[index].color,
        onColorSelected: (newColor) {
          setState(() {
            labels[index] = labels[index].copyWith(color: newColor);
          });
          // TODO: Persist label color change to DB
        },
      ),
    );
  }

  void _handleAddNewLabel(String name, String color) {
    final newLabel = Label(
      projectId: widget.project.id ?? 0,
      name: name,
      color: color,
    );

    setState(() {
      labels.add(newLabel);
      widget.project.labels ??= [];
      widget.project.labels!.add(newLabel); 
    });

    // Optional: print or do something else
    print('New label added: $name - $color');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                if (screenWidth >= 1600)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        ProjectDetailsSidebar(
                          project: widget.project,
                          selectedIndex: selectedIndex,
                          onItemSelected: _onItemTapped,
                        ),
                        Expanded(
                          child: AppDrawer(
                            fullMode: true,
                            selectedIndex: selectedIndex,
                            onItemSelected: _onItemTapped,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (screenWidth < 1600)
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
        // return DatasetViewPage(widget.project);
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.yellow, width: 3),
          ),
          child: DatasetViewPage(widget.project),
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text('Labels', style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            Divider(color: Colors.grey),
            SizedBox(height: 25),

            ProjectDetailsAddLabel(
              labels: labels,
              projectType: widget.project.type,
              onAddNewLabel: _handleAddNewLabel,
            ),
        
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: LabelListDialog(
                  labels: labels,
                  scrollController: _scrollController,
                  onColorTap: _showColorPicker,
                  onNameChanged: (index, newName) {
                    setState(() {
                      labels[index] = labels[index].copyWith(name: newName);
                    });
                    // TODO: Save updated label name to database
                  },
                  onDelete: (label) {
                    setState(() {
                      labels.remove(label);
                    });
                    // TODO: Delete label from database
                  },  
                  onColorChanged: (index, newColor) {
                    setState(() {
                      labels[index] = labels[index].copyWith(color: newColor);
                    });
                    // TODO: Update label color in database
                  },
                ),
              ),
            ),
          ],  
        );
        default:
          return DatasetViewPage(widget.project);
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
            icon: Icons.image,
            title: "Datasets",
            fullMode: fullMode,
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          DrawerItem(
            icon: Icons.label,
            title: "Labels",
            fullMode: fullMode,
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
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
      destinations: [
        NavigationRailDestination(icon: Icon(Icons.image), label: Text(
          'Datasets',
          style: Theme.of(context).textTheme.titleMedium,
        )),
        NavigationRailDestination(icon: Icon(Icons.label), label: Text(
          'Labels',
          style: Theme.of(context).textTheme.headlineMedium,
        )),
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
  final VoidCallback onTap;
  final double textSize;

  const DrawerItem({super.key, 
    required this.icon,
    required this.title,
    this.fullMode = false,
    required this.isSelected,
    required this.onTap,
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
                  Icon(icon, color: isSelected ? Colors.red : null), // Red icon if selected
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
