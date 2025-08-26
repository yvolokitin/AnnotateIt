import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart' as vp;

import '../../gen_l10n/app_localizations.dart';
import '../../models/project.dart';
import '../../utils/image_utils.dart';
import '../../data/dataset_database.dart';
import '../../data/project_database.dart';
import '../../session/user_session.dart';
import '../dialogs/camera_capture_dialog.dart';
import '../dialogs/ffmpeg_check_dialog.dart';
import '../../services/video_frame_extractor.dart';
import 'package:url_launcher/url_launcher.dart';

class DatasetUploadButtons extends StatefulWidget {
  final Project project;
  final int totalCount, itemsPerPage;
  final int selectedCount;
  final String datasetId;

  final bool isUploading;
  final bool cancelUpload;
  final bool allSelected;

  final Function(bool) onUploadingChanged;
  final VoidCallback onUploadSuccess;
  final void Function(String filename, int index, int total)? onFileProgress;
  final void Function(int newItemsPerPage)? onItemsPerPageChanged;
  final VoidCallback? onUploadError;

  final VoidCallback? onDeleteSelected;
  final VoidCallback? onToggleSelectAll;

  const DatasetUploadButtons({
    required this.project,
    required this.datasetId,
    required this.totalCount,
    required this.itemsPerPage,
    required this.isUploading,
    required this.onUploadingChanged,
    required this.onUploadSuccess,
    required this.cancelUpload,
    required this.selectedCount,
    required this.allSelected,
    this.onFileProgress,
    this.onUploadError,
    this.onDeleteSelected,
    this.onToggleSelectAll,
    this.onItemsPerPageChanged,
    super.key,
  });

  @override
  State<DatasetUploadButtons> createState() => _DatasetUploadButtonsState();
}

class _DatasetUploadButtonsState extends State<DatasetUploadButtons> {
  // Session-scoped cache for a user-selected ffmpeg executable on Windows
  static String? _ffmpegPathCache;

  bool _hoveringDelete = false;
  late int _currentItemsPerPage;

  @override
  void initState() {
    super.initState();
    _currentItemsPerPage = widget.itemsPerPage;
  }

  Future<void> _uploadMedia(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
      );

      if (result != null && result.files.isNotEmpty) {
        widget.onUploadingChanged(true);
        final total = result.files.length;

        if (widget.project.icon.contains('default_project_image') ||
            widget.project.icon.contains('folder')) {
          final platformFile = result.files[0];
          final thumbnailFile = await generateThumbnailFromImage(
              File(platformFile.path!), widget.project.id.toString());
          if (thumbnailFile != null) {
            await ProjectDatabase.instance
                .updateProjectIcon(widget.project.id!, thumbnailFile.path);
          }
        }

        for (int i = 0; i < total; i++) {
          if (widget.cancelUpload) {
            widget.onUploadingChanged(false);
            widget.onUploadError?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Upload stopped")),
            );
            return;
          }

          final file = result.files[i];
          final ext = file.extension?.toLowerCase() ?? 'unknown';
          final currentUser = UserSession.instance.getUser();
          if (currentUser.id == null) {
            widget.onUploadError?.call();
            return;
          }

          int? width;
          int? height;
          double? duration;
          double? fps;
          final isVideo = ['mp4', 'mov'].contains(ext);

          if (isVideo) {
            final videoMeta = await getVideoMetadata(file.path!);
            width = videoMeta['width'];
            height = videoMeta['height'];
            duration = videoMeta['duration'];
            fps = videoMeta['fps'];
          } else {
            final imageMeta = await getImageMetadata(file.path!);
            width = imageMeta['width'];
            height = imageMeta['height'];
          }

          await DatasetDatabase.instance.insertMediaItem(
            widget.datasetId,
            file.path!,
            ext,
            ownerId: currentUser.id!,
            width: width,
            height: height,
            duration: duration,
            fps: fps,
            source: 'local',
          );

          widget.onFileProgress?.call(file.name, i + 1, total);
        }

