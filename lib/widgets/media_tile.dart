import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/media_item.dart';

class MediaTile extends StatefulWidget {
  final MediaItem media;

  const MediaTile({super.key, required this.media});

  @override
  State<MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile> {
  late VideoPlayerController? _videoController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    if (widget.media.type == MediaType.video && File(widget.media.filePath).existsSync()) {
      _videoController = VideoPlayerController.file(File(widget.media.filePath))
        ..initialize().then((_) {
          setState(() {
            _initialized = true;
            _videoController?.pause(); // we only want the first frame
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
    final file = File(widget.media.filePath);
    final fileExists = file.existsSync();

    if (!fileExists) {
      return _buildBrokenTile();
    }

    if (widget.media.type == MediaType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(file, fit: BoxFit.cover),
      );
    }

    if (widget.media.type == MediaType.video && _initialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: Icon(Icons.play_circle_fill, color: Colors.white),
            ),
          ],
        ),
      );
    }

    return _buildLoadingTile();
  }

  Widget _buildBrokenTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
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
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
