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
    final l10n = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final smallScreen = (screenWidth < 1200) || (screenHeight < 750);

    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _showColorPicker,
            child: Container(
              width: smallScreen ? 38 : 48,
              height: smallScreen ? 38 : 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white70, width: 1),
              ),
              alignment: Alignment.center,
              child: Container(
                width: smallScreen ? 20 : 28,
                height: smallScreen ? 20 : 28,
                decoration: BoxDecoration(
                  color: Color(int.parse(newLabelColor.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: smallScreen ? 10 : 20),
        Expanded(
          child: SizedBox(
            height: smallScreen ? 38 : 48,
            child: TextField(
              controller: labelController,
              cursorColor: Colors.redAccent,
              decoration: InputDecoration(
                hintText: l10n.labelNameHint,
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: smallScreen ? 18 : 22,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'CascadiaCode',
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 7,
                ),
                filled: false,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white70, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white70, width: 1),
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: smallScreen ? 18 : 22,
                fontWeight: FontWeight.normal,
                fontFamily: 'CascadiaCode',
              ),
            ),
          ),
        ),

        SizedBox(width: smallScreen ? 10 : 20),
        if (smallScreen)...[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.redAccent, width: 2),
              borderRadius: BorderRadius.circular(30),
              color: Colors.transparent,
            ),
            child: IconButton(
              onPressed: _addLabel,
              icon: const Icon(Icons.add, color: Colors.white),
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              tooltip: l10n.createLabelButton, // Optional for accessibility
            ),
          ),

        ] else ...[
          SizedBox(
            height: smallScreen ? 36 : 46,
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
                  fontSize: smallScreen ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'CascadiaCode',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
