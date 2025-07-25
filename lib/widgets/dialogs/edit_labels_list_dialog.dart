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

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final smallScreen = (screenWidth < 1200) || (screenHeight < 750);

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
            padding: const EdgeInsets.only(left: 18),
            child: Column(
              children: [
                Expanded(
                  child: ReorderableListView.builder(
                    scrollController: widget.scrollController,
                    itemCount: _labels.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        // Adjust the newIndex if it's after the removal point
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        
                        // Move the item
                        final Label item = _labels.removeAt(oldIndex);
                        final TextEditingController controller = _controllers.removeAt(oldIndex);
                        _labels.insert(newIndex, item);
                        _controllers.insert(newIndex, controller);
                        
                        // Update labelOrder for all affected labels
                        for (int i = 0; i < _labels.length; i++) {
                          _labels[i] = _labels[i].copyWith(labelOrder: i);
                        }
                        
                        // Notify parent about the change
                        widget.onLabelsChanged(_labels);
                      });
                    },
                    itemBuilder: (context, index) {
                      // Add bounds checking
                      if (index >= _labels.length || index >= _controllers.length) {
                        return const SizedBox.shrink();
                      }

                      final label = _labels[index];
                      final controller = _controllers[index];
                      bool isEditing = false;
                      
                      // Create a unique key using a combination of label properties and index
                      final uniqueKey = ValueKey('${label.name}_${label.color}_$index');
                      return StatefulBuilder(
                        key: uniqueKey,
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
                                  height: smallScreen ? 38 : 48,
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 12),
                                      // Drag handle
                                      ReorderableDragStartListener(
                                        index: index,
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white10,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            Icons.drag_handle,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(width: 12),
                                      GestureDetector(
                                        onTap: () {
                                          widget.onColorTap(index);
                                        },
                                        child: Container(
                                          width: smallScreen ? 20 : 28,
                                          height: smallScreen ? 20 : 28,
                                          decoration: BoxDecoration(
                                            color: label.toColor(),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.white24, width: 1),
                                            // color: label.toColor(),
                                            // shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: SizedBox(
                                          height: smallScreen ? 34 : 44,
                                          child: TextField(
                                            controller: controller,
                                            cursorColor: Colors.redAccent,
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
                                              fontSize: smallScreen ? 18 : 22,
                                              color: Colors.white,
                                              fontFamily: 'CascadiaCode',
                                              fontWeight: FontWeight.normal,
                                            ),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: isEditing ? Colors.white10 : Colors.transparent,
                                              contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 8),
                                      // Three dots menu
                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                        ),
                                        iconSize: 30,
                                        onSelected: (String value) {
                                          switch (value) {
                                            case 'edit':
                                              setLocalState(() => isEditing = !isEditing);
                                              if (isEditing) {
                                                // Focus the text field
                                                FocusScope.of(context).requestFocus(FocusNode());
                                              } else if (controller.text != label.name) {
                                                // Save the edit
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
                                              break;
                                            case 'moveUp':
                                              if (index > 0) {
                                                setState(() {
                                                  // Swap with the item above
                                                  final Label item = _labels.removeAt(index);
                                                  final TextEditingController ctrl = _controllers.removeAt(index);
                                                  _labels.insert(index - 1, item);
                                                  _controllers.insert(index - 1, ctrl);
                                                  
                                                  // Update labelOrder for all affected labels
                                                  for (int i = 0; i < _labels.length; i++) {
                                                    _labels[i] = _labels[i].copyWith(labelOrder: i);
                                                  }
                                                  
                                                  // Notify parent about the change
                                                  widget.onLabelsChanged(_labels);
                                                });
                                              }
                                              break;
                                            case 'moveDown':
                                              if (index < _labels.length - 1) {
                                                setState(() {
                                                  // Swap with the item below
                                                  final Label item = _labels.removeAt(index);
                                                  final TextEditingController ctrl = _controllers.removeAt(index);
                                                  _labels.insert(index + 1, item);
                                                  _controllers.insert(index + 1, ctrl);
                                                  
                                                  // Update labelOrder for all affected labels
                                                  for (int i = 0; i < _labels.length; i++) {
                                                    _labels[i] = _labels[i].copyWith(labelOrder: i);
                                                  }
                                                  
                                                  // Notify parent about the change
                                                  widget.onLabelsChanged(_labels);
                                                });
                                              }
                                              break;
                                            case 'delete':
                                              try {
                                                setState(() {
                                                  final removedIndex = _labels.indexOf(label);
                                                  if (removedIndex != -1) {
                                                    _labels.removeAt(removedIndex);
                                                    _controllers[removedIndex].dispose();
                                                    _controllers.removeAt(removedIndex);
                                                    
                                                    // Update labelOrder for all affected labels
                                                    for (int i = 0; i < _labels.length; i++) {
                                                      _labels[i] = _labels[i].copyWith(labelOrder: i);
                                                    }
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
                                              break;
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                          PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(isEditing ? Icons.save : Icons.edit),
                                                SizedBox(width: 8),
                                                Text(isEditing ? 'Save' : 'Edit'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'moveUp',
                                            enabled: index > 0,
                                            child: Row(
                                              children: [
                                                Icon(Icons.arrow_upward_rounded),
                                                SizedBox(width: 8),
                                                Text('Move Up'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'moveDown',
                                            enabled: index < _labels.length - 1,
                                            child: Row(
                                              children: [
                                                Icon(Icons.arrow_downward_sharp),
                                                SizedBox(width: 8),
                                                Text('Move Down'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Delete', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
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
                    final encoder = const JsonEncoder.withIndent('  ');
                    final json = encoder.convert(_labels.map((l) => l.toMap()).toList());
                    // Pick a location to save the file (using file_picker or similar)
                    // Example using file_picker:
                    final result = await FilePicker.platform.saveFile(
                      dialogTitle: 'Save labels in JSON file',
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
