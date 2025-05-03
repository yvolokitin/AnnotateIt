import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import "color_picker_dialog.dart";

import '../pages/project_details_screen.dart';
import '../data/project_database.dart';
import '../data/labels_database.dart';

import '../models/project.dart';
import '../models/label.dart';

import '../pages/project_creation/create_new_project_dialog.dart';

class EditLabelsDialog extends StatefulWidget {
  final Project project;
  final VoidCallback onLabelsUpdated;
  final bool isFromCreationFlow;
  final List<Label>? initialLabels;

  const EditLabelsDialog({
    super.key,
    required this.project,
    required this.onLabelsUpdated,
    this.isFromCreationFlow = false,
    this.initialLabels,
  });

  @override
  EditLabelsDialogState createState() => EditLabelsDialogState();
}

class EditLabelsDialogState extends State<EditLabelsDialog> {
  final TextEditingController _labelController = TextEditingController();
  List<Label> _labels = [];

  // Default random color for new label
  late String _newLabelColor;

  @override
  void initState() {
    super.initState();
    
    // Load existing labels and colors
    _labels = List<Label>.from(widget.initialLabels ?? widget.project.labels ?? []);
    _newLabelColor = _generateRandomColor();
  }

  // Function to generate a random color for a new label
  String _generateRandomColor() {
    Random random = Random();
    return '#${(random.nextInt(0xFFFFFF) + 0x1000000).toRadixString(16).substring(1).toUpperCase()}';
  }

  // Add Label
  void _addLabel() {
    String newLabelName = _labelController.text.trim();
    print('_addLabel $newLabelName');

    if (newLabelName.isEmpty) {
      _showErrorMessage("Label name cannot be empty!", "Please, enter Label name.");
      return;

    } else if (_labels.any((label) => label.name.toLowerCase() == newLabelName.toLowerCase())) {
      _showErrorMessage("Duplicate label", "Label '$newLabelName' already exists! Please, enter a different name.");
      return;

    } else {
      setState(() {
        _labels.add(Label(
          projectId: widget.project.id ?? 0, // use 0 for new project, or set it later
          name: newLabelName,
          color: _newLabelColor,
        ));

        _labelController.clear();
        _newLabelColor = _generateRandomColor();
      });
    }
  }

  void _removeLabel(Label label) {
    setState(() {
      _labels.remove(label);
    });
  }

  // Save Updated Labels
  Future<void> _saveLabels() async {
    if (_labels.isEmpty) {
      _showErrorMessage(
        'Add at least one label',
        'You must create at least one label before continuing.',
      );
      return;
    }

    if (widget.isFromCreationFlow) {
      // Create new project
      final newProjectId = await ProjectDatabase.instance.createProject(
        Project(
          name: widget.project.name,
          type: widget.project.type,
          icon: widget.project.icon,
          creationDate: widget.project.creationDate,
          lastUpdated: DateTime.now(),
          defaultDatasetId: null,
          ownerId: widget.project.ownerId,
        ),
      );

      // Set new projectId on each label
      final labelsWithProjectId = _labels.map((label) {
        return label.copyWith(projectId: newProjectId);
      }).toList();

      await LabelsDatabase.instance.updateProjectLabels(newProjectId, labelsWithProjectId);
      // Navigator.pop(context); // Close dialog

      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(
            widget.project.copyWith(id: newProjectId),
          ),
        ),
      );

      // if user returned from project screen and we’re still alive
      if (!mounted) return;

    } else {
      // Update labels for existing project
      await LabelsDatabase.instance.updateProjectLabels(widget.project.id!, _labels);
      // Update project's lastUpdated timestamp
      await ProjectDatabase.instance.updateProjectLastUpdated(widget.project.id!);
      widget.onLabelsUpdated();
    }

    Navigator.pop(context, 'refresh');
  }

  void _showErrorMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: TextStyle(color: Colors.white)),
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.normal,
            fontSize: 24
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(int index) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: _labels[index].color,
        onColorSelected: (newColor) {
          setState(() {
            _labels[index] = _labels[index].copyWith(color: newColor);
          });
        },
      ),
    );
  }

  void _showNewLabelColorPicker() {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: _newLabelColor,
        onColorSelected: (newColor) {
          setState(() {
            _newLabelColor = newColor;
          });
        },
      ),
    );
  }

  // Safely converts a #RRGGBB or RRGGBB string into a Color object
  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    double dialogWidth = MediaQuery.of(context).size.width * 0.9; // 90% of window width
    double dialogHeight = MediaQuery.of(context).size.height * 0.9; // 90% of window height

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        padding: EdgeInsets.all(60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.isFromCreationFlow ? "Create labels for a New project" : "Edit Labels",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 12),

            // Label Input Field
            Row(
              children: [
                GestureDetector(
                  onTap: _showNewLabelColorPicker,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color(int.parse(_newLabelColor.replaceAll('#', '0xFF'))),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),

                SizedBox(width: 40),
                // Label Name Input
                Expanded(
                  child: TextField(
                    controller: _labelController,
                    decoration: InputDecoration(
                      labelText: "Label Name",
                      filled: true,
                      fillColor: Colors.grey[850],
                      errorText: _labels.any((label) => label.name.toLowerCase() == _labelController.text.trim().toLowerCase())
                        ? "Label already exists!"
                        : null,
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                SizedBox(width: 40),
                // Create Label Button
                ElevatedButton(
                  onPressed: _addLabel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text("Create Label", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 16),

            // List of Existing Labels
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _labels.length,
                itemBuilder: (context, index) {
                  final label = _labels[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Open Color Picker Dialog
                        GestureDetector(
                          onTap: () => _showColorPicker(index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _hexToColor(_labels[index].color),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                          ),
                        ),

                        SizedBox(width: 8),
                        // Label Name
                        Expanded(
                          child: Text(label.name, style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),

                        // Delete Button
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeLabel(label),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: TextStyle(color: Colors.white70)),
                  ),
                  Row(
                    children: [
                      if (widget.isFromCreationFlow)
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close EditLabelsDialog
                            // Reopen CreateProjectDialog with previous data
                            showDialog(
                              context: context,
                              builder: (_) => CreateNewProjectDialog(
                                initialName: widget.project.name,
                                initialType: widget.project.type,
                                initialLabels: _labels,
                              ),
                            );
                          },
                          child: Text("<- Back", style: TextStyle(color: Colors.white70)),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _saveLabels,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text(
                            widget.isFromCreationFlow ? "Next ->" : "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
