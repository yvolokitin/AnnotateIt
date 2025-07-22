import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../widgets/dialogs/alert_error_dialog.dart';
import '../../widgets/project_type_change/project_type_change_step_1_task_selection.dart';
import '../../widgets/project_type_change/project_type_change_step_2_confirmation.dart';

import '../../utils/project_type_migrator.dart';
import '../../gen_l10n/app_localizations.dart';

class ChangeProjectTypeDialog extends StatefulWidget {
  final Project project;

  const ChangeProjectTypeDialog({
    super.key,
    required this.project,
  });

  @override
  ChangeProjectTypeDialogState createState() => ChangeProjectTypeDialogState();
}

class ChangeProjectTypeDialogState extends State<ChangeProjectTypeDialog> {
  String currentProjectType = '';
  int currentStep = 1;

  @override
  void initState() {
    super.initState();
    currentProjectType = widget.project.type;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 1600;
    final isTablet = screenWidth >= 800 && screenWidth < 1600;
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
                                    Icons.build_circle_outlined,
                                    size: isLargeScreen ? 34 : 30,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    l10n.changeProjectTypeTitle,
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 26 : 22,
                                      fontFamily: 'CascadiaCode',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ]
                              ),
                              const SizedBox(height: 4),
                              if (screenWidth > 700)...[
                                Row(
                                  children: [                              
                                    Text(
                                      currentStep == 1
                                        ? l10n.changeProjectTypeStepOneSubtitle
                                        : l10n.changeProjectTypeStepTwoSubtitle,
                                      style: TextStyle(
                                        fontSize: screenWidth > 1200 ? 22 : 18,
                                        fontFamily: 'CascadiaCode',
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white24,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: screenWidth > 700 ? 12 : 6),
                        const Divider(color: Colors.white70),

                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth > 700 ? 15 : 5),
                            child: _buildCurrentStep(),
                          ),
                        ),

                        SizedBox(height: screenWidth > 700 ? 12 : 4),
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
                      onPressed: () => {
                        if (currentStep != 3) {
                          Navigator.of(context).pop()
                        }
                      }
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

  Widget _buildCurrentStep() {
    final l10n = AppLocalizations.of(context)!;
    switch (currentStep) {
      case 1:
        return StepProjectTypeSelection(
          projectType: widget.project.type,
          onSelectionChanged: (newProjectType) {
            setState(() {
              currentProjectType = newProjectType;
            });
          },
        );
      case 2:
        return StepProjectTypeSelectionConfirmation(
          currentProjectType: widget.project.type,
          newProjectType: currentProjectType,
        );
      case 3:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.redAccent),
              SizedBox(height: 20),
              Text(
                l10n.changeProjectTypeMigrating,
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
        );
      default:
        // Fallback for safety
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => {
            if (currentStep != 3) {
              Navigator.pop(context)
            }
          },
          child: Text(
            l10n.buttonCancel,
            style: const TextStyle(
              color: Colors.white54,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ),
        Row(
          children: [
            if (currentStep > 1)
              TextButton(
                onPressed: () => setState(() => currentStep--),
                child: Text(
                  l10n.buttonBack,
                  style: const TextStyle(
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
                currentStep == 1 ? l10n.buttonNext : l10n.buttonConfirm,
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
    final l10n = AppLocalizations.of(context)!;
    if (currentStep == 1) {
      if (currentProjectType != widget.project.type) {
        setState(() => currentStep = 2);
      }
    } else if (currentStep == 2) {
      // Step 2 confirmed – proceed to step 3: show loading and start migration
      setState(() => currentStep = 3);

      try {
        await ProjectTypeMigrator.migrateProjectType(
          project: widget.project,
          newProjectType: currentProjectType,
        );

        // Close dialog and maybe reopen the updated project or show success
        if (mounted) Navigator.of(context).pop('refresh');

      } catch (e, stack) {
        debugPrint('Error during project type migration: $e');
        debugPrint(stack.toString());

        if (mounted) {
          Future.microtask(() {
            AlertErrorDialog.show(
              context,
              l10n.changeProjectTypeErrorTitle,
              l10n.changeProjectTypeErrorMessage,
              tips: l10n.changeProjectTypeErrorTips,
            );
          });
        }
      }
    }
  }
}
