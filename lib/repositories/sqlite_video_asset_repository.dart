import 'package:sqflite/sqflite.dart';

import '../models/video_asset.dart';
import 'video_asset_repository.dart';

class SqliteVideoAssetRepository implements VideoAssetRepository {
  final Database _db;

  const SqliteVideoAssetRepository(this._db);

  @override
  Future<int> insert(VideoAsset asset) {
    return _db.insert('video_assets', asset.toMap());
  }

  @override
  Future<VideoAsset?> findById(int id) async {
    final rows = await _db.query(
      'video_assets',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : VideoAsset.fromMap(rows.first);
  }

  @override
  Future<VideoAsset?> findByUuid(String uuid) async {
    final rows = await _db.query(
      'video_assets',
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1,
    );
    return rows.isEmpty ? null : VideoAsset.fromMap(rows.first);
  }

  @override
  Future<List<VideoAsset>> findByProject(int projectId) async {
    final rows = await _db.query(
      'video_assets',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'created_at ASC',
    );
    return rows.map(VideoAsset.fromMap).toList();
  }

  @override
  Future<void> update(VideoAsset asset) async {
    await _db.update(
      'video_assets',
      asset.toMap(),
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    await _db.delete('video_assets', where: 'id = ?', whereArgs: [id]);
  }
}
