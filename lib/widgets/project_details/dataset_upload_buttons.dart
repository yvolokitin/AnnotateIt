import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../utils/platform_utils.dart';
import 'package:flutter/foundation.dart';
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
import '../../services/media_metadata_service.dart';
import '../../services/photo_picker_service.dart';

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
  bool _hoveringDelete = false;
  late int _currentItemsPerPage;

  @override
  void initState() {
    super.initState();
    _currentItemsPerPage = widget.itemsPerPage;
  }

  Future<void> _uploadMedia(BuildContext context) async {
    try {
      if (kIsWeb) {
        await _uploadMediaWeb(context);
        return;
      }

      // Pick files/photos depending on platform
      final bool isCupertino = PlatformUtils.isIOS || PlatformUtils.isMacOS;
      final List<String> selectedPaths = [];
      final List<String> selectedNames = [];

      if (isCupertino) {
        // iOS/macOS: use system Photos picker for images
        final images = await PhotoPickerService.pickMultipleImages();
        if (images.isEmpty) {
          final pickerError = PhotoPickerService.takeLastError();
          if (pickerError != null && mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(pickerError)));
          }
          widget.onUploadingChanged(false);
          return;
        }
        for (final x in images) {
          if (x.path.isNotEmpty) {
            selectedPaths.add(x.path);
            selectedNames.add(path.basename(x.path));
          }
        }
      } else {
        // Other platforms: use file picker for images/videos
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov'],
        );
        if (result == null || result.files.isEmpty) {
          widget.onUploadingChanged(false);
          return;
        }
        for (final f in result.files) {
          if (f.path != null) {
            selectedPaths.add(f.path!);
            selectedNames.add(f.name);
          }
        }
      }

      widget.onUploadingChanged(true);
      final total = selectedPaths.length;

      // Prepare destination dataset dir for iOS/macOS copies EARLY and seed progress UI immediately
      Directory? datasetDir;
      List<String>? expectedNames;
      if (isCupertino) {
        final importRoot =
            await UserSession.instance.getCurrentUserDatasetImportFolder();
        datasetDir = Directory(
          path.join(
            importRoot,
            'project_${widget.project.id}',
            'dataset_${widget.datasetId}',
          ),
        );
        if (!datasetDir.existsSync()) {
          datasetDir.createSync(recursive: true);
        }

        // Pre-compute final filenames to show consistent names in the progress UI
        final usedNames = <String>{};
        expectedNames = List<String>.filled(total, '', growable: false);
        for (int i = 0; i < total; i++) {
          final origPath = selectedPaths[i];
          final origName = selectedNames[i];
          final ext =
              path.extension(origPath).replaceFirst('.', '').toLowerCase();
          String candidateName =
              origName.isEmpty
                  ? 'media_${DateTime.now().millisecondsSinceEpoch}_${i + 1}.${ext.isEmpty ? 'bin' : ext}'
                  : origName;
          String destPath = path.join(datasetDir.path, candidateName);

          // Ensure unique filename (avoid clashes before copy)
          if (File(destPath).existsSync() ||
              usedNames.contains(candidateName)) {
            final base = path.basenameWithoutExtension(candidateName);
            final extension = path.extension(candidateName);
            int k = 1;
            String newName;
            do {
              newName = '${base}_$k$extension';
              destPath = path.join(datasetDir.path, newName);
              k++;
            } while (File(destPath).existsSync() ||
                usedNames.contains(newName));
            candidateName = newName;
          }
          usedNames.add(candidateName);
          expectedNames[i] = candidateName;
        }

        // Seed the upload progress immediately so the dialog appears without delay
        for (int i = 0; i < total; i++) {
          widget.onFileProgress?.call(expectedNames[i], 0, total);
        }
      }

      // If default icon, set it from the first image (runs after dialog appears)
      if (selectedPaths.isNotEmpty &&
          (widget.project.icon.contains('default_project_image') ||
              widget.project.icon.contains('folder'))) {
        final thumbSrc = File(selectedPaths.first);
        final thumbnailFile = await generateThumbnailFromImage(
          thumbSrc,
          widget.project.id.toString(),
        );
        if (thumbnailFile != null) {
          await ProjectDatabase.instance.updateProjectIcon(
            widget.project.id!,
            thumbnailFile.path,
          );
        }
      }

      // datasetDir was prepared earlier for iOS/macOS to enable immediate progress UI

      for (int i = 0; i < total; i++) {
        if (widget.cancelUpload) {
          widget.onUploadingChanged(false);
          widget.onUploadError?.call();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Upload stopped")));
          return;
        }

        final originalPath = selectedPaths[i];
        final originalName = selectedNames[i];
        final ext =
            path.extension(originalPath).replaceFirst('.', '').toLowerCase();
        final isVideo = ['mp4', 'mov'].contains(ext);

        final currentUser = UserSession.instance.getUser();
        if (currentUser.id == null) {
          widget.onUploadError?.call();
          return;
        }

        // On iOS/macOS: copy the file into the app dataset folder
        String finalPath = originalPath;
        if (isCupertino && datasetDir != null) {
          String candidateName =
              (expectedNames != null && expectedNames.length == total)
                  ? expectedNames[i]
                  : (originalName.isEmpty
                      ? 'media_${DateTime.now().millisecondsSinceEpoch}.${ext.isEmpty ? 'bin' : ext}'
                      : originalName);
          String destPath = path.join(datasetDir.path, candidateName);

          // Ensure unique filename (safety in case files changed since pre-compute)
          if (File(destPath).existsSync()) {
            final base = path.basenameWithoutExtension(candidateName);
            final extension = path.extension(candidateName);
            int k = 1;
            while (File(destPath).existsSync()) {
              final newName = '${base}_$k$extension';
              destPath = path.join(datasetDir.path, newName);
              k++;
            }
          }

          await File(originalPath).copy(destPath);
          finalPath = destPath;
        }

        // Gather metadata
        int? width;
        int? height;
        double? duration;
        double? fps;
        if (isVideo) {
          final videoMeta = await MediaMetadataService.instance
              .getVideoMetadata(finalPath);
          width = videoMeta['width'];
          height = videoMeta['height'];
          duration = videoMeta['duration'];
          fps = videoMeta['fps'];
        } else {
          final imageMeta = await MediaMetadataService.instance
              .getImageMetadata(finalPath);
          width = imageMeta['width'];
          height = imageMeta['height'];
        }

        await DatasetDatabase.instance.insertMediaItem(
          widget.datasetId,
          finalPath,
          ext.isEmpty ? 'unknown' : ext,
          ownerId: currentUser.id!,
          width: width,
          height: height,
          duration: duration,
          fps: fps,
          source: isCupertino ? 'photos' : 'local',
        );

        widget.onFileProgress?.call(path.basename(finalPath), i + 1, total);
      }

      await ProjectDatabase.instance.updateProjectLastUpdated(
        widget.project.id!,
      );
      widget.onUploadingChanged(false);
      widget.onUploadSuccess();
    } catch (e) {
      if (kDebugMode) print("_uploadMedia: Upload error: $e");
      widget.onUploadingChanged(false);
      widget.onUploadError?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not import media from gallery. Please check Photos access and try again.',
            ),
          ),
        );
      }
    }
  }

  /// Web-specific upload: files have no path, only bytes.
  Future<void> _uploadMediaWeb(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) {
      widget.onUploadingChanged(false);
      return;
    }

    widget.onUploadingChanged(true);
    final total = result.files.length;

    final currentUser = UserSession.instance.getUser();
    if (currentUser.id == null) {
      widget.onUploadError?.call();
      return;
    }

    for (int i = 0; i < total; i++) {
      if (widget.cancelUpload) {
        widget.onUploadingChanged(false);
        widget.onUploadError?.call();
        return;
      }

      final f = result.files[i];
      final bytes = f.bytes;
      if (bytes == null || bytes.isEmpty) continue;

      final ext = f.extension?.toLowerCase() ?? path.extension(f.name).replaceFirst('.', '').toLowerCase();

      int? width;
      int? height;
      try {
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          width = decoded.width;
          height = decoded.height;
        }
      } catch (_) {}

      await DatasetDatabase.instance.insertMediaItem(
        widget.datasetId,
        'web://${f.name}',
        ext.isEmpty ? 'unknown' : ext,
        ownerId: currentUser.id!,
        width: width,
        height: height,
        source: 'web_upload',
        imageData: bytes,
      );

      widget.onFileProgress?.call(f.name, i + 1, total);
    }

    await ProjectDatabase.instance.updateProjectLastUpdated(widget.project.id!);
    widget.onUploadingChanged(false);
    widget.onUploadSuccess();
  }

  Future<void> _uploadVideoAsFrames(BuildContext context) async {
    // Collect debug logs to show in UI if needed
    final List<String> _logs = [];
    void logMsg(String msg) {
      final line =
          '[VIDEO_IMPORT] ' + DateTime.now().toIso8601String() + ' ' + msg;
      _logs.add(line);
      if (kDebugMode) print(line);
    }

    try {
      logMsg(
        'Platform: ' +
            PlatformUtils.operatingSystem +
            ' ' +
            PlatformUtils.operatingSystem,
      );

      // Windows-only: Use FfmpegCheckDialog to show progress and perform selection + extraction
      if (PlatformUtils.isWindows) {
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
            final importRoot =
                await UserSession.instance.getCurrentUserDatasetImportFolder();
            final framesBaseDir = Directory(
              path.join(
                importRoot,
                'project_' + ((widget.project.id ?? 0).toString()),
                'dataset_' + widget.datasetId,
                baseName! + '_frames',
              ),
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
            final produced =
                runDir
                    .listSync()
                    .whereType<File>()
                    .where((f) => f.path.toLowerCase().endsWith('.png'))
                    .length;
            totalExtracted = produced;
            return produced;
          },
        );

        if (ffmpegPath == null ||
            selectedVideoPath == null ||
            framesDirPath == null ||
            baseName == null) {
          logMsg('User cancelled FFmpeg dialog or no video selected.');
          return;
        }

        // Collect generated frames
        final framesDir = Directory(framesDirPath!);
        final frameFiles =
            framesDir
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Upload stopped')));
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
        if (widget.project.icon.contains('default_project_image') ||
            widget.project.icon.contains('folder')) {
          final firstFramePath = frameFiles.first.path;
          final thumb = await generateThumbnailFromImage(
            File(firstFramePath),
            widget.project.id.toString(),
          );
          if (thumb != null) {
            await ProjectDatabase.instance.updateProjectIcon(
              widget.project.id!,
              thumb.path,
            );
          }
        }

        await ProjectDatabase.instance.updateProjectLastUpdated(
          widget.project.id!,
        );
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
                      'Extracted ' +
                          totalExtracted.toString() +
                          ' frame' +
                          (totalExtracted == 1 ? '' : 's') +
                          ' and added to dataset. (via FFmpeg)',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'CascadiaCode',
                      ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'CascadiaCode',
                          ),
                        ),
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
      if (PlatformUtils.isAndroid || PlatformUtils.isIOS) {
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
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'CascadiaCode',
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Tap Continue to choose a video file to import and extract frames as images.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'CascadiaCode',
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'CascadiaCode',
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Colors.orangeAccent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'CascadiaCode',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

      late String videoPath;
      late String fileName;
      if (PlatformUtils.isIOS) {
        final xfile = await PhotoPickerService.pickSingleVideo();
        if (xfile == null) {
          final pickerError = PhotoPickerService.takeLastError();
          if (pickerError != null && mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(pickerError)));
          }
          logMsg('User cancelled Photos video picking.');
          return;
        }
        videoPath = xfile.path;
        fileName = path.basename(videoPath);
      } else {
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
        videoPath = picked.path!;
        fileName = picked.name;
      }
      logMsg('Selected file: ' + videoPath);

      widget.onUploadingChanged(true);

      // Inform user we started working on the selected file

      // Determine target frames count (fallback if metadata is unavailable)
      final meta = await MediaMetadataService.instance.getVideoMetadata(
        videoPath,
      );
      final double durationStub = (meta['duration'] ?? 0.0) as double;
      final double fpsStub = (meta['fps'] ?? 0.0) as double;
      int totalFrames;
      if (durationStub > 0 && fpsStub > 0) {
        totalFrames = (durationStub * fpsStub).round().clamp(1, 600);
      } else {
        totalFrames = 60; // fallback default
      }
      logMsg(
        'Stub metadata -> duration: ' +
            durationStub.toString() +
            ', fps: ' +
            fpsStub.toString() +
            ', fallback totalFrames: ' +
            totalFrames.toString(),
      );

      // Prepare output directory inside Dataset import folder
      final videoFile = File(videoPath);
      if (!await videoFile.exists()) {
        throw Exception('Selected video file not found');
      }
      final fileSize = await videoFile.length();
      logMsg('Video exists. Size: ' + fileSize.toString() + ' bytes.');

      final importRoot =
          await UserSession.instance.getCurrentUserDatasetImportFolder();
      final baseName = path.basenameWithoutExtension(videoFile.path);
      final framesBaseDir = Directory(
        path.join(
          importRoot,
          'project_' + ((widget.project.id ?? 0).toString()),
          'dataset_' + widget.datasetId,
          baseName + '_frames',
        ),
      );
      if (!framesBaseDir.existsSync()) {
        framesBaseDir.createSync(recursive: true);
        logMsg('Created frames base directory: ' + framesBaseDir.path);
      } else {
        logMsg('Using existing frames base directory: ' + framesBaseDir.path);
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
        logMsg('Created run directory: ' + runDir.path);
      }

      // Ensure run directory writable
      final testFile = File(
        path.join(
          runDir.path,
          '.write_test_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
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
        logMsg(
          'video_player initialize OK. Duration: ' +
              videoSeconds.toString() +
              ' s, aspectRatio: ' +
              controller.value.aspectRatio.toString(),
        );
        await controller.dispose();
      } catch (e) {
        controllerError = e.toString();
        logMsg('video_player initialize FAILED: ' + controllerError);
      }

      // Choose an extraction fps (configurable)
      final double extractFps =
          FfmpegCheckDialog.lastSelectedFps; // configurable fps
      int expectedFrames =
          (videoSeconds > 0 ? (videoSeconds * extractFps) : totalFrames)
              .round();
      if (expectedFrames <= 0)
        expectedFrames = totalFrames > 0 ? totalFrames : 60;
      expectedFrames = expectedFrames.clamp(1, 1200); // safety cap
      logMsg(
        'Extraction fps: ' +
            extractFps.toString() +
            ', expectedFrames: ' +
            expectedFrames.toString(),
      );

      // Prepare variables for extraction
      String? firstThumbError;
      final List<File> frameFiles = [];

      // On Windows, skip video_thumbnail (no plugin implementation) and rely on FFmpeg fallback below
      if (!PlatformUtils.isWindows) {
        try {
          final probe = await VideoThumbnail.thumbnailData(
            video: videoPath,
            timeMs: 0,
            imageFormat: ImageFormat.PNG,
            quality: 100,
          );
          logMsg(
            'video_thumbnail probe@0ms -> bytes: ' +
                (probe?.length ?? 0).toString(),
          );
        } catch (e) {
          firstThumbError = e.toString();
          logMsg('video_thumbnail probe FAILED: ' + firstThumbError);
        }

        // Generate frames using video_thumbnail at regular intervals
        final int intervalMs = (1000 / extractFps).round();
        for (int i = 0; i < expectedFrames; i++) {
          if (widget.cancelUpload) {
            logMsg(
              'User requested cancel during extraction loop at frame ' +
                  (i + 1).toString(),
            );
            widget.onUploadingChanged(false);
            widget.onUploadError?.call();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Upload stopped')));
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
                baseName +
                    '_frame_' +
                    (i + 1).toString().padLeft(5, '0') +
                    '.png',
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
      if (!PlatformUtils.isWindows) {
        logMsg(
          'video_thumbnail extracted frames: ' + totalExtracted.toString(),
        );
      }

      // Windows fallback with FFmpeg if no frames extracted
      bool usedFfmpeg = false;
      bool ffmpegResolved = false;
      String? ffmpegError;
      String? ffmpegPathUsed;
      if (totalExtracted == 0 && PlatformUtils.isWindows) {
        logMsg(
          'No frames via video_thumbnail and running on Windows. Trying FFmpeg extraction...',
        );

        // Use the already-created unique runDir; do not clean previous runs
        final ffmpegPath = await VideoFrameExtractor().resolveFfmpegPath(
          log: logMsg,
        );
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
            final all =
                runDir
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
          ffmpegError =
              'FFmpeg not available on PATH and user did not provide a valid ffmpeg.exe.';
        }
      }

      if (totalExtracted == 0) {
        // Gracefully handle platforms where extraction is not supported and show diagnostics
        widget.onUploadingChanged(false);
        final String diag = [
          'Platform: ' + PlatformUtils.operatingSystem,
          'video path: ' + videoPath,
          if (controllerError != null)
            'video_player error: ' + controllerError!,
          if (firstThumbError != null)
            'video_thumbnail error: ' + firstThumbError!,
          if (PlatformUtils.isWindows)
            'ffmpeg resolved: ' + (ffmpegResolved ? 'YES' : 'NO'),
          if (PlatformUtils.isWindows && ffmpegPathUsed != null)
            'ffmpeg path: ' + ffmpegPathUsed!,
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
                        'Could not extract frames from the selected video.\n\nDiagnostics:\n' +
                            diag,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontFamily: 'CascadiaCode',
                        ),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'CascadiaCode',
                          ),
                        ),
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
          logMsg(
            'First frame dimensions: ' +
                frameWidth.toString() +
                'x' +
                frameHeight.toString(),
          );
        }
      } catch (e) {
        logMsg('Failed to read first frame size: ' + e.toString());
      }

      // Insert extracted frames into DB with progress
      int inserted = 0;
      for (final f in frameFiles) {
        if (widget.cancelUpload) {
          logMsg(
            'User requested cancel during DB insert at item ' +
                (inserted + 1).toString(),
          );
          widget.onUploadingChanged(false);
          widget.onUploadError?.call();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Upload stopped')));
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
      if (widget.project.icon.contains('default_project_image') ||
          widget.project.icon.contains('folder')) {
        final firstFramePath = frameFiles.first.path;
        final thumb = await generateThumbnailFromImage(
          File(firstFramePath),
          widget.project.id.toString(),
        );
        if (thumb != null) {
          await ProjectDatabase.instance.updateProjectIcon(
            widget.project.id!,
            thumb.path,
          );
        }
      }

      await ProjectDatabase.instance.updateProjectLastUpdated(
        widget.project.id!,
      );
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
                    'Extracted ' +
                        totalExtracted.toString() +
                        ' frame' +
                        (totalExtracted == 1 ? '' : 's') +
                        ' and added to dataset.' +
                        (usedFfmpeg
                            ? ' (via FFmpeg)'
                            : ' (via video_thumbnail)'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'CascadiaCode',
                    ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'CascadiaCode',
                        ),
                      ),
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
      if (kDebugMode) print('_uploadVideoAsFrames error: ' + e.toString());
      if (kDebugMode) print(st.toString());
      widget.onUploadingChanged(false);
      widget.onUploadError?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video to frames failed: ' + e.toString())),
      );
    }
  }

  Future<void> _openCamera(BuildContext context) async {
    try {
      // Check if running on Linux
      if (PlatformUtils.isLinux) {
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
          // Ensure captured media is persisted inside the Dataset application folder
          // to avoid permission loss (especially on iOS/macOS) after app relaunch.
          String ext =
              (fileType.isNotEmpty
                      ? fileType
                      : path.extension(file.path).replaceFirst('.', ''))
                  .toLowerCase();
          if (ext.isEmpty) {
            ext = 'jpg';
          }

          final currentUser = UserSession.instance.getUser();
          if (currentUser.id == null) {
            widget.onUploadError?.call();
            return;
          }

          // Build destination directory: <ImportRoot>/project_<id>/dataset_<datasetId>
          final importRoot =
              await UserSession.instance.getCurrentUserDatasetImportFolder();
          final List<String> segments = [];
          segments.addAll(['project_' + ((widget.project.id ?? 0).toString())]);
          segments.addAll(['dataset_' + widget.datasetId]);
          final destDir = Directory(
            path.join(importRoot, path.joinAll(segments)),
          );
          if (!destDir.existsSync()) {
            destDir.createSync(recursive: true);
          }

          // Create a unique, stable filename and copy the file there
          final safeStamp = DateTime.now()
              .toIso8601String()
              .replaceAll(':', '-')
              .replaceAll('.', '-');
          final originalBase = path.basenameWithoutExtension(file.path);
          final destFilename =
              (originalBase.isNotEmpty
                  ? (safeStamp + '_' + originalBase)
                  : ('capture_' + safeStamp)) +
              '.' +
              ext;
          final destPath = path.join(destDir.path, destFilename);

          File savedFile;
          try {
            savedFile = await file.copy(destPath);
            // Best effort: remove the temp/original file if different
            if (!path.equals(file.path, destPath)) {
              try {
                await file.delete();
              } catch (_) {}
            }
          } catch (_) {
            // If copy fails for any reason, fall back to original file path
            savedFile = file;
          }

          // Gather metadata from the saved location
          int? width;
          int? height;
          double? duration;
          double? fps;
          final bool isVideo = (ext == 'mp4' || ext == 'mov');

          if (isVideo) {
            final videoMeta = await MediaMetadataService.instance
                .getVideoMetadata(savedFile.path);
            width = videoMeta['width'];
            height = videoMeta['height'];
            duration = videoMeta['duration'];
            fps = videoMeta['fps'];
          } else {
            final imageMeta = await MediaMetadataService.instance
                .getImageMetadata(savedFile.path);
            width = imageMeta['width'];
            height = imageMeta['height'];
          }

          await DatasetDatabase.instance.insertMediaItem(
            widget.datasetId,
            savedFile.path,
            ext,
            ownerId: currentUser.id!,
            width: width,
            height: height,
            duration: duration,
            fps: fps,
            source: 'camera',
          );

          widget.onFileProgress?.call(path.basename(savedFile.path), 1, 1);

          // Update project icon if needed
          if (widget.project.icon.contains('default_project_image') ||
              widget.project.icon.contains('folder')) {
            if (!isVideo) {
              final thumbnailFile = await generateThumbnailFromImage(
                savedFile,
                widget.project.id.toString(),
              );
              if (thumbnailFile != null) {
                await ProjectDatabase.instance.updateProjectIcon(
                  widget.project.id!,
                  thumbnailFile.path,
                );
              }
            }
          }

          await ProjectDatabase.instance.updateProjectLastUpdated(
            widget.project.id!,
          );
          widget.onUploadingChanged(false);
          widget.onUploadSuccess();
        },
      );

      // If we get here without capturing media, reset the uploading state
      if (widget.isUploading) {
        widget.onUploadingChanged(false);
      }
    } catch (e) {
      if (kDebugMode) print("_openCamera: Camera error: $e");
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final smallScreen = (screenWidth < 700) || (screenHeight < 750);

    final bool showDeleteButton =
        widget.allSelected ||
        ((widget.selectedCount < widget.itemsPerPage) &&
            (widget.allSelected == false));

    return Container(
      height:
          screenWidth > 1300
              ? 120
              : smallScreen
              ? 45
              : 80,
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
              screenWidth > 1300
                  ? "${widget.totalCount} files"
                  : "${widget.totalCount}",
              style: TextStyle(
                color: Colors.white70,
                fontSize: smallScreen ? 18 : 22,
                fontFamily: 'CascadiaCode',
              ),
            ),
          ],

          if (showDeleteButton && widget.selectedCount > 0) ...[
            Text(
              screenWidth > 1300
                  ? " / ${widget.selectedCount} selected "
                  : " / ${widget.selectedCount}",
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
                    color:
                        _hoveringDelete
                            ? const Color(0x26FF0000)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color:
                          _hoveringDelete ? Colors.redAccent : Colors.white70,
                    ),
                    tooltip: l10n.buttonDelete,
                    onPressed: widget.onDeleteSelected,
                  ),
                ),
              ),
            ),
          ],

          const Spacer(),

          if (screenWidth > 1024) ...[
            const SizedBox(width: 20),
            DropdownButton<int>(
              value: _currentItemsPerPage,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white, fontSize: 16),
              iconEnabledColor: Colors.white,
              underline: Container(height: 0),
              items:
                  [8, 16, 24, 36, 48].map((value) {
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
            buttonName: l10n.uploadVideo,
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
            buttonName: l10n.uploadCamera,
            buttonIcon: Icons.camera_alt,
            borderColor: Colors.blue,
            screenWidth: screenWidth,
            smallScreen: smallScreen,
            onPressed:
                PlatformUtils.isLinux
                    ? null
                    : () async {
                      await _openCamera(context);
                    },
            tooltip: PlatformUtils.isLinux ? 'Camera not supported on Linux' : null,
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

    final buttonOnPressed =
        widget.isUploading ? null : (onPressed ?? defaultOnPressed);

    if (screenWidth < 1024) {
      return Tooltip(
        message: tooltip ?? buttonName,
        child: SizedBox(
          width: smallScreen ? 36 : 40,
          height: smallScreen ? 36 : 40,
          child: ElevatedButton(
            onPressed: buttonOnPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: BorderSide(
                  color: buttonOnPressed == null ? Colors.grey : borderColor,
                  width: 1,
                ),
              ),
              fixedSize: Size.square(smallScreen ? 36 : 40),
            ),
            child: Icon(
              buttonIcon,
              color: buttonOnPressed == null ? Colors.grey : borderColor,
              size: smallScreen ? 24 : 26,
            ),
          ),
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
                width: 2,
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
