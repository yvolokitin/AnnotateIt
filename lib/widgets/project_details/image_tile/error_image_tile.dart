import 'package:flutter/material.dart';

import '../../../gen_l10n/app_localizations.dart';
import '../../../models/annotated_labeled_media.dart';
import '../../dialogs/image_details_dialog.dart';
import '../../dialogs/delete_image_dialog.dart';
import 'select_checkbox_overlay.dart';

class ErrorImageTile extends StatefulWidget {
  final String message;
  final AnnotatedLabeledMedia media;
  final bool isSelected;
  final void Function(bool isSelected) onSelectedChanged;
  final VoidCallback? onRefreshNeeded;

  const ErrorImageTile({
    required this.message,
    required this.media,
    required this.isSelected,
    required this.onSelectedChanged,
    this.onRefreshNeeded,
    super.key,
  });

  @override
  State<ErrorImageTile> createState() => _ErrorImageTileState();
}

class _ErrorImageTileState extends State<ErrorImageTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[850],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Center content showing error icon and message
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image, color: Colors.white24, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      widget.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontFamily: 'CascadiaCode',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection checkbox overlay (top-left)
              Positioned(
                top: 4,
                left: 4,
                child: SelectCheckboxOverlay(
                  isVisible: _hovered || isSelected,
                  isSelected: isSelected,
                  onTap: () => widget.onSelectedChanged(!isSelected),
                ),
              ),

              // Menu button (top-right) with Details and Delete
              Positioned(
                top: 4,
                right: 4,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _hovered ? 1.0 : 0.0,
                  child: PopupMenuButton<String>(
                    color: Colors.grey[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: const BorderSide(color: Colors.white70, width: 1),
                    ),
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) async {
                      switch (value) {
                        case 'details':
                          await showDialog(
                            context: context,
                            builder: (_) => ImageDetailsDialog(media: widget.media),
                          );
                          break;
                        case 'delete':
                          final deleted = await showDialog<List<String>>(
                            context: context,
                            builder: (_) => DeleteImageDialog(
                              mediaItems: [widget.media.mediaItem],
                              onConfirmed: (deletedPaths) => Navigator.pop(context, deletedPaths),
                              dbOnly: true,
                            ),
                          );
                          if (deleted != null && deleted.isNotEmpty) {
                            debugPrint('Image deleted: \\${widget.media.mediaItem.filePath}');
                            widget.onRefreshNeeded?.call();
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      final screenWidth = MediaQuery.of(context).size.width;
                      TextStyle textStyle = TextStyle(
                        fontSize: screenWidth > 1200 ? 22 : 18,
                        fontFamily: 'CascadiaCode',
                      );
                      return [
                        PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: screenWidth > 1200 ? 26 : 22),
                              SizedBox(width: screenWidth > 1200 ? 8 : 4),
                              Text(l10n.menuImageDetails, style: textStyle),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: screenWidth > 1200 ? 26 : 22),
                              SizedBox(width: screenWidth > 1200 ? 8 : 4),
                              Text(l10n.menuImageDelete, style: textStyle),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
