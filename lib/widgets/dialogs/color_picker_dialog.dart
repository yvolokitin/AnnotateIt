import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/color_utils.dart' as app_colors;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../utils/theme.dart';

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

  @override
  void initState() {
    super.initState();
    selectedColor = app_colors.colorFromHex(widget.initialColor);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.white24, width: 1),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.palette, size: 32, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                l10n.colorPickerTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(thickness: 1, color: Colors.white),
            const SizedBox(height: 20),
            ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (color) => setState(() => selectedColor = color),
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
            const SizedBox(height: 25),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.colorPickerBasicColors,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: app_colors.basicColors.map((color) {
                final isSelected = selectedColor == color;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => setState(() => selectedColor = color),
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
                              ? [BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 4, spreadRadius: 1)]
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
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onColorSelected(app_colors.colorToHex(selectedColor));
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            l10n.buttonConfirm,
            style: const TextStyle(color: Colors.white,  fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
