import 'package:flutter/material.dart';

import '../../../gen_l10n/app_localizations.dart';

import '../../../models/annotated_labeled_media.dart';
import '../../../models/project.dart';

import '../../dialogs/image_details_dialog.dart';
import '../../dialogs/set_image_icon_dialog.dart';
import '../../dialogs/delete_image_dialog.dart';
import '../../dialogs/duplicate_image_dialog.dart';

class ImageTileMenuButton extends StatelessWidget {
  final Project project;
  final AnnotatedLabeledMedia media;

  final void Function(bool withAnnotations)? onDuplicate;
  final void Function()? onDeleted;
  final void Function(String thumbnailPath)? onProjectThumbnailUpdate;
  final void Function()? onEditImage;
  final void Function()? onAnnotate;

  const ImageTileMenuButton({
    required this.project,
    required this.media,
    this.onDuplicate,
    this.onDeleted,
    this.onProjectThumbnailUpdate,
    this.onEditImage,
    this.onAnnotate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: Colors.white70, width: 1),
      ),
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) async {
        switch (value) {
          /// disable image edit since it is production ready
          case 'edit':
            // Call the edit image callback
            onEditImage?.call();
            break;

          case 'annotate':
            // Navigate to the image annotation screen
            onAnnotate?.call();
            break;

          case 'details':
            await showDialog(
              context: context,
              builder: (_) => ImageDetailsDialog(
                media: media,
              ),
            );
            break;

          case 'duplicate':
            await showDialog(
              context: context,
              builder: (_) => DuplicateImageDialog(
                media: media,
                onConfirmed: (withAnnotations, _) => onDuplicate?.call(withAnnotations),
              ),
            );
            break;

          case 'seticon':
            showDialog(
              context: context,
              builder: (_) => SetImageIconDialog(
                media: media.mediaItem,
                projectId: project.id.toString(),
                onConfirmed: (thumbnailPath) {
                  if (thumbnailPath != null) {
                    onProjectThumbnailUpdate?.call(thumbnailPath);
                  }
                },
              ),
            );
            break;
          case 'delete':
            final deleted = await showDialog<List<String>>(
              context: context,
              builder: (_) => DeleteImageDialog(
                mediaItems: [media.mediaItem],
                onConfirmed: (deletedPaths) => Navigator.pop(context, deletedPaths),
              ),
            );
            
            if (deleted != null && deleted.isNotEmpty) {
              debugPrint('Image deleted: ${media.mediaItem.filePath}');
              onDeleted?.call();
            }
            break;
        }
      },
      itemBuilder: (context) => [
        /// disable image edit since it is production ready
        /// PopupMenuItem(value: 'edit', child: _MenuItemRow(Icons.edit, 'Edit image')),
        PopupMenuItem(value: 'annotate', child: _MenuItemRow(Icons.info_outline, l10n.menuImageAnnotate)),
        PopupMenuItem(value: 'details', child: _MenuItemRow(Icons.info_outline, l10n.menuImageDetails)),
        PopupMenuItem(value: 'duplicate', child: _MenuItemRow(Icons.copy, l10n.menuImageDuplicate)),
        PopupMenuItem(value: 'seticon', child: _MenuItemRow(Icons.image_outlined, l10n.menuImageSetAsIcon)),
        PopupMenuItem(value: 'delete', child: _MenuItemRow(Icons.delete_outline, l10n.menuImageDelete)),
      ],
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MenuItemRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Icon(icon, size: screenWidth > 1200 ? 26 : 22),
        SizedBox(width: screenWidth > 1200 ? 8 : 4),
        Text(
          text,
          style: TextStyle(
            fontSize: screenWidth > 1200 ? 22 : 18,
            fontFamily: 'CascadiaCode',
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
