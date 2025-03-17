import "package:vap/pages/header.dart";

import "package:vap/pages/about.dart";
import "package:vap/pages/account.dart";
import "package:vap/pages/learn.dart";
import "package:vap/pages/projects.dart";

import "package:flutter/material.dart";

// Main page layout with Persistent Header and adaptive Left Drawer
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                        child: AppDrawer(
                          fullMode: true,
                          selectedIndex: selectedIndex,
                          onItemSelected: _onItemTapped,
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
        return ProjectsPage();
      case 1:
        return AccountWidget();
      case 2:
        return LearnWidget();
      case 3:
        return AboutWidget();
      default:
        return ProjectsPage();
    }
  }
}

// Full Sidebar Drawer
class AppDrawer extends StatelessWidget {
  final bool fullMode;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
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
            title: "Projects",
            fullMode: fullMode,
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          DrawerItem(
            icon: Icons.account_circle,
            title: "Account",
            fullMode: fullMode,
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          DrawerItem(
            icon: Icons.school,
            title: "Learn",
            fullMode: fullMode,
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),
          DrawerItem(
            icon: Icons.info,
            title: "About",
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

  const NavigationRailMenu({
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
          'Projects',
          style: Theme.of(context).textTheme.titleMedium,
        )),
        NavigationRailDestination(icon: Icon(Icons.account_circle), label: Text(
          'Account',
          style: Theme.of(context).textTheme.headlineMedium,
        )),
        NavigationRailDestination(icon: Icon(Icons.school), label: Text(
          'Learn',
          style: Theme.of(context).textTheme.headlineMedium,
        )),
        NavigationRailDestination(icon: Icon(Icons.info), label: Text(
          'About',
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

  const DrawerItem({
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
    final Color lighterRed = baseRed.withOpacity(0.1); // 80% opacity for a lighter effect
    
    return Stack(
      children: [
        Container(
          height: 100,
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isSelected ? lighterRed : Colors.transparent, // 20% lighter red when selected
          ),
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 10, right: 16),
            title: Row(
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
            selected: isSelected,
            onTap: onTap,
          ),
        ),
      
        if (isSelected)
          Positioned(
            right: 0, // Align to the right
            top: 0,
            bottom: 0,
            child: Container(
              width: 10, // 10px width
              color: Colors.red, // Red color for the selection indicator
            ),
          ),
      ],
    );
    
    /*
    return Container(
      height: 100,
      alignment: Alignment.centerLeft, // Aligns content to the left
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.yellow, width: 3), // 3px border
        color: isSelected ? Colors.red.withOpacity(0.2) : Colors.transparent, // Red background if selected
      ),
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 10, right: 16),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Ensures vertical alignment
          children: [
            Icon(icon, color: isSelected ? Colors.red : null),
            if (fullMode) SizedBox(width: 16), // Space between icon and text
            if (fullMode)
              Text(
                title,
                style: TextStyle(
                  fontSize: textSize,
                  color: isSelected ? Colors.red : Colors.white)
              ),
          ],
        ),
        selected: isSelected,
        onTap: onTap,
      ),
    );
    */
  }
}
