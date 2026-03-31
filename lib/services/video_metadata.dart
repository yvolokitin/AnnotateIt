/// Metadata extracted from a video file via a probe engine.
class VideoMetadata {
  final int width;
  final int height;
  final double durationSec;
  final double fpsNominal;
  final int frameCountEstimate;
  final String codec;

  const VideoMetadata({
    required this.width,
    required this.height,
    required this.durationSec,
    required this.fpsNominal,
    required this.frameCountEstimate,
    required this.codec,
  });

  static const VideoMetadata empty = VideoMetadata(
    width: 0,
    height: 0,
    durationSec: 0.0,
    fpsNominal: 0.0,
    frameCountEstimate: 0,
    codec: '',
  );

  bool get isValid => width > 0 && height > 0 && durationSec > 0;

  Map<String, dynamic> toMap() => {
    'width': width,
    'height': height,
    'duration': durationSec,
    'fps': fpsNominal,
    'frameCount': frameCountEstimate,
    'codec': codec,
  };

  @override
  String toString() =>
      'VideoMetadata(${width}x$height, ${durationSec}s, ${fpsNominal}fps, '
      '~$frameCountEstimate frames, codec=$codec)';
}

/// Abstract probe engine. Implementations use platform-specific tools
/// (ffprobe, AVAsset, HTML5 video element, etc.) to extract metadata.
abstract class VideoProbeEngine {
  Future<VideoMetadata> probe(String videoPath);
}
