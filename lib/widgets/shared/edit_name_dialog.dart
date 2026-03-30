import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Reusable responsive rename dialog. Works for projects, datasets, or any
/// entity that needs a simple "edit name" flow.
///
/// Replaces the near-duplicate `EditProjectNameDialog` and
/// `EditDatasetNameDialog` layout (the callers still handle persistence).
class EditNameDialog extends StatefulWidget {
  /// Current name pre-filled in the text field.
  final String currentName;

  /// Dialog title shown in header.
  final String title;

  /// Description text below the title.
  final String description;

  /// Label for the save button.
  final String saveLabel;

  /// Label for the close/cancel button.
  final String closeLabel;

  /// Accent color used for header icon, border, divider, and save button.
  final Color accentColor;

  /// Optional async callback invoked with the trimmed name before the dialog
  /// pops. Use this to persist the name change (e.g. DB update) from a
  /// thin wrapper widget without needing a separate StatefulWidget layer.
  final Future<void> Function(String newName)? onSave;

  const EditNameDialog({
    super.key,
    required this.currentName,
    required this.title,
    required this.description,
    required this.saveLabel,
    required this.closeLabel,
    this.accentColor = AppColors.accent,
    this.onSave,
  });

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late TextEditingController _controller;
  late String _name;

  @override
  void initState() {
    super.initState();
    _name = widget.currentName;
    _controller = TextEditingController(text: _name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final trimmed = _name.trim();
    if (trimmed.isNotEmpty) {
      await widget.onSave?.call(trimmed);
      if (!mounted) return;
      Navigator.pop(context, trimmed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 800) {
      return _buildMobile(context);
    }
    return _buildDesktop(context, screenWidth);
  }

  // ------ header row (shared) ------
  Widget _headerRow(double iconSize, double fontSize) {
    return Row(
      children: [
        Icon(Icons.edit_note_outlined, size: iconSize, color: widget.accentColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              color: widget.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.white.withOpacity(0.5)),
          tooltip: widget.closeLabel,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ------ text field (shared) ------
  Widget _nameField(double fontSize) {
    return TextField(
      controller: _controller,
      onChanged: (v) => setState(() => _name = v),
      style: TextStyle(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        filled: false,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.accentColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.accentColor, width: 1),
        ),
      ),
    );
  }

  // ------ action buttons (shared) ------
  Widget _actionRow(double fontSize) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkSurface,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            widget.closeLabel,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: fontSize,
            ),
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkSurface,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: widget.accentColor, width: 2),
            ),
          ),
          child: Text(
            widget.saveLabel,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ),
      ],
    );
  }

  // ------ mobile layout ------
  Widget _buildMobile(BuildContext context) {
    return Dialog.fullscreen(
      child: SafeArea(
        child: Container(
          color: AppColors.darkSurface,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerRow(28, 22),
              Divider(color: widget.accentColor),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.description,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18),
                ),
              ),
              Padding(padding: const EdgeInsets.all(12), child: _nameField(18)),
              const Spacer(),
              _actionRow(18),
            ],
          ),
        ),
      ),
    );
  }

  // ------ desktop layout ------
  Widget _buildDesktop(BuildContext context, double screenWidth) {
    final isLarge = screenWidth > 1200;
    final pad = isLarge ? 25.0 : 12.0;
    final titleSize = isLarge ? 26.0 : 20.0;
    final bodySize = isLarge ? 24.0 : 20.0;
    final inputSize = isLarge ? 22.0 : 18.0;
    final btnSize = isLarge ? 22.0 : 20.0;

    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: widget.accentColor, width: 1),
      ),
      title: _headerRow(isLarge ? 34 : 26, titleSize),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: widget.accentColor),
          Padding(
            padding: EdgeInsets.all(pad),
            child: Text(
              widget.description,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: bodySize),
            ),
          ),
          Padding(padding: EdgeInsets.all(pad), child: _nameField(inputSize)),
        ],
      ),
      actions: [_actionRow(btnSize)],
    );
  }
}
