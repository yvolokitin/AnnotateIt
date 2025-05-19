import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/label.dart';

import '../dialogs/alert_error_dialog.dart';
import '../dialogs/color_picker_dialog.dart';
import '../dialogs/label_list_dialog.dart';

class CreateNewProjectStepLabels extends StatefulWidget {
  final List<Map<String, dynamic>> createdLabels;
  final void Function(List<Map<String, dynamic>>)? onLabelsChanged;
  final String projectType;

  const CreateNewProjectStepLabels({
    Key? key,
    required this.createdLabels,
    required this.projectType,
    this.onLabelsChanged,
  }) : super(key: key);

  @override
  State<CreateNewProjectStepLabels> createState() => _CreateNewProjectStepLabelsState();
}

class _CreateNewProjectStepLabelsState extends State<CreateNewProjectStepLabels> {
  final TextEditingController _labelController = TextEditingController();
  final List<Label> _labels = [];
  late final ScrollController _scrollController;
  late String _labelColor;

  @override
  void initState() {
    super.initState();
    _labelColor = _generateRandomColor();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _generateRandomColor() {
    Random random = Random();
    return '#${(random.nextInt(0xFFFFFF) + 0x1000000).toRadixString(16).substring(1).toUpperCase()}';
  }

  void _showNewLabelColorPicker() {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: _labelColor,
        onColorSelected: (newColor) {
          setState(() {
            _labelColor = newColor;
          });
        },
      ),
    );
  }

  void _showColorPicker(int index) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: _labels[index].color,
        onColorSelected: (newColor) {
          setState(() {
            _labels[index] = _labels[index].copyWith(color: newColor);
          });
          widget.onLabelsChanged?.call(
            _labels.map((e) => {'name': e.name, 'color': e.color}).toList(),
          );
        },
      ),
    );
  }

  void _addLabel() {
    String newLabelName = _labelController.text.trim();

    final l10n = AppLocalizations.of(context)!;
    if (newLabelName.isEmpty) {
      AlertErrorDialog.show(
        context,
        l10n.labelEmptyTitle,
        l10n.labelEmptyMessage,
        tips: l10n.labelEmptyTips,
      );
      return;
    }

    if (_labels.any((label) => label.name.toLowerCase() == newLabelName.toLowerCase())) {
      AlertErrorDialog.show(
        context,
        l10n.labelDuplicateTitle,
        l10n.labelDuplicateMessage(newLabelName),
        tips: l10n.labelDuplicateTips,
      );
      return;
    }

    final isBinary = widget.projectType.toLowerCase() == 'binary classification';
    if (isBinary && _labels.length >= 2) {
      AlertErrorDialog.show(
        context,
        l10n.binaryLimitTitle,
        l10n.binaryLimitMessage,
        tips: l10n.binaryLimitTips,
      );
      return;
    }

    setState(() {
      _labels.add(Label(
        projectId: 0,
        name: newLabelName,
        color: _labelColor,
      ));
      _labelController.clear();
      _labelColor = _generateRandomColor();
    });

    widget.onLabelsChanged?.call(
      _labels.map((e) => {'name': e.name, 'color': e.color}).toList(),
    );
  }

  void _removeLabel(Label label) {
    setState(() => _labels.remove(label));
    widget.onLabelsChanged?.call(
      _labels.map((e) => {'name': e.name, 'color': e.color}).toList(),
    );
  }

  String _getLabelCreationNote(String type) {
    final l10n = AppLocalizations.of(context)!;
    final lower = type.toLowerCase();
    if (lower == 'binary classification') {
      return l10n.noteBinaryClassification;
    } else if (lower == 'multi-class classification') {
      return l10n.noteMultiClassClassification;
    } else if (lower == 'object detection' || lower == 'instance segmentation') {
      return l10n.noteDetectionOrSegmentation;
    } else {
      return l10n.noteDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLabelCreationNote(widget.projectType),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.white),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _showNewLabelColorPicker,
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(int.parse(_labelColor.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _labelController,
                decoration: InputDecoration(
                  hintText: l10n.labelNameHint,
                  hintStyle: const TextStyle(color: Colors.white54, fontWeight: FontWeight.normal),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _addLabel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(
                l10n.createLabelButton,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(l10n.createdLabelsTitle, style: const TextStyle(fontSize: 20, color: Colors.white)),
        ),
        const SizedBox(height: 12),

        LabelListDialog(
          labels: _labels,
          scrollController: _scrollController,
          onColorTap: _showColorPicker,
          onNameChanged: (index, newName) {
            setState(() {
              _labels[index] = _labels[index].copyWith(name: newName);
            });
            widget.onLabelsChanged?.call(
              _labels.map((e) => {'name': e.name, 'color': e.color}).toList(),
            );
          },
          onDelete: (label) {
            setState(() {
              _labels.remove(label);
            });
            widget.onLabelsChanged?.call(
              _labels.map((e) => {'name': e.name, 'color': e.color}).toList(),
            );
          },
          onColorChanged: (index, newColor) {
            setState(() {
              _labels[index] = _labels[index].copyWith(color: newColor);
            });
            widget.onLabelsChanged?.call(
              _labels.map((e) => {'name': e.name, 'color': e.color}).toList(),
            );
          },
)

/*
Expanded(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thickness: 8,
      radius: const Radius.circular(8),
      trackVisibility: true,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _labels.length,
          itemBuilder: (context, index) {
            final label = _labels[index];
            final TextEditingController controller = TextEditingController(text: label.name);
            bool isEditing = false;

            return StatefulBuilder(
              builder: (context, setLocalState) {
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        // Color circle
                        GestureDetector(
                          onTap: () => _showColorPicker(index),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(int.parse(label.color.replaceFirst('#', '0xFF'))),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Editable name
                        Expanded(
                          child: TextField(
                            controller: controller,
                            enabled: isEditing,
                            onSubmitted: (value) {
                              setState(() {
                                _labels[index] = label.copyWith(name: value.trim());
                              });
                              setLocalState(() => isEditing = false);
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isEditing ? Colors.white10 : Colors.transparent,
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(30)),
                              ),
                              hintText: 'Label name',
                              hintStyle: const TextStyle(color: Colors.white54),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Edit/Save button
                        IconButton(
                          icon: Icon(isEditing ? Icons.save : Icons.edit, color: Colors.white),
                          iconSize: 32,
                          onPressed: () {
                            if (isEditing) {
                              setState(() {
                                _labels[index] = label.copyWith(name: controller.text.trim());
                              });
                            }
                            setLocalState(() => isEditing = !isEditing);
                          },
                        ),

                        // Delete
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          iconSize: 32,
                          onPressed: () => _removeLabel(label),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ),
  ),
),
*/
      ],
    );
  }
}
