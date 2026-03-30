import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../models/media_item.dart';
import '../../data/dataset_database.dart';
import '../../widgets/dialogs/alert_error_dialog.dart';
import '../../utils/theme.dart';

class DeleteImageDialog extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final Function(List<String> deletedPaths) onConfirmed;
  final bool dbOnly;

  const DeleteImageDialog({
    super.key,
    required this.mediaItems,
    required this.onConfirmed,
    this.dbOnly = false,
  });

  @override
  State<DeleteImageDialog> createState() => _DeleteImageDialogState();
}

class _DeleteImageDialogState extends State<DeleteImageDialog> {
  bool _isDeleting = false;
  final List<String> _successfullyDeleted = [];
  late bool _dbOnly;

  @override
  void initState() {
    super.initState();
    _dbOnly = widget.dbOnly;
  }

  Future<void> _deleteFiles() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDeleting = true;
      _successfullyDeleted.clear();
    });

    try {
      for (final mediaItem in widget.mediaItems) {
        if (mediaItem.id == null) continue;

        if (_dbOnly) {
          // Delete only from DB, keep physical files intact
          try {
            await DatasetDatabase.instance.deleteMediaItemWithAnnotations(mediaItem.id!);
            if (kDebugMode) debugPrint('Deleted from DB only: ${mediaItem.filePath}');
            _successfullyDeleted.add(mediaItem.filePath);
          } catch (e) {
            if (kDebugMode) debugPrint('Failed to delete DB record for: ${mediaItem.filePath}\n$e');
          }
          continue;
        }

        // Default behavior: Try to delete from filesystem first
        final file = File(mediaItem.filePath);
        bool fileDeleted = false;
        
        if (await file.exists()) {
          try {
            await file.delete();
            if (kDebugMode) debugPrint('Successfully deleted: ${mediaItem.filePath}');
            fileDeleted = true;
            _successfullyDeleted.add(mediaItem.filePath);
          } catch (e) {
            if (kDebugMode) debugPrint('Failed to delete file: ${mediaItem.filePath}\n$e');
          }
        }

        // Only delete from DB if file was successfully deleted
        if (fileDeleted) {
          try {
            await DatasetDatabase.instance.deleteMediaItemWithAnnotations(mediaItem.id!);
          } catch (e) {
            if (kDebugMode) debugPrint('Failed to delete DB record for: ${mediaItem.filePath}\n$e');
            _successfullyDeleted.remove(mediaItem.filePath);
          }
        }
      }

      if (mounted) {
        // Show success message if any files were deleted
        if (_successfullyDeleted.isNotEmpty) {
          widget.onConfirmed(_successfullyDeleted);
        } else {
          // Show error if nothing was deleted
          await AlertErrorDialog.show(
            context,
            l10n.removeFilesFailedTitle,
            l10n.removeFilesFailedMessage,
            tips: l10n.removeFilesFailedTips,
          );
        }
      }
    } catch (e, stack) {
      if (kDebugMode) debugPrint('Error in deletion process: $e\n$stack');
      if (mounted) {
        Navigator.of(context).pop();
        await AlertErrorDialog.show(
          context,
          l10n.removeFilesFailedTitle,
          '${l10n.removeFilesFailedMessage}: ${e.toString()}',
          tips: l10n.removeFilesFailedTips,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 700;

    if (screenWidth < 800) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(color: AppColors.accent, width: 1),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16, right: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.delete_outline,
                                size: 32,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.removeFilesFromDataset,
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLargeScreen ? 24 : 20,
                                ),
                              ),
                            ],
                          ),
                          if (!_isDeleting)
                            IconButton(
                              icon: const Icon(Icons.close, color: AppColors.accent),
                              tooltip: l10n.buttonClose,
                              onPressed: () => Navigator.pop(context),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.accent),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: _isDeleting
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(height: 40),
                                    const CircularProgressIndicator(
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      l10n.removeFilesFromDatasetInProgress,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: isLargeScreen ? 22 : 18,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.removeFilesFromDatasetConfirm(widget.mediaItems.length),
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: isLargeScreen ? 22 : 18,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    CheckboxListTile(
                                      value: !_dbOnly,
                                      onChanged: (v) => setState(() => _dbOnly = !(v ?? false)),
                                      controlAffinity: ListTileControlAffinity.leading,
                                      activeColor: AppColors.accent,
                                      checkColor: Colors.black,
                                      title: Text(
                                        l10n.deleteProjectOptionDeleteFromDisk,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: isLargeScreen ? 20 : 16,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(height: 8),
                                    if (_dbOnly)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.info_outline, color: Colors.amberAccent),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              l10n.removeFilesDbOnlyNote,
                                              style: const TextStyle(
                                                color: Colors.amberAccent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (_dbOnly) const SizedBox(height: 16),
                                    ...widget.mediaItems.map((item) {
                                      final fileName = File(item.filePath).uri.pathSegments.last;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.image, size: 24, color: Colors.white38),
                                            const SizedBox(width: 15),
                                            Expanded(
                                              child: Text(
                                                fileName,
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: isLargeScreen ? 20 : 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const Divider(color: AppColors.accent),
                    if (!_isDeleting)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkSurface,
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.white70, width: 2),
                                ),
                              ),
                              child: Text(
                                l10n.buttonCancel,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLargeScreen ? 22 : 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _deleteFiles,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkSurface,
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.redAccent, width: 2),
                                ),
                              ),
                              child: Text(
                                l10n.buttonDelete,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLargeScreen ? 22 : 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    }

    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.accent, width: 1),
      ),
      titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.delete_outline,
                size: 32,
                color: AppColors.accent,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.removeFilesFromDataset,
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 24 : 20,
                ),
              ),
            ],
          ),
          if (!_isDeleting)
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.accent),
              tooltip: l10n.buttonClose,
              onPressed: () => Navigator.pop(context),
            ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: AppColors.accent),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isDeleting
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40),
                          const CircularProgressIndicator(
                            color: AppColors.accent,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.removeFilesFromDatasetInProgress,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isLargeScreen ? 22 : 18,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.removeFilesFromDatasetConfirm(widget.mediaItems.length),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isLargeScreen ? 22 : 18,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CheckboxListTile(
                            value: !_dbOnly,
                            onChanged: (v) => setState(() => _dbOnly = !(v ?? false)),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: AppColors.accent,
                            checkColor: Colors.black,
                            title: Text(
                              l10n.deleteProjectOptionDeleteFromDisk,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isLargeScreen ? 20 : 16,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 8),
                          if (_dbOnly)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.info_outline, color: Colors.amberAccent),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.removeFilesDbOnlyNote,
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (_dbOnly) const SizedBox(height: 16),
                          ...widget.mediaItems.map((item) {
                            final fileName = File(item.filePath).uri.pathSegments.last;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.image, size: 24, color: Colors.white38),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: isLargeScreen ? 20 : 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
              ),
              const Divider(color: AppColors.accent),
            ],
          ),
        ),
      ),
      actions: _isDeleting
          ? null
          : [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.white70, width: 2),
                  ),
                ),
                child: Text(
                  l10n.buttonCancel,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 22 : 18,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _deleteFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
                child: Text(
                  l10n.buttonDelete,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 22 : 18,
                  ),
                ),
              ),
            ],
    );
  }
}
