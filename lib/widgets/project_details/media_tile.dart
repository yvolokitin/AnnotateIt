import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/media_item.dart';

class MediaTile extends StatefulWidget {
  final MediaItem media;

  const MediaTile({super.key, required this.media});

  @override
  State<MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile> {
  VideoPlayerController? _videoController;
  bool _initialized = false;
  bool _videoSupported = true;

  @override
  void initState() {
    super.initState();

    if (widget.media.type == MediaType.video && File(widget.media.filePath).existsSync()) {
      try {
        _videoController = VideoPlayerController.file(File(widget.media.filePath));
        _videoController!.initialize().then((_) {
          if (mounted) {
            setState(() {
              _initialized = true;
              _videoController?.pause(); // we only want the first frame
            });
          }
        }).catchError((error) {
          // Handle initialization error
          if (mounted) {
            setState(() {
              _videoController = null;
              _videoSupported = false;
            });
          }
        });
      } catch (e) {
        // Handle platform not supported error
        _videoController = null;
        _videoSupported = false;
      }
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

    if (widget.media.type == MediaType.video) {
      if (_initialized && _videoController != null) {
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
      } else if (!_videoSupported) {
        // Video player not supported on this platform
        return _buildVideoNotSupportedTile();
      }
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

  Widget _buildVideoNotSupportedTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(
              'Video not supported',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Supported formats: MP4, WebM, MKV (platform dependent)',
                style: TextStyle(color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}