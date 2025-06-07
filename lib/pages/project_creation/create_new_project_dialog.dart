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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth >= 1600;
        final isTablet = constraints.maxWidth >= 800 && constraints.maxWidth < 1600;

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
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.createProjectTitle,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _step == 0
                                    ? AppLocalizations.of(context)!.createProjectStepOneSubtitle
                                    : AppLocalizations.of(context)!.createProjectStepTwoSubtitle,
                                style: const TextStyle(fontSize: 22, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _step == 0 ? _buildStepOne() : _buildStepTwo(),
                        ),
                        _buildBottomButtons(),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      tooltip: 'Close',
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
                  projectId: 0,
                  name: map['name'],
                  color: map['color'],
                )));
        });
      },
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context)!.dialogCancel,
            style: TextStyle(color: Colors.white70)
          ),
        ),
        Row(
          children: [
            if (_step > 0)
              TextButton(
                onPressed: () => setState(() => _step--),
                child: Text(
                  AppLocalizations.of(context)!.dialogBack,
                  style: TextStyle(color: Colors.white70)
                ),
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _handleStepButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _step == 0 ? AppLocalizations.of(context)!.dialogNext : AppLocalizations.of(context)!.dialogFinish,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
      if (_createdLabels.isEmpty) {
        AlertErrorDialog.show(
          context,
          l10n.labelRequiredTitle,
          l10n.labelRequiredMessage,
          tips: l10n.labelRequiredTips,
        );
        return;
      }

      final isBinary = _selectedTaskType.toLowerCase() == 'binary classification';
      if (isBinary && _createdLabels.length != 2) {
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

        final newProjectId = await ProjectDatabase.instance.createProject(newProject);
        final labelsWithNewProjectId = _createdLabels
          .map((label) => label.copyWith(projectId: newProjectId))
          .toList();

        await LabelsDatabase.instance.updateProjectLabels(newProjectId, labelsWithNewProjectId);

        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailsPage(
              newProject.copyWith(
                id: newProjectId,
                labels: labelsWithNewProjectId,
              ),
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
