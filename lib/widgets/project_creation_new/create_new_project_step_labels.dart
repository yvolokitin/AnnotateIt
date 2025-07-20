import 'dart:math';
import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

import '../../models/label.dart';

import '../dialogs/alert_error_dialog.dart';
import '../dialogs/color_picker_dialog.dart';
import '../dialogs/edit_labels_list_dialog.dart';

class CreateNewProjectStepLabels extends StatefulWidget {
  final int projectId;
  final String projectType;
  final List<Map<String, dynamic>> createdLabels;
  final void Function(List<Map<String, dynamic>>)? onLabelsChanged;

  const CreateNewProjectStepLabels({
    required this.projectId,
    required this.projectType,
    required this.createdLabels,
    this.onLabelsChanged,
    super.key,
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
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.normal,
              color: Colors.white70,
            ),
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

            SizedBox(width: screenWidth > 650 ? 20 : 5),
            Expanded(
              child: TextField(
                controller: _labelController,
                decoration: InputDecoration(
                  hintText: l10n.labelNameHint,
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'CascadiaCode',
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
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),

            SizedBox(width: screenWidth > 650 ? 20 : 5),
            
            if (screenWidth >= 650)...[
              SizedBox(
                height: screenWidth > 1200 ? 46 : (screenWidth > 640) ? 36 : 24,
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
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth > 1200 ? 22 : 20,
                    ),
                  ),
                ),
              ),
            ],
          
          if (screenWidth < 650)...[
            IconButton(
              onPressed: _addLabel,
              icon: const Icon(Icons.add_circle_outline, color: Colors.redAccent),
              tooltip: l10n.createLabelButton,
              iconSize: 28,
            ),
          ],
          ],
        ),

        const SizedBox(height: 10),

        Flexible(
          child: EditLabelsListDialog(
            projectId: 0,
            projectType: widget.projectType,
            labels: _labels,
            scrollController: _scrollController,
            onColorTap: _showColorPicker,

            onLabelsChanged: (updatedLabels) {
              setState(() {
                _labels
                  ..clear()
                  ..addAll(updatedLabels);
              });
              widget.onLabelsChanged?.call(
                updatedLabels.map((e) => {'name': e.name, 'color': e.color}).toList(),
              );
            },

          ),
        ),
      ],
    );
  }
}
