import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../gen_l10n/app_localizations.dart';
import '../../models/annotated_labeled_media.dart';
import '../../models/media_item.dart';
import 'image_tile/select_checkbox_overlay.dart';
import '../dialogs/image_details_dialog.dart';
import '../dialogs/delete_image_dialog.dart';

class MediaTile extends StatefulWidget {
  final AnnotatedLabeledMedia mediaItem;
  final void Function(bool isSelected)? onSelectedChanged;
  final VoidCallback? onRefreshNeeded;

  const MediaTile({super.key, required this.mediaItem, this.onSelectedChanged, this.onRefreshNeeded});

  @override
  State<MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile> {
  VideoPlayerController? _videoController;
  bool _initialized = false;
  bool _videoSupported = true;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();

    final media = widget.mediaItem.mediaItem;
    if (media.type == MediaType.video && File(media.filePath).existsSync()) {
      try {
        _videoController = VideoPlayerController.file(File(media.filePath));
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
    final media = widget.mediaItem.mediaItem;
    final file = File(media.filePath);
    final fileExists = file.existsSync();

    final isSelected = widget.mediaItem.isSelected;

    Widget preview;
    if (!fileExists) {
      preview = _buildBrokenTile();
    } else if (media.type == MediaType.video) {
      if (_initialized && _videoController != null) {
        preview = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              const Positioned(
                right: 4,
                bottom: 4,
                child: Icon(Icons.play_circle_fill, color: Colors.white),
              ),
            ],
          ),
        );
      } else if (!_videoSupported) {
        preview = _buildVideoNotSupportedTile();
      } else {
        preview = _buildLoadingTile();
      }
    } else {
      preview = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(file, fit: BoxFit.cover),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Colors.redAccent : Colors.transparent, width: 2),
        ),
        child: ClipRRect(
          child: Stack(
            children: [
              Positioned.fill(child: preview),
              Positioned(
                top: 4,
                left: 4,
                child: SelectCheckboxOverlay(
                  isVisible: _hovered || isSelected,
                  isSelected: isSelected,
                  onTap: () => widget.onSelectedChanged?.call(!isSelected),
                ),
              ),
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
                            builder: (_) => ImageDetailsDialog(media: widget.mediaItem),
                          );
                          break;
                        case 'delete':
                          final deleted = await showDialog<List<String>>(
                            context: context,
                            builder: (_) => DeleteImageDialog(
                              mediaItems: [media],
                              onConfirmed: (deletedPaths) => Navigator.pop(context, deletedPaths),
                            ),
                          );
                          if (deleted != null && deleted.isNotEmpty) {
                            debugPrint('Media deleted: \\${media.filePath}');
                            widget.onRefreshNeeded?.call();
                          }
                          break;
                      }
                    },
                    itemBuilder: (context) {
                      final l10n = AppLocalizations.of(context)!;
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