import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import '../../models/project.dart';
import '../../data/project_database.dart';

class EditProjectNameDialog extends StatefulWidget {
  final Project project;
  final String Function(String)? onProjectNameUpdated;

  const EditProjectNameDialog({
    super.key,
    required this.project,
    this.onProjectNameUpdated,
  });

  @override
  EditProjectNameDialogState createState() => EditProjectNameDialogState();
}

class EditProjectNameDialogState extends State<EditProjectNameDialog> {
  late TextEditingController _controller;
  String projectName = "";
  
  @override
  void initState() {
    super.initState();
    projectName = widget.project.name;
    _controller = TextEditingController(text: projectName);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (projectName.isNotEmpty) {
      await ProjectDatabase.instance.updateProjectName(widget.project.id!, projectName);
      widget.onProjectNameUpdated?.call(projectName);
      if (!mounted) return;
      Navigator.pop(context, projectName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orangeAccent, width: 1),
      ),
      title: Row(
        children: [
          Icon(
            Icons.edit_note_outlined,
            size: (screenWidth > 1200) ? 34 : 26,
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 12),
          Text(
            l10n.editProjectTitle,
            style: TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              fontSize: (screenWidth > 1200) ? 26 : 20,
            ),
          ),
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.orangeAccent),
          Padding(
            padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
            child: Text(
              l10n.editProjectDescription,
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.normal,
                fontSize: (screenWidth > 1200) ? 24 : 20,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
            child: TextField(
                controller: _controller,
                onChanged: (value) => setState(() {
                  projectName = value;
                }),
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.normal,
                    fontSize: screenWidth > 1200 ? 22 : 18,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orangeAccent, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orangeAccent, width: 1),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (screenWidth > 1200) ? 22 : 18,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ),
        ],
      ),

      actions: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.closeButton,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.normal,
                  fontSize: (screenWidth > 1200) ? 22 : 20,
                ),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orangeAccent, width: 2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.saveButton,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: (screenWidth > 1200) ? 22 : 20,
                    ),
                  ),
                ],
              ),
            ),
        ]
        ),
      ],
    );
  }
}
