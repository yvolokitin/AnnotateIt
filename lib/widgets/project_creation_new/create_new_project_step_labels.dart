import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import '../../models/label.dart';

import '../dialogs/alert_error_dialog.dart';
import '../dialogs/color_picker_dialog.dart';
import '../dialogs/edit_labels_list_dialog.dart';

class CreateNewProjectStepLabels extends StatefulWidget {
  final List<Map<String, dynamic>> createdLabels;
  final void Function(List<Map<String, dynamic>>)? onLabelsChanged;
  final String projectType;

  const CreateNewProjectStepLabels({
    super.key,
    required this.createdLabels,
    required this.projectType,
    this.onLabelsChanged,
  });

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
        labelOrder: 0,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (screenWidth > 1200)...[
          Text(
            _getLabelCreationNote(widget.projectType),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.white70),
          ),
          const SizedBox(height: 30),
        ],

        Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _showNewLabelColorPicker,
                child: Container(
                  width: screenWidth > 1200 ? 48 : 38,
                  height: screenWidth > 1200 ? 48 : 38,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orangeAccent, width: 1),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: screenWidth > 1200 ? 28 : 22,
                    height: screenWidth > 1200 ? 28 : 22,
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
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.normal,
                    fontSize: screenWidth > 1200 ? 22 : 18,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                  ),
                ),
                style: TextStyle(
                  fontSize: screenWidth > 1200 ? 22 : 18,
                  color: Colors.white,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),

            const SizedBox(width: 20),
            SizedBox(
              height: screenWidth > 1200 ? 46 : 36,
              child: ElevatedButton(
                onPressed: _addLabel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
                child: Text(
                  l10n.createLabelButton,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth > 1200 ? 22 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          ],
        ),

        Flexible(
          child: EditLabelsListDialog(
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
          ),
        ),
      ],
    );
  }
}
