import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../data/project_database.dart';
import '../../utils/theme.dart';

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

    if (screenWidth < 800) {
      final titleStyle = TextStyle(
        color: Theme.of(context).colorScheme.info,
        fontFamily: 'CascadiaCode',
        fontWeight: FontWeight.bold,
        fontSize: 22,
      );
      final bodyStyle = TextStyle(
        color: Theme.of(context).colorScheme.muted,
        fontFamily: 'CascadiaCode',
        fontWeight: FontWeight.normal,
        fontSize: 18,
      );
      final inputTextStyle = TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontFamily: 'CascadiaCode',
        fontWeight: FontWeight.normal,
      );

      return Dialog.fullscreen(
        child: SafeArea(
          child: Container(
            color: Colors.grey[800],
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note_outlined,
                      size: 28,
                      color: Theme.of(context).colorScheme.info,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.editProjectTitle, style: titleStyle),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).colorScheme.muted),
                      tooltip: l10n.buttonClose,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Divider(color: Theme.of(context).colorScheme.info),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    l10n.editProjectDescription,
                    style: bodyStyle,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) => setState(() {
                      projectName = value;
                    }),
                    decoration: InputDecoration(
                      hintStyle: bodyStyle,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      filled: false,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
                      ),
                    ),
                    style: inputTextStyle,
                  ),
                ),
                const Spacer(),
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
                        l10n.buttonClose,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.muted,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'CascadiaCode',
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).colorScheme.info, width: 2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.buttonSave,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'CascadiaCode',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
      ),
      title: Row(
        children: [
          Icon(
            Icons.edit_note_outlined,
            size: (screenWidth > 1200) ? 34 : 26,
            color: Theme.of(context).colorScheme.info,
          ),
          const SizedBox(width: 12),
          Text(
            l10n.editProjectTitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.info,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
              fontSize: (screenWidth > 1200) ? 26 : 20,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.muted),
            tooltip: l10n.buttonClose,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: Theme.of(context).colorScheme.info),
          Padding(
            padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
            child: Text(
              l10n.editProjectDescription,
              style: TextStyle(
                color: Theme.of(context).colorScheme.muted,
                fontFamily: 'CascadiaCode',
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
                    color: Theme.of(context).colorScheme.muted,
                    fontFamily: 'CascadiaCode',
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
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: (screenWidth > 1200) ? 22 : 18,
                  fontFamily: 'CascadiaCode',
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
                l10n.buttonClose,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.muted,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'CascadiaCode',
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
                  side: BorderSide(color: Theme.of(context).colorScheme.info, width: 2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.buttonSave,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'CascadiaCode',
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
