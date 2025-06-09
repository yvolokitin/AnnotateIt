import 'dart:io';
import 'package:flutter/material.dart';

import '../dialogs/image_details_dialog.dart';
import '../dialogs/set_image_icon_dialog.dart';
import '../dialogs/delete_image_dialog.dart';
import '../dialogs/duplicate_image_dialog.dart';

import '../../pages/annotator_page.dart';

import '../../models/project.dart';
import '../../models/annotated_labeled_media.dart';

class ImageTile extends StatefulWidget {
  final Project project;
  final String datasetId;
  final AnnotatedLabeledMedia mediaItem;
  final int pageIndex, pageSize, localIndex;
  final int totalMediaCount;

  final void Function(bool isSelected)? onSelectedChanged;
  final void Function(AnnotatedLabeledMedia media, bool withAnnotations)? onImageDuplicated;

  const ImageTile({
    required this.project,
    required this.datasetId,
    required this.mediaItem,
    required this.pageIndex,
    required this.pageSize,
    required this.localIndex,
    required this.totalMediaCount,
    this.onSelectedChanged,
    this.onImageDuplicated,
    super.key,
  });

  @override
  State<ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  bool _hovered = false;
  final GlobalKey _popupKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final file = File(widget.mediaItem.mediaItem.filePath);

    if (!file.existsSync()) {
      return _errorContainer("File not found");
    }

    final Matrix4 transform = Matrix4.identity();
    if (_hovered) transform.scale(1.15);

    final bool isSelected = widget.mediaItem.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: transform,
                transformAlignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnnotatorPage(
                          project: widget.project,
                          mediaItem: widget.mediaItem,
                          datasetId: widget.datasetId,
                          pageIndex: widget.pageIndex,
                          pageSize: widget.pageSize,
                          localIndex: widget.localIndex,
                          totalMediaCount: widget.totalMediaCount,
                        ),
                      ),
                    );
                  },
                  child: Image.file(
                    file,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),

              // left-top select icon
              Positioned(
                top: 4,
                left: 4,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _hovered || isSelected ? 1.0 : 0.0,
                  child: GestureDetector(
                    onTap: () {
                      widget.onSelectedChanged?.call(!isSelected);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Icon(
                        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

              // right-top 3-dot menu
              Positioned(
                top: 4,
                right: 4,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _hovered ? 1.0 : 0.0,
                  child: Container(
                    key: _popupKey,
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) async {
                        if (value == 'details') {
                          await showDialog(
                            context: context,
                            builder: (context) => ImageDetailsDialog(media: widget.mediaItem),
                          );
                        } else if (value == 'duplicate') {
                          await showDialog(
                            context: context,
                            builder: (context) => DuplicateImageDialog(
                              media: widget.mediaItem,
                              onConfirmed: (withAnnotations, saveAsDefault) {
                                print('ImageTile duplicating image withAnnotations: $withAnnotations, saveAsDefault: $saveAsDefault');
                                widget.onImageDuplicated?.call(widget.mediaItem, withAnnotations);
                              },
                            ),
                          );
                        } else if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (context) => DeleteImageDialog(
                              mediaItems: [widget.mediaItem.mediaItem],
                              onConfirmed: () {
                                print('File Delete: ${widget.mediaItem.mediaItem.filePath}');
                              },
                            ),
                          );
                        } else if (value == 'seticon') {
                          showDialog(
                            context: context,
                            builder: (context) => SetImageIconDialog(
                              media: widget.mediaItem.mediaItem,
                              onConfirmed: () {
                                print('Set project icon to: ${widget.mediaItem.mediaItem.filePath}');
                              },
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 22),
                              SizedBox(width: 8),
                              Text('Details', style: TextStyle(fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'duplicate',
                          child: Row(
                            children: [
                              Icon(Icons.copy, size: 22),
                              SizedBox(width: 8),
                              Text('Duplicate', style: TextStyle(fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),

                        const PopupMenuItem<String>(
                          value: 'seticon',
                          child: Row(
                            children: [
                              Icon(Icons.image_outlined, size: 22),
                              SizedBox(width: 8),
                              Text('Set as Icon', style: TextStyle(fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 22),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(fontWeight: FontWeight.normal)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // annotation badge (bottom-right)
              if (widget.mediaItem.hasAnnotations == true)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.label_important, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.mediaItem.annotationCount ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorContainer(String message) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[850],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image, color: Colors.white24, size: 40),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }
}
