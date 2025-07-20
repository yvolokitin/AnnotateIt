import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../models/project.dart';
import '../../data/labels_database.dart';

import '../dialogs/edit_labels_list_dialog.dart';
import '../dialogs/color_picker_dialog.dart';

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
        onColorSelected: (newColor) {
          _handleLabelColorChange(index, newColor);
        },
      ),
    );
  }

  void _handleLabelColorChange(int index, String newColor) async {
    final updatedLabel = widget.project.labels![index].copyWith(color: newColor);
    await LabelsDatabase.instance.updateLabel(updatedLabel);

    final updated = List<Label>.from(widget.project.labels!);
    updated[index] = updatedLabel;

    widget.onLabelsUpdated!(updated);
  }

  void _handleAddNewLabel(String name, String color) async {
    final newLabel = Label(
      id: null, // will be set after DB insert
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
      print('Added new label "$name" with color $color');

    } catch (e) {
      print('Failed to insert label: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Ensure that labels are not null
    assert(widget.project.labels != null, 'Error: Project labels must not be null!');
    
    final labels = widget.project.labels!;
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Text(
                'Labels',
                style: const TextStyle(
                  fontSize: 24,
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
                // 1. Handle updates
                for (final label in updatedLabels) {
                  if (label.id != null) {
                    await LabelsDatabase.instance.updateLabel(label);
                  }
                }
                // 2. Handle deletions
                final deletedLabels = previousLabels.where((oldLabel) =>
                  !updatedLabels.any((newLabel) => newLabel.id == oldLabel.id)).toList();
                for (final label in deletedLabels) {
                  if (label.id != null) {
                    await LabelsDatabase.instance.deleteLabel(label.id!);
                  }
                }
                widget.onLabelsUpdated?.call(updatedLabels);
                print('PROJECT VIEW: Labels updated: ${updatedLabels.map((l) => l.name).join(', ')}');
              },
            ),
          ),
        ),
      ],
    );
  }
}
