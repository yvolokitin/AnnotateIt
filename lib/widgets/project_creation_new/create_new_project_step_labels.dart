import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../utils/color_utils.dart';
import '../dialogs/alert_error_dialog.dart';
import '../dialogs/color_picker_dialog.dart';
import '../dialogs/edit_labels_list_dialog.dart';
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
  final TextEditingController labelController = TextEditingController();
  late final ScrollController scrollController;
  late String newLabelColor;

  @override
  void initState() {
    super.initState();

    newLabelColor = generateColorByIndex(widget.labels.length);
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    labelController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _showNewLabelColorPicker() {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: newLabelColor,
        onColorSelected: (newColor) {
          setState(() {
            newLabelColor = newColor;
          });
        },
      ),
    );
  }

  void _showColorPicker(int index) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: widget.labels[index].color,
        onColorSelected: (newColor) async {
          final updatedLabel = widget.labels[index].copyWith(color: newColor);
          final updated = List<Label>.from(widget.labels);
          updated[index] = updatedLabel;
          widget.onLabelsUpdated(updated);
        },
      ),
    );
  }

  void _addLabel() {
    String newLabelName = labelController.text.trim();
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

    if (widget.labels.any((label) => label.name.toLowerCase() == newLabelName.toLowerCase())) {
      AlertErrorDialog.show(
        context,
        l10n.labelDuplicateTitle,
        l10n.labelDuplicateMessage(newLabelName),
        tips: l10n.labelDuplicateTips,
      );
      return;
    }

    final isBinary = widget.projectType.toLowerCase() == 'binary classification';
    if (isBinary && widget.labels.length >= 2) {
      AlertErrorDialog.show(
        context,
        l10n.binaryLimitTitle,
        l10n.binaryLimitMessage,
        tips: l10n.binaryLimitTips,
      );
      return;
    }

    final newLabel = Label(
      id: null, // will be set after DB insert
      labelOrder: widget.labels.length,
      projectId: widget.projectId,
      name: newLabelName,
      color: newLabelColor,
      createdAt: DateTime.now(),
    );

    final updated = List<Label>.from(widget.labels);
    updated.add(newLabel);
    widget.onLabelsUpdated.call(updated);

    setState(() {
      newLabelColor = generateColorByIndex(widget.labels.length+1);
      labelController.clear();
    });
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
                      color: Color(int.parse(newLabelColor.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(width: screenWidth > 650 ? 20 : 5),
            Expanded(
              child: TextField(
                controller: labelController,
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
            projectId: widget.projectId,
            projectType: widget.projectType,
            labels: widget.labels,
            scrollController: scrollController,
            onColorTap: _showColorPicker,
            onLabelsChanged: (updatedLabels) {
              widget.onLabelsUpdated.call(updatedLabels);
            },
          ),
        ),
      ],
    );
  }
}
