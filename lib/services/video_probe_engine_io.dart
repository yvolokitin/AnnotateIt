import 'ffprobe_video_probe_engine.dart';
import 'video_metadata.dart';

/// IO implementation: delegates to [FfprobeVideoProbeEngine].
class PlatformVideoProbeEngine implements VideoProbeEngine {
  PlatformVideoProbeEngine();

  final FfprobeVideoProbeEngine _engine = FfprobeVideoProbeEngine();

  @override
  Future<VideoMetadata> probe(String videoPath) => _engine.probe(videoPath);
}
