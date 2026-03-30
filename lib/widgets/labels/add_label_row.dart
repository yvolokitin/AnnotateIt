import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../utils/color_utils.dart';
import '../dialogs/alert_error_dialog.dart';
import '../dialogs/color_picker_dialog.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';

/// Shared inline row for creating a new label: [color swatch] [name field] [add button].
///
/// Used in project details, project creation wizard, and anywhere labels
/// need to be created inline. Handles validation (empty, duplicate, binary limit).
class AddLabelRow extends StatefulWidget {
  final List<Label> existingLabels;
  final String projectType;
  final void Function(String name, String color) onAdd;

  const AddLabelRow({
    super.key,
    required this.existingLabels,
    required this.projectType,
    required this.onAdd,
  });

  @override
  State<AddLabelRow> createState() => _AddLabelRowState();
}

class _AddLabelRowState extends State<AddLabelRow> {
  final TextEditingController _controller = TextEditingController();
  late String _color;

  @override
  void initState() {
    super.initState();
    _color = generateColorByIndex(widget.existingLabels.length);
  }

  @override
  void didUpdateWidget(covariant AddLabelRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.existingLabels.length != widget.existingLabels.length) {
      _color = generateColorByIndex(widget.existingLabels.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Returns a validation error string, or null if valid.
  String? _validate(String name) {
    final l10n = AppLocalizations.of(context)!;
    if (name.isEmpty) return l10n.labelEmptyMessage;
    if (widget.existingLabels.any((l) => l.name.toLowerCase() == name.toLowerCase())) {
      return l10n.labelDuplicateMessage(name);
    }
    final isBinary = widget.projectType.toLowerCase() == 'binary classification';
    if (isBinary && widget.existingLabels.length >= 2) {
      return l10n.binaryLimitMessage;
    }
    return null;
  }

  void _submit() {
    final name = _controller.text.trim();
    final error = _validate(name);
    if (error != null) {
      final l10n = AppLocalizations.of(context)!;
      String title = l10n.labelEmptyTitle;
      if (name.isNotEmpty && widget.existingLabels.any((l) => l.name.toLowerCase() == name.toLowerCase())) {
        title = l10n.labelDuplicateTitle;
      } else if (widget.projectType.toLowerCase() == 'binary classification' && widget.existingLabels.length >= 2) {
        title = l10n.binaryLimitTitle;
      }
      AlertErrorDialog.show(context, title, error);
      return;
    }
    widget.onAdd(name, _color);
    setState(() {
      _color = generateColorByIndex(widget.existingLabels.length + 1);
      _controller.clear();
    });
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (_) => ColorPickerDialog(
        initialColor: _color,
        onColorSelected: (c) => setState(() => _color = c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final small = (screenWidth < 1200) || (screenHeight < 750);
    final swatchSize = small ? 38.0 : 48.0;
    final innerSize = small ? 20.0 : 28.0;
    final fontSize = small ? 18.0 : 22.0;

    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _pickColor,
            child: Container(
              width: swatchSize,
              height: swatchSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white70, width: 1),
              ),
              alignment: Alignment.center,
              child: Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  color: colorFromHex(_color),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: small ? 10 : 20),
        Expanded(
          child: SizedBox(
            height: swatchSize,
            child: TextField(
              controller: _controller,
              cursorColor: AppColors.accent,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: l10n.labelNameHint,
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: fontSize,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white70, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1),
                ),
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
        SizedBox(width: small ? 10 : 20),
        if (small)
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.accent, width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              onPressed: _submit,
              icon: const Icon(Icons.add, color: Colors.white),
              iconSize: 24,
              padding: const EdgeInsets.all(1),
              tooltip: l10n.createLabelButton,
            ),
          )
        else
          SizedBox(
            height: swatchSize,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
              child: Text(
                l10n.createLabelButton,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
