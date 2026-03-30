import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';

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

    Widget boxedIcon(IconData iconData, {bool active = false}) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: active ? AppColors.accent.withOpacity(0.12) : Colors.transparent,
        ),
        child: Icon(
          iconData,
          color: active ? AppColors.accent : Colors.white.withOpacity(0.45),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkRail,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemSelected,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: Colors.white.withOpacity(0.45),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconSize: 24,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: boxedIcon(Icons.cases_outlined),
            activeIcon: boxedIcon(Icons.cases_outlined, active: true),
            label: l10n.menuProjects,
          ),
          BottomNavigationBarItem(
            icon: boxedIcon(Icons.memory_rounded),
            activeIcon: boxedIcon(Icons.memory_rounded, active: true),
            label: l10n.menuModels,
          ),
          BottomNavigationBarItem(
            icon: boxedIcon(Icons.account_circle_outlined),
            activeIcon: boxedIcon(Icons.account_circle_outlined, active: true),
            label: l10n.menuAccount,
          ),
          BottomNavigationBarItem(
            icon: boxedIcon(Icons.info_outline_rounded),
            activeIcon: boxedIcon(Icons.info_outline_rounded, active: true),
            label: l10n.menuAbout,
          ),
        ],
      ),
    );
  }
}
