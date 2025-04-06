import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:drift/drift.dart' as drift;

import 'responsive/responsive_text.dart';
import '../data/app_database.dart';

class AccountStorage extends StatefulWidget {
  final User user;
  final bool isEditing;
  final VoidCallback onToggleEdit;
  final Function(User) onUserChange;

  const AccountStorage({
    super.key,
    required this.user,
    required this.isEditing,
    required this.onToggleEdit,
    required this.onUserChange,
  });

  @override
  State<AccountStorage> createState() => _AccountStorageState();
}

class _AccountStorageState extends State<AccountStorage> {
  late TextEditingController _datasetController;
  late TextEditingController _thumbnailController;

  @override
  void initState() {
    super.initState();
    _datasetController = TextEditingController(text: widget.user.datasetsFolderPath ?? '');
    _thumbnailController = TextEditingController(text: widget.user.thumbnailsFolderPath ?? '');
  }

  @override
  void didUpdateWidget(covariant AccountStorage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.user.datasetsFolderPath != widget.user.datasetsFolderPath) {
      _datasetController.text = widget.user.datasetsFolderPath ?? '';
    }
    if (oldWidget.user.thumbnailsFolderPath != widget.user.thumbnailsFolderPath) {
      _thumbnailController.text = widget.user.thumbnailsFolderPath ?? '';
    }
  }

  @override
  void dispose() {
    _datasetController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _folderField(
          label: 'Datasets Folder',
          controller: _datasetController,
          editable: widget.isEditing,
          onPathSelected: (val) {
            _datasetController.text = val;
            widget.onUserChange(widget.user.copyWith(
              datasetsFolderPath: drift.Value(val),
            ));
          },
        ),
        const SizedBox(height: 16),
        _folderField(
          label: 'Thumbnails Folder',
          controller: _thumbnailController,
          editable: widget.isEditing,
          onPathSelected: (val) {
            _thumbnailController.text = val;
            widget.onUserChange(widget.user.copyWith(
              thumbnailsFolderPath: drift.Value(val),
            ));
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: widget.onToggleEdit,
            child: Text(widget.isEditing ? 'Save' : 'Edit'),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: ResponsiveText(
                  'You can change where datasets and thumbnails are stored.\n'
                  'Tap "Edit" and then select a folder.\n\n'
                  '💡 Recommended folders by platform:\n'
                  '\n🪟 Windows:\n'
                  '  C:\\Users\\<you>\\AppData\\Roaming\\AnnotateIt\\datasets\n'
                  '\n🐧 Linux / Ubuntu:\n'
                  '  /home/<you>/.annotateit/datasets\n'
                  '\n🍏 macOS:\n'
                  '  /Users/<you>/Library/Application Support/AnnotateIt/datasets\n'
                  '\n📱 Android:\n'
                  '  /storage/emulated/0/AnnotateIt/datasets\n'
                  '\n📱 iOS:\n'
                  '  <App sandbox path>/Documents/AnnotateIt/datasets\n',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _folderField({
    required String label,
    required TextEditingController controller,
    required bool editable,
    required Function(String) onPathSelected,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(labelText: label),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.folder_open),
          tooltip: 'Choose folder',
          onPressed: editable
              ? () async {
                  final selectedPath = await getDirectoryPath();
                  if (selectedPath != null) {
                    controller.text = selectedPath;
                    onPathSelected(selectedPath);
                  }
                }
              : null,
        ),
      ],
    );
  }
}
