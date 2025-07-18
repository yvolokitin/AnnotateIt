import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../models/project.dart';
import '../../data/labels_database.dart';

import '../dialogs/edit_labels_list_dialog.dart';
import '../dialogs/color_picker_dialog.dart';

import 'project_details_add_label.dart';

class ProjectViewLabels extends StatefulWidget {
  final Project project;
  // final List<Label> labels;

  final ValueChanged<List<Label>>? onLabelsUpdated;

  const ProjectViewLabels({
    required this.project,
    // required this.labels,
    this.onLabelsUpdated,
    super.key,
  });

  @override
  ProjectViewLabelsState createState() => ProjectViewLabelsState();
}

class ProjectViewLabelsState extends State<ProjectViewLabels> with TickerProviderStateMixin {
  late List<Label> labels;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    labels = List.from(widget.project.labels ?? []);
  }

  void _showColorPicker(int index) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: labels[index].color,
        onColorSelected: (newColor) {
          _handleLabelColorChange(index, newColor);
        },
      ),
    );
  }

  void _handleLabelColorChange(int index, String newColor) async {
    final updatedLabel = labels[index].copyWith(color: newColor);
    await LabelsDatabase.instance.updateLabel(updatedLabel);

    final updated = List<Label>.from(labels);
    updated[index] = updatedLabel;

    // Update project.labels as well
    if (widget.project.labels != null && widget.project.labels!.length > index) {
      widget.project.labels![index] = updatedLabel;
    }

    _updateLabels(updated);
  }

  void _updateLabels(List<Label> updated) {
    setState(() {
      labels = updated;
    });
    widget.onLabelsUpdated!(updated);
  }

  void _handleAddNewLabel(String name, String color) async {
    final newLabel = Label(
      id: null, // will be set after DB insert
      labelOrder: labels.length,
      projectId: widget.project.id ?? 0,
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );

    try {
      final insertedId = await LabelsDatabase.instance.insertLabel(newLabel);
      final finalLabel = newLabel.copyWith(id: insertedId);

      setState(() {
        labels.add(finalLabel);
        widget.project.labels ??= [];
        widget.project.labels!.add(finalLabel);
      });

      // _updateLabels([...labels]);
      // Notify parent only once, with the updated list
      widget.onLabelsUpdated?.call(List<Label>.from(labels));

      print('Added new label "$name" with color $color');
    } catch (e) {
      print('Failed to insert label: $e');
    }
  }

  void _handleDeleteLabel(Label label) async {
    if (label.id == null) {
      print('Cannot delete label without ID');
      return;
    }

    try {
      final deletedCount = await LabelsDatabase.instance.deleteLabel(label.id!);
      if (deletedCount > 0) {
        setState(() {
          labels.removeWhere((l) => l.id == label.id);
          widget.project.labels?.removeWhere((l) => l.id == label.id);
        });

        _updateLabels([...labels]);
        print('Deleted label "${label.name}"');
      } else {
        print('Label with id ${label.id} not found in DB');
      }
    } catch (e) {
      print('Failed to delete label: $e');
    }
  }

  void _handleLabelNameChange(int index, String newName) async {
    final updatedLabel = labels[index].copyWith(name: newName);
    await LabelsDatabase.instance.updateLabel(updatedLabel);

    final updated = List<Label>.from(labels);
    updated[index] = updatedLabel;
    _updateLabels(updated);
  }

  @override
  Widget build(BuildContext context) {
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
              labels: widget.project.labels ?? [],
              scrollController: _scrollController,
              onColorTap: _showColorPicker,
              onNameChanged: _handleLabelNameChange,
              onDelete:  _handleDeleteLabel,
              onColorChanged: _handleLabelColorChange,
            ),
          ),
        ),
      ],
    );
  }
}
