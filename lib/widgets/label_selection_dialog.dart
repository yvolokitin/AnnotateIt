import 'package:flutter/material.dart';

import "create_project_dialog.dart";

import '../data/project_database.dart';
import '../models/project.dart';

class LabelSelectionDialog extends StatefulWidget {
  final String projectName;
  final String projectType;

  const LabelSelectionDialog({required this.projectName, required this.projectType});

  @override
  _LabelSelectionDialogState createState() => _LabelSelectionDialogState();
}

class _LabelSelectionDialogState extends State<LabelSelectionDialog> {
  final TextEditingController _labelController = TextEditingController();
  List<String> _labels = [];
  List<String> _labelColors = [];

  // 📌 Add Label to List
  void _addLabel() {
    if (_labelController.text.isNotEmpty) {
      setState(() {
        _labels.add(_labelController.text);
        _labelController.clear();
      });
    }
  }

  // 📌 Remove Label
  void _removeLabel(String label) {
    setState(() {
      _labels.remove(label);
    });
  }

  // 📌 Save Project & Close Window
  Future<void> _createProject() async {
    final newProject = Project(
      name: widget.projectName,
      type: widget.projectType,
      icon: "folder",
      creationDate: DateTime.now(),
      lastUpdated: DateTime.now(),
      labels: _labels,
      labelColors: _labelColors,
    );

    await ProjectDatabase.instance.insertProject(newProject);
    Navigator.pop(context); // Close window
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Add Labels"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 📌 Label Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _labelController,
                  decoration: InputDecoration(labelText: "Enter Label"),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: Colors.blue),
                onPressed: _addLabel,
              ),
            ],
          ),

          // 📌 Label List
          Wrap(
            spacing: 8,
            children: _labels.map((label) {
              return Chip(
                label: Text(label),
                backgroundColor: Colors.blueAccent,
                deleteIcon: Icon(Icons.close, color: Colors.white),
                onDeleted: () => _removeLabel(label),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        // 🔙 Back Button (Go to Step 1)
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => CreateProjectDialog(),
            );
          },
          child: Text("Back"),
        ),

        // Create Project Button
        ElevatedButton(
          onPressed: _createProject,
          child: Text("Create"),
        ),
      ],
    );
  }
}
