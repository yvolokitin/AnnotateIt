import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

import '../session/user_session.dart';
import '../utils/platform_utils.dart';
import 'video_metadata.dart';

/// Extracts video metadata via the ffprobe CLI (ships alongside ffmpeg).
///
/// Resolution order for the ffprobe binary:
/// 1. Sibling of the user-configured ffmpeg path (replace `ffmpeg` → `ffprobe`).
/// 2. Well-known Homebrew / MacPorts locations (macOS).
/// 3. `ffprobe` on the system PATH.
class FfprobeVideoProbeEngine implements VideoProbeEngine {
  FfprobeVideoProbeEngine();

  static final _log = Logger('FfprobeVideoProbeEngine');
  static String? _cachedFfprobePath;

  @override
  Future<VideoMetadata> probe(String videoPath) async {
    final ffprobe = await _resolveFfprobePath();
    if (ffprobe == null) {
      _log.warning('ffprobe not found — returning empty metadata');
      return VideoMetadata.empty;
    }

    try {
      final result = await Process.run(
        ffprobe,
        [
          '-v', 'quiet',
          '-print_format', 'json',
          '-show_streams',
          '-show_format',
          videoPath,
        ],
        runInShell: true,
      );

      if (result.exitCode != 0) {
        final stderr = result.stderr?.toString() ?? '';
        _log.warning('ffprobe exited with ${result.exitCode}: $stderr');
        return VideoMetadata.empty;
      }

      final json = jsonDecode(result.stdout as String) as Map<String, dynamic>;
      return _parseJson(json);
    } catch (e, st) {
      _log.warning('ffprobe execution failed', e, st);
      return VideoMetadata.empty;
    }
  }

  // ---------------------------------------------------------------------------
  // JSON parsing
  // ---------------------------------------------------------------------------

  VideoMetadata _parseJson(Map<String, dynamic> json) {
    final streams = json['streams'] as List<dynamic>? ?? [];
    final format = json['format'] as Map<String, dynamic>? ?? {};

    final videoStream = streams.cast<Map<String, dynamic>>().firstWhere(
      (s) => s['codec_type'] == 'video',
      orElse: () => <String, dynamic>{},
    );

    if (videoStream.isEmpty) {
      _log.info('No video stream found in ffprobe output');
      return VideoMetadata.empty;
    }

    final width = _parseInt(videoStream['width']);
    final height = _parseInt(videoStream['height']);
    final codec = (videoStream['codec_name'] as String?) ?? '';

    final durationSec = _parseDuration(videoStream, format);
    final fpsNominal = _parseFps(videoStream);
    final frameCountEstimate = _estimateFrameCount(
      videoStream,
      durationSec,
      fpsNominal,
    );

    final meta = VideoMetadata(
      width: width,
      height: height,
      durationSec: durationSec,
      fpsNominal: fpsNominal,
      frameCountEstimate: frameCountEstimate,
      codec: codec,
    );
    _log.fine('Probed: $meta');
    return meta;
  }

  double _parseDuration(
    Map<String, dynamic> stream,
    Map<String, dynamic> format,
  ) {
    // Prefer stream-level, fall back to format-level.
    final raw = stream['duration'] ?? format['duration'];
    if (raw == null) return 0.0;
    return double.tryParse(raw.toString()) ?? 0.0;
  }

  double _parseFps(Map<String, dynamic> stream) {
    // avg_frame_rate is the most reliable (e.g. "30000/1001" or "25/1").
    final avg = stream['avg_frame_rate'] as String?;
    if (avg != null) {
      final fps = _parseRational(avg);
      if (fps > 0) return fps;
    }
    // Fallback to r_frame_rate.
    final r = stream['r_frame_rate'] as String?;
    if (r != null) {
      final fps = _parseRational(r);
      if (fps > 0) return fps;
    }
    return 0.0;
  }

  int _estimateFrameCount(
    Map<String, dynamic> stream,
    double durationSec,
    double fps,
  ) {
    // Some containers report nb_frames directly.
    final nb = stream['nb_frames'];
    if (nb != null) {
      final n = int.tryParse(nb.toString());
      if (n != null && n > 0) return n;
    }
    // Estimate from duration * fps.
    if (durationSec > 0 && fps > 0) {
      return (durationSec * fps).round();
    }
    return 0;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  int _parseInt(dynamic v) {
    if (v is int) return v;
    if (v == null) return 0;
    return int.tryParse(v.toString()) ?? 0;
  }

  /// Parses a rational string like "30000/1001" into a double.
  double _parseRational(String rational) {
    final parts = rational.split('/');
    if (parts.length == 2) {
      final num = double.tryParse(parts[0]) ?? 0;
      final den = double.tryParse(parts[1]) ?? 0;
      if (den > 0) return num / den;
    }
    return double.tryParse(rational) ?? 0.0;
  }

  // ---------------------------------------------------------------------------
  // ffprobe binary resolution
  // ---------------------------------------------------------------------------

  Future<String?> _resolveFfprobePath() async {
    if (_cachedFfprobePath != null) {
      return _cachedFfprobePath;
    }

    // 1) Derive from user-configured ffmpeg path.
    final fromUser = await _deriveFromFfmpegSetting();
    if (fromUser != null) {
      _cachedFfprobePath = fromUser;
      return fromUser;
    }

    // 2) macOS well-known locations.
    if (PlatformUtils.isMacOS) {
      for (final candidate in const [
        '/opt/homebrew/bin/ffprobe',
        '/usr/local/bin/ffprobe',
        '/opt/local/bin/ffprobe',
      ]) {
        if (await _isExecutable(candidate)) {
          _log.fine('Detected ffprobe at $candidate');
          _cachedFfprobePath = candidate;
          return candidate;
        }
      }
    }

    // 3) Windows well-known location.
    if (PlatformUtils.isWindows) {
      const candidate = r'C:\ffmpeg\bin\ffprobe.exe';
      if (await File(candidate).exists()) {
        _cachedFfprobePath = candidate;
        return candidate;
      }
    }

    // 4) System PATH.
    try {
      final r = await Process.run('ffprobe', ['-version']);
      if (r.exitCode == 0) {
        _cachedFfprobePath = 'ffprobe';
        return 'ffprobe';
      }
    } catch (_) {}

    _log.warning('Could not resolve ffprobe binary');
    return null;
  }

  /// If the user has configured an ffmpeg path like `/usr/local/bin/ffmpeg`,
  /// ffprobe is almost certainly at `/usr/local/bin/ffprobe`.
  Future<String?> _deriveFromFfmpegSetting() async {
    try {
      final ffmpegPath = UserSession.instance.getUser().ffmpegPath;
      if (ffmpegPath == null || ffmpegPath.isEmpty) return null;

      final dir = p.dirname(ffmpegPath);
      final ext = p.extension(ffmpegPath);
      final candidate = p.join(dir, 'ffprobe$ext');

      if (await _isExecutable(candidate)) {
        _log.fine('Derived ffprobe from ffmpeg setting: $candidate');
        return candidate;
      }
    } catch (e) {
      _log.fine('Could not derive ffprobe from ffmpeg setting: $e');
    }
    return null;
  }

  Future<bool> _isExecutable(String path) async {
    try {
      return await File(path).exists();
    } catch (_) {
      return false;
    }
  }
}
