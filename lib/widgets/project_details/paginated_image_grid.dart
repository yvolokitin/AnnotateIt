import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

import '../../models/annotated_labeled_media.dart';
import '../../models/media_item.dart';
import '../../models/label.dart';
import '../../models/project.dart';

import 'image_tile.dart';
import 'media_tile.dart';

class PaginatedImageGrid extends StatefulWidget {
  final void Function(AnnotatedLabeledMedia media, bool withAnnotations)? onImageDuplicated;
  final void Function(List<AnnotatedLabeledMedia>)? onSelectionChanged;
  final void Function(int newPage) onPageChanged;

  final Project project;
  final String datasetId;
  final List<Label> labels;
  final List<AnnotatedLabeledMedia> annotatedMediaItems;
  final int totalCount, totalPages, currentPage, itemsPerPage;

  const PaginatedImageGrid({
    required this.project,
    required this.datasetId,
    required this.labels,
    required this.annotatedMediaItems,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.onSelectionChanged,
    this.onImageDuplicated,
    super.key,
  });

  @override
  State<PaginatedImageGrid> createState() => _PaginatedImageGridState();
}

class _PaginatedImageGridState extends State<PaginatedImageGrid> {
  int _getCrossAxisCount() {
    switch (widget.itemsPerPage) {
      case 8:
        return 3;
      case 16:
        return 4;
      case 24:
        return 6;
      case 32:
        return 8;
      case 48:
        return 8;
      default:
        return 6;
    }
  }

  String getPaginationText() {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 700) {
      return l10n.paginationPageFromTotal(widget.currentPage + 1, widget.totalPages);

    } else {
      return "${(widget.currentPage + 1)} / ${widget.totalPages}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaItems = widget.annotatedMediaItems;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            itemCount: mediaItems.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final media = mediaItems[index].mediaItem;
              if (media.type == MediaType.image) {
                return ImageTile(
                  project: widget.project,
                  datasetId: widget.datasetId,
                  mediaItem: mediaItems[index],
                  pageIndex: widget.currentPage,
                  pageSize: widget.itemsPerPage,
                  localIndex: index,
                  totalMediaCount: widget.totalCount,
                  onSelectedChanged: (isSelected) {
                    setState(() {
                      mediaItems[index].isSelected = isSelected;
                    });
                    widget.onSelectionChanged?.call(
                      mediaItems.where((item) => item.isSelected).toList(),
                    );
                  },
                  onImageDuplicated: (media, withAnnotations) {
                    widget.onImageDuplicated?.call(media, withAnnotations);
                  },
                );
              } else {
                return MediaTile(media: media);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: widget.currentPage > 0
                    ? () => widget.onPageChanged(widget.currentPage - 1)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                child: Text(
                  screenWidth > 700 ? l10n.dialogBack : '<-',
                  style: const TextStyle(
                    fontFamily: 'CascadiaCode',
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                getPaginationText(),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'CascadiaCode',
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: widget.currentPage < widget.totalPages - 1
                    ? () => widget.onPageChanged(widget.currentPage + 1)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.red, width: 1),
                  ),
                ),
                child: Text(
                  screenWidth > 700 ? l10n.dialogNext : '->',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'CascadiaCode',
                  ),
                ),
              ),
            ],
          ),
        ),  
      ],
    );
  }
}
