import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import '../../models/user.dart';
import '../responsive/responsive_text.dart';


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
    _datasetController = TextEditingController(text: widget.user.datasetFolder);
    _thumbnailController = TextEditingController(text: widget.user.thumbnailFolder);
  }

  @override
  void didUpdateWidget(covariant AccountStorage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text controllers when user or edit state changes
    if (oldWidget.user.datasetFolder != widget.user.datasetFolder) {
      _datasetController.text = widget.user.datasetFolder;
    }
    if (oldWidget.user.thumbnailFolder != widget.user.thumbnailFolder) {
      _thumbnailController.text = widget.user.thumbnailFolder;
    }
  }

  @override
  void dispose() {
    _datasetController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  Future<void> _pickFolder(Function(String) onPathSelected) async {
    final path = await getDirectoryPath();
    if (path != null) {
      onPathSelected(path);
    }
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
            widget.onUserChange(widget.user.copyWith(datasetFolder: val));
          },
        ),

        SizedBox(height: 16),
        _folderField(
          label: 'Thumbnails Folder',
          controller: _thumbnailController,
          editable: widget.isEditing,
          onPathSelected: (val) {
            _thumbnailController.text = val;
            widget.onUserChange(widget.user.copyWith(thumbnailFolder: val));
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
            children: [
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
          icon: Icon(Icons.folder_open),
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
