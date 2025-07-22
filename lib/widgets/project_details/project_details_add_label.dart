import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../utils/color_utils.dart';
import '../dialogs/alert_error_dialog.dart';
import '../dialogs/color_picker_dialog.dart';
import '../../gen_l10n/app_localizations.dart';

class ProjectDetailsAddLabel extends StatefulWidget {
  final int projectId;
  final String projectType;
  final List<Label> labels;

  final void Function(String name, String color) onAddNewLabel;

  const ProjectDetailsAddLabel({
    super.key,
    required this.labels,
    required this.projectId,
    required this.projectType,
    required this.onAddNewLabel,
  });

  @override
  State<ProjectDetailsAddLabel> createState() => _ProjectDetailsAddLabelState();
}

class _ProjectDetailsAddLabelState extends State<ProjectDetailsAddLabel> {
  final TextEditingController labelController = TextEditingController();
  late String newLabelColor;

  @override
  void initState() {
    super.initState();
    newLabelColor = generateColorByIndex(widget.labels.length);
  }

  void _addLabel() {
    final l10n = AppLocalizations.of(context)!;
    String newLabelName = labelController.text.trim();

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

    widget.onAddNewLabel(newLabelName, newLabelColor);
    setState(() {
      newLabelColor = generateColorByIndex(widget.labels.length+1);
      labelController.clear();
    });
  }

  void _showColorPicker() {
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _showColorPicker,
            child: Container(
              width: screenWidth > 1200 ? 48 : 38,
              height: screenWidth > 1200 ? 48 : 38,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white70, width: 1),
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
        SizedBox(width: 20),
        Expanded(
          child: TextField(
            controller: labelController,
            decoration: InputDecoration(
              hintText: l10n.labelNameHint,
              hintStyle: TextStyle(
                color: Colors.white54,
                fontSize: screenWidth > 1200 ? 22 : 18,
                fontWeight: FontWeight.normal,
                fontFamily: 'CascadiaCode',
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              filled: false,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white70, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white70, width: 1),
              ),
            ),
            style: const TextStyle(color: Colors.white, fontFamily: 'CascadiaCode',),
          ),
        ),
        SizedBox(width: 20),

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
                fontFamily: 'CascadiaCode',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
