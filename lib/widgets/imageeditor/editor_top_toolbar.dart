import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../gen_l10n/app_localizations.dart';

class EditorTopToolbar extends StatefulWidget {
  final Project project;
  final bool isModified;

  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback? onSave;

  const EditorTopToolbar({
    super.key,
    required this.project,
    required this.onBack,
    required this.onHelp,
    this.isModified = false,
    this.onSave,
  });

  @override
  State<EditorTopToolbar> createState() => _EditorTopToolbarState();
}

class _EditorTopToolbarState extends State<EditorTopToolbar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: const Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBack,
              tooltip: l10n.annotatorTopToolbarBackTooltip,
              iconSize: 32,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ),
          
          // Project title
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Image Editor - ${widget.project.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          
          // Save button (only shown when image is modified)
          if (widget.isModified && widget.onSave != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: widget.onSave,
                icon: const Icon(Icons.save),
                label: Text(l10n.buttonSave),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}