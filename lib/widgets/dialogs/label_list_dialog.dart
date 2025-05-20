import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/label.dart';
import '../dialogs/alert_error_dialog.dart';

class LabelListDialog extends StatelessWidget {
  final List<Label> labels;
  final ScrollController scrollController;
  final void Function(int index) onColorTap;
  final void Function(int index, String newName) onNameChanged;
  final void Function(Label label) onDelete;
  final void Function(int index, String newColor) onColorChanged;

  const LabelListDialog({
    super.key,
    required this.labels,
    required this.scrollController,
    required this.onColorTap,
    required this.onNameChanged,
    required this.onDelete,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(8),
          trackVisibility: true,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ListView.builder(
              controller: scrollController,
              itemCount: labels.length,
              itemBuilder: (context, index) {
                final label = labels[index];
                final TextEditingController controller =
                    TextEditingController(text: label.name);
                bool isEditing = false;

                return StatefulBuilder(
                  builder: (context, setLocalState) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                onColorTap(index);
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(label.color.replaceFirst('#', '0xFF'))),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: controller,
                                enabled: isEditing,
                                onSubmitted: (value) {
                                  final newName = value.trim();
                                  final isDuplicate = labels.any((l) =>
                                      l.name.toLowerCase() == newName.toLowerCase() &&
                                      l != label);
                                  if (isDuplicate) {
                                    final l10n = AppLocalizations.of(context)!;
                                    AlertErrorDialog.show(
                                      context,
                                      l10n.labelDuplicateTitle,
                                      l10n.labelDuplicateMessage(newName),
                                      tips: l10n.labelDuplicateTips,
                                    );
                                    return;
                                  }
                                  onNameChanged(index, newName);
                                  setLocalState(() => isEditing = false);
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: isEditing ? Colors.white10 : Colors.transparent,
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                  ),
                                  hintText: 'Label name',
                                  hintStyle: const TextStyle(color: Colors.white54),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                isEditing ? Icons.save : Icons.edit,
                                color: Colors.white,
                              ),
                              iconSize: 32,
                              onPressed: () {
                                if (isEditing) {
                                  final newName = controller.text.trim();
                                  final isDuplicate = labels.any((l) =>
                                      l.name.toLowerCase() == newName.toLowerCase() &&
                                      l != label);
                                  if (isDuplicate) {
                                    final l10n = AppLocalizations.of(context)!;
                                    AlertErrorDialog.show(
                                      context,
                                      l10n.labelDuplicateTitle,
                                      l10n.labelDuplicateMessage(newName),
                                      tips: l10n.labelDuplicateTips,
                                    );
                                    return;
                                  }
                                  onNameChanged(index, newName);
                                }
                                setLocalState(() => isEditing = !isEditing);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.white),
                              iconSize: 32,
                              onPressed: () => onDelete(label),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      // ),
    );
  }
}
