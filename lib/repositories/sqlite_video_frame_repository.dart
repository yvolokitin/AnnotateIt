import 'package:sqflite/sqflite.dart';

import '../models/video_frame.dart';
import 'video_frame_repository.dart';

class SqliteVideoFrameRepository implements VideoFrameRepository {
  final Database _db;

  const SqliteVideoFrameRepository(this._db);

  @override
  Future<int> insert(VideoFrame frame) {
    return _db.insert('video_frames', frame.toMap());
  }

  @override
  Future<void> insertBatch(List<VideoFrame> frames) async {
    final batch = _db.batch();
    for (final frame in frames) {
      batch.insert('video_frames', frame.toMap());
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<VideoFrame?> findById(int id) async {
    final rows = await _db.query(
      'video_frames',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : VideoFrame.fromMap(rows.first);
  }

  @override
  Future<List<VideoFrame>> findByVideoAsset(int videoAssetId) async {
    final rows = await _db.query(
      'video_frames',
      where: 'video_asset_id = ?',
      whereArgs: [videoAssetId],
      orderBy: 'frame_index ASC',
    );
    return rows.map(VideoFrame.fromMap).toList();
  }

  @override
  Future<VideoFrame?> findByAssetAndIndex(
    int videoAssetId,
    int frameIndex,
  ) async {
    final rows = await _db.query(
      'video_frames',
      where: 'video_asset_id = ? AND frame_index = ?',
      whereArgs: [videoAssetId, frameIndex],
      limit: 1,
    );
    return rows.isEmpty ? null : VideoFrame.fromMap(rows.first);
  }

  @override
  Future<List<VideoFrame>> findByExtractionRun(String extractionRunId) async {
    final rows = await _db.query(
      'video_frames',
      where: 'extraction_run_id = ?',
      whereArgs: [extractionRunId],
      orderBy: 'frame_index ASC',
    );
    return rows.map(VideoFrame.fromMap).toList();
  }

  @override
  Future<void> delete(int id) async {
    await _db.delete('video_frames', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteByVideoAsset(int videoAssetId) async {
    await _db.delete(
      'video_frames',
      where: 'video_asset_id = ?',
      whereArgs: [videoAssetId],
    );
  }
}
