import "package:flutter/material.dart";
import '../gen_l10n/app_localizations.dart';
import '../utils/theme.dart';


import '../session/user_session.dart';
import "../data/project_database.dart";
import "../models/project.dart";

import "../widgets/project_list/empty_project_placeholder.dart";
import "../widgets/project_list/project_tile.dart";
import "../widgets/project_list/projects_topbar.dart";
import "../widgets/project_list/crawling_snakes_footer.dart";

import '../widgets/dialogs/delete_project_dialog.dart';
import "../widgets/dialogs/edit_project_name_dialog.dart";

import "project_details_page.dart";
import "project_creation/create_from_dataset_dialog.dart";
import "project_creation/create_new_project_dialog.dart";
import "project_creation/change_project_type_dialog.dart";
import "project_export/export_project_dialog.dart";
import "project_prelabel/pre_label_project_dialog.dart";

class ProjectsListPage extends StatefulWidget {

  const ProjectsListPage({
    super.key,
  });

  @override
  ProjectsListPageState createState() => ProjectsListPageState();
}

class ProjectsListPageState extends State<ProjectsListPage> {
  bool sortDetection = false, sortClassification = false, sortSegmentation = false;

  List<Project> _allProjects = [];
  List<Project> _filteredProjects = [];
  String _searchQuery = "";
  
