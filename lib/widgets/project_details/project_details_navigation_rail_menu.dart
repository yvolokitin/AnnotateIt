import 'package:flutter/material.dart';

class ProjectDetailsNavigationRailMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ProjectDetailsNavigationRailMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      selectedIconTheme: const IconThemeData(color: Colors.red),
      selectedLabelTextStyle: const TextStyle(color: Colors.red, fontFamily: 'CascadiaCode',),
      unselectedIconTheme: const IconThemeData(color: Colors.white70),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white54, fontFamily: 'CascadiaCode',),
      backgroundColor: Colors.grey[800],

      destinations: [
        _buildDestination(0, Icons.wallpaper_rounded, 'Media'),
        _buildDestination(1, Icons.discount_outlined, 'Labels'),
        _buildDestination(2, Icons.library_books_outlined, 'Overview'),
      ],
    );
  }

  NavigationRailDestination _buildDestination(int index, IconData icon, String label) {
    return NavigationRailDestination(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selectedIndex == index ? Colors.grey[850] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(size: 28, icon),
      ),
      label: Text(
        label,
        style: TextStyle(
          color: Colors.white54,
          fontFamily: 'CascadiaCode',
        ),
      ),
    );
  }
}