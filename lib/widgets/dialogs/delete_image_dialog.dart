import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';
import '../../models/media_item.dart';

class DeleteImageDialog extends StatelessWidget {
  final List<MediaItem> mediaItems;
  final VoidCallback onConfirmed;

  const DeleteImageDialog({
    super.key,
    required this.mediaItems,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isFullscreen = isMobile || isTablet;

    final dialogContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.removeFilesFromDatasetConfirm(mediaItems.length),
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 12),
        ...mediaItems.map((item) {
          final fileName = File(item.filePath).uri.pathSegments.last;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              children: [
                const Icon(Icons.image, size: 16, color: Colors.white38),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(color: Colors.white54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );

    return AlertDialog(
      insetPadding: isFullscreen ? EdgeInsets.zero : const EdgeInsets.all(40),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.removeFilesFromDataset),
          const SizedBox(height: 8),
          const Divider(thickness: 1, color: Colors.white),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isFullscreen ? double.infinity : 800,
          maxHeight: isFullscreen ? double.infinity : 500,
        ),
        child: SingleChildScrollView(child: dialogContent),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.white70, width: 2),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancelButton,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
          // onPressed: onConfirmed,
          onPressed: () {
            onConfirmed();
            Navigator.pop(context);
          },
          child: Text(
            l10n.deleteButton,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
