import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class MainMenuNavigationRailMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onCreateProject;
  final VoidCallback onCreateFromDataset;

  const MainMenuNavigationRailMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onCreateProject,
    required this.onCreateFromDataset,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 70,
      color: Colors.grey[850],
      child: Column(
        children: [
          Expanded(
            child: NavigationRail(
              selectedIndex: selectedIndex,
              backgroundColor: Colors.grey[850],
              onDestinationSelected: onItemSelected,
              selectedIconTheme: const IconThemeData(color: Colors.red),
              selectedLabelTextStyle: const TextStyle(color: Colors.red, fontFamily: 'CascadiaCode'),
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white54, fontFamily: 'CascadiaCode'),
              destinations: [
                _buildDestination(0, Icons.cases_outlined, l10n.menuProjects, screenWidth),
                _buildDestination(1, Icons.account_circle_outlined, l10n.menuProjects, screenWidth),
                _buildDestination(2, Icons.error_outline_rounded, l10n.menuProjects, screenWidth),
              ],
            ),
          ),

          // const Divider(color: Colors.white30),
          // Bottom buttons
          if (screenWidth<700)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
              child: Column(
                children: [
                  // Create New Project (Red icon button)
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onCreateProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(
                        size: 28,
                        color: Colors.white,
                        Icons.add_circle_outline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Import Dataset (Grey icon button)
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onCreateFromDataset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(
                        size: 28,
                        Icons.upload_file,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  NavigationRailDestination _buildDestination(int index, IconData icon, String label, double screenWidth) {
    return NavigationRailDestination(
      icon: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: selectedIndex == index ? Colors.grey[900] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(size: 28, icon),
      ),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'CascadiaCode',
        ),
      ),
    );
  }
}
