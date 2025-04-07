import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import "color_picker_dialog.dart";

import '../pages/project_details_screen.dart';
import '../data/project_database.dart';
import '../models/project.dart';

import 'create_project_dialog.dart';

class EditLabelsDialog extends StatefulWidget {
  final Project project;
  final VoidCallback onLabelsUpdated;
  final bool isFromCreationFlow;

  const EditLabelsDialog({
    required this.project,
    required this.onLabelsUpdated,
    this.isFromCreationFlow = false,
  });

  @override
  _EditLabelsDialogState createState() => _EditLabelsDialogState();
}

class _EditLabelsDialogState extends State<EditLabelsDialog> {
  final TextEditingController _labelController = TextEditingController();
  List<String> _labels = [];
  List<String> _labelColors = [];

  // Holds the error message
  String? _errorMessage;

  // Default random color for new label
  late String _newLabelColor;

  @override
  void initState() {
    super.initState();
    
    // Load existing labels and colors
    _labels = List.from(widget.project.labels);
    _labelColors = List.from(widget.project.labelColors);

    _newLabelColor = _generateRandomColor();
  }

  // Function to generate a random color for a new label
  String _generateRandomColor() {
    Random random = Random();
    return '#${(random.nextInt(0xFFFFFF) + 0x1000000).toRadixString(16).substring(1).toUpperCase()}';
  }

  // Add Label
  void _addLabel() {
    String newLabel = _labelController.text.trim();
    print('CALLED: _addLabel $newLabel');

    if (newLabel.isEmpty) {
      _showErrorMessage("Label name cannot be empty!", "Please, enter Label name.");
      return;

    } else if (_labels.contains(newLabel)) {
      _showErrorMessage("Label name cannot duplicated", "Label '$newLabel' already exists! Please, enter a different name.");
      return;

    } else {
      setState(() {
        _labels.add(_labelController.text);
        _labelColors.add(_newLabelColor); // use selected color
        _labelController.clear();
        // Generate a new random color for next label
        _newLabelColor = _generateRandomColor();
      });
    }
  }

  // Remove Label
  void _removeLabel(String label) {
    int index = _labels.indexOf(label);
    if (index != -1) {
      setState(() {
        _labels.removeAt(index);
        _labelColors.removeAt(index);
      });
    }
  }

  // Save Updated Labels
  Future<void> _saveLabels() async {
    if (_labels.isEmpty) {
      _showErrorMessage('Add at least one label', 'You must create at least one label before continuing.');
      return;
    }

    final updatedProject = Project(
      id: widget.project.id,
      name: widget.project.name,
      type: widget.project.type,
      icon: widget.project.icon,
      creationDate: widget.project.creationDate,
      lastUpdated: DateTime.now(),
      labels: _labels,
      labelColors: _labelColors,
      defaultDatasetId: widget.project.defaultDatasetId,
      ownerId: widget.project.ownerId,
    );

    if (widget.isFromCreationFlow) {
      // Create new project
      final newProjectId = await ProjectDatabase.instance.createProject(updatedProject);
      final newProject = updatedProject.copyWith(id: newProjectId);

      Navigator.pop(context); // Close EditLabelsDialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(newProject),
        ),
      ).then((_) {
        widget.onLabelsUpdated(); // Refresh project list when returning
      });

    } else {
      // Update existing project
      await ProjectDatabase.instance.updateProjectLabels(
        widget.project.id!,
        _labels,
        _labelColors,
      );

      widget.onLabelsUpdated(); // Refresh UI
      Navigator.pop(context);  // Close dialog
    }
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
        initialColor: _labelColors[index],
        onColorSelected: (newColor) {
          setState(() {
            _labelColors[index] = newColor; // Update the color in the list
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
            _newLabelColor = newColor; // Update new label color before adding
          });
        },
      ),
    );
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
                    errorText: _labels.contains(_labelController.text.trim()) ? "Label already exists!" : null,
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

          // 📌 List of Existing Labels
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
                            color: Color(int.parse(_labelColors[index].replaceAll('#', '0xFF'))),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        ),
                      ),

                      SizedBox(width: 8),
                      // Label Name
                      Expanded(
                        child: Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
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
                            builder: (_) => CreateProjectDialog(
                              initialName: widget.project.name,
                              initialType: widget.project.type,
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
