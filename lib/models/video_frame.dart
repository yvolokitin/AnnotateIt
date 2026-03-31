import 'frame_identity.dart';

/// A single extracted frame persisted in the database, linked to its source
/// [VideoAsset] and carrying the [FrameIdentity] contract fields.
class VideoFrame {
  final int? id;
  final int videoAssetId;
  final int? mediaItemId;
  final int frameIndex;
  final double timestampMs;
  final double sourceFps;
  final SamplingPolicy samplingPolicy;
  final String extractionRunId;
  final String? filePath;
  final DateTime createdAt;

  const VideoFrame({
    this.id,
    required this.videoAssetId,
    this.mediaItemId,
    required this.frameIndex,
    this.timestampMs = 0.0,
    this.sourceFps = 0.0,
    this.samplingPolicy = SamplingPolicy.fixedFps,
    required this.extractionRunId,
    this.filePath,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'video_asset_id': videoAssetId,
    'media_item_id': mediaItemId,
    'frame_index': frameIndex,
    'timestamp_ms': timestampMs,
    'source_fps': sourceFps,
    'sampling_policy': samplingPolicy.name,
    'extraction_run_id': extractionRunId,
    'file_path': filePath,
    'created_at': createdAt.toIso8601String(),
  };

  factory VideoFrame.fromMap(Map<String, dynamic> map) {
    return VideoFrame(
      id: map['id'] as int?,
      videoAssetId: map['video_asset_id'] as int,
      mediaItemId: map['media_item_id'] as int?,
      frameIndex: map['frame_index'] as int,
      timestampMs: (map['timestamp_ms'] as num?)?.toDouble() ?? 0.0,
      sourceFps: (map['source_fps'] as num?)?.toDouble() ?? 0.0,
      samplingPolicy: SamplingPolicy.values.firstWhere(
        (e) => e.name == map['sampling_policy'],
        orElse: () => SamplingPolicy.fixedFps,
      ),
      extractionRunId: map['extraction_run_id'] as String,
      filePath: map['file_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to the domain-layer [FrameIdentity] given a video UUID.
  FrameIdentity toFrameIdentity(String videoUuid) => FrameIdentity(
    videoId: videoUuid,
    frameIndex: frameIndex,
    timestampMs: timestampMs,
    sourceFps: sourceFps,
    samplingPolicy: samplingPolicy,
    extractionRunId: extractionRunId,
  );

  @override
  String toString() =>
      'VideoFrame(id=$id, asset=$videoAssetId, idx=$frameIndex, '
      't=${timestampMs.toStringAsFixed(1)}ms)';
}
