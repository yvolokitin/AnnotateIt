import 'video_metadata.dart';

/// Web fallback: no native probe available.
/// Returns [VideoMetadata.empty] — callers should degrade gracefully.
class PlatformVideoProbeEngine implements VideoProbeEngine {
  const PlatformVideoProbeEngine();

  @override
  Future<VideoMetadata> probe(String videoPath) async => VideoMetadata.empty;
}
