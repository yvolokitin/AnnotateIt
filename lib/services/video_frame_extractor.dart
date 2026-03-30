import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';

import '../session/user_session.dart';
import '../utils/platform_utils.dart';

/// A small, non-UI service encapsulating reusable FFmpeg-related video frame
/// extraction utilities. Widgets should depend on this service rather than
/// duplicating logic.
class VideoFrameExtractor {
  // Session-scoped cache for a user-selected ffmpeg executable path.
  static String? _ffmpegPathCache;

  /// Try to resolve an ffmpeg executable path without any UI prompts.
  ///
  /// Resolution order:
  /// 1) User setting persisted in UserSession
  /// 2) In-memory cache for this session
  /// 3) ffmpeg available on PATH
  ///
  /// Returns null if not found/validated.
  Future<bool> _isLikelyExecutableMachO(String p) async {
    try {
      final f = File(p);
      if (!await f.exists()) return false;
      final raf = await f.open();
      final header = await raf.read(4);
      await raf.close();
      if (header.length < 4) return false;
      final b0 = header[0], b1 = header[1], b2 = header[2], b3 = header[3];
      final isMachO =
          (b0 == 0xCE && b1 == 0xFA && b2 == 0xED && b3 == 0xFE) ||
          (b0 == 0xCF && b1 == 0xFA && b2 == 0xED && b3 == 0xFE) ||
          (b0 == 0xFE && b1 == 0xED && b2 == 0xFA && b3 == 0xCE) ||
          (b0 == 0xFE && b1 == 0xED && b2 == 0xFA && b3 == 0xCF) ||
          (b0 == 0xCA && b1 == 0xFE && b2 == 0xBA && (b3 == 0xBE || b3 == 0xBF));
      return isMachO;
    } catch (_) {
      return false;
    }
  }

  Future<String?> resolveFfmpegPath({void Function(String)? log}) async {
    void _log(String m) {
      if (log != null) log(m);
    }

    // Platform-specific quick checks (avoid executing binaries on macOS where not necessary)
    if (PlatformUtils.isMacOS) {
      // 1) User setting
      try {
        final saved = UserSession.instance.getUser().ffmpegPath;
        if (saved != null && saved.isNotEmpty && await _isLikelyExecutableMachO(saved)) {
          _ffmpegPathCache = saved;
          _log('Using ffmpeg from settings (macOS): ' + saved);
          return saved;
        }
      } catch (e) {
        _log('Failed to check ffmpeg from settings (macOS): ' + e.toString());
      }
      // 2) Common Homebrew/MacPorts locations
      for (final c in const ['/opt/homebrew/bin/ffmpeg', '/usr/local/bin/ffmpeg', '/opt/local/bin/ffmpeg']) {
        if (await _isLikelyExecutableMachO(c)) {
          _log('Detected ffmpeg at: ' + c);
          return c;
        }
      }
      // 3) PATH as a last resort
      try {
        final ver = await Process.run('ffmpeg', ['-version']);
        if (ver.exitCode == 0) {
          _log('ffmpeg found on PATH (macOS).');
          return 'ffmpeg';
        }
      } catch (e) {
        _log('ffmpeg not found on PATH (macOS): ' + e.toString());
      }
      return null;
    }

    // Non-macOS: existing logic
    // 1) Check persisted user setting
    try {
      final saved = UserSession.instance.getUser().ffmpegPath;
      if (saved != null && saved.isNotEmpty) {
        final ver = await Process.run(saved, ['-version']);
        if (ver.exitCode == 0) {
          _ffmpegPathCache = saved;
          _log('Using ffmpeg from settings: ' + saved);
          return saved;
        } else {
          _log('ffmpeg from settings invalid (exit ${ver.exitCode}).');
        }
      }
    } catch (e) {
      _log('Failed to validate ffmpeg from settings: ' + e.toString());
    }

    // 2) Check in-memory cache
    if (_ffmpegPathCache != null) {
      final p = _ffmpegPathCache!;
      try {
        final ver = await Process.run(p, ['-version']);
        if (ver.exitCode == 0) {
          _log('Using cached ffmpeg: ' + p);
          return p;
        } else {
          _log('Cached ffmpeg path invalid (exit ${ver.exitCode}).');
        }
      } catch (e) {
        _log('Cached ffmpeg path failed: ' + e.toString());
      }
    }

    // 3) Try PATH
    try {
      final ver = await Process.run('ffmpeg', ['-version']);
      if (ver.exitCode == 0) {
        _log('ffmpeg found on PATH.');
        return 'ffmpeg';
      } else {
        _log('ffmpeg on PATH returned exit: ' + ver.exitCode.toString());
      }
    } catch (e) {
      _log('ffmpeg not found on PATH: ' + e.toString());
    }

    return null;
  }

  /// Run ffmpeg to extract frames as PNG files into [framesDir]. The output
  /// file pattern is `<baseName>_frame_%05d.png`.
  Future<bool> extractFramesWithFfmpeg({
    required String ffmpegPath,
    required String videoPath,
    required String framesDir,
    required String baseName,
    required double fps,
    void Function(String)? log,
  }) async {
    void _log(String m) {
      if (log != null) log(m);
    }
    try {
      final String outPattern = path.join(framesDir, baseName + '_frame_%05d.png');
      _log('Running ffmpeg to extract frames at ' + fps.toString() + ' fps. Using: ' + ffmpegPath);
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
      _log('ffmpeg exitCode: ' + result.exitCode.toString());
      if ((result.stdout as Object?) != null) {
        final s = result.stdout.toString();
        if (s.isNotEmpty) _log('ffmpeg stdout: ' + s);
      }
      if ((result.stderr as Object?) != null) {
        final s = result.stderr.toString();
        if (s.isNotEmpty) _log('ffmpeg stderr: ' + s);
      }

      final dir = Directory(framesDir);
      final produced = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.png'))
          .length;
      _log('ffmpeg produced PNG files: ' + produced.toString());
      return produced > 0;
    } catch (e) {
      _log('FFmpeg execution failed: ' + e.toString());
      return false;
    }
  }

  /// Delete all .png files in [framesDir].
  Future<void> cleanFrames(String framesDir, {void Function(String)? log}) async {
    void _log(String m) {
      if (log != null) log(m);
    }
    try {
      final dir = Directory(framesDir);
      if (!dir.existsSync()) return;
      final stale = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.png'))
          .toList();
      for (final f in stale) {
        try {
          await f.delete();
        } catch (e) {
          _log('Failed to delete ' + f.path + ': ' + e.toString());
        }
      }
    } catch (e) {
      _log('Failed to clean frames in ' + framesDir + ': ' + e.toString());
    }
  }
}
