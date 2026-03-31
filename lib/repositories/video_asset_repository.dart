import '../models/video_asset.dart';

abstract class VideoAssetRepository {
  Future<int> insert(VideoAsset asset);
  Future<VideoAsset?> findById(int id);
  Future<VideoAsset?> findByUuid(String uuid);
  Future<List<VideoAsset>> findByProject(int projectId);
  Future<void> update(VideoAsset asset);
  Future<void> delete(int id);
}
