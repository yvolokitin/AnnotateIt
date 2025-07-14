import 'dart:io';
import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../models/media_item.dart';
import '../../data/dataset_database.dart';
import '../../widgets/dialogs/alert_error_dialog.dart';

class DeleteImageDialog extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final Function(List<String> deletedPaths) onConfirmed;

  const DeleteImageDialog({
    super.key,
    required this.mediaItems,
    required this.onConfirmed,
  });

  @override
  State<DeleteImageDialog> createState() => _DeleteImageDialogState();
}

class _DeleteImageDialogState extends State<DeleteImageDialog> {
  bool _isDeleting = false;
  final List<String> _successfullyDeleted = [];

  Future<void> _deleteFiles() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isDeleting = true;
      _successfullyDeleted.clear();
    });

    try {
      for (final mediaItem in widget.mediaItems) {
        if (mediaItem.id == null) continue;

        // Try to delete from filesystem
        final file = File(mediaItem.filePath);
        bool fileDeleted = false;
        
        if (await file.exists()) {
          try {
            await file.delete();
            debugPrint('Successfully deleted: ${mediaItem.filePath}');
            fileDeleted = true;
            _successfullyDeleted.add(mediaItem.filePath);
          } catch (e) {
            debugPrint('Failed to delete file: ${mediaItem.filePath}\n$e');
          }
        }

        // Only delete from DB if file was successfully deleted
        if (fileDeleted) {
          try {
            await DatasetDatabase.instance.deleteMediaItemWithAnnotations(mediaItem.id!);
          } catch (e) {
            debugPrint('Failed to delete DB record for: ${mediaItem.filePath}\n$e');
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
      debugPrint('Error in deletion process: $e\n$stack');
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

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.redAccent, width: 1),
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
                color: Colors.redAccent,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.removeFilesFromDataset,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                  fontSize: isLargeScreen ? 24 : 20,
                ),
              ),
            ],
          ),
          if (!_isDeleting)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
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
              const Divider(color: Colors.redAccent),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isDeleting
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40),
                          const CircularProgressIndicator(
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.removeFilesFromDatasetInProgress,
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'CascadiaCode',
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
                              fontFamily: 'CascadiaCode',
                              fontSize: isLargeScreen ? 22 : 18,
                            ),
                          ),
                          const SizedBox(height: 20),
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
                                        fontFamily: 'CascadiaCode',
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
              const Divider(color: Colors.redAccent),
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
                  backgroundColor: Colors.grey[800],
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
                    fontFamily: 'CascadiaCode',
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 22 : 18,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: _deleteFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
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
                    fontFamily: 'CascadiaCode',
                    fontWeight: FontWeight.bold,
                    fontSize: isLargeScreen ? 22 : 18,
                  ),
                ),
              ),
            ],
    );
  }
}
