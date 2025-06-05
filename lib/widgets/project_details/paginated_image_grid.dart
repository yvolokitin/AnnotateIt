import 'package:flutter/material.dart';

import '../../models/annotated_labeled_media.dart';
import '../../models/media_item.dart';
import '../../models/project.dart';

import 'image_tile.dart';
import 'media_tile.dart';

class PaginatedImageGrid extends StatefulWidget {
  final void Function(List<AnnotatedLabeledMedia>)? onSelectionChanged;
  final void Function(int newPage) onPageChanged;

  final List<AnnotatedLabeledMedia> annotatedMediaItems;
  final int totalCount, totalPages, currentPage, itemsPerPage;
  final Project project;

  const PaginatedImageGrid({
    required this.annotatedMediaItems,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.itemsPerPage,
    required this.project,
    required this.onPageChanged,
    this.onSelectionChanged,
    super.key,
  });

  @override
  State<PaginatedImageGrid> createState() => _PaginatedImageGridState();
}

class _PaginatedImageGridState extends State<PaginatedImageGrid> {
  int _currentPage = 0;

  int _getCrossAxisCount() {
    print('PaginatedImageGrid:: itemsPerPage: ${widget.itemsPerPage}');

    switch (widget.itemsPerPage) {
      case 8:
        return 2;
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

  @override
  Widget build(BuildContext context) {
    final mediaItems = widget.annotatedMediaItems;

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            // padding: const EdgeInsets.all(16),
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
                  media: mediaItems[index],
                  index: index,
                  project: widget.project,
                  onSelectedChanged: (isSelected) {
                    setState(() {
                      mediaItems[index].isSelected = isSelected;
                    });
                    widget.onSelectionChanged?.call(
                      mediaItems.where((item) => item.isSelected).toList(),
                    );
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
                child: const Text("<- Back"),
              ),
              const SizedBox(width: 20),
              Text(
                "Page ${widget.currentPage + 1} from ${widget.totalPages}",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: widget.currentPage < widget.totalPages - 1
                    ? () => widget.onPageChanged(widget.currentPage + 1)
                    : null,
                child: const Text("Next ->"),
              ),
            ],
          ),
        ),  
      ],
    );
  }
}
