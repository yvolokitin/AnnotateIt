import "package:flutter/material.dart";

import "../data/project_database.dart";

import "../widgets/mainmenu/header.dart";
import '../widgets/mainmenu/main_menu_app_drawer.dart';
import '../widgets/mainmenu/main_menu_navigation_rail_menu.dart';

import "project_creation/create_from_dataset_dialog.dart";
import "project_creation/create_new_project_dialog.dart";

import "project_details_page.dart";
import "projects_list_page.dart";
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return LayoutBuilder(
      builder: (context, constraints) {
        print('Height $screenHeight, Width $screenWidth');
        return Scaffold(
          key: _scaffoldKey,
          body: Column(
            children: [
              AppHeader(),
              Expanded(
                child: Row(
                  children: [
                    // Full drawer for large screens
                    if (screenWidth >= 1600)
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
                    if (screenWidth < 1600)
                      MainMenuNavigationRailMenu(
                        selectedIndex: selectedIndex,
                        onItemSelected: _onItemTapped,
                        onCreateProject: () async {
                          final result = await showDialog<String>(
                            context: context,
                            builder: (context) => CreateNewProjectDialog(),
                          );
                          if (result == 'refresh') {
                            setState(() {});
                          }
                        },
                        onCreateFromDataset: () async {
                          final result = await showDialog<int>(
                            context: context,
                            builder: (_) => const CreateFromDatasetDialog(),
                          );
                          if (result != null) {
                            final newProject = await ProjectDatabase.instance.fetchProjectById(result);
                            if (newProject != null && context.mounted) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProjectDetailsPage(newProject)),
                              );
                              setState(() {}); // перерисовать ProjectsListPage
                            }
                          }
                        },
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
        return AboutWidget();

      default:
        return ProjectsListPage();
    }
  }
}
