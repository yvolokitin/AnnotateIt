import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../utils/color_utils.dart';
import '../dialogs/color_picker_dialog.dart';
import '../dialogs/edit_labels_list_dialog.dart';
import '../labels/add_label_row.dart';
import '../../gen_l10n/app_localizations.dart';

class CreateNewProjectStepLabels extends StatefulWidget {
  final int projectId;
  final String projectType;
  final List<Label> labels;
  final Function(List<Label>) onLabelsUpdated;

  const CreateNewProjectStepLabels({
    required this.projectId,
    required this.projectType,
    required this.labels,
    required this.onLabelsUpdated,
    super.key,
  });

  @override
  State<CreateNewProjectStepLabels> createState() => _CreateNewProjectStepLabelsState();
}

class _CreateNewProjectStepLabelsState extends State<CreateNewProjectStepLabels> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showColorPicker(int index) {
    showDialog(
      context: context,
      builder: (_) => ColorPickerDialog(
        initialColor: widget.labels[index].color,
        onColorSelected: (newColor) {
          final updated = List<Label>.from(widget.labels);
          updated[index] = updated[index].copyWith(color: newColor);
          widget.onLabelsUpdated(updated);
        },
      ),
    );
  }

  void _handleAdd(String name, String color) {
    final newLabel = Label(
      id: -1,
      labelOrder: widget.labels.length,
      projectId: widget.projectId,
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );
    final updated = List<Label>.from(widget.labels)..add(newLabel);
    widget.onLabelsUpdated(updated);
  }

  String _getLabelCreationNote(String type) {
    final l10n = AppLocalizations.of(context)!;
    final lower = type.toLowerCase();
    if (lower == 'binary classification') return l10n.noteBinaryClassification;
    if (lower == 'multi-class classification') return l10n.noteMultiClassClassification;
    if (lower == 'object detection' || lower == 'instance segmentation') return l10n.noteDetectionOrSegmentation;
    return l10n.noteDefault;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final small = (screenWidth < 1200) || (screenHeight < 750);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!small) ...[
          Text(
            _getLabelCreationNote(widget.projectType),
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'CascadiaCode',
              color: Colors.white70,
            ),
          ),
          SizedBox(height: screenWidth > 1600 ? 30 : 10),
        ],
        AddLabelRow(
          existingLabels: widget.labels,
          projectType: widget.projectType,
          onAdd: _handleAdd,
        ),
        const SizedBox(height: 10),
        Flexible(
          child: EditLabelsListDialog(
            projectId: widget.projectId,
            projectType: widget.projectType,
            labels: widget.labels,
            scrollController: _scrollController,
            onColorTap: _showColorPicker,
            onLabelsChanged: (updatedLabels) {
              widget.onLabelsUpdated(updatedLabels);
            },
          ),
        ),
      ],
    );
  }
}