        await ProjectDatabase.instance.updateProjectLastUpdated(widget.project.id!);
        widget.onUploadingChanged(false);
        widget.onUploadSuccess();
      } else {
        widget.onUploadingChanged(false);
      }
    } catch (e) {
      print("_uploadMedia: Upload error: $e");
      widget.onUploadError?.call();
    }
  }
  
  Future<void> _uploadVideoAsFrames(BuildContext context) async {
    // Collect debug logs to show in UI if needed
    final List<String> _logs = [];
    void logMsg(String msg) {
      final line = '[VIDEO_IMPORT] ' + DateTime.now().toIso8601String() + ' ' + msg;
      _logs.add(line);
      print(line);
    }

    try {
      logMsg('Platform: ' + Platform.operatingSystem + ' ' + Platform.version.split('\n').first);

      // macOS: use ffmpeg-kit (no ffmpeg selection)
      if (Platform.isMacOS) {
        await _uploadVideoAsFramesMac(context, logMsg);
        return;
      }

      // Windows-only: Use FfmpegCheckDialog to show progress and perform selection + extraction
      if (Platform.isWindows) {
        String? selectedVideoPath;
        String? framesDirPath;
        String? baseName;
        int totalExtracted = 0;

        final ffmpegPath = await FfmpegCheckDialog.show(
          context,
          initialFps: FfmpegCheckDialog.lastSelectedFps,
          onContinueExtract: (String ffPath, double fps) async {
            // 1) Ask user to select a video
            final pick = await FilePicker.platform.pickFiles(
              allowMultiple: false,
              type: FileType.custom,
              allowedExtensions: ['mp4', 'mov'],
            );
            if (pick == null || pick.files.isEmpty) {
              throw Exception('No video selected');
            }
            selectedVideoPath = pick.files.first.path!;
            baseName = path.basenameWithoutExtension(selectedVideoPath!);

            // 2) Prepare frames base directory inside Dataset import folder, then create unique run dir
            final importRoot = await UserSession.instance.getCurrentUserDatasetImportFolder();
            final framesBaseDir = Directory(path.join(
              importRoot,
              'project_' + ((widget.project.id ?? 0).toString()),
              'dataset_' + widget.datasetId,
              baseName! + '_frames',
            ));
            if (!framesBaseDir.existsSync()) {
              framesBaseDir.createSync(recursive: true);
            }
            final String runStamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
            final runDir = Directory(path.join(framesBaseDir.path, 'run_' + runStamp));
            if (!runDir.existsSync()) {
              runDir.createSync(recursive: true);
            }
            framesDirPath = runDir.path;

            // 3) Run FFmpeg extraction via service into runDir (do not touch previous runs)
            final ok = await VideoFrameExtractor().extractFramesWithFfmpeg(
              ffmpegPath: ffPath,
              videoPath: selectedVideoPath!,
              framesDir: runDir.path,
              baseName: baseName!,
              fps: fps,
              log: logMsg,
            );
            if (!ok) {
              throw Exception('FFmpeg did not produce frames');
            }

            // 4) Return produced count for dialog UI from runDir
            final produced = runDir
                .listSync()
                .whereType<File>()
                .where((f) => f.path.toLowerCase().endsWith('.png'))
                .length;
            totalExtracted = produced;
            return produced;
          },
        );

        if (ffmpegPath == null || selectedVideoPath == null || framesDirPath == null || baseName == null) {
          logMsg('User cancelled FFmpeg dialog or no video selected.');
          return;
        }

        // Collect generated frames
        final framesDir = Directory(framesDirPath!);
        final frameFiles = framesDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.toLowerCase().endsWith('.png'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));

        if (frameFiles.isEmpty) {
          logMsg('No frames found after FFmpeg extraction.');
          return;
        }

        // Read size from first frame (optional)
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

        // Insert into DB with progress outside of dialog
        final currentUser = UserSession.instance.getUser();
        if (currentUser.id == null) {
          widget.onUploadError?.call();
          return;
        }

        widget.onUploadingChanged(true);
        int inserted = 0;
        for (final f in frameFiles) {
          if (widget.cancelUpload) {
            widget.onUploadingChanged(false);
            widget.onUploadError?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload stopped')),
            );
            return;
          }

          await DatasetDatabase.instance.insertMediaItem(
            widget.datasetId,
            f.path,
            'png',
            ownerId: currentUser.id!,
            width: frameWidth,
            height: frameHeight,
            source: 'video_frames',
          );
          inserted++;
        }

        // Update project icon if default
        if (widget.project.icon.contains('default_project_image') || widget.project.icon.contains('folder')) {
          final firstFramePath = frameFiles.first.path;
          final thumb = await generateThumbnailFromImage(File(firstFramePath), widget.project.id.toString());
          if (thumb != null) {
            await ProjectDatabase.instance.updateProjectIcon(widget.project.id!, thumb.path);
          }
        }

        await ProjectDatabase.instance.updateProjectLastUpdated(widget.project.id!);
        widget.onUploadingChanged(false);
        widget.onUploadSuccess();

        // Show summary dialog
        if (mounted) {
          await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.orangeAccent, width: 1),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: (MediaQuery.of(ctx).size.width > 1200) ? 34 : 26,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Import complete',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontFamily: 'CascadiaCode',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.orangeAccent),
                    const SizedBox(height: 6),
                    Text(
                      'Extracted ' + totalExtracted.toString() + ' frame' + (totalExtracted == 1 ? '' : 's') + ' and added to dataset. (via FFmpeg)',
                      style: const TextStyle(color: Colors.white70, fontFamily: 'CascadiaCode'),
                    ),
                  ],
                ),
                actions: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close', style: TextStyle(color: Colors.white70, fontFamily: 'CascadiaCode')),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              );
            },
          );
        }

        return;
      }


      // Android/iOS info dialog (built-in extraction, no FFmpeg needed)
      if (Platform.isAndroid || Platform.isIOS) {
        final bool? proceedMobile = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            final screenWidth = MediaQuery.of(ctx).size.width;
            return AlertDialog(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.orangeAccent, width: 1),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.movie_creation_outlined,
                    size: (screenWidth > 1200) ? 34 : 26,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Video import',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Divider(color: Colors.orangeAccent),
                  SizedBox(height: 4),
                  Text(
                    'Frames will be extracted using built-in capabilities of your device (no FFmpeg required).',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'CascadiaCode'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tap Continue to choose a video file to import and extract frames as images.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'CascadiaCode'),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontFamily: 'CascadiaCode')),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.orangeAccent, width: 2),
                        ),
                      ),
                      child: const Text('Continue', style: TextStyle(color: Colors.white, fontFamily: 'CascadiaCode', fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            );
          },
        );
        if (proceedMobile != true) {
          logMsg('User cancelled mobile pre-info dialog.');
          return;
        }
      }

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov'],
      );

      if (result == null || result.files.isEmpty) {
        logMsg('User cancelled file picking.');
        return;
      }

      final picked = result.files.first;
      final videoPath = picked.path!;
      final fileName = picked.name;
      logMsg('Selected file: ' + videoPath);

      widget.onUploadingChanged(true);

      // Inform user we started working on the selected file

      // Determine target frames count (fallback if metadata is unavailable)
      final meta = await getVideoMetadata(videoPath);
      final double durationStub = (meta['duration'] ?? 0.0) as double;
      final double fpsStub = (meta['fps'] ?? 0.0) as double;
      int totalFrames;
      if (durationStub > 0 && fpsStub > 0) {
        totalFrames = (durationStub * fpsStub).round().clamp(1, 600);
      } else {
        totalFrames = 60; // fallback default
      }
      logMsg('Stub metadata -> duration: ' + durationStub.toString() + ', fps: ' + fpsStub.toString() + ', fallback totalFrames: ' + totalFrames.toString());

      // Prepare output directory inside Dataset import folder
      final videoFile = File(videoPath);
      if (!await videoFile.exists()) {
        throw Exception('Selected video file not found');
      }
      final fileSize = await videoFile.length();
      logMsg('Video exists. Size: ' + fileSize.toString() + ' bytes.');

      final importRoot = await UserSession.instance.getCurrentUserDatasetImportFolder();
      final baseName = path.basenameWithoutExtension(videoFile.path);
      final framesBaseDir = Directory(path.join(
        importRoot,
        'project_' + ((widget.project.id ?? 0).toString()),
        'dataset_' + widget.datasetId,
        baseName + '_frames',
      ));
      if (!framesBaseDir.existsSync()) {
        framesBaseDir.createSync(recursive: true);
        logMsg('Created frames base directory: ' + framesBaseDir.path);
      } else {
        logMsg('Using existing frames base directory: ' + framesBaseDir.path);
      }
      final String runStamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final runDir = Directory(path.join(framesBaseDir.path, 'run_' + runStamp));
      if (!runDir.existsSync()) {
        runDir.createSync(recursive: true);
        logMsg('Created run directory: ' + runDir.path);
      }

      // Ensure run directory writable
      final testFile = File(path.join(runDir.path, '.write_test_${DateTime.now().millisecondsSinceEpoch}'));
      try {
        await testFile.writeAsString('test');
        await testFile.delete();
        logMsg('Write test in run directory succeeded.');
      } catch (e) {
        logMsg('Write test failed for ' + runDir.path + ': ' + e.toString());
        throw Exception('Cannot write to directory: ${runDir.path}');
      }

      // Extract frames and insert into dataset
      final currentUser = UserSession.instance.getUser();
      if (currentUser.id == null) {
        logMsg('Current user is not set (id == null). Aborting.');
        widget.onUploadingChanged(false);
        widget.onUploadError?.call();
        return;
      }

      // Initialize a video controller to get accurate duration
      double videoSeconds = 0.0;
      String? controllerError;
      try {
        final controller = vp.VideoPlayerController.file(File(videoPath));
        await controller.initialize();
        videoSeconds = controller.value.duration.inMilliseconds / 1000.0;
        logMsg('video_player initialize OK. Duration: ' + videoSeconds.toString() + ' s, aspectRatio: ' + controller.value.aspectRatio.toString());
        await controller.dispose();
      } catch (e) {
        controllerError = e.toString();
        logMsg('video_player initialize FAILED: ' + controllerError);
      }

      // Choose an extraction fps (configurable)
      final double extractFps = FfmpegCheckDialog.lastSelectedFps; // configurable fps
      int expectedFrames = (videoSeconds > 0 ? (videoSeconds * extractFps) : totalFrames).round();
      if (expectedFrames <= 0) expectedFrames = totalFrames > 0 ? totalFrames : 60;
      expectedFrames = expectedFrames.clamp(1, 1200); // safety cap
      logMsg('Extraction fps: ' + extractFps.toString() + ', expectedFrames: ' + expectedFrames.toString());

      // Prepare variables for extraction
      String? firstThumbError;
      final List<File> frameFiles = [];

      // On Windows, skip video_thumbnail (no plugin implementation) and rely on FFmpeg fallback below
      if (!Platform.isWindows) {
        try {
          final probe = await VideoThumbnail.thumbnailData(
            video: videoPath,
            timeMs: 0,
            imageFormat: ImageFormat.PNG,
            quality: 100,
          );
          logMsg('video_thumbnail probe@0ms -> bytes: ' + (probe?.length ?? 0).toString());
        } catch (e) {
          firstThumbError = e.toString();
          logMsg('video_thumbnail probe FAILED: ' + firstThumbError);
        }

        // Generate frames using video_thumbnail at regular intervals
        final int intervalMs = (1000 / extractFps).round();
        for (int i = 0; i < expectedFrames; i++) {
          if (widget.cancelUpload) {
            logMsg('User requested cancel during extraction loop at frame ' + (i + 1).toString());
            widget.onUploadingChanged(false);
            widget.onUploadError?.call();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload stopped')),
            );
            return;
          }

          final timeMs = i * intervalMs;
          try {
            final bytes = await VideoThumbnail.thumbnailData(
              video: videoPath,
              timeMs: timeMs,
              imageFormat: ImageFormat.PNG,
              quality: 100,
            );
            if (bytes != null && bytes.isNotEmpty) {
              final framePath = path.join(
                runDir.path,
                baseName + '_frame_' + (i + 1).toString().padLeft(5, '0') + '.png',
              );
              final frameFile = File(framePath);
              await frameFile.writeAsBytes(bytes);
              frameFiles.add(frameFile);
            } else {
              if (i == 0) {
                logMsg('video_thumbnail returned empty bytes at first frame.');
              }
            }
          } catch (e) {
            if (i == 0) {
              logMsg('video_thumbnail threw at frame 1: ' + e.toString());
            }
            // Skip frame on error
          }
        }
      }

      int totalExtracted = frameFiles.length;
      if (!Platform.isWindows) {
        logMsg('video_thumbnail extracted frames: ' + totalExtracted.toString());
      }

      // Windows fallback with FFmpeg if no frames extracted
      bool usedFfmpeg = false;
      bool ffmpegResolved = false;
      String? ffmpegError;
      String? ffmpegPathUsed;
      if (totalExtracted == 0 && Platform.isWindows) {
        logMsg('No frames via video_thumbnail and running on Windows. Trying FFmpeg extraction...');

        // Use the already-created unique runDir; do not clean previous runs
        final ffmpegPath = await VideoFrameExtractor().resolveFfmpegPath(log: logMsg);
        if (ffmpegPath != null) {
          ffmpegResolved = true;
          ffmpegPathUsed = ffmpegPath;
          final ok = await VideoFrameExtractor().extractFramesWithFfmpeg(
            ffmpegPath: ffmpegPath,
            videoPath: videoPath,
            framesDir: runDir.path,
            baseName: baseName,
            fps: extractFps,
            log: logMsg,
          );
          usedFfmpeg = ok;
          if (ok) {
            // Collect generated frames
            final all = runDir
                .listSync()
                .whereType<File>()
                .where((f) => f.path.toLowerCase().endsWith('.png'))
                .toList()
              ..sort((a, b) => a.path.compareTo(b.path));
            frameFiles.addAll(all);
            totalExtracted = frameFiles.length;
            logMsg('FFmpeg extracted frames: ' + totalExtracted.toString());
          } else {
            ffmpegError = 'FFmpeg run did not produce frames (see logs above).';
          }
        } else {
          ffmpegError = 'FFmpeg not available on PATH and user did not provide a valid ffmpeg.exe.';
        }
      }

      if (totalExtracted == 0) {
        // Gracefully handle platforms where extraction is not supported and show diagnostics
        widget.onUploadingChanged(false);
        final String diag = [
          'Platform: ' + Platform.operatingSystem,
          'video path: ' + videoPath,
          if (controllerError != null) 'video_player error: ' + controllerError!,
          if (firstThumbError != null) 'video_thumbnail error: ' + firstThumbError!,
          if (Platform.isWindows) 'ffmpeg resolved: ' + (ffmpegResolved ? 'YES' : 'NO'),
          if (Platform.isWindows && ffmpegPathUsed != null) 'ffmpeg path: ' + ffmpegPathUsed!,
          if (ffmpegError != null) ffmpegError!,
          'frames dir: ' + runDir.path,
        ].join('\n');

        if (mounted) {
          await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.orangeAccent, width: 1),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: (MediaQuery.of(ctx).size.width > 1200) ? 34 : 26,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Import not completed',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontFamily: 'CascadiaCode',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Colors.orangeAccent),
                      const SizedBox(height: 6),
                      SelectableText(
                        'Could not extract frames from the selected video.\n\nDiagnostics:\n' + diag,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'CascadiaCode'),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close', style: TextStyle(color: Colors.white70, fontFamily: 'CascadiaCode')),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              );
            },
          );
        }
        return;
      }

      // Read size from first image (optional metadata)
      int? frameWidth;
      int? frameHeight;
      try {
        final firstBytes = await frameFiles.first.readAsBytes();
        final decoded = img.decodeImage(firstBytes);
        if (decoded != null) {
          frameWidth = decoded.width;
          frameHeight = decoded.height;
          logMsg('First frame dimensions: ' + frameWidth.toString() + 'x' + frameHeight.toString());
        }
      } catch (e) {
        logMsg('Failed to read first frame size: ' + e.toString());
      }

      // Insert extracted frames into DB with progress
      int inserted = 0;
      for (final f in frameFiles) {
        if (widget.cancelUpload) {
          logMsg('User requested cancel during DB insert at item ' + (inserted + 1).toString());
          widget.onUploadingChanged(false);
          widget.onUploadError?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload stopped')),
          );
          return;
        }

        await DatasetDatabase.instance.insertMediaItem(
          widget.datasetId,
          f.path,
          'png',
          ownerId: currentUser.id!,
          width: frameWidth,
          height: frameHeight,
          source: 'video_frames',
        );

        inserted++;
      }

      // Update project icon using the first frame if project still has default icon
      if (widget.project.icon.contains('default_project_image') || widget.project.icon.contains('folder')) {
        final firstFramePath = frameFiles.first.path;
        final thumb = await generateThumbnailFromImage(File(firstFramePath), widget.project.id.toString());
        if (thumb != null) {
          await ProjectDatabase.instance.updateProjectIcon(widget.project.id!, thumb.path);
        }
      }

      await ProjectDatabase.instance.updateProjectLastUpdated(widget.project.id!);
      widget.onUploadingChanged(false);
      widget.onUploadSuccess();

      // Show summary dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.orangeAccent, width: 1),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: (MediaQuery.of(ctx).size.width > 1200) ? 34 : 26,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Import complete',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.orangeAccent),
                  const SizedBox(height: 6),
                  Text(
                    'Extracted ' + totalExtracted.toString() + ' frame' + (totalExtracted == 1 ? '' : 's') + ' and added to dataset.' + (usedFfmpeg ? ' (via FFmpeg)' : ' (via video_thumbnail)'),
                    style: const TextStyle(color: Colors.white70, fontFamily: 'CascadiaCode'),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Close', style: TextStyle(color: Colors.white70, fontFamily: 'CascadiaCode')),
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            );
          },
        );
      }
    } catch (e, st) {
      print('_uploadVideoAsFrames error: ' + e.toString());
      print(st.toString());
      widget.onUploadingChanged(false);
      widget.onUploadError?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video to frames failed: ' + e.toString())),
      );
    }
  }

  Future<String?> _resolveFfmpegPath({
    required void Function(String) log,
  }) async {
    // Try persisted user setting first
    try {
      final saved = UserSession.instance.getUser().ffmpegPath;
      if (saved != null && saved.isNotEmpty) {
        final ver = await Process.run(saved, ['-version']);
        if (ver.exitCode == 0) {
          _ffmpegPathCache = saved;
          log('Using ffmpeg from settings: ' + saved);
          return saved;
        } else {
          log('ffmpeg from settings invalid (exit ${ver.exitCode}).');
        }
      }
    } catch (e) {
      log('Failed to validate ffmpeg from settings: ' + e.toString());
    }

    // If cached and valid, use it
    if (_ffmpegPathCache != null) {
      final p = _ffmpegPathCache!;
      try {
        final ver = await Process.run(p, ['-version']);
        if (ver.exitCode == 0) {
          log('Using cached ffmpeg: ' + p);
          return p;
        } else {
          log('Cached ffmpeg path invalid (exit ${ver.exitCode}).');
        }
      } catch (e) {
        log('Cached ffmpeg path failed: ' + e.toString());
      }
    }

    // Try PATH
    try {
      final ver = await Process.run('ffmpeg', ['-version']);
      if (ver.exitCode == 0) {
        log('ffmpeg found on PATH.');
        return 'ffmpeg';
      } else {
        log('ffmpeg on PATH returned exit: ' + ver.exitCode.toString());
      }
    } catch (e) {
      log('ffmpeg not found on PATH: ' + e.toString());
    }

    // Prompt user to select ffmpeg.exe (Windows)
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: Platform.isWindows ? ['exe'] : null,
        dialogTitle: 'Select ffmpeg executable',
      );
      if (result != null && result.files.isNotEmpty) {
        final picked = result.files.first.path!;
        final file = File(picked);
        if (await file.exists()) {
          final ver = await Process.run(picked, ['-version']);
          if (ver.exitCode == 0) {
            _ffmpegPathCache = picked;
            try {
              // Persist for future sessions on desktop platforms
              if (!Platform.isAndroid && !Platform.isIOS) {
                await UserSession.instance.setFfmpegPath(picked);
              }
            } catch (_) {}
            log('User-selected ffmpeg validated: ' + picked);
            return picked;
          } else {
            log('Selected ffmpeg returned exit: ' + ver.exitCode.toString());
          }
        } else {
          log('Selected ffmpeg file does not exist: ' + picked);
        }
      } else {
        log('User cancelled ffmpeg selection.');
      }
    } catch (e) {
      log('Error during ffmpeg selection: ' + e.toString());
    }

    return null;
  }

  Future<bool> _tryExtractFramesWithFfmpeg({
    required String ffmpegPath,
    required String videoPath,
    required String framesDir,
    required String baseName,
    required double fps,
    required void Function(String) log,
  }) async {
    try {
      final String outPattern = path.join(framesDir, baseName + '_frame_%05d.png');
      log('Running ffmpeg to extract frames at ' + fps.toString() + ' fps. Using: ' + ffmpegPath);
      final result = await Process.run(
        ffmpegPath,
        [
          '-y',
          '-hide_banner',
          '-loglevel', 'error',
          '-i', videoPath,
          '-vf', 'fps=' + fps.toString(),
          outPattern,
        ],
        runInShell: true,
      );
      log('ffmpeg exitCode: ' + result.exitCode.toString());
      if ((result.stdout as Object?) != null) {
        final s = result.stdout.toString();
        if (s.isNotEmpty) log('ffmpeg stdout: ' + s);
      }
      if ((result.stderr as Object?) != null) {
        final s = result.stderr.toString();
        if (s.isNotEmpty) log('ffmpeg stderr: ' + s);
      }

      final dir = Directory(framesDir);
      final produced = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.png'))
          .length;
      log('ffmpeg produced PNG files: ' + produced.toString());
      return produced > 0;
    } catch (e) {
      log('FFmpeg execution failed: ' + e.toString());
      return false;
    }
  }
  
  Future<void> _uploadVideoAsFramesMac(BuildContext context, void Function(String) log) async {
    try {
      // 1) Ask user to select a video
      final pick = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov'],
      );
      if (pick == null || pick.files.isEmpty) {
        log('User cancelled video selection.');
        return;
      }
      final videoPath = pick.files.first.path!;
      final baseName = path.basenameWithoutExtension(videoPath);

      // 2) Prepare frames base directory inside Dataset import folder, then create unique run dir
      final importRoot = await UserSession.instance.getCurrentUserDatasetImportFolder();
      final framesBaseDir = Directory(path.join(
        importRoot,
        'project_' + ((widget.project.id ?? 0).toString()),
        'dataset_' + widget.datasetId,
        baseName + '_frames',
      ));
      if (!framesBaseDir.existsSync()) {
        framesBaseDir.createSync(recursive: true);
      }
      final String runStamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final runDir = Directory(path.join(framesBaseDir.path, 'run_' + runStamp));
      if (!runDir.existsSync()) {
        runDir.createSync(recursive: true);
      }

      // 3) Choose fps (reuse last selected from dialog, default 2.0)
      final double fps = FfmpegCheckDialog.lastSelectedFps;

      // 4) Extract frames using ffmpeg-kit on macOS
      widget.onUploadingChanged(true);
      final ok = await VideoFrameExtractor().extractFramesWithFfmpegKit(
        videoPath: videoPath,
        framesDir: runDir.path,
        baseName: baseName,
        fps: fps,
        log: log,
      );

      // 5) Collect generated frames
      final frameFiles = runDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.png'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

      if (!ok || frameFiles.isEmpty) {
        widget.onUploadingChanged(false);
        if (mounted) {
          await showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.orangeAccent, width: 1),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: (MediaQuery.of(ctx).size.width > 1200) ? 34 : 26,
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Import not completed',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontFamily: 'CascadiaCode',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'Could not extract frames from the selected video (ffmpeg-kit).',
                  style: TextStyle(color: Colors.white70, fontFamily: 'CascadiaCode'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK', style: TextStyle(color: Colors.orangeAccent, fontFamily: 'CascadiaCode')),
                  )
                ],
              );
            },
          );
        }
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

      // 6) Insert into DB with progress
      final currentUser = UserSession.instance.getUser();
      if (currentUser.id == null) {
        widget.onUploadingChanged(false);
        widget.onUploadError?.call();
        return;
      }

      int inserted = 0;
      for (final f in frameFiles) {
        if (widget.cancelUpload) {
          widget.onUploadingChanged(false);
          widget.onUploadError?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload stopped')),
          );
          return;
        }

        await DatasetDatabase.instance.insertMediaItem(
          widget.datasetId,
          f.path,
          'png',
          ownerId: currentUser.id!,
          width: frameWidth,
          height: frameHeight,
          source: 'video_frames',
        );
        inserted++;
      }

      // 7) Update project icon if default
      if (widget.project.icon.contains('default_project_image') || widget.project.icon.contains('folder')) {
        final firstFramePath = frameFiles.first.path;
        final thumb = await generateThumbnailFromImage(File(firstFramePath), widget.project.id.toString());
        if (thumb != null) {
          await ProjectDatabase.instance.updateProjectIcon(widget.project.id!, thumb.path);
        }
      }

      await ProjectDatabase.instance.updateProjectLastUpdated(widget.project.id!);
      widget.onUploadingChanged(false);
      widget.onUploadSuccess();

      // 8) Show summary dialog
      if (mounted) {
        await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.orangeAccent, width: 1),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: (MediaQuery.of(ctx).size.width > 1200) ? 34 : 26,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Import complete',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Colors.orangeAccent),
                  const SizedBox(height: 6),
                  Text(
                    'Extracted ' + inserted.toString() + ' frame' + (inserted == 1 ? '' : 's') + ' and added to dataset. (via FFmpeg‑Kit)',
                    style: const TextStyle(color: Colors.white70, fontFamily: 'CascadiaCode'),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.orangeAccent, width: 1),
                        ),
                      ),
                      child: const Text('Close', style: TextStyle(color: Colors.orangeAccent, fontFamily: 'CascadiaCode')),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      log('macOS video import failed: ' + e.toString());
      widget.onUploadingChanged(false);
      widget.onUploadError?.call();
    }
  }

  Future<void> _openCamera(BuildContext context) async {
    try {
      // Check if running on Linux
      if (Platform.isLinux) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Camera functionality is not supported on Linux"),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      
      // Note: Windows platform is handled in camera_capture_widget.dart
      // by using image_picker instead of direct camera access
      
      widget.onUploadingChanged(true);
      
      await CameraCaptureDialog.show(
        context,
        onMediaCaptured: (File file, String fileType) async {
          final filename = path.basename(file.path);
          final ext = fileType.toLowerCase();
          
          final currentUser = UserSession.instance.getUser();
          if (currentUser.id == null) {
            widget.onUploadError?.call();
            return;
          }
          
          int? width;
          int? height;
          double? duration;
          double? fps;
          final isVideo = ext == 'mp4';
          
          if (isVideo) {
            final videoMeta = await getVideoMetadata(file.path);
            width = videoMeta['width'];
            height = videoMeta['height'];
            duration = videoMeta['duration'];
            fps = videoMeta['fps'];
          } else {
            final imageMeta = await getImageMetadata(file.path);
            width = imageMeta['width'];
            height = imageMeta['height'];
          }
          
          await DatasetDatabase.instance.insertMediaItem(
            widget.datasetId,
            file.path,
            ext,
            ownerId: currentUser.id!,
            width: width,
            height: height,
            duration: duration,
            fps: fps,
            source: 'camera',
          );
          
          widget.onFileProgress?.call(filename, 1, 1);
          
          // Update project icon if needed
          if (widget.project.icon.contains('default_project_image') ||
              widget.project.icon.contains('folder')) {
            if (!isVideo) {
              final thumbnailFile = await generateThumbnailFromImage(
                  file, widget.project.id.toString());
              if (thumbnailFile != null) {
                await ProjectDatabase.instance
                    .updateProjectIcon(widget.project.id!, thumbnailFile.path);
              }
            }
          }
          
          await ProjectDatabase.instance.updateProjectLastUpdated(widget.project.id!);
          widget.onUploadingChanged(false);
          widget.onUploadSuccess();
        },
      );
      
      // If we get here without capturing media, reset the uploading state
      if (widget.isUploading) {
        widget.onUploadingChanged(false);
      }
    } catch (e) {
      print("_openCamera: Camera error: $e");
      widget.onUploadingChanged(false);
      widget.onUploadError?.call();
      
      // Show a user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Camera Error: ${e.toString().split('\n')[0]}"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getImageMetadata(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final decodedImage = await decodeImageFromList(bytes);
    return {
      'width': decodedImage.width,
      'height': decodedImage.height,
    };
  }

  Future<Map<String, dynamic>> getVideoMetadata(String path) async {
    // print('getVideoMetadata (stub with zeros) called for: $path');
    return {
      'width': 0,
      'height': 0,
      'duration': 0.0,
      'fps': 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final smallScreen = (screenWidth < 700) || (screenHeight < 750);

    final bool showDeleteButton = widget.allSelected || ((widget.selectedCount < widget.itemsPerPage) && (widget.allSelected == false));

    return Container(
      height: screenWidth>1300 ? 120 : smallScreen ? 45 : 80,
      width: double.infinity,
        child: Row(
        children: [
          if (widget.totalCount > 0) ...[
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: IconButton(
                icon: Icon(
                  widget.allSelected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                  color: Colors.white70,
                  size: 24,
                ),
                onPressed: widget.onToggleSelectAll,
              ),
            ),
            SizedBox(width: smallScreen ? 10 : 20),
            Text(
              screenWidth > 1300 ? "${widget.totalCount} files" : "${widget.totalCount}",
              style: TextStyle(
                color: Colors.white70,
                fontSize: smallScreen ? 18 : 22,
                fontFamily: 'CascadiaCode',
              ),
            ),
          ],

          if (showDeleteButton && widget.selectedCount > 0) ...[
            Text(
              screenWidth > 1300 ? " / ${widget.selectedCount} selected " : " / ${widget.selectedCount}",
              style: TextStyle(
                color: Colors.white70,
                fontSize: smallScreen ? 18 : 22,
                fontFamily: 'CascadiaCode',
              ),
            ),
            SizedBox(width: smallScreen ? 10 : 20),
            MouseRegion(
              onEnter: (_) => setState(() => _hoveringDelete = true),
              onExit: (_) => setState(() => _hoveringDelete = false),
              cursor: SystemMouseCursors.click,
              child: AnimatedScale(
                scale: _hoveringDelete ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: _hoveringDelete
                        ? const Color(0x26FF0000)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: _hoveringDelete ? Colors.redAccent : Colors.white70,
                    ),
                    tooltip: l10n.buttonDelete,
                    onPressed: widget.onDeleteSelected,
                  ),
                ),
              ),
            ),
          ],

          const Spacer(),

          if (screenWidth > 1024)...[
            const SizedBox(width: 20),
            DropdownButton<int>(
              value: _currentItemsPerPage,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              iconEnabledColor: Colors.white,
              underline: Container(height: 0),
              items: [8, 16, 24, 36, 48].map((value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(
                    '$value per page',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'CascadiaCode',
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null && value != _currentItemsPerPage) {
                  setState(() {
                    _currentItemsPerPage = value;
                  });
                  widget.onItemsPerPageChanged?.call(value);
                }
              },
            ),
          ],

          SizedBox(width: smallScreen ? 10 : 20),
          _buildButton(
            context,
            buttonName: l10n.uploadMedia,
            buttonIcon: Icons.add_to_photos,
            borderColor: Colors.red,
            screenWidth: screenWidth,
            smallScreen: smallScreen,
            onPressed: () async {
              await _uploadMedia(context);
            },
          ),
          
          SizedBox(width: smallScreen ? 10 : 20),
          _buildButton(
            context,
            buttonName: 'Upload video',
            buttonIcon: Icons.movie_creation_outlined,
            borderColor: Colors.orange,
            screenWidth: screenWidth,
            smallScreen: smallScreen,
            onPressed: () async {
              await _uploadVideoAsFrames(context);
            },
            tooltip: 'Extract frames to images',
          ),
          
          SizedBox(width: smallScreen ? 10 : 20),
          _buildButton(
            context,
            buttonName: 'Camera',
            buttonIcon: Icons.camera_alt,
            borderColor: Colors.blue,
            screenWidth: screenWidth,
            smallScreen: smallScreen,
            onPressed: Platform.isLinux ? null : () async {
              await _openCamera(context);
            },
            tooltip: Platform.isLinux ? 'Camera not supported on Linux' : null,
          ),
          SizedBox(width: smallScreen ? 10 : 5),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String buttonName,
    required IconData buttonIcon,
    required Color borderColor,
    required double screenWidth,
    required bool smallScreen,
    VoidCallback? onPressed,
    String? tooltip,
  }) {
    final defaultOnPressed = () async {
      await _uploadMedia(context);
    };
    
    final buttonOnPressed = widget.isUploading
        ? null
        : (onPressed ?? defaultOnPressed);
    
    if (screenWidth < 1024) {
      return Tooltip(
        message: tooltip ?? buttonName,
        child: ElevatedButton(
          onPressed: buttonOnPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(14),
            backgroundColor: Colors.transparent,
            side: BorderSide(
              color: buttonOnPressed == null ? Colors.grey : borderColor, 
              width: 1
            ),
          ),
          child: Icon(
            buttonIcon,
            color: buttonOnPressed == null ? Colors.grey : borderColor,
            size: smallScreen ? 24 : 30),
        ),
      );

    } else {
      return Tooltip(
        message: tooltip ?? buttonName,
        child: ElevatedButton(
          onPressed: buttonOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(
                color: buttonOnPressed == null ? Colors.grey : borderColor, 
                width: 2
              ),
            ),
          ),
          child: Text(
            buttonName,
            style: TextStyle(
              color: buttonOnPressed == null ? Colors.grey : Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ),
      );
    }
  }
}
