import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vap/models/project.dart';

import '../models/media_item.dart';
import '../models/project.dart';

import 'image_tile.dart';
import 'media_tile.dart';

class PaginatedImageGrid extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int itemsPerPage;
  final Project project;

  const PaginatedImageGrid({
    required this.mediaItems,
    required this.project,
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
    final mediaItems = widget.mediaItems;

    final totalPages = (mediaItems.length / widget.itemsPerPage).ceil();
    final start = _currentPage * widget.itemsPerPage;
    final end = (start + widget.itemsPerPage).clamp(0, mediaItems.length);
    final pageItems = mediaItems.sublist(start, end);

    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pageItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final media = pageItems[index];
              if (media.type == MediaType.image) {
                return ImageTile(
                  media: media,
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
                onPressed: _currentPage > 0
                    ? () => setState(() => _currentPage--)
                    : null,
                child: const Text("<- Back"),
              ),
              const SizedBox(width: 20),
              Text(
                "Page ${_currentPage + 1} from $totalPages",
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _currentPage < totalPages - 1
                    ? () => setState(() => _currentPage++)
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
