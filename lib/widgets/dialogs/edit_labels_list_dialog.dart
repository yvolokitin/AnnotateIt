import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';


import '../../gen_l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../models/label.dart';

import 'alert_error_dialog.dart';
import 'no_labels_dialog.dart';

class EditLabelsListDialog extends StatelessWidget {
  final int projectId;
  final List<Label> labels;
  final ScrollController scrollController;

  final void Function(int index) onColorTap;
  final void Function(Label label) onDelete;
  final void Function(int index, String newName) onNameChanged;
  final void Function(int index, String newColor) onColorChanged;
  
  const EditLabelsListDialog({
    super.key,
    required this.projectId,
    required this.labels,
    required this.scrollController,
    required this.onColorTap,
    required this.onNameChanged,
    required this.onDelete,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;

    if (labels.isEmpty) {
      return NoLabelsDialog(
        projectId: projectId,
        onLabelsImported: (importedLabels) {
          // Handle imported labels
        }
      );

    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          thickness: 8,
          trackVisibility: true,
          child: Padding(
            padding: const EdgeInsets.only(right: 26, left: 18),
            child: Column(
              children: [
                Expanded(
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
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                ),
                                child: SizedBox(
                                  height: 60,
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () {
                                          onColorTap(index);
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: label.toColor(),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: SizedBox(
                                          height: 46,
                                          child: TextField(
                                            controller: controller,
                                            enabled: isEditing,
                                            onSubmitted: (value) {
                                              final newName = value.trim();
                                              final isDuplicate = labels.any((l) =>
                                                  l.name.toLowerCase() == newName.toLowerCase() &&
                                                  l != label);
                                              if (isDuplicate) {
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
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontFamily: 'CascadiaCode',
                                              fontWeight: FontWeight.normal,
                                            ),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: isEditing ? Colors.white10 : Colors.transparent,
                                              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(
                                          isEditing ? Icons.save : Icons.edit,
                                          color: Colors.white,
                                        ),
                                        iconSize: 30,
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

                                      // move down and up buttons
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(
                                          Icons.arrow_downward_sharp,
                                          color: (index == (labels.length - 1)) ? Colors.white24 : Colors.white,
                                        ),
                                        iconSize: 30,
                                        onPressed: () { },
                                      ),

                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(
                                          Icons.arrow_upward_rounded,
                                          color: (index == 0) ? Colors.white24 : Colors.white,
                                        ),
                                        iconSize: 30,
                                        onPressed: () { },
                                      ),

                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.white),
                                        iconSize: 30,
                                        onPressed: () => onDelete(label),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Convert labels to JSON
                    // final json = jsonEncode(labels.map((l) => l.toMap()).toList());
                    final encoder = const JsonEncoder.withIndent('  ');
                    final json = encoder.convert(labels.map((l) => l.toMap()).toList());
                    // Pick a location to save the file (using file_picker or similar)
                    // Example using file_picker:
                    final result = await FilePicker.platform.saveFile(
                      dialogTitle: 'Save labels as JSON',
                      fileName: 'labels.json',
                    );
                    if (result != null) {
                      final file = File(result);
                      await file.writeAsString(json);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.white70, width: 1),
                    ),
                  ),
                  child: Text(
                    'Export Labels',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth > 1200 ? 18 : 16,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'CascadiaCode',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