  // Default sort option
  late String _sortOption;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with localized default sort option
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _sortOption = 'Custom order';
        });
      }
    });
    loadProjectsWithLabels();
  }

  // preload labels and attach them to each project (as an extra field — not stored in DB, just in memory).
  Future<void> loadProjectsWithLabels() async {
    setState(() {
      _isLoading = true;
    });
    final projects = await ProjectDatabase.instance.fetchProjectsWithLabels();
    if (!mounted) return;
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
      loadProjectsWithLabels();
    }
  }

  void _handleChangeProjectType(Project project) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ChangeProjectTypeDialog(project: project),
    );

    if (result == 'refresh') {
      loadProjectsWithLabels(); // Refresh the list if new project was created
    }
  }
  
  void _handleExportProject(Project project) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ExportProjectDialog(project: project),
    );

    if (result == 'refresh') {
      loadProjectsWithLabels(); // Refresh the list after export
    }
  }

  void _handlePreLabelProject(Project project, {bool useTFLite = false}) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => PreLabelProjectDialog(project: project, useTFLite: useTFLite),
    );

    if (result == 'refresh') {
      loadProjectsWithLabels();
    } else if (result == 'open_project') {
      // Dialog is already closed; open the project details page
      final projectWithLabels = await ProjectDatabase.instance.fetchProjectWithLabelsById(project.id!);
      if (projectWithLabels != null) {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsPage(projectWithLabels),
          ),
        );
        // Refresh list after returning from details
        loadProjectsWithLabels();
      } else {
        // If fetching failed, just refresh list
        loadProjectsWithLabels();
      }
    }
  }

  void _onSortSelected(String option) {
    setState(() {
      _sortOption = option;
      _filteredProjects = _applySearchAndSort(_allProjects);
    });
  }

  List<Project> _applySearchAndSort(List<Project> projects) {
    final query = _searchQuery.toLowerCase();

    List<Project> filtered = projects.where((p) {
      final nameMatches = p.name.toLowerCase().contains(query);
      final type = p.type.toLowerCase();

      final matchesDetection = sortDetection && type.contains("detection");
      final matchesClassification = sortClassification && type.contains("classification");
      final matchesSegmentation = sortSegmentation && type.contains("segmentation");
  
      final anyFilterActive = sortDetection || sortClassification || sortSegmentation;

      // If any filter is active, return only matching types
      final matchesFilter = anyFilterActive
        ? (matchesDetection || matchesClassification || matchesSegmentation)
        : true;
      return nameMatches && matchesFilter;
    }).toList();

    // Get localized strings for comparison
    final l10n = AppLocalizations.of(context)!;
    
    // Sort options
    switch (_sortOption) {
      case 'Custom order':
        filtered.sort((a, b) => a.order.compareTo(b.order));
        break;
      case String option when option == l10n.menuSortLastUpdated:
        filtered.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
        break;
      case String option when option == l10n.menuSortNewestOldest:
        filtered.sort((a, b) => b.creationDate.compareTo(a.creationDate));
        break;
      case String option when option == l10n.menuSortOldestNewest:
        filtered.sort((a, b) => a.creationDate.compareTo(b.creationDate));
        break;
      case String option when option == l10n.menuSortAZ:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case String option when option == l10n.menuSortZA:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case String option when option == l10n.menuSortProjectType:
        filtered.sort((a, b) => a.type.compareTo(b.type));
        break;
      default:
        // Default to Last Updated if no match
        filtered.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
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
      loadProjectsWithLabels(); // Refresh the list if new project was created
    }
  }

  void _handleImportFromDataset() async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => const CreateFromDatasetDialog(),
    );

    if (result != null) {
      final newProject = await ProjectDatabase.instance.fetchProjectWithLabelsById(result);
      if (newProject != null) {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsPage(newProject),
          ),
        );
        // Refresh after returning from details
        loadProjectsWithLabels();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _isLoading
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accent),
              const SizedBox(height: 12),
              Text(
                l10n.loadingProjects,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.muted,
                ),
              ),
            ],
          ),
        )
        : Column(
        children: [
          // Row with Create Button, Search Bar, and Sort Icon
          if (screenWidth >= 270)...[
            ProjectsTopBar(
              sortDetection: sortDetection,
              sortClassification: sortClassification,
              sortSegmentation: sortSegmentation,
              onSearchPressed: () { },
              onSortSelected: _onSortSelected,
              onCreateProject: _handleCreateNewProject,
              onCreateFromDataset: _handleImportFromDataset,
              onCreateFromExport: _handleImportFromDataset,
              onSortDetection: () {
                setState(() {
                  sortDetection = !sortDetection;
                  _filteredProjects = _applySearchAndSort(_allProjects);
                });
              },
              onSortClassification: () {
                setState(() {
                  sortClassification = !sortClassification;
                  _filteredProjects = _applySearchAndSort(_allProjects);
                });
              },
              onSortSegmentation: () {
                setState(() {
                  sortSegmentation = !sortSegmentation;
                  _filteredProjects = _applySearchAndSort(_allProjects);
                });
              },
            ),
          ],

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
              : ((_sortOption == 'Custom order') && _searchQuery.isEmpty && !sortDetection && !sortClassification && !sortSegmentation)
                  ? ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      proxyDecorator: (child, index, animation) {
                        return MouseRegion(
                          cursor: SystemMouseCursors.grabbing,
                          child: child,
                        );
                      },
                      itemCount: _filteredProjects.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex -= 1;
                          final moved = _filteredProjects.removeAt(oldIndex);
                          _filteredProjects.insert(newIndex, moved);
                          // Update order locally to match new positions
                          for (int i = 0; i < _filteredProjects.length; i++) {
                            _filteredProjects[i] = _filteredProjects[i].copyWith(order: i);
                          }
                          _allProjects = List<Project>.from(_filteredProjects);
                        });
                        // Persist order (fire-and-forget)
                        final ids = _filteredProjects.map((p) => p.id!).toList();
                        ProjectDatabase.instance.reorderProjects(ids);
                      },
                      itemBuilder: (context, index) {
                        final project = _filteredProjects[index];
                        return ReorderableDragStartListener(
                          key: ValueKey('project_${project.id}'),
                          index: index,
                          child: ProjectTile(
                            key: ValueKey('project_tile_${project.id}'),
                            project: project,
                            onMorePressed: () {
                              _showProjectOptions(context, project);
                            },
                            onTap: () async {
                              final projectWithLabels = await ProjectDatabase.instance.fetchProjectWithLabelsById(project.id!);
                              if (projectWithLabels != null) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectDetailsPage(projectWithLabels),
                                  ),
                                );
                                loadProjectsWithLabels();
                              }
                            },
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: _filteredProjects.length,
                      itemBuilder: (context, index) {
                        final project = _filteredProjects[index];
                        return ProjectTile(
                          key: ValueKey('project_tile_${project.id}'),
                          project: project,
                          onMorePressed: () {
                            _showProjectOptions(context, project);
                          },
                          onTap: () async {
                            final projectWithLabels = await ProjectDatabase.instance.fetchProjectWithLabelsById(project.id!);
                            if (projectWithLabels != null) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProjectDetailsPage(projectWithLabels),
                                ),
                              );
                              loadProjectsWithLabels();
                            }
                          },
                        );
                      },
                    ),
          ),

          // Animated footer with colorful crawling lines (only when placeholder is shown)
          (_filteredProjects.isEmpty && screenHeight>650)
            ? SafeArea(
                top: false,
                child: CrawlingSnakesFooter(
                  height: screenWidth>500 ? 72 : 36,
                  snakeCount: screenWidth>500 ? 7 : 5,
                ),
              )
            : const SizedBox.shrink(),
        ],
      ),
    );
  }

  void _showProjectOptions(BuildContext context, Project project) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildOptionTile(
                  context,
                  icon: Icons.edit_note_outlined,
                  label: l10n.editProjectTitle,
                  color: Theme.of(context).colorScheme.info,
                  onTap: () {
                    Navigator.pop(context);
                    _editProjectName(project);
                  },
                ),
                _buildOptionTile(
                  context,
                  icon: Icons.build_circle_outlined,
                  label: l10n.changeProjectTypeTitle,
                  color: Theme.of(context).colorScheme.warning,
                  onTap: () {
                    Navigator.pop(context);
                    _handleChangeProjectType(project);
                  },
                ),
                _buildOptionTile(
                  context,
                  icon: Icons.save_alt_rounded,
                  label: l10n.exportProjectAsDataset,
                  color: Theme.of(context).colorScheme.success,
                  onTap: () {
                    Navigator.pop(context);
                    _handleExportProject(project);
                  },
                ),
                if (project.type.toLowerCase().contains('classification') ||
                    project.type.toLowerCase().contains('detection'))
                  _buildOptionTile(
                    context,
                    icon: Icons.auto_awesome,
                    label: l10n.preLabelProject,
                    color: Theme.of(context).colorScheme.purple,
                    onTap: () {
                      Navigator.pop(context);
                      _handlePreLabelProject(project);
                    },
                  ),
                _buildOptionTile(
                  context,
                  icon: Icons.delete_outline_rounded,
                  label: l10n.deleteProjectTitle,
                  color: Theme.of(context).colorScheme.error,
                  onTap: () {
                    final currentContext = context;
                    Navigator.pop(context);
                    Future.delayed(Duration.zero, () {
                      showDialog(
                        context: currentContext,
                        builder: (_) => DeleteProjectDialog(
                          project: project,
                          onConfirmed: () {
                            loadProjectsWithLabels();
                          },
                          onOptionsSelected: (deleteFromDisk, dontAskAgain) async {
                            if (dontAskAgain) {
                              await UserSession.instance.setProjectSkipDeleteConfirm(true);
                            }
                          },
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: color, size: 26),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}
