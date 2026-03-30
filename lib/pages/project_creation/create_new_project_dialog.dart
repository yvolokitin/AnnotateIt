import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';
import '../../widgets/dialogs/alert_error_dialog.dart';
import '../../widgets/project_creation_new/create_new_project_step_labels.dart';
import '../../widgets/project_creation_new/create_new_project_step_task_selection.dart';

import '../project_details_page.dart';
import '../../session/user_session.dart';

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
  final TextEditingController nameController = TextEditingController();
  final Map<String, String> taskTypePerTab = {};

  String selectedTab = 'Detection';
  List<Label> labels = [];
  int currentStep = 0;

  String get selectedTaskType => taskTypePerTab[selectedTab] ?? '';

  @override
  void initState() {
    super.initState();
    nameController.text = widget.initialName ?? '';
    selectedTab = widget.initialTab ?? 'Detection';
    if (widget.initialTab != null && widget.initialType != null) {
      taskTypePerTab[widget.initialTab!] = widget.initialType!;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    final isDesktop = screenWidth >= 1200;
    final isTablet = screenWidth >= 700 && screenWidth < 1200;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dialogWidth =
            isDesktop ? constraints.maxWidth * 0.85 : constraints.maxWidth;
        final dialogHeight =
            isDesktop ? constraints.maxHeight * 0.9 : constraints.maxHeight;
        final borderRadius = isDesktop ? 20.0 : 0.0;

        final hPad = isDesktop
            ? 48.0
            : isTablet
                ? 24.0
                : 16.0;
        final vPad = isDesktop
            ? 32.0
            : isTablet
                ? 20.0
                : 12.0;

        final titleFs = isDesktop
            ? 24.0
            : isTablet
                ? 22.0
                : 18.0;
        final subtitleFs = isDesktop
            ? 15.0
            : isTablet
                ? 14.0
                : 12.0;

        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: AppColors.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: SizedBox(
              width: dialogWidth,
              height: dialogHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
                child: Column(
                  children: [
                    // ── Header row ──
                    Row(
                      children: [
                        // Icon + title
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppColors.headerGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.create_new_folder_rounded,
                            size: isDesktop ? 26 : 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.createProjectTitle,
                                style: TextStyle(
                                  fontSize: titleFs,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentStep == 0
                                    ? l10n.createProjectStepOneSubtitle
                                    : l10n.createProjectStepTwoSubtitle,
                                style: TextStyle(
                                  fontSize: subtitleFs,
                                  color: Colors.white38,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Step indicator
                        _buildStepIndicator(),
                        const SizedBox(width: 8),
                        // Close button
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white54),
                          tooltip: l10n.buttonClose,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),

                    SizedBox(height: vPad * 0.4),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withAlpha(0),
                            Colors.white.withAlpha(20),
                            Colors.white.withAlpha(0),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: vPad * 0.3),

                    // ── Content ──
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: currentStep == 0
                            ? _buildStepOne()
                            : _buildStepTwo(),
                      ),
                    ),

                    SizedBox(height: vPad * 0.3),

                    // ── Bottom buttons ──
                    _buildBottomButtons(context, l10n),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Step indicator: pill dots ──
  Widget _buildStepIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(2, (i) {
        final isActive = currentStep == i;
        final isPast = currentStep > i;
        return Padding(
          padding: EdgeInsets.only(left: i > 0 ? 6 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 28 : 10,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: (isActive || isPast) ? AppColors.headerGradient : null,
              color: (isActive || isPast) ? null : Colors.white.withAlpha(31),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepOne() {
    return CreateNewProjectStepTaskSelection(
      key: const ValueKey('step1'),
      nameController: nameController,
      selectedTaskType: selectedTaskType,
      onTaskSelectionChanged: _setSelectedTabAndTask,
    );
  }

  Widget _buildStepTwo() {
    return CreateNewProjectStepLabels(
      key: const ValueKey('step2'),
      projectId: 0,
      projectType: selectedTaskType,
      labels: labels,
      onLabelsUpdated: (updatedLabels) {
        setState(() {
          labels = List<Label>.from(updatedLabels);
        });
      },
    );
  }

  Widget _buildBottomButtons(BuildContext context, AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final btnFs = screenWidth > 1200
        ? 16.0
        : screenWidth > 700
            ? 15.0
            : 14.0;
    final btnPadH = screenWidth > 700 ? 24.0 : 16.0;
    final btnPadV = screenWidth > 700 ? 14.0 : 10.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Cancel
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: btnPadH, vertical: btnPadV),
          ),
          child: Text(
            l10n.buttonCancel,
            style: TextStyle(color: Colors.white38, fontSize: btnFs),
          ),
        ),

        Row(
          children: [
            // Back
            if (currentStep > 0)
              TextButton(
                onPressed: () => setState(() => currentStep--),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: btnPadH, vertical: btnPadV),
                ),
                child: Text(
                  l10n.dialogBack,
                  style: TextStyle(color: Colors.white54, fontSize: btnFs),
                ),
              ),
            const SizedBox(width: 8),

            // Next / Finish
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withAlpha(51),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _handleStepButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                      horizontal: btnPadH + 8, vertical: btnPadV),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  currentStep == 0 ? l10n.dialogNext : l10n.buttonFinish,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: btnFs,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleStepButtonPressed() async {
    final currentTask = taskTypePerTab[selectedTab];
    final l10n = AppLocalizations.of(context)!;

    if (currentStep == 0 && (currentTask == null || currentTask.isEmpty)) {
      AlertErrorDialog.show(
        context,
        l10n.taskTypeRequiredTitle,
        l10n.taskTypeRequiredMessage(selectedTab),
        tips: l10n.taskTypeRequiredTips(selectedTab),
      );
      return;
    }

    if (currentStep == 1) {
      final isBinary =
          selectedTaskType.toLowerCase() == 'binary classification';
      if (isBinary && labels.length > 2) {
        AlertErrorDialog.show(
          context,
          l10n.binaryLimitTitle,
          l10n.binaryLimitMessage,
          tips: l10n.binaryLimitTips,
        );
        return;
      }
    }

    if (currentStep == 0) {
      setState(() => currentStep++);
    } else {
      try {
        final currentUser = UserSession.instance.getUser();
        final newProject = Project(
          name: nameController.text.trim(),
          type: selectedTaskType,
          icon: "assets/images/empty_project_folder.png",
          creationDate: DateTime.now(),
          lastUpdated: DateTime.now(),
          defaultDatasetId: null,
          ownerId: currentUser.id ?? -1,
        );

        final fullProject =
            await ProjectDatabase.instance.createProject(newProject);
        final setFirstLabelAsDefault = currentUser.labelsSetFirstAsDefault;

        List<Label> labelsWithNewProjectId = labels
            .map((label) => label.copyWith(projectId: fullProject.id!))
            .toList();

        if (labelsWithNewProjectId.isNotEmpty && setFirstLabelAsDefault) {
          labelsWithNewProjectId = labelsWithNewProjectId.map((label) {
            return label.copyWith(
                isDefault: label == labelsWithNewProjectId.first);
          }).toList();
        }

        await LabelsDatabase.instance
            .updateProjectLabels(fullProject.id!, labelsWithNewProjectId);

        final updatedLabels =
            await LabelsDatabase.instance.fetchLabelsByProject(fullProject.id!);

        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailsPage(
              fullProject.copyWith(labels: updatedLabels),
            ),
          ),
        );

        if (!mounted) return;
        Navigator.pop(context, 'refresh');
      } catch (e, stack) {
        if (kDebugMode) debugPrint('Error while creating project: $e\n$stack');

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
      selectedTab = tab;
      taskTypePerTab[tab] = task;
    });
  }
}
