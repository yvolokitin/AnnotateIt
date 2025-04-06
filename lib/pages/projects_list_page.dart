import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../widgets/project_tile.dart';
import '../widgets/projects_topbar.dart';
import '../widgets/create_project_dialog.dart';
import '../widgets/edit_project_name.dart';
import '../widgets/edit_labels_dialog.dart';

import 'project_details_screen.dart';
import 'package:vap/data/app_database.dart';
import 'package:vap/data/providers.dart';

class ProjectsPage extends ConsumerStatefulWidget {
  const ProjectsPage({super.key});

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends ConsumerState<ProjectsPage> {
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
    // Используем ref для получения данных из базы данных через databaseProvider
    final db = ref.read(databaseProvider);
    List<Project> projects = await db.getAllProjects();
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
    final db = ref.read(databaseProvider);
    await db.deleteProject(project.id!);
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
                  builder: (context) => const CreateProjectDialog(),
                );
              },
          ),

          // Project List -> list of ProjectTile's (in widgets)
          Expanded(
            child: _filteredProjects.isEmpty
                ? const Center(child: Text("No projects found"))
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.green),
                title: const Text("Edit Project Name"),
                onTap: () {
                  Navigator.pop(context);
                  _editProjectName(project);
                },
              ),
              ListTile(
                leading: const Icon(Icons.label, color: Colors.orange),
                title: const Text("Update Project Labels"),
                onTap: () {
                  Navigator.pop(context);
                  _editProjectLabels(project);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Project"),
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
