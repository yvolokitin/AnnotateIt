import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart' as vthumb;
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

import '../../gen_l10n/app_localizations.dart';
import '../../models/annotated_labeled_media.dart';
import '../../models/media_item.dart';
import '../../data/dataset_database.dart';
import '../../session/user_session.dart';
import 'image_tile/select_checkbox_overlay.dart';
import '../dialogs/image_details_dialog.dart';
import '../dialogs/ffmpeg_check_dialog.dart';
import '../../services/video_frame_extractor.dart';
import '../dialogs/delete_image_dialog.dart';
import '../app_snackbar.dart';

class MediaTile extends StatefulWidget {
  final AnnotatedLabeledMedia mediaItem;
  final void Function(bool isSelected)? onSelectedChanged;
  final VoidCallback? onRefreshNeeded;

  const MediaTile({
    super.key,
    required this.mediaItem,
    this.onSelectedChanged,
    this.onRefreshNeeded,
  });

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
        _videoController!
            .initialize()
            .then((_) {
              if (mounted) {
                setState(() {
                  _initialized = true;
                  _videoController?.pause(); // we only want the first frame
                });
              }
            })
            .catchError((error) {
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
          border: Border.all(
            color: isSelected ? Colors.redAccent : Colors.transparent,
            width: 2,
          ),
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
                            builder:
                                (_) =>
                                    ImageDetailsDialog(media: widget.mediaItem),
                          );
                          break;
                        case 'open_in_folder':
                          await _openInFolder(context);
                          break;
                        case 'extract_frames':
                          await _extractFramesFromThisVideo(context);
                          break;
                        case 'delete':
                          final deleted = await showDialog<List<String>>(
                            context: context,
                            builder:
                                (_) => DeleteImageDialog(
                                  mediaItems: [media],
                                  onConfirmed:
                                      (deletedPaths) =>
                                          Navigator.pop(context, deletedPaths),
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
                      final items = <PopupMenuEntry<String>>[
                        PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: screenWidth > 1200 ? 26 : 22,
                              ),
                              SizedBox(width: screenWidth > 1200 ? 8 : 4),
                              Text(l10n.menuImageDetails, style: textStyle),
                            ],
                          ),
                        ),
                      ];
                      items.add(
                        PopupMenuItem(
                          value: 'open_in_folder',
                          child: Row(
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: screenWidth > 1200 ? 26 : 22,
                              ),
                              SizedBox(width: screenWidth > 1200 ? 8 : 4),
                              Text('Open in folder', style: textStyle),
                            ],
                          ),
                        ),
                      );
                      if (media.type == MediaType.video) {
                        items.add(
                          PopupMenuItem(
                            value: 'extract_frames',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.movie_creation_outlined,
                                  size: screenWidth > 1200 ? 26 : 22,
                                ),
                                SizedBox(width: screenWidth > 1200 ? 8 : 4),
                                Text('Extract frames', style: textStyle),
                              ],
                            ),
                          ),
                        );
                      }
                      items.add(
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: screenWidth > 1200 ? 26 : 22,
                              ),
                              SizedBox(width: screenWidth > 1200 ? 8 : 4),
                              Text(l10n.menuImageDelete, style: textStyle),
                            ],
                          ),
                        ),
                      );
                      return items;
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

  Future<void> _openInFolder(BuildContext context) async {
    final media = widget.mediaItem.mediaItem;
    final filePath = media.filePath;
    final file = File(filePath);
    if (!file.existsSync()) {
      AppSnackbar.show(context, 'File not found: ' + filePath);
      return;
    }

    try {
      if (Platform.isWindows) {
        final winPath = path.windows.normalize(filePath);
        final result = await Process.run('explorer', ['/select,' + winPath]);
        if (result.exitCode != 0) {
          AppSnackbar.show(context, 'Failed to open Explorer');
        }
      } else if (Platform.isMacOS) {
        final result = await Process.run('open', ['-R', filePath]);
        if (result.exitCode != 0) {
          AppSnackbar.show(context, 'Failed to reveal in Finder');
        }
      } else if (Platform.isLinux) {
        final dirPath = path.dirname(filePath);
        final result = await Process.run('xdg-open', [dirPath]);
        if (result.exitCode != 0) {
          AppSnackbar.show(context, 'Failed to open folder');
        }
      } else {
        AppSnackbar.show(
          context,
          'Open in folder is not supported on this platform',
        );
      }
    } catch (e) {
      AppSnackbar.show(context, 'Failed to open folder: ' + e.toString());
    }
  }

  // Extract frames from this video and insert into current dataset
  Future<void> _extractFramesFromThisVideo(BuildContext context) async {
    final media = widget.mediaItem.mediaItem;
    if (media.type != MediaType.video) {
      AppSnackbar.show(context, 'Not a video item');
      return;
    }

    final videoPath = media.filePath;
    final file = File(videoPath);
    if (!file.existsSync()) {
      AppSnackbar.show(context, 'File not found: $videoPath');
      return;
    }

    final logPrefix = '[MEDIA_TILE_VIDEO] ';
    void log(String msg) => print(logPrefix + msg);

    try {
      final currentUser = UserSession.instance.getUser();
      if (currentUser.id == null) {
        AppSnackbar.show(context, 'User not set');
        return;
      }

      AppSnackbar.show(context, 'Extracting frames...', saveToDb: false);

      // Determine duration (best effort)
      double durationSec = 0.0;
      try {
        final tmp = VideoPlayerController.file(File(videoPath));
        await tmp.initialize();
        durationSec = tmp.value.duration.inMilliseconds / 1000.0;
        await tmp.dispose();
      } catch (e) {
        log('video_player init failed: ' + e.toString());
      }

      double extractFps = FfmpegCheckDialog.lastSelectedFps;
      int expectedFrames =
          (durationSec > 0 ? (durationSec * extractFps) : 60).round();
      expectedFrames = expectedFrames.clamp(1, 1200);

      // Prepare frames base directory and a unique run directory inside Dataset import folder
      final baseName = path.basenameWithoutExtension(videoPath);
      final importRoot =
          await UserSession.instance.getCurrentUserDatasetImportFolder();
      int? projectId;
      try {
        final ds = await DatasetDatabase.instance.loadDatasetWithFolderIds(
          media.datasetId,
        );
        projectId = ds?.projectId;
      } catch (_) {}
      final List<String> segments = [];
      if (projectId != null) {
        segments.addAll(['project_' + projectId.toString()]);
      }
      segments.addAll(['dataset_' + media.datasetId, baseName + '_frames']);
      final framesBaseDir = Directory(
        path.join(importRoot, path.joinAll(segments)),
      );
      if (!framesBaseDir.existsSync()) {
        framesBaseDir.createSync(recursive: true);
      }
      final String runStamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final runDir = Directory(
        path.join(framesBaseDir.path, 'run_' + runStamp),
      );
      if (!runDir.existsSync()) {
        runDir.createSync(recursive: true);
      }

      final List<File> frameFiles = [];

      // Try video_thumbnail first on non-Windows
      if (!Platform.isWindows) {
        try {
          final intervalMs = (1000 / extractFps).round();
          for (int i = 0; i < expectedFrames; i++) {
            final timeMs = i * intervalMs;
            final bytes = await vthumb.VideoThumbnail.thumbnailData(
              video: videoPath,
              timeMs: timeMs,
              imageFormat: vthumb.ImageFormat.PNG,
              quality: 100,
            );
            if (bytes != null && bytes.isNotEmpty) {
              final framePath = path.join(
                runDir.path,
                baseName +
                    '_frame_' +
                    (i + 1).toString().padLeft(5, '0') +
                    '.png',
              );
              final out = File(framePath);
              await out.writeAsBytes(bytes);
              frameFiles.add(out);
            }
          }
        } catch (e) {
          log('video_thumbnail failed: ' + e.toString());
        }
      }

      // Windows fallback or if nothing extracted
      if (frameFiles.isEmpty && Platform.isWindows) {
        final ffmpegPath = await FfmpegCheckDialog.show(
          context,
          existingVideoPath: videoPath,
          initialFps: extractFps,
          onContinueExtract: (String ffPath, double fps) async {
            // Extract into unique run directory (do not modify previous runs)
            final ok = await VideoFrameExtractor().extractFramesWithFfmpeg(
              ffmpegPath: ffPath,
              videoPath: videoPath,
              framesDir: runDir.path,
              baseName: baseName,
              fps: fps,
              log: log,
            );

            if (!ok) {
              throw Exception('FFmpeg did not produce frames');
            }

            // Return number of produced frames from runDir
            final produced =
                runDir
                    .listSync()
                    .whereType<File>()
                    .where((f) => f.path.toLowerCase().endsWith('.png'))
                    .length;
            return produced;
          },
        );
        if (ffmpegPath != null) {
          final all =
              runDir
                  .listSync()
                  .whereType<File>()
                  .where((f) => f.path.toLowerCase().endsWith('.png'))
                  .toList()
                ..sort((a, b) => a.path.compareTo(b.path));
          frameFiles.addAll(all);
        }
      }

      if (frameFiles.isEmpty) {
        AppSnackbar.show(context, 'No frames extracted');
        return;
      }

      // Optional: read size from first frame
      int? frameWidth;
      int? frameHeight;
      try {
        final firstBytes = await frameFiles.first.readAsBytes();
        final decoded = img.decodeImage(firstBytes);
        if (decoded != null) {
          frameWidth = decoded.width;
          frameHeight = decoded.height;
        }
      } catch (_) {}

      // Insert frames into dataset
      int inserted = 0;
      for (final f in frameFiles) {
        await DatasetDatabase.instance.insertMediaItem(
          media.datasetId,
          f.path,
          'png',
          ownerId: currentUser.id!,
          width: frameWidth,
          height: frameHeight,
          source: 'video_frames',
        );
        inserted++;
      }

      AppSnackbar.show(
        context,
        'Extracted and added $inserted frame${inserted == 1 ? '' : 's'}',
      );

      widget.onRefreshNeeded?.call();
    } catch (e, st) {
      log('Extraction error: ' + e.toString());
      log(st.toString());
      AppSnackbar.show(context, 'Extraction failed: ' + e.toString());
    }
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
      child: Center(child: CircularProgressIndicator()),
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
