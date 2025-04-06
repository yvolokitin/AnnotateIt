import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:flutter_svg/flutter_svg.dart";
import "package:flutter/material.dart";
import 'package:logger/logger.dart';

import "../utils/date_utils.dart";
import "dataset_view_page.dart";

import 'package:vap/data/app_database.dart';

import "../widgets/buttons/hover_icon_button.dart";
// import "../widgets/edit_labels_dialog.dart";

class ProjectDetailsScreen extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailsScreen(this.project, {super.key});

  @override
  ConsumerState<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends ConsumerState<ProjectDetailsScreen> {
  final _logger = Logger();

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProjectDetails();
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> _loadProjectDetails() async {
    _logger.i("Load project details, which is in fact nothing for now");
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Column(
        children: [
          Container(
            height: screenWidth >= 1600 ? 80 : 40,
            width: double.infinity,
            color: Colors.grey[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HoverIconButton(
                  icon: Icons.arrow_back,
                  margin: EdgeInsets.only(left: 20.0),
                  onPressed: () => Navigator.pop(context, true),
                ),
                HoverIconButton(
                  icon: Icons.help_outline,
                  margin: EdgeInsets.only(right: 20.0),
                  onPressed: () {
                    _logger.w("Help is not implemented yet");
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (screenWidth >= 1600)
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(40.0),
                          color: Colors.grey[850],
                          height: 330,
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.project.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                              SizedBox(height: 6),
                              SvgPicture.asset(
                                'assets/images/default_project_image.svg',
                                height: 100,
                                fit: BoxFit.cover,
                                color: Colors.white,
                              ),
                              Text("Type: ${widget.project.type}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 18)),
                              SizedBox(height: 6),
                              Text("Created at ${formatDate(widget.project.creationDate)}",
                                  style: TextStyle(color: Colors.white60, fontWeight: FontWeight.normal, fontSize: 18)),
                            ],
                          ),
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
                    padding: const EdgeInsets.all(30.0),
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
        return DatasetViewPage(widget.project);
      case 1:
        return DatasetViewPage(widget.project); // placeholder for labels UI
      default:
        return DatasetViewPage(widget.project);
    }
  }
}

// Full Sidebar Drawer
class AppDrawer extends ConsumerWidget {
  final bool fullMode;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    this.fullMode = false,
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
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
class NavigationRailMenu extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const NavigationRailMenu({
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      labelType: NavigationRailLabelType.all,
      destinations: [
        NavigationRailDestination(
          icon: Icon(Icons.image),
          label: Text('Datasets', style: Theme.of(context).textTheme.titleMedium),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.label),
          label: Text('Labels', style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}

// Drawer List Item
class DrawerItem extends ConsumerWidget {
  final IconData icon;
  final String title;
  final bool fullMode;
  final bool isSelected;
  final VoidCallback onTap;
  final double textSize;

  const DrawerItem({
    required this.icon,
    required this.title,
    this.fullMode = false,
    required this.isSelected,
    required this.onTap,
    this.textSize = 28.0,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color baseRed = Colors.red;
    final Color lighterRed = baseRed.withOpacity(0.1);

    return Stack(
      children: [
        Container(
          height: 100,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isSelected ? lighterRed : Colors.transparent,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 40, right: 16),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? Colors.red : null),
                if (fullMode) SizedBox(width: 16),
                if (fullMode)
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: textSize,
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
            selected: isSelected,
            onTap: onTap,
          ),
        ),
        if (isSelected)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 10,
              color: Colors.red,
            ),
          ),
      ],
    );
  }
}
