import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';
import 'exported_datasets_dialog.dart';

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
      color: AppColors.darkRail,
      child: Column(
        children: [
          Expanded(
            child: NavigationRail(
              selectedIndex: selectedIndex,
              backgroundColor: AppColors.darkRail,
              onDestinationSelected: onItemSelected,
              selectedIconTheme: const IconThemeData(color: AppColors.accent),
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              unselectedIconTheme: IconThemeData(
                color: Colors.white.withOpacity(0.5),
              ),
              unselectedLabelTextStyle: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
              destinations: [
                _buildDestination(0, Icons.cases_outlined, l10n.menuProjects),
                _buildDestination(1, Icons.memory_rounded, l10n.menuModels),
                _buildDestination(2, Icons.account_circle_outlined, l10n.menuAccount),
                _buildDestination(3, Icons.info_outline_rounded, l10n.menuAbout),
              ],
            ),
          ),

          if (screenWidth < 700)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
              child: Column(
                children: [
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: onCreateProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Icon(
                        size: 24,
                        color: Colors.white,
                        Icons.add_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: onCreateFromDataset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkSurface,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Icon(
                        size: 24,
                        Icons.upload_file_rounded,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10),
            child: Tooltip(
              message: l10n.menuExportedDatasetsLong,
              child: SizedBox(
                width: 46,
                height: 46,
                child: ElevatedButton(
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => const ExportedDatasetsDialog(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBg,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Icon(
                    size: 24,
                    Icons.folder_zip_outlined,
                    color: Colors.white.withOpacity(0.45),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  NavigationRailDestination _buildDestination(int index, IconData icon, String label) {
    return NavigationRailDestination(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: selectedIndex == index
              ? AppColors.accent.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(size: 24, icon),
      ),
      label: Text(label),
    );
  }
}
