import "package:flutter/material.dart";
import "../data/project_database.dart";
import "../models/project.dart";

import "../widgets/project_tile.dart";
import "../widgets/projects_topbar.dart";
import "../widgets/create_project_dialog.dart";
import "../widgets/edit_project_name.dart";
import "../widgets/edit_labels_dialog.dart";

import "project_details_screen.dart";

class ProjectsPage extends StatefulWidget {
  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late Future<List<Project>> _projectsFuture;
  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  String _searchQuery = "";
  
  // Default sort option
  String _sortOption = "Last Updated";

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    List<Project> projects = await ProjectDatabase.instance.fetchProjects();
    setState(() {
      _allProjects = projects;
      _filteredProjects = _applySearchAndSort(projects);
    });
  }

  // Function to Edit a Project (Add Edit Logic)
  void _editProjectName(Project project) {
    showDialog(
      context: context,
      builder: (context) => EditProjectName(
        project: project,
        onProjectUpdated: () {
          _loadProjects(); // Refresh project list after saving
        },
      ),
    );
  }

  // Open Edit Labels Dialog
  void _editProjectLabels(Project project) {
    showDialog(
      context: context,
      builder: (context) => EditLabelsDialog(
        project: project,
        // Refresh projects after label update
        onLabelsUpdated: _loadProjects,
      ),
    );
  }

  // Function to Delete a Project
  Future<void> _deleteProject(Project project) async {
    await ProjectDatabase.instance.deleteProject(project.id!);
    _loadProjects(); // Refresh list after deletion
  }  

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProjects = _applySearchAndSort(_allProjects);
    });
  }

  void _onSortSelected(String option) {
    setState(() {
      _sortOption = option;
      _filteredProjects = _applySearchAndSort(_allProjects);
    });
  }

  List<Project> _applySearchAndSort(List<Project> projects) {
    List<Project> filtered = projects.where((p) {
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    switch (_sortOption) {
      case "Last Updated":
        filtered.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
        break;
      case "Newest-Oldest":
        filtered.sort((a, b) => b.creationDate.compareTo(a.creationDate));
        break;
      case "Oldest-Newest":
        filtered.sort((a, b) => a.creationDate.compareTo(b.creationDate));
        break;
      case "A-Z":
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case "Z-A":
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case "Project Type":
        filtered.sort((a, b) => a.type.compareTo(b.type));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 📌 Row with Create Button, Search Bar, and Sort Icon
          ProjectsTopBar(
              onSearchPressed: () {
                print("Project Search button pressed, not implemented yet");
              },
              onSortSelected: _onSortSelected,
              onCreateProject: () {
                print("Started a new project dialog creation");
                showDialog(
                  context: context,
                  builder: (context) => CreateProjectDialog(),
                );
              },
          ),

          // Project List -> list of ProjectTile's (in widgets)
          Expanded(
            child: _filteredProjects.isEmpty
                ? Center(child: Text("No projects found"))
                : ListView.builder(
                    itemCount: _filteredProjects.length,
                    itemBuilder: (context, index) {
                      final project = _filteredProjects[index];
                      return ProjectTile(
                        project: project,
                        onMorePressed: () {
                          _showProjectOptions(context, project);
                        },
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetailsScreen(project),
                            ),
                          );
                          if (result == true) {
                            _loadProjects();
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Function to Show Edit/Delete Options
  void _showProjectOptions(BuildContext context, Project project) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.green),
                title: Text("Edit Project Name"),
                onTap: () {
                  Navigator.pop(context);
                  _editProjectName(project);
                },
              ),
              ListTile(
                leading: Icon(Icons.label, color: Colors.orange),
                title: Text("Update Project Labels"),
                onTap: () {
                  Navigator.pop(context);
                  _editProjectLabels(project);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text("Delete Project"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteProject(project);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
