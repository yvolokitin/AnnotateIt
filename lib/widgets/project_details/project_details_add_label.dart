import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import '../../models/label.dart';
import '../dialogs/alert_error_dialog.dart';
import '../dialogs/color_picker_dialog.dart';

class ProjectDetailsAddLabel extends StatefulWidget {
  final List<Label> labels;
  final String projectType;
  final void Function(String name, String color) onAddNewLabel;

  const ProjectDetailsAddLabel({
    super.key,
    required this.labels,
    required this.projectType,
    required this.onAddNewLabel,
  });

  @override
  State<ProjectDetailsAddLabel> createState() => _ProjectDetailsAddLabelState();
}

class _ProjectDetailsAddLabelState extends State<ProjectDetailsAddLabel> {
  final TextEditingController _labelController = TextEditingController();
  String _labelColor = '#FF0000'; // Default color
  late List<Label> _labels;

  @override
  void initState() {
    super.initState();
    _labels = List.from(widget.labels); // Make a mutable local copy
  }

  String _generateRandomColor() {
    final random = (0xFFFFFF & (DateTime.now().millisecondsSinceEpoch * 997)).toRadixString(16).padLeft(6, '0');
    return '#$random';
  }

  void _addLabel() {
    final l10n = AppLocalizations.of(context)!;
    String newLabelName = _labelController.text.trim();

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

    widget.onAddNewLabel(newLabelName, _labelColor);
  }

  void _showColorPicker() {
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
                  color: Color(int.parse(_labelColor.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: TextField(
            controller: _labelController,
            decoration: InputDecoration(
              hintText: l10n.labelNameHint,
              hintStyle: TextStyle(
                color: Colors.white54,
                fontSize: screenWidth > 1200 ? 22 : 18,
                fontWeight: FontWeight.normal
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
            style: const TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(width: 20),

        ElevatedButton(
          onPressed: _addLabel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Colors.white70, width: 2),
            ),
          ),
          child: Text(
            l10n.createLabelButton,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth > 1200 ? 22 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
