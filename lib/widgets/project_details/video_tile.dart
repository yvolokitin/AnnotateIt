import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/media_item.dart';
import '../../models/project.dart';
import '../../models/annotated_labeled_media.dart';
import '../../pages/image_annotator_page.dart';

class VideoTile extends StatefulWidget {
  final AnnotatedLabeledMedia annotated;
  final List<AnnotatedLabeledMedia> allAnnotated;
  final int index;
  final Project project;

  const VideoTile({
    super.key,
    required this.annotated,
    required this.allAnnotated,
    required this.index,
    required this.project,
  });

  @override
  State<VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  late VideoPlayerController? _videoController;
  bool _initialized = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    final media = widget.annotated.mediaItem;

    if (media.type == MediaType.video && File(media.filePath).existsSync()) {
      _videoController = VideoPlayerController.file(File(media.filePath))
        ..initialize().then((_) {
          setState(() {
            _initialized = true;
            _videoController?.pause(); // show thumbnail
          });
        });
    } else {
      _videoController = null;
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.annotated.mediaItem;
    final file = File(media.filePath);

    if (!file.existsSync()) return _buildBrokenTile();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageAnnotatorPage(
                annotatedItems: widget.allAnnotated,
                initialIndex: widget.index,
                project: widget.project,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _initialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : _buildLoadingTile(),
            ),
            const Positioned(
              right: 4,
              bottom: 4,
              child: Icon(Icons.play_circle_fill, color: Colors.white),
            ),
            _buildOverlayLabel(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrokenTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildLoadingTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildOverlayLabel() {
    final labelText = widget.annotated.labels.isNotEmpty
        ? widget.annotated.labels.first.name
        : null;

    if (labelText == null) return const SizedBox.shrink();

    return Positioned(
      top: 4,
      left: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          labelText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
