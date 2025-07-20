import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';


import '../../gen_l10n/app_localizations.dart';
import '../../models/label.dart';

import 'alert_error_dialog.dart';
import 'no_labels_dialog.dart';

class EditLabelsListDialog extends StatefulWidget {
  final int projectId;
  final String projectType;
  final List<Label> labels;
  final ScrollController scrollController;

  final void Function(int index) onColorTap;
  final void Function(List<Label>) onLabelsChanged;

  const EditLabelsListDialog({
    super.key,
    required this.projectId,
    required this.projectType,
    required this.labels,
    required this.scrollController,
    required this.onColorTap,
    required this.onLabelsChanged,
  });

  @override
  State<EditLabelsListDialog> createState() => _EditLabelsListDialogState();
}

class _EditLabelsListDialogState extends State<EditLabelsListDialog> {
  late List<TextEditingController> _controllers;
  late List<Label> _labels;

  @override
  void initState() {
    super.initState();
    _labels = List.of(widget.labels);
    _controllers = _labels.map((label) => TextEditingController(text: label.name)).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EditLabelsListDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.labels != oldWidget.labels) {
      // Clean up old controllers
      for (final controller in _controllers) {
        controller.dispose();
      }
      // Update internal label state
      _labels = List.of(widget.labels);
      // Recreate controllers
      _controllers = _labels.map((label) => TextEditingController(text: label.name)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;

    if (_labels.isEmpty) {
      return NoLabelsDialog(
        projectId: widget.projectId,
        projectType: widget.projectType,
        onLabelsImported: (importedLabels) {
          setState(() {
            _labels = importedLabels;
          });
          widget.onLabelsChanged(_labels);
        }
      );

    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Scrollbar(
          controller: widget.scrollController,
          thumbVisibility: true,
          thickness: 8,
          trackVisibility: true,
          child: Padding(
            padding: const EdgeInsets.only(right: 26, left: 18),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: widget.scrollController,
                    itemCount: _labels.length,
                    itemBuilder: (context, index) {
                      // Add bounds checking
                      if (index >= _labels.length || index >= _controllers.length) {
                        return const SizedBox.shrink();
                      }

                      final label = _labels[index];
                      final controller = _controllers[index];
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
                                          widget.onColorTap(index);
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
                                              final isDuplicate = _labels.any((l) =>
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
                                              setState(() {
                                                _labels[index] = _labels[index].copyWith(name: newName);
                                              });
                                              widget.onLabelsChanged(_labels);
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
                                            final isDuplicate = _labels.any((l) =>
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
                                            setState(() {
                                              _labels[index] = _labels[index].copyWith(name: newName);
                                            });
                                            widget.onLabelsChanged(_labels);
                                          }
                                          setLocalState(() => isEditing = !isEditing);
                                        },
                                      ),

                                      // move down and up buttons
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(
                                          Icons.arrow_downward_sharp,
                                          color: (index == (_labels.length - 1)) ? Colors.white24 : Colors.white,
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
                                        // onPressed: () => widget.onDelete(label),
                                        onPressed: () {
                                          try {
                                            setState(() {
                                              final removedIndex = _labels.indexOf(label);
                                              if (removedIndex != -1) {
                                                _labels.removeAt(removedIndex);
                                                _controllers[removedIndex].dispose();
                                                _controllers.removeAt(removedIndex);
                                              }
                                            });
                                            widget.onLabelsChanged(_labels);
                                          } catch (e) {
                                            AlertErrorDialog.show(
                                              context,
                                              l10n.importLabelsFailedTitle,
                                              'Failed to delete label: ${e.toString()}',
                                              tips: 'Make sure the label still exists or is not used elsewhere.',
                                            );
                                          }
                                        },
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
                    final json = encoder.convert(_labels.map((l) => l.toMap()).toList());
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
