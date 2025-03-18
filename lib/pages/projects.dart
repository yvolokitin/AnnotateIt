import 'package:flutter/material.dart';
import '../data/project_database.dart';
import '../models/project.dart';

import '../widgets/project_tile.dart';
import '../widgets/projects_topbar.dart';
import '../widgets/create_project_dialog.dart';

class ProjectsPage extends StatefulWidget {
  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late Future<List<Project>> _projectsFuture;
  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  String _searchQuery = "";
  String _sortOption = "A-Z"; // Default sort option

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
      case "A-Z":
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case "Z-A":
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case "Newest-Oldest":
        filtered.sort((a, b) => b.creationDate.compareTo(a.creationDate));
        break;
      case "Oldest-Newest":
        filtered.sort((a, b) => a.creationDate.compareTo(b.creationDate));
        break;
      case "Project Type":
        filtered.sort((a, b) => a.type.compareTo(b.type));
        break;
    }

    return filtered;
  }

  Future<void> _addProject() async {
    final newProject = Project(
      name: "New Project",
      type: "Classification",
      icon: "folder",
      creationDate: DateTime.now(),
      labels: ["Label1", "Label2"],
    );

    await ProjectDatabase.instance.insertProject(newProject);
    _loadProjects(); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("          ")),
      body: Column(
        children: [
          // 📌 Row with Create Button, Search Bar, and Sort Icon
          ProjectsTopBar(
              onSearchPressed: () {
                print("Project Search button pressed");
              },
              onSortSelected: _onSortSelected,
              onCreateProject: () {
                print("Pressed new project creation");
                showDialog(
                  context: context,
                  builder: (context) => CreateProjectDialog(),
                );
              },
          ),

          // 📌 Project List
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
                        }
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
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text("Edit Project"),
                onTap: () {
                  Navigator.pop(context);
                  _editProject(project);
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

  // Function to Edit a Project (Add Edit Logic)
  void _editProject(Project project) {
    print("Editing: ${project.name}");
    // Implement edit logic (e.g., open a dialog to edit project details)
  }

  // Function to Delete a Project
  Future<void> _deleteProject(Project project) async {
    await ProjectDatabase.instance.deleteProject(project.id!);
    _loadProjects(); // Refresh list after deletion
  }  
}
