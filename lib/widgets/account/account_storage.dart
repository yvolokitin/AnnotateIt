import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_selector/file_selector.dart';
import 'package:logging/logging.dart';

import '../app_snackbar.dart';
import '../dialogs/alert_error_dialog.dart';
import '../../models/user.dart';
import '../../session/user_session.dart';
import '../../gen_l10n/app_localizations.dart';

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
  final _logger = Logger('AccountStorage');
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
    _datasetImportController.text = widget.user.datasetImportFolder;
    _datasetExportController.text = widget.user.datasetExportFolder;
    _thumbnailController.text = widget.user.thumbnailFolder;
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
              _folderField(
                controller: _datasetImportController,
                onPathSelected: (val) async {
                  _datasetImportController.text = val;
                  widget.onUserChange(widget.user.copyWith(datasetImportFolder: val));
                  await UserSession.instance.setCurrentUserDatasetImportFolder(val);
                },
                isWide: isWide,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              l10n.accountStorage_thumbnailsFolderTitle,
              _folderField(
                controller: _thumbnailController,
                onPathSelected: (val) async {
                  _thumbnailController.text = val;
                  widget.onUserChange(widget.user.copyWith(thumbnailFolder: val));
                  await UserSession.instance.setCurrentUserThumbnailFolder(val);
                },
                isWide: isWide,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              l10n.accountStorage_exportFolderTitle,
              _folderField(
                controller: _datasetExportController,
                onPathSelected: (val) async {
                  _datasetExportController.text = val;
                  widget.onUserChange(widget.user.copyWith(datasetExportFolder: val));
                  await UserSession.instance.setCurrentUserDatasetExportFolder(val);
                },
                isWide: isWide,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
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
            padding: const EdgeInsets.only(left: 18, top: 10),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'CascadiaCode',
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _folderField({
    required TextEditingController controller,
    required Function(String) onPathSelected,
    required bool isWide,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: l10n.accountStorage_folderTooltip,
              onPressed: () async {
                final selectedPath = await getDirectoryPath();
                if (selectedPath != null) {
                  controller.text = selectedPath;
                  onPathSelected(selectedPath);
                }
              },
            ),
            SizedBox(width: isWide ? 16 : 6),
            Expanded(
              child: TextFormField(
                controller: controller,
                readOnly: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWide ? 24 : 18,
                  fontFamily: 'CascadiaCode',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _actionButton(
              icon: Icons.info_outline,
              label: 'Info',
              tooltip: l10n.buttonHelp,
              isWide: isWide,
              onPressed: () {
                AlertErrorDialog.show(
                  context,
                  l10n.accountStorage_helpTitle,
                  l10n.accountStorage_helpMessage,
                  tips: l10n.accountStorage_helpTips,
                );
              },
            ),
            _actionButton(
              icon: Icons.copy,
              label: 'Copy path',
              tooltip: 'Copy path',
              isWide: isWide,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: controller.text));
                AppSnackbar.show(context, l10n.accountStorage_copySuccess);
              },
            ),
            _actionButton(
              icon: Icons.open_in_new,
              label: 'Open folder',
              tooltip: 'Open folder',
              isWide: isWide,
              onPressed: () async {
                final folder = controller.text;
                if (folder.isEmpty) {
                  AppSnackbar.show(context, l10n.accountStorage_pathEmpty);
                  return;
                }
                
                // Check if directory exists with improved error handling
                try {
                  if (!await Directory(folder).exists()) {
                    final errorMessage = 'Directory does not exist: $folder';
                    _logger.warning(errorMessage);
                    AppSnackbar.show(context, l10n.accountStorage_openError.replaceFirst('{path}', folder));
                    return;
                  }
                } catch (e, stack) {
                  final errorMessage = 'Failed to check if directory exists: $folder';
                  _logger.severe(errorMessage, e, stack);
                  AppSnackbar.show(context, l10n.accountStorage_openError.replaceFirst('{path}', folder));
                  return;
                }
                
                // Implement retry mechanism for opening folder
                const maxRetries = 3;
                int retryCount = 0;
                bool success = false;
                
                while (retryCount < maxRetries && !success) {
                  try {
                    if (Platform.isWindows) {
                      await Process.run('explorer', [folder]);
                    } else if (Platform.isMacOS) {
                      await Process.run('open', [folder]);
                    } else if (Platform.isLinux) {
                      await Process.run('xdg-open', [folder]);
                    } else {
                      final uri = Uri.file(folder);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        throw Exception('Unsupported platform or URI cannot be launched');
                      }
                    }
                    success = true;
                    _logger.info('Successfully opened folder: $folder');
                  } catch (e, stack) {
                    retryCount++;
                    final errorMessage = 'Failed to open folder (attempt $retryCount/$maxRetries): $folder';
                    _logger.warning(errorMessage, e, stack);
                    
                    if (retryCount >= maxRetries) {
                      _logger.severe('All attempts to open folder failed: $folder', e, stack);
                      AppSnackbar.show(context, l10n.accountStorage_openFailed.replaceFirst('{error}', e.toString()));
                      
                      // Show more detailed error dialog for persistent failures
                      AlertErrorDialog.show(
                        context,
                        'Failed to Open Folder',
                        'Multiple attempts to open the folder failed. Please check if the folder exists and you have permission to access it.',
                        tips: 'Error details: ${e.toString()}',
                      );
                    } else {
                      // Wait before retrying
                      await Future.delayed(Duration(milliseconds: 500 * retryCount));
                    }
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required String tooltip,
    required bool isWide,
    required VoidCallback onPressed,
  }) {
    final textStyle = const TextStyle(
      fontFamily: 'CascadiaCode',
      fontSize: 14,
      color: Colors.white,
    );

    if (isWide) {
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Tooltip(
          message: tooltip,
          textStyle: textStyle,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
          ),
          waitDuration: const Duration(milliseconds: 400),
          child: TextButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white),
            label: Text(label, style: textStyle),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return Tooltip(
        message: tooltip,
        textStyle: textStyle,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(4),
        ),
        waitDuration: const Duration(milliseconds: 400),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
      );
    }
  }
}
