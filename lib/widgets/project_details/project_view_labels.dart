import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../models/project.dart';
import '../../data/labels_database.dart';
import '../../data/annotation_database.dart';
import '../../session/user_session.dart';

import '../dialogs/alert_error_dialog.dart';
import '../dialogs/edit_labels_list_dialog.dart';
import '../dialogs/color_picker_dialog.dart';
import '../app_snackbar.dart';

import 'project_details_add_label.dart';

class ProjectViewLabels extends StatefulWidget {
  final Project project;

  final ValueChanged<List<Label>>? onLabelsUpdated;

  const ProjectViewLabels({
    required this.project,
    this.onLabelsUpdated,
    super.key,
  });

  @override
  ProjectViewLabelsState createState() => ProjectViewLabelsState();
}

class ProjectViewLabelsState extends State<ProjectViewLabels> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  void _showColorPicker(int index) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: widget.project.labels![index].color,
        onColorSelected: (newColor) async {
          final updatedLabel = widget.project.labels![index].copyWith(color: newColor);
          await LabelsDatabase.instance.updateLabel(updatedLabel);

          final updated = List<Label>.from(widget.project.labels!);
          updated[index] = updatedLabel;

          widget.onLabelsUpdated!(updated);
        },
      ),
    );
  }

  void _handleAddNewLabel(String name, String color) async {
    final newLabel = Label(
      id: -1, // will be set after DB insert
      labelOrder: widget.project.labels!.length,
      projectId: widget.project.id ?? 0,
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );

    try {
      final insertedId = await LabelsDatabase.instance.insertLabel(newLabel);
      final finalLabel = newLabel.copyWith(id: insertedId);

      final updated = List<Label>.from(widget.project.labels!);
      updated.add(finalLabel);
      widget.onLabelsUpdated?.call(updated);

      // Check if this is the first label and if we should set it as default
      if (updated.length == 1) {
        final shouldSetFirstLabelAsDefault = UserSession.instance.getUser().labelsSetFirstAsDefault;
        if (shouldSetFirstLabelAsDefault) {
          await LabelsDatabase.instance.setLabelAsDefault(insertedId, widget.project.id!);
        }
      }

    } catch (e) {
      AlertErrorDialog.show(
        context,
        'Failed to insert label',
        'Failed to insert label: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.project.labels;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final smallScreen = (screenWidth < 700) || (screenHeight < 750);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(smallScreen ? 7 : 20),
          child: Row(
            children: [
              Text(
                'Labels (${labels.length})',
                style: TextStyle(
                  fontSize: smallScreen ? 18 : 22,
                  color: Colors.white,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.grey),

        Container(
          margin: EdgeInsets.all(screenWidth > 1600 ? 20 : 6),
          padding: EdgeInsets.all(screenWidth > 1600 ? 20 : 6),
          decoration: BoxDecoration(
            color: Colors.grey[800],
          ),
          child: ProjectDetailsAddLabel(
            labels: labels,
            projectId: widget.project.id ?? 0,
            projectType: widget.project.type,
            onAddNewLabel: _handleAddNewLabel,
          ),
        ),

        Expanded(
          child: Container(
            margin: EdgeInsets.all(screenWidth > 1600 ? 15 : 6),
            padding: EdgeInsets.all(screenWidth > 1600 ? 15 : 6),
            child: EditLabelsListDialog(
              projectId: widget.project.id!,
              projectType: widget.project.type,
              labels: labels,
              scrollController: _scrollController,
              onColorTap: _showColorPicker,
              onLabelsChanged: (updatedLabels) async {
                final previousLabels = List<Label>.from(labels);
                final List<Label> newLabels = [];

                // 1. Handle updates
                for (final label in updatedLabels) {
                  if (label.id > 0) {
                    await LabelsDatabase.instance.updateLabel(label);
                    newLabels.add(label);
                  } else if (label.id == -1) {
                    // New label, insert it
                    final insertedId = await LabelsDatabase.instance.insertLabel(label);
                    newLabels.add(label.copyWith(id: insertedId));
                  }
                }

                // 2. Handle deletions
                final deletedLabels = previousLabels.where((oldLabel) =>
                  !updatedLabels.any((newLabel) => newLabel.id == oldLabel.id)).toList();
                for (final label in deletedLabels) {
                  // Only show snackbar if label has valid ID (>0)
                  if (label.id > 0) {
                    // Check if we should delete annotations when label is removed
                    final shouldDeleteAnnotations = UserSession.instance.getUser().labelsDeleteAnnotations;
                    if (shouldDeleteAnnotations) {
                      // Delete annotations associated with this label
                      await AnnotationDatabase.instance.deleteAnnotationsByLabelId(label.id);
                      // Show snackbar that annotations were removed together with the label
                      AppSnackbar.show(
                        context,
                        'Label "${label.name}" and all its annotations have been removed.',
                        backgroundColor: Colors.orange,
                        textColor: Colors.black,
                      );
                    } else {
                      // Show snackbar that existing annotations will show as Unknown
                      AppSnackbar.show(
                        context,
                        'Label "${label.name}" removed. Existing annotations with this label will show as Unknown and need to be re-labeled.',
                        backgroundColor: Colors.orange,
                        textColor: Colors.black,
                      );
                    }
                  }
                  
                  // Delete the label
                  await LabelsDatabase.instance.deleteLabel(label.id);
                }

                widget.onLabelsUpdated?.call(newLabels);
              },
            ),
          ),
        ),
      ],
    );
  }
}
