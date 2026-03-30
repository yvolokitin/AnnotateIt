import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';
import 'main_menu_drawer_item.dart';
import 'exported_datasets_dialog.dart';

class MainMenuAppDrawer extends StatelessWidget {
  final bool fullMode;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const MainMenuAppDrawer({
    super.key,
    this.fullMode = false,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      backgroundColor: AppColors.darkRail,
      elevation: 0,
      child: Column(
        children: [
          MainMenuDrawerItem(
            icon: Icons.cases_outlined,
            title: l10n.menuProjects,
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          MainMenuDrawerItem(
            icon: Icons.memory_rounded,
            title: l10n.menuModels,
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          MainMenuDrawerItem(
            icon: Icons.account_circle_outlined,
            title: l10n.menuAccount,
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),
          MainMenuDrawerItem(
            icon: Icons.info_outline_rounded,
            title: l10n.menuAbout,
            isSelected: selectedIndex == 3,
            onTap: () => onItemSelected(3),
          ),
          const Spacer(),
          MainMenuDrawerItem(
            icon: Icons.folder_zip_outlined,
            title: screenWidth >= 1600
                ? l10n.menuExportedDatasetsLong
                : l10n.menuExportedDatasetsShort,
            isSelected: false,
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) => const ExportedDatasetsDialog(),
              );
            },
          ),
        ],
      ),
    );
  }
}
