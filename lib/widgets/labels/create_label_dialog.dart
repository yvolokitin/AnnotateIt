import 'package:flutter/material.dart';

import '../../models/label.dart';
import '../../utils/color_utils.dart';
import '../dialogs/color_picker_dialog.dart';

/// Compact dialog for creating a single label (name + color).
///
/// Used from the annotator toolbar when no labels exist, or as a quick-add
/// from any screen. Returns the chosen (name, color) via [onCreateLabel],
/// or null if cancelled.
class CreateLabelDialog extends StatefulWidget {
  final List<Label> existingLabels;
  final Future<Label?> Function(String name, String color) onCreateLabel;

  const CreateLabelDialog({
    super.key,
    required this.existingLabels,
    required this.onCreateLabel,
  });

  /// Shows the dialog and returns the created [Label], or null.
  static Future<Label?> show({
    required BuildContext context,
    required List<Label> existingLabels,
    required Future<Label?> Function(String name, String color) onCreateLabel,
  }) {
    return showDialog<Label?>(
      context: context,
      builder: (_) => CreateLabelDialog(
        existingLabels: existingLabels,
        onCreateLabel: onCreateLabel,
      ),
    );
  }

  @override
  State<CreateLabelDialog> createState() => _CreateLabelDialogState();
}

class _CreateLabelDialogState extends State<CreateLabelDialog> {
  final _controller = TextEditingController();
  late String _color;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _color = generateColorByIndex(widget.existingLabels.length);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _submitting) return;

    if (widget.existingLabels.any((l) => l.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Label "$name" already exists')),
      );
      return;
    }

    setState(() => _submitting = true);
    final created = await widget.onCreateLabel(name, _color);
    if (!mounted) return;
    Navigator.pop(context, created);
  }

  void _openColorPicker() {
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
    final displayColor = colorFromHex(_color);
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24, width: 1),
      ),
      title: const Row(
        children: [
          Icon(Icons.label_outline, color: Colors.white, size: 28),
          SizedBox(width: 10),
          Text(
            'Create Label',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: _openColorPicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: displayColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white38, width: 1.5),
                    ),
                    child: const Icon(Icons.palette, color: Colors.white70, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'CascadiaCode',
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Label name',
                      hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'CascadiaCode'),
                      filled: true,
                      fillColor: Colors.grey[800],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: basicColors.map((c) {
                final hex = colorToHex(c);
                final isSelected = _color.toUpperCase().replaceAll('#', '') ==
                    hex.toUpperCase().replaceAll('#', '');
                return GestureDetector(
                  onTap: () => setState(() => _color = hex),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontFamily: 'CascadiaCode')),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Create',
            style: TextStyle(color: Colors.white, fontFamily: 'CascadiaCode', fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
