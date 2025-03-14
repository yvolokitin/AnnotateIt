import "package:vap/pages/header.dart";
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
                        child: Text(
                          "Selected Screen: ${selectedIndex == 0 ? "Projects" : selectedIndex == 1 ? "Account" : selectedIndex == 2 ? "Learn" : "About"}",
                          style: TextStyle(fontSize: 24),
                        ),
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

  const DrawerItem({
    required this.icon,
    required this.title,
    this.fullMode = false,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      // decoration: BoxDecoration(border: Border.all(color: Colors.yellow, width: 3)),
      
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : null),
        title: fullMode ? Text(title) : null, // Hide text in compact mode
        selected: isSelected,
        onTap: onTap,
      ),
    );
  }
}
