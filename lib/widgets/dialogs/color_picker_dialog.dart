import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget {
  final String initialColor;
  final ValueChanged<String> onColorSelected;

  const ColorPickerDialog({
    required this.initialColor,
    required this.onColorSelected,
    super.key,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color selectedColor;

  static const List<Color> basicColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.brown,
    Colors.pink,
    Colors.teal,
    Color(0xFF336666),
    Color(0xFF888888),
    Color(0xFFCCCCCC),
    Color(0xFFFFC107),
    Colors.black,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    selectedColor = _fromHex(widget.initialColor);
  }

  Color _fromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // Add full opacity
    return Color(int.parse(hex, radix: 16));
  }

  String _toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: Colors.grey[800],
      title: Text(
        l10n.colorPickerTitle,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'CascadiaCode',
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(thickness: 1, color: Colors.white),
            const SizedBox(height: 20),

            ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.colorPickerBasicColors,
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'CascadiaCode',
                ),
              ),
            ),
            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: basicColors.map((color) {
                final isSelected = selectedColor == color;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        setState(() => selectedColor = color);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                          borderRadius: BorderRadius.circular(6),
                        ),
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
          child: Text(
            l10n.buttonCancel,
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onColorSelected(_toHex(selectedColor));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            l10n.buttonConfirm,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }
}
