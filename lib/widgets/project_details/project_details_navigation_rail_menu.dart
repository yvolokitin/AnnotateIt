import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: screenWidth > 550 ? 70 : 60,
      color: Colors.grey[800],
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onItemSelected,
        selectedIconTheme: const IconThemeData(color: Colors.red),
        selectedLabelTextStyle: const TextStyle(color: Colors.red, fontFamily: 'CascadiaCode',),
        unselectedIconTheme: const IconThemeData(color: Colors.white70),
        unselectedLabelTextStyle: const TextStyle(color: Colors.white54, fontFamily: 'CascadiaCode',),
        backgroundColor: Colors.grey[800],

        destinations: [
          _buildDestination(0, Icons.wallpaper_rounded, l10n.userProfileMedia, screenWidth),
          _buildDestination(1, Icons.discount_outlined, l10n.userProfileLabels, screenWidth),
          _buildDestination(2, Icons.library_books_outlined, l10n.userProfileOverview, screenWidth),
        ],
      ),
    );
  }

  NavigationRailDestination _buildDestination(int index, IconData icon, String label, double width) {
    return NavigationRailDestination(
      icon: Container(
        width: width > 550 ? 48 : 44,
        height: width > 550 ? 48 : 44,
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