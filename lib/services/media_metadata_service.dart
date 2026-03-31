import 'dart:io';

import 'package:logging/logging.dart';

import '../utils/compute_helpers.dart';
import 'perf_counters.dart';
import 'video_metadata.dart';
import 'video_probe_engine_barrel.dart';

class MediaMetadataService {
  static final MediaMetadataService instance = MediaMetadataService._();

  MediaMetadataService._() : _videoProbeEngine = PlatformVideoProbeEngine();

  /// Visible for testing: allows injecting a mock probe engine.
  MediaMetadataService.withEngine(VideoProbeEngine engine)
      : _videoProbeEngine = engine;

  final VideoProbeEngine _videoProbeEngine;
  static final _log = Logger('MediaMetadataService');

  Future<Map<String, dynamic>> getImageMetadata(String path) async {
    return PerfCounters.instance.measureAsync('image_metadata', () async {
      final bytes = await File(path).readAsBytes();
      final dims = await getImageDimensionsInIsolate(bytes);
      if (dims == null) {
        return {'width': 0, 'height': 0};
      }
      return {'width': dims.width, 'height': dims.height};
    });
  }

  /// Returns a map compatible with existing callers:
  /// `width`, `height`, `duration`, `fps`, plus new `frameCount` and `codec`.
  Future<Map<String, dynamic>> getVideoMetadata(String path) async {
    final meta = await getVideoMetadataTyped(path);
    return meta.toMap();
  }

  /// Typed alternative — prefer this in new code.
  Future<VideoMetadata> getVideoMetadataTyped(String path) async {
    try {
      return await _videoProbeEngine.probe(path);
    } catch (e, st) {
      _log.warning('Video probe failed, returning empty metadata', e, st);
      return VideoMetadata.empty;
    }
  }
}
