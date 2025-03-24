import 'package:flutter/material.dart';
import '../data/project_database.dart';
import '../models/project.dart';

class EditProjectName extends StatefulWidget {
  final Project project;
  final VoidCallback onProjectUpdated; // Callback to refresh list after update

  const EditProjectName({required this.project, required this.onProjectUpdated});

  @override
  _EditProjectNameState createState() => _EditProjectNameState();
}

class _EditProjectNameState extends State<EditProjectName> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name); // Pre-fill project name
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 📌 Update Project Name in Database
  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) return;

    Project updatedProject = Project(
      id: widget.project.id,
      name: _nameController.text,
      type: widget.project.type,
      icon: widget.project.icon,
      creationDate: widget.project.creationDate,
      lastUpdated: widget.project.lastUpdated,
      labels: widget.project.labels,
      labelColors: widget.project.labelColors,
    );

    await ProjectDatabase.instance.updateProjectName(updatedProject);
    widget.onProjectUpdated(); // Refresh UI after update
    Navigator.pop(context); // Close dialog
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900], // Dark theme
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 800, // Set width
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 📌 Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Edit Project Name",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 12),

            // 📌 Project Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Edit Project Name",
                filled: true,
                fillColor: Colors.grey[850],
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),

            // 📌 Action Buttons (Cancel, Save)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Save", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.check, color: Colors.black),
                    ],)
                    
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
