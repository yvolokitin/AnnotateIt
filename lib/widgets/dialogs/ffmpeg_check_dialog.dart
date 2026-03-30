import 'dart:io';

import 'package:file_picker/file_picker.dart';
import '../../utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../session/user_session.dart';
import '../../utils/theme.dart';

/// A reusable dialog to check/select FFmpeg executable on Windows.
/// Returns a resolved ffmpeg path (e.g., "ffmpeg" from PATH or an absolute path),
/// or null if the user cancels.
class FfmpegCheckDialog {
  static String? _ffmpegPathCache;
  static double lastSelectedFps = 2.0;

  static Future<String?> show(
    BuildContext context, {
    String? existingVideoPath,
    double? initialFps,
    Future<int> Function(String ffmpegPath, double fps)? onContinueExtract,
  }) async {
    if (!PlatformUtils.isWindows) {
      // On non-Windows, this dialog is not required. Just return a non-null
      // value to indicate "proceed" if someone calls it by mistake.
      return 'ffmpeg';
    }

    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool initialized = false;
        bool checking = false;
        bool resolved = false;
        String? ffmpegPath;

        // Persistent state for this dialog instance
        double fpsValue = (initialFps ?? lastSelectedFps).clamp(0.5, 30.0);
        bool extracting = false;
        String? errorMsg;

        Future<void> runQuickCheck(StateSetter setState2) async {
          setState2(() => checking = true);
          String? candidate;
          // 1) user setting
          try {
            final saved = UserSession.instance.getUser().ffmpegPath;
            if (saved != null && saved.isNotEmpty) {
              final ver = await Process.run(saved, ['-version']);
              if (ver.exitCode == 0) candidate = saved;
            }
          } catch (_) {}
          // 2) cached
          if (candidate == null && _ffmpegPathCache != null) {
            try {
              final ver = await Process.run(_ffmpegPathCache!, ['-version']);
              if (ver.exitCode == 0) candidate = _ffmpegPathCache!;
            } catch (_) {}
          }
          // 3) PATH
          if (candidate == null) {
            try {
              final ver = await Process.run('ffmpeg', ['-version']);
              if (ver.exitCode == 0) candidate = 'ffmpeg';
            } catch (_) {}
          }
          setState2(() {
            ffmpegPath = candidate;
            resolved = ffmpegPath != null;
            checking = false;
          });
        }

        Future<void> selectFfmpeg(StateSetter setState2) async {
          try {
            final result = await FilePicker.platform.pickFiles(
              allowMultiple: false,
              type: FileType.custom,
              allowedExtensions: PlatformUtils.isWindows ? ['exe'] : null,
              dialogTitle: 'Select ffmpeg executable',
            );
            if (result != null && result.files.isNotEmpty) {
              final picked = result.files.first.path!;
              final f = File(picked);
              if (await f.exists()) {
                final ver = await Process.run(picked, ['-version']);
                if (ver.exitCode == 0) {
                  _ffmpegPathCache = picked;
                  try {
                    if (!PlatformUtils.isAndroid && !PlatformUtils.isIOS) {
                      await UserSession.instance.setFfmpegPath(picked);
                    }
                  } catch (_) {}
                  setState2(() {
                    ffmpegPath = picked;
                    resolved = true;
                  });
                }
              }
            }
          } catch (_) {}
        }

        return StatefulBuilder(
          builder: (context2, setState2) {
            if (!initialized) {
              initialized = true;
              Future.microtask(() => runQuickCheck(setState2));
            }

            Future<void> onContinuePressed() async {
              if (!resolved || ffmpegPath == null) return;
              lastSelectedFps = fpsValue;
              if (onContinueExtract == null) {
                Navigator.of(ctx).pop(ffmpegPath);
                return;
              }
              setState2(() {
                extracting = true;
                errorMsg = null;
              });
              try {
                await onContinueExtract!(ffmpegPath!, fpsValue);
                if (Navigator.of(ctx).mounted) {
                  Navigator.of(ctx).pop(ffmpegPath);
                }
              } catch (e) {
                setState2(() {
                  errorMsg = e.toString();
                  extracting = false;
                });
              }
            }

            return AlertDialog(
              backgroundColor: AppColors.darkSurface,
              insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context2).size.width * 0.05, vertical: MediaQuery.of(context2).size.height * 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.orangeAccent, width: 1),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.movie_creation_outlined,
                    size: (MediaQuery.of(context2).size.width > 1200) ? 34 : 26,
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Video frames extraction',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'Close',
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: extracting ? null : () => Navigator.of(ctx).pop(null),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context2).size.width * 0.9,
                height: MediaQuery.of(context2).size.height * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(color: Colors.orangeAccent),
                      Row(children: [
                        Icon(resolved ? Icons.check_circle : Icons.error_outline,
                            color: resolved ? Colors.greenAccent : Colors.orangeAccent),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('Step 1: Check FFmpeg',
                              style: TextStyle(color: Colors.white,  fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      const Text(
                        'FFmpeg is a free, open‑source suite for processing video and audio. AnnotateIt uses FFmpeg on Windows to extract individual frames from your video for annotation.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.orangeAccent),
                            onPressed: () async {
                              final uri = Uri.parse('https://ffmpeg.org/download.html');
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('FFmpeg website'),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(foregroundColor: Colors.orangeAccent),
                            onPressed: () async {
                              final uri = Uri.parse('https://www.gyan.dev/ffmpeg/builds/');
                              await launchUrl(uri, mode: LaunchMode.externalApplication);
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Windows builds'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tip: After installing, either add ffmpeg.exe to your PATH or click "Select FFmpeg" to choose the executable.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      if (checking) const LinearProgressIndicator(),
                      if (!checking)
                        Text(
                          resolved
                              ? 'Using: ' + (ffmpegPath ?? '')
                              : 'FFmpeg not available. Select ffmpeg.exe first.',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      const SizedBox(height: 12),
                      Row(children: [
                        TextButton(
                          onPressed: checking || extracting ? null : () => selectFfmpeg(setState2),
                          style: TextButton.styleFrom(foregroundColor: Colors.orangeAccent),
                          child: const Text('Select FFmpeg'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: checking || extracting ? null : () => runQuickCheck(setState2),
                          style: TextButton.styleFrom(foregroundColor: Colors.orangeAccent),
                          child: const Text('Re-check'),
                        ),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: const [
                        Icon(Icons.speed, color: Colors.white70),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Frames per second',
                              style: TextStyle(color: Colors.white,  fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: fpsValue,
                              onChanged: extracting
                                  ? null
                                  : (v) {
                                      setState2(() {
                                        fpsValue = double.parse(v.toStringAsFixed(1));
                                      });
                                    },
                              min: 0.5,
                              max: 30.0,
                              divisions: 59,
                              label: fpsValue.toStringAsFixed(1) + ' fps',
                              activeColor: Colors.orangeAccent,
                              inactiveColor: Colors.white24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(fpsValue.toStringAsFixed(1) + ' fps',
                              style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                      const Divider(height: 20, color: Colors.orangeAccent),
                      Row(children: const [
                        Icon(Icons.video_file_outlined, color: Colors.white70),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Step 2: Select video file',
                              style: TextStyle(color: Colors.white,  fontWeight: FontWeight.bold)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      if (existingVideoPath != null)
                        Text(
                          'Video already in gallery: ' + existingVideoPath.split('\\').last + '. Press Continue to extract frames.',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        )
                      else
                        const Text(
                          'After FFmpeg is resolved, click Continue to choose a video to import.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: extracting
                            ? Column(
                                key: const ValueKey('extracting'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.8, end: 1.2),
                                        duration: const Duration(milliseconds: 700),
                                        curve: Curves.easeInOut,
                                        builder: (c, v, child) => Transform.scale(
                                          scale: v,
                                          child: const Icon(Icons.bolt, color: Colors.orangeAccent),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'Extracting frames... this may take a while.',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                                    backgroundColor: Colors.white24,
                                  ),
                                  if (errorMsg != null) ...[
                                    const SizedBox(height: 8),
                                    Text(errorMsg!,
                                        style: const TextStyle(color: AppColors.accent,  fontSize: 12)),
                                  ],
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: extracting ? null : () => Navigator.of(ctx).pop(null),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkSurface,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                    ),
                    const Spacer(),
                    if (resolved)
                      ElevatedButton(
                        onPressed: extracting ? null : onContinuePressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.orangeAccent, width: 2),
                          ),
                        ),
                        child: const Text('Continue',
                            style: TextStyle(color: Colors.white,  fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
