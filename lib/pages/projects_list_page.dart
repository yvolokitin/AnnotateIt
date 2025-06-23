import "package:flutter/material.dart";

import '../session/user_session.dart';
import "../models/project.dart";
import "../data/project_database.dart";
import "../data/labels_database.dart";

import "../widgets/project_list/project_tile.dart";
import "../widgets/projects_topbar.dart";
import "../widgets/empty_project_placeholder.dart";

import '../widgets/dialogs/delete_project_dialog.dart';
import "../widgets/dialogs/edit_project_name_dialog.dart";

import "project_details_page.dart";
import "project_creation/create_from_dataset_dialog.dart";
import "project_creation/create_new_project_dialog.dart";

class ProjectsListPage extends StatefulWidget {
  const ProjectsListPage({super.key});

  @override
  ProjectsListPageState createState() => ProjectsListPageState();
}

class ProjectsListPageState extends State<ProjectsListPage> {
  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  String _searchQuery = "";
  
  // Default sort option
  String _sortOption = "Last Updated";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  // preload labels and attach them to each project (as an extra field — not stored in DB, just in memory).
  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
    });
  
    List<Project> projects = await ProjectDatabase.instance.fetchProjects();

    if (!mounted) return;

    for (final project in projects) {
      final labels = await LabelsDatabase.instance.fetchLabelsByProject(project.id!);
      project.labels = labels; // attach in-memory only
    }
  
    setState(() {
      _allProjects = projects;
      _filteredProjects = _applySearchAndSort(projects);
      _isLoading = false;
    });
  }

  // Function to Edit a Project (Add Edit Logic)
  void _editProjectName(Project project) async {
    final updatedName = await showDialog<String>(
      context: context,
      builder: (_) => EditProjectNameDialog(project: project),
    );
  
    if (updatedName != null) {
      // Refresh project list after saving
      _loadProjects();
    }
  }

  /// to be implemented later, now its disabled
/*
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filteredProjects = _applySearchAndSort(_allProjects);
    });
  }
*/
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

  void _handleCreateNewProject() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => CreateNewProjectDialog(),
    );

    if (result == 'refresh') {
      _loadProjects(); // Refresh the list if new project was created
    }
  }

  void _handleImportFromDataset() async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => const CreateFromDatasetDialog(),
    );

    if (result != null) {
      final newProject = await ProjectDatabase.instance.fetchProjectById(result);
      if (newProject != null) {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsPage(newProject),
          ),
        );  
        _loadProjects(); // Refresh after returning from details
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text("Loading projects...", style: TextStyle(color: Colors.white70)),
            ],
          ),
        )
        : Column(
        children: [
          // 📌 Row with Create Button, Search Bar, and Sort Icon
          ProjectsTopBar(
              onSearchPressed: () {
                print("Project Search button pressed, not implemented yet");
              },
              onSortSelected: _onSortSelected,
              onCreateProject: _handleCreateNewProject,
              onCreateFromDataset: _handleImportFromDataset,
              onCreateFromExport: _handleImportFromDataset,
          ),

          // Project List -> list of ProjectTile's (in widgets)
          Expanded(
            child: _filteredProjects.isEmpty
              ? SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: EmptyProjectPlaceholder(
                    onCreateNewProject: _handleCreateNewProject,
                    onImportFromDataset: _handleImportFromDataset,
                  ),
                ),
              )                
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
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailsPage(project),
                        ),
                      );
                      _loadProjects();
                    },
                  );
                },
              ),
          ),
        ],
      ),
    );
  }

  // Function to show Edit / Change type and Delete options
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
                leading: Icon(
                  Icons.edit_note_outlined,
                  color: Colors.white70,
                  size: 30,
                ),
                title: Text(
                  "Edit project name",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editProjectName(project);
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.build_circle_outlined,
                  color: Colors.white70,
                  size: 30,
                ),
                title: Text(
                  "Change project type",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70,
                    ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editProjectName(project);
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.delete_sweep_outlined,
                  color: Colors.white70,
                  size: 30,
                ),
                title: Text(
                  "Delete project",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70,
                  ),
                ),
                onTap: () {
                    final currentContext = context;
                    Navigator.pop(context);

                    Future.delayed(Duration.zero, () {
                      showDialog(
                        context: currentContext,
                        builder: (_) => DeleteProjectDialog(
                          project: project,
                          onConfirmed: () {
                            // Refresh the list after deletion
                            _loadProjects();
                          },
                          onOptionsSelected: (deleteFromDisk, dontAskAgain) async {
                            if (dontAskAgain) {
                              await UserSession.instance.setProjectSkipDeleteConfirm(true);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
