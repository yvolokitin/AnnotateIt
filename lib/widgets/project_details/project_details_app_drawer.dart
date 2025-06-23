// lib/features/project_details/components/navigation/app_drawer.dart
import 'package:flutter/material.dart';
import 'project_details_drawer_item.dart';

class ProjectDetailsAppDrawer extends StatelessWidget {
  final bool fullMode;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ProjectDetailsAppDrawer({
    super.key,
    this.fullMode = false,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          ProjectDetailsDrawerItem(
            icon: Icons.wallpaper_rounded,
            title: "Media",
            fullMode: fullMode,
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          ProjectDetailsDrawerItem(
            icon: Icons.label_outline_rounded,
            title: "Labels",
            fullMode: fullMode,
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          ProjectDetailsDrawerItem(
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