import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import 'main_menu_drawer_item.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      child: Column(
        children: [
          MainMenuDrawerItem(
            icon: Icons.cases_outlined,
            title: l10n.menuProjects,
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          MainMenuDrawerItem(
            icon: Icons.account_circle_outlined,
            title: l10n.menuAccount,
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          MainMenuDrawerItem(
            icon: Icons.error_outline_rounded,
            title: l10n.menuAbout,
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),
        ],
      ),
    );
  }
}
