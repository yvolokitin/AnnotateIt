import 'dart:io';

import 'package:logging/logging.dart';

import 'perf_counters.dart';

final _log = Logger('FfmpegResolver');

/// Result of an ffmpeg path resolution attempt.
class FfmpegResolveResult {
  final String? path;
  final FfmpegSource source;
  final String message;

  const FfmpegResolveResult({
    this.path,
    required this.source,
    required this.message,
  });

  bool get found => path != null;

  @override
  String toString() => 'FfmpegResolveResult(path=$path, source=${source.name})';
}

enum FfmpegSource {
  userSetting,
  sessionCache,
  wellKnownPath,
  systemPath,
  notFound,
}

/// Sandbox-aware FFmpeg path resolver with validation caching.
///
/// On macOS App Sandbox, `Process.run` may fail for binaries outside
/// the sandbox. This resolver:
///
/// 1. Validates via Mach-O header check (no process spawn needed)
///    before attempting execution.
/// 2. Caches the validated path for the session to avoid repeated
///    filesystem probes.
/// 3. Reports the resolution source for transparency.
/// 4. Measures resolution time via [PerfCounters].
///
/// Well-known paths checked (macOS):
///   - `/opt/homebrew/bin/ffmpeg` (Apple Silicon Homebrew)
///   - `/usr/local/bin/ffmpeg` (Intel Homebrew)
///   - `/opt/local/bin/ffmpeg` (MacPorts)
///
/// Well-known paths checked (Windows):
///   - `C:\ffmpeg\bin\ffmpeg.exe`
///   - `C:\Program Files\ffmpeg\bin\ffmpeg.exe`
class FfmpegResolver {
  String? _cachedPath;
  FfmpegSource? _cachedSource;

  /// Resolve the ffmpeg binary path.
  ///
  /// [userSettingPath] — path from user preferences (may be null).
  /// [skipExecution] — if true, only checks file existence and headers
  /// (safer in sandboxed environments).
  Future<FfmpegResolveResult> resolve({
    String? userSettingPath,
    bool skipExecution = false,
  }) async {
    return PerfCounters.instance.measureAsync('ffmpeg_resolve', () async {
      // 1. Session cache
      if (_cachedPath != null) {
        return FfmpegResolveResult(
          path: _cachedPath,
          source: _cachedSource ?? FfmpegSource.sessionCache,
          message: 'Using cached path: $_cachedPath',
        );
      }

      // 2. User setting
      if (userSettingPath != null && userSettingPath.isNotEmpty) {
        final valid = await _validate(userSettingPath, skipExecution);
        if (valid) {
          _cache(userSettingPath, FfmpegSource.userSetting);
          return FfmpegResolveResult(
            path: userSettingPath,
            source: FfmpegSource.userSetting,
            message: 'Validated user-configured path: $userSettingPath',
          );
        }
        _log.fine('User setting path invalid: $userSettingPath');
      }

      // 3. Well-known paths
      final candidates = _wellKnownPaths();
      for (final candidate in candidates) {
        final valid = await _validate(candidate, skipExecution);
        if (valid) {
          _cache(candidate, FfmpegSource.wellKnownPath);
          return FfmpegResolveResult(
            path: candidate,
            source: FfmpegSource.wellKnownPath,
            message: 'Found ffmpeg at well-known path: $candidate',
          );
        }
      }

      // 4. System PATH (requires process spawn — may fail in sandbox)
      if (!skipExecution) {
        try {
          final result = await Process.run('ffmpeg', ['-version']);
          if (result.exitCode == 0) {
            _cache('ffmpeg', FfmpegSource.systemPath);
            return const FfmpegResolveResult(
              path: 'ffmpeg',
              source: FfmpegSource.systemPath,
              message: 'Found ffmpeg on system PATH.',
            );
          }
        } catch (e) {
          _log.fine('ffmpeg not on PATH: $e');
        }
      }

      return const FfmpegResolveResult(
        source: FfmpegSource.notFound,
        message: 'ffmpeg not found. Install via Homebrew '
            '(brew install ffmpeg) or set the path manually.',
      );
    });
  }

  /// Clear the cached path (e.g. when user changes settings).
  void clearCache() {
    _cachedPath = null;
    _cachedSource = null;
  }

  /// Current cached path, or null.
  String? get cachedPath => _cachedPath;

  void _cache(String path, FfmpegSource source) {
    _cachedPath = path;
    _cachedSource = source;
  }

  Future<bool> _validate(String path, bool skipExecution) async {
    final file = File(path);
    if (!await file.exists()) return false;

    if (await _isMachOOrPE(path)) {
      return true;
    }

    if (skipExecution) return false;

    try {
      final result = await Process.run(path, ['-version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Check if a file has a valid Mach-O (macOS) or PE (Windows) header
  /// without executing it.
  Future<bool> _isMachOOrPE(String path) async {
    try {
      final file = File(path);
      final raf = await file.open();
      final header = await raf.read(4);
      await raf.close();
      if (header.length < 4) return false;

      final b0 = header[0], b1 = header[1], b2 = header[2], b3 = header[3];

      // Mach-O magic numbers
      final isMachO = (b0 == 0xCE && b1 == 0xFA && b2 == 0xED && b3 == 0xFE) ||
          (b0 == 0xCF && b1 == 0xFA && b2 == 0xED && b3 == 0xFE) ||
          (b0 == 0xFE && b1 == 0xED && b2 == 0xFA && b3 == 0xCE) ||
          (b0 == 0xFE && b1 == 0xED && b2 == 0xFA && b3 == 0xCF) ||
          (b0 == 0xCA && b1 == 0xFE && b2 == 0xBA && (b3 == 0xBE || b3 == 0xBF));

      // PE (Windows) magic: MZ header
      final isPE = b0 == 0x4D && b1 == 0x5A;

      // ELF (Linux)
      final isElf = b0 == 0x7F && b1 == 0x45 && b2 == 0x4C && b3 == 0x46;

      return isMachO || isPE || isElf;
    } catch (_) {
      return false;
    }
  }

  List<String> _wellKnownPaths() {
    if (Platform.isMacOS) {
      return const [
        '/opt/homebrew/bin/ffmpeg',
        '/usr/local/bin/ffmpeg',
        '/opt/local/bin/ffmpeg',
      ];
    }
    if (Platform.isWindows) {
      return const [
        r'C:\ffmpeg\bin\ffmpeg.exe',
        r'C:\Program Files\ffmpeg\bin\ffmpeg.exe',
      ];
    }
    if (Platform.isLinux) {
      return const [
        '/usr/bin/ffmpeg',
        '/usr/local/bin/ffmpeg',
        '/snap/bin/ffmpeg',
      ];
    }
    return const [];
  }
}
