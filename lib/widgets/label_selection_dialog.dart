import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:vap/data/app_database.dart';
import 'package:vap/data/providers.dart'; 

import 'create_project_dialog.dart';

class LabelSelectionDialog extends ConsumerStatefulWidget {
  final String projectName;
  final String projectType;

  const LabelSelectionDialog({required this.projectName, required this.projectType});

  @override
  ConsumerState<LabelSelectionDialog> createState() => _LabelSelectionDialogState();
}

class _LabelSelectionDialogState extends ConsumerState<LabelSelectionDialog> {
  final TextEditingController _labelController = TextEditingController();
  List<String> _labels = [];
  List<String> _labelColors = [];

  // Add label to the list
  void _addLabel() {
    if (_labelController.text.isNotEmpty) {
      setState(() {
        _labels.add(_labelController.text);
        _labelColors.add('black'); // Default color (can be expanded later with color selection)
        _labelController.clear();
      });
    }
  }

  // Remove label from the list
  void _removeLabel(String label) {
    setState(() {
      _labels.remove(label);
      _labelColors.removeAt(_labels.indexOf(label));
    });
  }

  // Create project function
  Future<void> _createProject() async {
    final newProject = ProjectsCompanion(
      name: drift.Value(widget.projectName), // Wrap in Value for non-nullable fields
      iconPath: drift.Value("folder"), // Wrap in Value for non-nullable fields
      createdAt: drift.Value(DateTime.now()), // Wrap in Value for non-nullable fields
      ownerId: drift.Value(1), // Wrap in Value for non-nullable fields (Replace with actual owner ID)
      labels: drift.Value(_labels.join(',')), // Wrap the string for labels
      labelColors: drift.Value(_labelColors.join(',')), // Wrap the string for label colors
    );

    final db = ref.read(databaseProvider); // Access the database provider
    await db.insertProject(newProject); // Insert the new project into the database
    Navigator.pop(context); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Labels"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _labelController,
                  decoration: const InputDecoration(labelText: "Enter Label"),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue),
                onPressed: _addLabel,
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: _labels.map((label) {
              return Chip(
                label: Text(label),
                backgroundColor: Colors.blueAccent,
                deleteIcon: const Icon(Icons.close, color: Colors.white),
                onDeleted: () => _removeLabel(label),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        // "Back" button to go to the previous screen
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => CreateProjectDialog(),
            );
          },
          child: const Text("Back"),
        ),

        // "Create" button to create the new project
        ElevatedButton(
          onPressed: _createProject,
          child: const Text("Create"),
        ),
      ],
    );
  }
}
