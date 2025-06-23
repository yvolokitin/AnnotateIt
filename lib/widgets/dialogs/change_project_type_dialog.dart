import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import '../../models/project.dart';
import '../../data/project_database.dart';

class ChangeProjectTypeDialog extends StatefulWidget {
  final Project project;
  final String Function(String)? onProjecttypeChanged;

  const ChangeProjectTypeDialog({
    super.key,
    required this.project,
    this.onProjecttypeChanged,
  });

  @override
  ChangeProjectTypeDialogState createState() => ChangeProjectTypeDialogState();
}

class ChangeProjectTypeDialogState extends State<ChangeProjectTypeDialog> {
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
      widget.onProjecttypeChanged?.call(projectName);
      if (!mounted) return;
      Navigator.pop(context, projectName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orangeAccent, width: 1),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.build_circle_outlined,
            size: 32,
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 12),
          Text(
            l10n.changeProjectTypeTitle,
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              fontSize: 24
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
            padding: EdgeInsets.all(screenWidth > 1600 ? 40.0 : 20.0),
            child: Text(
              "Please, choose a clear, descriptive project name (3 - 86 characters). It's recommended to avoid special characters",
              style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.normal,
                fontSize: 22,
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(screenWidth > 1600 ? 40.0 : 20.0),
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
                style: const TextStyle(
                  color: Colors.white,
                  // fontSize: 22,
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
                  fontSize: 22,
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
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
