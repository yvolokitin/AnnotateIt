import "package:flutter/material.dart";

import '../widgets/mainmenu/main_menu_navigation_rail_menu.dart';
import '../widgets/mainmenu/main_menu_app_drawer.dart';
import "../widgets/mainmenu/header.dart";

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
              AppHeader(
                onHeaderPressed: isSmallScreen
                  ? () {
                      _scaffoldKey.currentState?.openDrawer();
                    }
                  : null,
              ),

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
                              color: Colors.grey[850],
                            ),

                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: MainMenuAppDrawer(
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
                      MainMenuNavigationRailMenu(
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
              ? MainMenuAppDrawer(
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
