import "package:flutter/material.dart";
import 'package:vap/gen_l10n/app_localizations.dart';

import "package:vap/pages/header.dart";

import "projects_list_page.dart";
import "learn_page.dart";
import "about_page.dart";
import "account_page.dart";

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // final sWidth = MediaQuery.of(context).size.width;
        // final sHeight = MediaQuery.of(context).size.height;
        // print('Screen width: $sWidth, height: $sHeight');

        double screenWidth = MediaQuery.of(context).size.width;

        // 16+ inches screens
        bool isLargeScreen = screenWidth >= 1600;

        // 13-16 inches -> tablets and small laptops
        bool isMediumScreen = screenWidth >= 1200 && screenWidth < 1600;

        // less than 13 inches -> mobile devices
        bool isSmallScreen = screenWidth < 1200;

        return Scaffold(
          key: _scaffoldKey,
          body: Column(
            children: [
              // Always visible top header (Persistent App Header (always on top)
              AppHeader(onHeaderPressed: isSmallScreen ? () => _scaffoldKey.currentState?.openDrawer() : null),
              Expanded(
                child: Row(
                  children: [
                    // Full drawer for large screens
                    if (isLargeScreen)
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Container(
                              height: 95,
                              width: double.infinity,
                              color: Color(0xFF11191F), // Color(0xFF0F151C),
                            ),

                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: AppDrawer(
                                  fullMode: true,
                                  selectedIndex: selectedIndex,
                                  onItemSelected: _onItemTapped,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // NavigationRail for medium screens
                    if (isMediumScreen)
                      NavigationRailMenu(
                        selectedIndex: selectedIndex,
                        onItemSelected: _onItemTapped,
                      ),

                    // Main content area
                    Expanded(
                      flex: 8,
                      child: Center(
                        child: getSelectedWidget(selectedIndex),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Drawer only for small screens
          drawer: isSmallScreen
              ? AppDrawer(
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) {
                    _onItemTapped(index);
                    Navigator.pop(context); // Close the drawer after selection
                  },
                )
              : null,
        );
      },
    );
  }

  Widget getSelectedWidget(int index) {
    switch (index) {
      case 0:
        return ProjectsListPage();
      case 1:
        return AccountPage();
      case 2:
        return LearnWidget();
      case 3:
        return AboutWidget();
      default:
        return ProjectsListPage();
    }
  }
}

// Full Sidebar Drawer
class AppDrawer extends StatelessWidget {
  final bool fullMode;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    super.key,
    this.fullMode = false,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer items
          DrawerItem(
            icon: Icons.work,
            title: AppLocalizations.of(context)!.menuProjects,
            fullMode: fullMode,
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          DrawerItem(
            icon: Icons.account_circle,
            title: AppLocalizations.of(context)!.menuAccount,
            fullMode: fullMode,
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          DrawerItem(
            icon: Icons.school,
            title: AppLocalizations.of(context)!.menuLearn,
            fullMode: fullMode,
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),
          DrawerItem(
            icon: Icons.info,
            title: AppLocalizations.of(context)!.menuAbout,
            fullMode: fullMode,
            isSelected: selectedIndex == 3,
            onTap: () => onItemSelected(3),
          ),
        ],
      ),
    );
  }
}

// Compact NavigationRail (for medium screens)
class NavigationRailMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const NavigationRailMenu({super.key, 
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onItemSelected,
      destinations: [
        NavigationRailDestination(icon: Icon(Icons.work), label: Text(
          AppLocalizations.of(context)!.menuProjects,
          style: Theme.of(context).textTheme.titleMedium,
        )),
        NavigationRailDestination(icon: Icon(Icons.account_circle), label: Text(
          AppLocalizations.of(context)!.menuAccount,
          style: Theme.of(context).textTheme.headlineMedium,
        )),
        NavigationRailDestination(icon: Icon(Icons.school), label: Text(
          AppLocalizations.of(context)!.menuLearn,
          style: Theme.of(context).textTheme.headlineMedium,
        )),
        NavigationRailDestination(icon: Icon(Icons.info), label: Text(
          AppLocalizations.of(context)!.menuAbout,
          style: Theme.of(context).textTheme.headlineMedium,
        )),
      ],
    );
  }
}

// Drawer List Item
class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool fullMode;
  final bool isSelected;
  final VoidCallback onTap;
  final double textSize;

  const DrawerItem({super.key, 
    required this.icon,
    required this.title,
    this.fullMode = false,
    required this.isSelected,
    required this.onTap,
    this.textSize = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    // Base red color
    final Color baseRed = Colors.red;
    // Compute a 20% lighter color for the background
    // final Color lighterRed = baseRed.withOpacity(0.1); // 80% opacity for a lighter effect
    final Color lighterRed = baseRed.withAlpha(26); // 10% of 255

    return Stack(
      children: [
        Container(
          height: 100,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isSelected ? lighterRed : Colors.transparent, // 20% lighter red when selected
          ),
          child: SizedBox.expand(
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 40, right: 16),
              title: SizedBox(
                height: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, color: isSelected ? Colors.red : null), // Red icon if selected
                    if (fullMode) SizedBox(width: 16),
                    if (fullMode)
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: textSize,
                          color: isSelected ? Colors.white : Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                  ],  
                ),
              ),
              selected: isSelected,
              onTap: onTap,
            ),
          ),
        ),
      
        if (isSelected)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 10,
              color: Colors.red,
            ),
          ),
      ],
    );
  }
}
