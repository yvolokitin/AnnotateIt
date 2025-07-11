import 'package:flutter/material.dart';

import '../../../models/annotated_labeled_media.dart';
import '../../dialogs/image_details_dialog.dart';
import '../../dialogs/set_image_icon_dialog.dart';
import '../../dialogs/delete_image_dialog.dart';
import '../../dialogs/duplicate_image_dialog.dart';


class ImageTileMenuButton extends StatelessWidget {
  final AnnotatedLabeledMedia media;
  final void Function(bool withAnnotations)? onDuplicate;

  const ImageTileMenuButton({
    required this.media,
    this.onDuplicate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
          case 'delete':
            showDialog(
              context: context,
              builder: (_) => DeleteImageDialog(
                mediaItems: [media.mediaItem],
                onConfirmed: () {
                  debugPrint('Image deleted: ${media.mediaItem.filePath}');
                },
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
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'CascadiaCode',
            fontWeight: FontWeight.normal,
          ),
        ),
      ]
    );
  }
}
