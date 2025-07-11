import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import '../../models/user.dart';
import '../../session/user_session.dart';
import '../dialogs/alert_error_dialog.dart';

class AccountStorage extends StatefulWidget {
  final User user;
  final Function(User) onUserChange;

  const AccountStorage({
    super.key,
    required this.user,
    required this.onUserChange,
  });

  @override
  State<AccountStorage> createState() => _AccountStorageState();
}

class _AccountStorageState extends State<AccountStorage> {
  late TextEditingController _datasetImportController;
  late TextEditingController _datasetExportController;
  late TextEditingController _thumbnailController;

  @override
  void initState() {
    super.initState();
    _datasetImportController = TextEditingController(text: widget.user.datasetImportFolder);
    _datasetExportController = TextEditingController(text: widget.user.datasetExportFolder);
    _thumbnailController = TextEditingController(text: widget.user.thumbnailFolder);
  }

  @override
  void didUpdateWidget(covariant AccountStorage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.user.datasetImportFolder != widget.user.datasetImportFolder) {
      _datasetImportController.text = widget.user.datasetImportFolder;
    }

    if (oldWidget.user.datasetExportFolder != widget.user.datasetExportFolder) {
      _datasetExportController.text = widget.user.datasetExportFolder;
    }

    if (oldWidget.user.thumbnailFolder != widget.user.thumbnailFolder) {
      _thumbnailController.text = widget.user.thumbnailFolder;
    }
  }

  @override
  void dispose() {
    _datasetImportController.dispose();
    _datasetExportController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 800;

    return Container(
      color: Colors.grey[800],
      child: SingleChildScrollView(
        padding: isWide ? const EdgeInsets.all(24) : const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              l10n.accountStorage_importFolderTitle,
              [
                _folderField(
                  controller: _datasetImportController,
                  onPathSelected: (val) async {
                    _datasetImportController.text = val;
                    widget.onUserChange(widget.user.copyWith(datasetImportFolder: val));
                    await UserSession.instance.setCurrentUserDatasetImportFolder(val);
                  },
                ),
              ], isWide),

            SizedBox(height: 16),
            _buildSection(
              l10n.accountStorage_thumbnailsFolderTitle,
              [
                _folderField(
                  controller: _thumbnailController,
                  onPathSelected: (val) async {
                    print('thumbnail $val');
                    _thumbnailController.text = val;
                    widget.onUserChange(widget.user.copyWith(thumbnailFolder: val));
                    await UserSession.instance.setCurrentUserThumbnailFolder(val);
                  },
                ),
              ], isWide),

            SizedBox(height: 16),
            _buildSection(
              l10n.accountStorage_exportFolderTitle,
              [
                _folderField(
                  controller: _datasetExportController,
                  onPathSelected: (val) async {
                    // print('Dataset EXPORT $val');
                    _datasetExportController.text = val;
                    widget.onUserChange(widget.user.copyWith(datasetExportFolder: val));
                    await UserSession.instance.setCurrentUserDatasetExportFolder(val);
                  },
                ),
              ], isWide),

          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isWide) {
    final padding = isWide ? const EdgeInsets.all(18) : const EdgeInsets.all(8);
    final titlePadding = isWide ? const EdgeInsets.only(left: 18, top: 10) : const EdgeInsets.only(left: 8, top: 5);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: titlePadding,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'CascadiaCode',
                color: Colors.white,
                ),
            ),
          ),
          ...children.map((child) => Padding(padding: padding, child: child)).toList(),
        ],
      ),
    );
  }

  Widget _folderField({
    required TextEditingController controller,
    required Function(String) onPathSelected,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          icon: Icon(Icons.folder_open),
          tooltip: l10n.accountStorage_folderTooltip,
          onPressed: () async {
            final selectedPath = await getDirectoryPath();
            if (selectedPath != null) {
              controller.text = selectedPath;
              onPathSelected(selectedPath);
            }
          }
        ),
        SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: controller,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white24, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white, width: 1),
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.help_outline_rounded),
          tooltip: l10n.buttonHelp,
          onPressed: () {
            AlertErrorDialog.show(
              context,
              l10n.accountStorage_helpTitle,
              l10n.accountStorage_helpMessage,
              tips: l10n.accountStorage_helpTips,
            );
          },
        ),
      ],
    );
  }
}
