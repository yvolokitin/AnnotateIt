import 'package:flutter/material.dart';
import '../../../models/annotated_labeled_media.dart';
import '../../dialogs/image_details_dialog.dart';
import '../../dialogs/set_image_icon_dialog.dart';
import '../../dialogs/delete_image_dialog.dart';
import '../../dialogs/duplicate_image_dialog.dart';

class ImageTileMenuButton extends StatelessWidget {
  final AnnotatedLabeledMedia media;
  final void Function(bool withAnnotations)? onDuplicate;
  final void Function()? onDeleted;

  const ImageTileMenuButton({
    required this.media,
    this.onDuplicate,
    this.onDeleted,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: const BorderSide(color: Colors.white70, width: 1),
      ),
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) async {
        switch (value) {
          case 'details':
            await showDialog(context: context, builder: (_) => ImageDetailsDialog(media: media));
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
                onConfirmed: () {
                  debugPrint('Icon set: ${media.mediaItem.filePath}');
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
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'details', child: _MenuItemRow(Icons.info_outline, 'Details')),
        PopupMenuItem(value: 'duplicate', child: _MenuItemRow(Icons.copy, 'Duplicate')),
        PopupMenuItem(value: 'seticon', child: _MenuItemRow(Icons.image_outlined, 'Set as Icon')),
        PopupMenuItem(value: 'delete', child: _MenuItemRow(Icons.delete_outline, 'Delete')),
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
