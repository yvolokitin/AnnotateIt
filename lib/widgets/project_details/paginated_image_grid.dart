import 'package:flutter/material.dart';

import '../../models/annotated_labeled_media.dart';
import '../../models/media_item.dart';
import '../../models/project.dart';

import 'image_tile.dart';
import 'media_tile.dart';

class PaginatedImageGrid extends StatefulWidget {
  final void Function(int newPage) onPageChanged;

  final List<AnnotatedLabeledMedia> annotatedMediaItems;
  final totalCount, totalPages, currentPage;
  final Project project;
  final int itemsPerPage;

  const PaginatedImageGrid({
    required this.annotatedMediaItems,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
    required this.project,
    required this.onPageChanged,
    this.itemsPerPage = 24,
    super.key,
  });

  @override
  State<PaginatedImageGrid> createState() => _PaginatedImageGridState();
}

class _PaginatedImageGridState extends State<PaginatedImageGrid> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final mediaItems = widget.annotatedMediaItems;

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.annotatedMediaItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final media = widget.annotatedMediaItems[index].mediaItem;
              if (media.type == MediaType.image) {
                return ImageTile(
                  media: widget.annotatedMediaItems[index],
                  mediaItems: mediaItems,
                  index: index,
                  project: widget.project,
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
