import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import '../../widgets/dialogs/alert_error_dialog.dart';

import '../../widgets/project_creation_new/create_new_project_step_task_selection.dart';
import '../../widgets/project_creation_new/create_new_project_step_labels.dart';

import '../../session/user_session.dart';
import '../project_details_page.dart';

import '../../data/project_database.dart';
import '../../data/labels_database.dart';

import '../../models/project.dart';
import '../../models/label.dart';

class CreateNewProjectDialog extends StatefulWidget {
  final String? initialName;
  final String? initialType;
  final String? initialTab;

  const CreateNewProjectDialog({
    super.key,
    this.initialName,
    this.initialType,
    this.initialTab,
  });

  @override
  CreateNewProjectDialogState createState() => CreateNewProjectDialogState();
}

class CreateNewProjectDialogState extends State<CreateNewProjectDialog> {
  final TextEditingController _nameController = TextEditingController();
  final Map<String, String> _taskTypePerTab = {};
  String _selectedTab = 'Detection';
  int _step = 0;
  final List<Label> _createdLabels = [];

  /// Returns the task selected for the current tab.
  String get _selectedTaskType => _taskTypePerTab[_selectedTab] ?? '';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _selectedTab = widget.initialTab ?? 'Detection';

    // Initialize initial values if provided
    if (widget.initialTab != null && widget.initialType != null) {
      _taskTypePerTab[widget.initialTab!] = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1600;
    final isTablet = screenWidth >= 900 && screenWidth < 1600;
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {

        final dialogPadding = isLargeScreen
            ? const EdgeInsets.all(60)
            : isTablet
                ? const EdgeInsets.all(24)
                : const EdgeInsets.all(12);

        final dialogWidth = constraints.maxWidth * (isLargeScreen ? 0.9 : 1.0);
        final dialogHeight = constraints.maxHeight * (isLargeScreen ? 0.9 : 1.0);

        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.grey[850],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Padding(
              padding: dialogPadding,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenWidth>1400 ? 40 : 10),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [                              
                                  Icon(
                                    Icons.create_new_folder_rounded,
                                    size: isLargeScreen ? 34 : 30,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n.createProjectTitle,
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 26 : 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'CascadiaCode',
                                      color: Colors.white,
                                    ),
                                  ),
                                ]
                              ),
                              const SizedBox(height: 4),
                              if (screenWidth>445)...[
                                Row(
                                  children: [                              
                                    Text(
                                      _step == 0
                                        ? l10n.createProjectStepOneSubtitle
                                        : l10n.createProjectStepTwoSubtitle,
                                      style: TextStyle(
                                        fontSize: isLargeScreen ? 22 : (screenWidth>660) ? 18 : 12,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'CascadiaCode',
                                        color: Colors.white24,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: screenWidth>1200 ? 12 : (screenWidth>650) ? 6 : 2),
                        const Divider(color: Colors.white70),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth>1200 ? 15 : 4),
                            child: _step == 0 ? _buildStepOne() : _buildStepTwo(),
                          ),
                        ),

                        SizedBox(height: screenWidth>1200 ? 12 : (screenWidth>650) ? 6 : 2),
                        _buildBottomButtons(),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      tooltip: l10n.buttonClose,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepOne() {
    return CreateNewProjectStepTaskSelection(
      nameController: _nameController,
      selectedTaskType: _selectedTaskType,
      onTaskSelectionChanged: _setSelectedTabAndTask,
    );
  }

  Widget _buildStepTwo() {
    return CreateNewProjectStepLabels(
      createdLabels: _createdLabels
          .map((label) => {'name': label.name, 'color': label.color})
          .toList(),
      projectType: _selectedTaskType,
      onLabelsChanged: (labelMaps) {
        setState(() {
          _createdLabels
            ..clear()
            ..addAll(labelMaps.map((map) => Label(
                  labelOrder: 0,
                  projectId: 0,
                  name: map['name'],
                  color: map['color'],
                )));
        });
      },
    );
  }

  Widget _buildBottomButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.buttonCancel,
            style: TextStyle(
              color: Colors.white54,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ),
        Row(
          children: [
            if (_step > 0)
              TextButton(
                onPressed: () => setState(() => _step--),
                child: Text(
                  l10n.dialogBack,
                  style: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'CascadiaCode',
                  ),
                ),
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _handleStepButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.red, width: 2),
                ),
              ),
              child: Text(
                _step == 0 ? l10n.dialogNext : l10n.buttonFinish,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleStepButtonPressed() async {
    final currentTask = _taskTypePerTab[_selectedTab];
    final l10n = AppLocalizations.of(context)!;

    if (_step == 0 && (currentTask == null || currentTask.isEmpty)) {
      AlertErrorDialog.show(
        context,
        l10n.taskTypeRequiredTitle,
        l10n.taskTypeRequiredMessage(_selectedTab),
        tips: l10n.taskTypeRequiredTips(_selectedTab),
      );
      return;
    }

    if (_step == 1) {
      final isBinary = _selectedTaskType.toLowerCase() == 'binary classification';
      if (isBinary && _createdLabels.length > 2) {
        AlertErrorDialog.show(
          context,
          l10n.binaryLimitTitle,
          l10n.binaryLimitMessage,
          tips: l10n.binaryLimitTips,
        );
        return;
      }
    }

    if (_step == 0) {
      setState(() => _step++);

    } else {
      try {
        final currentUser = UserSession.instance.getUser();
        final newProject = Project(
          name: _nameController.text.trim(),
          type: _selectedTaskType,
          icon: "assets/images/default_project_image.svg",
          creationDate: DateTime.now(),
          lastUpdated: DateTime.now(),
          defaultDatasetId: null,
          ownerId: currentUser.id ?? -1,
        );

        final fullProject = await ProjectDatabase.instance.createProject(newProject);
        final labelsWithNewProjectId = _createdLabels
          .map((label) => label.copyWith(projectId: fullProject.id!))
          .toList();

        await LabelsDatabase.instance.updateProjectLabels(fullProject.id!, labelsWithNewProjectId);

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailsPage(
              fullProject.copyWith(labels: labelsWithNewProjectId),
            ),
          ),
        );

        if (!mounted) return;
        Navigator.pop(context, 'refresh');

      } catch (e, stack) {
        debugPrint('Error while creating project: $e\n$stack');

        AlertErrorDialog.show(
          context,
          'Unexpected Error',
          'Something went wrong while creating your project. Please try again or contact support.',
          tips: e.toString(),
        );
      }
    }
  }

  void _setSelectedTabAndTask(String tab, String task) {
    setState(() {
      _selectedTab = tab;
      _taskTypePerTab[tab] = task;
    });
  }
}
