import 'dart:io';
import 'dart:async';
import '../../utils/platform_utils.dart';
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
import '../../utils/theme.dart';

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
  late TextEditingController _modelsController;
  late TextEditingController _ffmpegController;

  Future<bool> _isLikelyExecutableMachO(String path) async {
    try {
      final f = File(path);
      if (!await f.exists()) return false;
      // Check executable permission bits where available
      try {
        final stat = await f.stat();
        final mode = stat.mode;
        final hasExec = (mode & 0x49) != 0; // any of user/group/other exec bits
        if (!hasExec) {
          // Still continue to check magic in case permissions are lax
        }
      } catch (_) {}

      // Read first 4 bytes to identify Mach-O or fat binary
      final raf = await f.open();
      final header = await raf.read(4);
      await raf.close();
      if (header.length < 4) return false;
      final b0 = header[0], b1 = header[1], b2 = header[2], b3 = header[3];
      final isMachO =
          // Mach-O 32/64 little-endian
          (b0 == 0xCE && b1 == 0xFA && b2 == 0xED && b3 == 0xFE) ||
          (b0 == 0xCF && b1 == 0xFA && b2 == 0xED && b3 == 0xFE) ||
          // Mach-O 32/64 big-endian
          (b0 == 0xFE && b1 == 0xED && b2 == 0xFA && b3 == 0xCE) ||
          (b0 == 0xFE && b1 == 0xED && b2 == 0xFA && b3 == 0xCF) ||
          // Fat/universal binaries (32/64)
          (b0 == 0xCA && b1 == 0xFE && b2 == 0xBA && (b3 == 0xBE || b3 == 0xBF));
      return isMachO;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _findFfmpegOnMac() async {
    if (!PlatformUtils.isMacOS) return null;
    try {
      final candidates = <String>[
        '/opt/homebrew/bin/ffmpeg',
        '/usr/local/bin/ffmpeg',
        '/opt/local/bin/ffmpeg', // MacPorts (optional)
      ];

      // Also scan PATH directories for 'ffmpeg'
      final pathEnv = PlatformUtils.isWeb ? null : Platform.environment['PATH'];
      if (pathEnv != null && pathEnv.isNotEmpty) {
        for (final dir in pathEnv.split(':')) {
          if (dir.trim().isEmpty) continue;
          final p = dir.endsWith('/') ? dir + 'ffmpeg' : dir + '/ffmpeg';
          candidates.add(p);
        }
      }

      for (final c in candidates) {
        try {
          if (await _isLikelyExecutableMachO(c)) {
            return c;
          }
        } catch (_) {/* continue */}
      }
    } catch (_) {/* ignore */}
    return null;
  }

  @override
  void initState() {
    super.initState();
    _datasetImportController = TextEditingController(text: widget.user.datasetImportFolder);
    _datasetExportController = TextEditingController(text: widget.user.datasetExportFolder);
    _thumbnailController = TextEditingController(text: widget.user.thumbnailFolder);
    _modelsController = TextEditingController(text: widget.user.modelsFolder);
    _ffmpegController = TextEditingController(text: widget.user.ffmpegPath ?? '');
    _loadAbsolutePaths();
  }

  Future<void> _loadAbsolutePaths() async {
    try {
      final importPath = await UserSession.instance.getCurrentUserDatasetImportFolder();
      final exportPath = await UserSession.instance.getCurrentUserDatasetExportFolder();
      final thumbPath = await UserSession.instance.getCurrentUserThumbnailFolder();
      final modelsPath = await UserSession.instance.getCurrentUserModelsFolder();
      if (!mounted) return;
      setState(() {
        _datasetImportController.text = importPath;
        _datasetExportController.text = exportPath;
        _thumbnailController.text = thumbPath;
        _modelsController.text = modelsPath;
      });
    } catch (e) {
      _logger.warning('Failed to resolve absolute storage paths', e);
    }
  }

  @override
  void didUpdateWidget(covariant AccountStorage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _datasetImportController.text = widget.user.datasetImportFolder;
    _datasetExportController.text = widget.user.datasetExportFolder;
    _thumbnailController.text = widget.user.thumbnailFolder;
    _modelsController.text = widget.user.modelsFolder;
    _ffmpegController.text = widget.user.ffmpegPath ?? '';
    _loadAbsolutePaths();
  }

  @override
  void dispose() {
    _datasetImportController.dispose();
    _datasetExportController.dispose();
    _thumbnailController.dispose();
    _modelsController.dispose();
    _ffmpegController.dispose();
    super.dispose();
  }

  Widget _ffmpegPathField({required bool isWide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.file_open),
              tooltip: 'Browse ffmpeg executable',
              onPressed: () async {
                try {
                  XTypeGroup? typeGroup;
                  List<XTypeGroup> groups = [];
                  if (PlatformUtils.isWindows) {
                    typeGroup = XTypeGroup(
                      label: 'Executable',
                      extensions: ['exe'],
                    );
                    groups = <XTypeGroup>[typeGroup];
                  } else if (PlatformUtils.isMacOS) {
                    // Allow selecting Unix executables on macOS
                    typeGroup = XTypeGroup(
                      label: 'Executable',
                      uniformTypeIdentifiers: ['public.unix-executable', 'public.executable', 'public.data'],
                    );
                    groups = <XTypeGroup>[typeGroup];
                  } else {
                    // Linux and others: allow any file
                    typeGroup = XTypeGroup(
                      label: 'Any',
                    );
                    groups = <XTypeGroup>[typeGroup];
                  }
                  final file = await openFile(
                    acceptedTypeGroups: groups,
                  );
                  if (file != null) {
                    _ffmpegController.text = file.path;
                  }
                } catch (e, st) {
                  _logger.warning('ffmpeg browse failed', e, st);
                  AppSnackbar.show(context, 'Failed to open file picker');
                }
              },
            ),
            SizedBox(width: isWide ? 16 : 6),
            Expanded(
              child: TextFormField(
                controller: _ffmpegController,
                readOnly: false,
                enableInteractiveSelection: true,
                decoration: InputDecoration(
                  hintText: PlatformUtils.isWindows ? 'e.g. C:\\ffmpeg\\bin\\ffmpeg.exe' : 'ffmpeg binary path',
                  hintStyle: const TextStyle(color: Colors.white38),
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
                ),
                maxLines: 2,
                minLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _actionButton(
              icon: Icons.check_circle_outline,
              label: 'Validate & Save',
              tooltip: 'Validate with "ffmpeg -version" and save',
              isWide: isWide,
              onPressed: () async {
                String p = _ffmpegController.text.trim();

                try {
                  // macOS: try to auto-detect when empty or a bare command name
                  if (PlatformUtils.isMacOS) {
                    bool isBareName = p.isNotEmpty && !p.startsWith('/');
                    if (p.isEmpty || p == 'ffmpeg' || isBareName) {
                      final found = await _findFfmpegOnMac();
                      if (found != null) {
                        p = found;
                        _ffmpegController.text = p;
                        AppSnackbar.show(context, 'Detected ffmpeg at: ' + p, saveToDb: false);
                      }
                    }
                  }

                  if (p.isEmpty) {
                    AppSnackbar.show(context, 'Path is empty');
                    return;
                  }

                  // On macOS, avoid executing external processes to prevent app termination.
                  if (PlatformUtils.isMacOS) {
                    final isValid = await _isLikelyExecutableMachO(p);
                    if (isValid) {
                      await UserSession.instance.setFfmpegPath(p);
                      widget.onUserChange(widget.user.copyWith(ffmpegPath: p));
                      AppSnackbar.show(context, 'FFmpeg path saved', saveToDb: false);
                    } else {
                      AppSnackbar.show(
                        context,
                        'Not a valid ffmpeg binary at: ' + p,
                        saveToDb: false,
                      );
                    }
                    return;
                  }

                  // Other platforms: validate by running "ffmpeg -version" with a timeout
                  final ver = await Process.run(p, ['-version']).timeout(const Duration(seconds: 8));
                  if (ver.exitCode == 0) {
                    await UserSession.instance.setFfmpegPath(p);
                    widget.onUserChange(widget.user.copyWith(ffmpegPath: p));
                    AppSnackbar.show(context, 'FFmpeg saved', saveToDb: false);
                  } else {
                    AppSnackbar.show(
                      context,
                      'Not a valid ffmpeg executable (exit ${ver.exitCode})',
                      saveToDb: false,
                    );
                  }
                } catch (e, st) {
                  _logger.warning('FFmpeg validate failed', e, st);
                  AppSnackbar.show(context, 'Failed to run ffmpeg: ' + e.toString());
                }
              },
            ),
            _actionButton(
              icon: Icons.clear,
              label: 'Clear',
              tooltip: 'Clear saved path',
              isWide: isWide,
              onPressed: () async {
                _ffmpegController.text = '';
                await UserSession.instance.setFfmpegPath(null);
                widget.onUserChange(widget.user.copyWith(ffmpegPath: null));
                AppSnackbar.show(context, 'FFmpeg path cleared', saveToDb: false,);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'On Windows, select ffmpeg.exe. On macOS/Linux, provide the ffmpeg binary if not on PATH.',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 800;

    return Container(
      color: AppColors.darkSurface,
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
            const SizedBox(height: 16),
            _buildSection(
              'Models folder',
              _folderField(
                controller: _modelsController,
                onPathSelected: (val) async {
                  _modelsController.text = val;
                  widget.onUserChange(widget.user.copyWith(modelsFolder: val));
                  await UserSession.instance.setCurrentUserModelsFolder(val);
                },
                isWide: isWide,
              ),
            ),
            const SizedBox(height: 16),
            if (!(PlatformUtils.isAndroid || PlatformUtils.isIOS))
              _buildSection(
                'FFmpeg path (desktop only)',
                _ffmpegPathField(isWide: isWide),
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
        color: AppColors.darkCard,
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
                enableInteractiveSelection: true,
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
                ),
                maxLines: 2,
                minLines: 1,
                // overflow: TextOverflow.visible,
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
                AppSnackbar.show(context, l10n.accountStorage_copySuccess, saveToDb: false,);
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
                  AppSnackbar.show(context, l10n.accountStorage_pathEmpty, saveToDb: false,);
                  return;
                }
                
                // Check if directory exists with improved error handling
                try {
                  if (!await Directory(folder).exists()) {
                    final errorMessage = 'Directory does not exist: $folder';
                    _logger.warning(errorMessage);
                    AppSnackbar.show(context, l10n.accountStorage_openError.replaceFirst('{path}', folder), saveToDb: false,);
                    return;
                  }
                } catch (e, stack) {
                  final errorMessage = 'Failed to check if directory exists: $folder';
                  _logger.severe(errorMessage, e, stack);
                  AppSnackbar.show(context, l10n.accountStorage_openError.replaceFirst('{path}', folder), saveToDb: false,);
                  return;
                }
                
                // Implement retry mechanism for opening folder
                const maxRetries = 3;
                int retryCount = 0;
                bool success = false;
                
                while (retryCount < maxRetries && !success) {
                  try {
                    if (PlatformUtils.isWindows) {
                      await Process.run('explorer', [folder]);
                    } else if (PlatformUtils.isMacOS) {
                      await Process.run('open', [folder]);
                    } else if (PlatformUtils.isLinux) {
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
                      AppSnackbar.show(context, l10n.accountStorage_openFailed.replaceFirst('{error}', e.toString()), saveToDb: false,);
                      
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
