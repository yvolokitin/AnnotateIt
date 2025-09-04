import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class MainMenuBottomDrawerMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const MainMenuBottomDrawerMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget _boxedIcon(IconData iconData, {bool active = false}) {
      final Color borderColor = active ? Colors.red : Colors.transparent;
      final Color iconColor = active ? Colors.red : Colors.white70;
      return Container(
        // padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          // border: Border.all(color: borderColor, width: active ? 2.0 : 0.0),
        ),
        child: Icon(iconData, color: iconColor),
      );
    }

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemSelected,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white70,
      backgroundColor: Colors.transparent, // Colors.grey[950],
      iconSize: 28,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: _boxedIcon(Icons.cases_outlined, active: false),
          activeIcon: _boxedIcon(Icons.cases_outlined, active: true),
          label: l10n.menuProjects,
        ),
        BottomNavigationBarItem(
          icon: _boxedIcon(Icons.memory_rounded, active: false),
          activeIcon: _boxedIcon(Icons.memory_rounded, active: true),
          label: l10n.menuModels,
        ),
        BottomNavigationBarItem(
          icon: _boxedIcon(Icons.account_circle_outlined, active: false),
          activeIcon: _boxedIcon(Icons.account_circle_outlined, active: true),
          label: l10n.menuAccount,
        ),
        BottomNavigationBarItem(
          icon: _boxedIcon(Icons.error_outline_rounded, active: false),
          activeIcon: _boxedIcon(Icons.error_outline_rounded, active: true),
          label: l10n.menuAbout,
        ),
      ],
    );
  }
}
