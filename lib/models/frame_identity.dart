import 'dart:convert';

/// How frames were sampled from the source video.
enum SamplingPolicy {
  /// Every frame in the video (native fps).
  everyFrame,

  /// Sampled at a fixed fps rate (e.g. 1 fps, 5 fps).
  fixedFps,

  /// Only key-frames / I-frames extracted.
  keyframesOnly,
}

/// Canonical identity of a single frame extracted from a video.
///
/// Two frames with the same [videoId], [frameIndex], [sourceFps], and
/// [samplingPolicy] represent the same visual content regardless of when
/// or where extraction happened.
class FrameIdentity {
  /// Identifier of the source video (typically the media-item UUID).
  final String videoId;

  /// 0-based index within the extraction run's output sequence.
  final int frameIndex;

  /// Estimated presentation timestamp in milliseconds.
  final double timestampMs;

  /// Native fps of the source video (from probe metadata).
  final double sourceFps;

  /// Sampling strategy used during extraction.
  final SamplingPolicy samplingPolicy;

  /// Unique ID grouping all frames from one extraction invocation.
  final String extractionRunId;

  const FrameIdentity({
    required this.videoId,
    required this.frameIndex,
    required this.timestampMs,
    required this.sourceFps,
    required this.samplingPolicy,
    required this.extractionRunId,
  });

  Map<String, dynamic> toMap() => {
    'videoId': videoId,
    'frameIndex': frameIndex,
    'timestampMs': timestampMs,
    'sourceFps': sourceFps,
    'samplingPolicy': samplingPolicy.name,
    'extractionRunId': extractionRunId,
  };

  String toJson() => jsonEncode(toMap());

  factory FrameIdentity.fromMap(Map<String, dynamic> map) {
    return FrameIdentity(
      videoId: map['videoId'] as String,
      frameIndex: map['frameIndex'] as int,
      timestampMs: (map['timestampMs'] as num).toDouble(),
      sourceFps: (map['sourceFps'] as num).toDouble(),
      samplingPolicy: SamplingPolicy.values.firstWhere(
        (e) => e.name == map['samplingPolicy'],
        orElse: () => SamplingPolicy.fixedFps,
      ),
      extractionRunId: map['extractionRunId'] as String,
    );
  }

  factory FrameIdentity.fromJson(String json) =>
      FrameIdentity.fromMap(jsonDecode(json) as Map<String, dynamic>);

  @override
  String toString() =>
      'FrameIdentity(video=$videoId, frame=$frameIndex, '
      't=${timestampMs.toStringAsFixed(1)}ms, '
      'srcFps=$sourceFps, policy=${samplingPolicy.name}, '
      'run=$extractionRunId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrameIdentity &&
          videoId == other.videoId &&
          frameIndex == other.frameIndex &&
          samplingPolicy == other.samplingPolicy &&
          extractionRunId == other.extractionRunId;

  @override
  int get hashCode => Object.hash(
    videoId,
    frameIndex,
    samplingPolicy,
    extractionRunId,
  );
}

/// Result of a frame extraction run: pairs file paths with their identities.
class ExtractionResult {
  final String extractionRunId;
  final String videoId;
  final double samplingFps;
  final double sourceFps;
  final SamplingPolicy samplingPolicy;
  final List<ExtractedFrame> frames;

  const ExtractionResult({
    required this.extractionRunId,
    required this.videoId,
    required this.samplingFps,
    required this.sourceFps,
    required this.samplingPolicy,
    required this.frames,
  });

  bool get isEmpty => frames.isEmpty;
  int get frameCount => frames.length;
}

/// A single extracted frame file paired with its identity.
class ExtractedFrame {
  final String filePath;
  final FrameIdentity identity;

  const ExtractedFrame({required this.filePath, required this.identity});
}
