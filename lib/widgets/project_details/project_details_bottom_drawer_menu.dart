import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class ProjectDetailsBottomDrawerMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const ProjectDetailsBottomDrawerMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget boxedIcon(IconData iconData, {bool active = false}) {
      final Color iconColor = active ? Colors.red : Colors.white70;
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
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
      backgroundColor: Colors.transparent,
      iconSize: 28,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
          icon: boxedIcon(Icons.wallpaper_rounded, active: false),
          activeIcon: boxedIcon(Icons.wallpaper_rounded, active: true),
          label: l10n.userProfileMedia,
        ),
        BottomNavigationBarItem(
          icon: boxedIcon(Icons.discount_outlined, active: false),
          activeIcon: boxedIcon(Icons.discount_outlined, active: true),
          label: l10n.userProfileLabels,
        ),
        BottomNavigationBarItem(
          icon: boxedIcon(Icons.library_books_outlined, active: false),
          activeIcon: boxedIcon(Icons.library_books_outlined, active: true),
          label: l10n.userProfileOverview,
        ),
      ],
    );
  }
}
