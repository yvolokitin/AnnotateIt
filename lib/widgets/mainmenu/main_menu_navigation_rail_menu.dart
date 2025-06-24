import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

class MainMenuNavigationRailMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const MainMenuNavigationRailMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return NavigationRail(
      selectedIndex: selectedIndex,
      backgroundColor: Colors.grey[850],
      onDestinationSelected: onItemSelected,
      selectedIconTheme: const IconThemeData(color: Colors.red),
      selectedLabelTextStyle: const TextStyle(color: Colors.red),
      unselectedIconTheme: const IconThemeData(color: Colors.white70),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
      destinations: [
        _buildDestination(0, Icons.cases_outlined, l10n.menuProjects),
        _buildDestination(1, Icons.account_circle_outlined, l10n.menuProjects),
        _buildDestination(2, Icons.school_outlined, l10n.menuProjects),
        _buildDestination(3, Icons.error_outline_rounded, l10n.menuProjects),
      ],
    );
  }

  NavigationRailDestination _buildDestination(int index, IconData icon, String label) {
    return NavigationRailDestination(
      icon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selectedIndex == index ? Colors.grey[900] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(size: 28, icon),
      ),
      label: Text(label),
    );
  }
}
