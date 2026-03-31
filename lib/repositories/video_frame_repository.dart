import '../models/video_frame.dart';

abstract class VideoFrameRepository {
  Future<int> insert(VideoFrame frame);
  Future<void> insertBatch(List<VideoFrame> frames);
  Future<VideoFrame?> findById(int id);
  Future<List<VideoFrame>> findByVideoAsset(int videoAssetId);
  Future<VideoFrame?> findByAssetAndIndex(int videoAssetId, int frameIndex);
  Future<List<VideoFrame>> findByExtractionRun(String extractionRunId);
  Future<void> delete(int id);
  Future<void> deleteByVideoAsset(int videoAssetId);
}
