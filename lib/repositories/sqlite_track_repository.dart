import 'package:sqflite/sqflite.dart';

import '../models/annotation_track.dart';
import '../models/track_keyframe.dart';
import 'track_repository.dart';

class SqliteTrackRepository implements TrackRepository {
  final Database _db;

  const SqliteTrackRepository(this._db);

  // -- Tracks -----------------------------------------------------------------

  @override
  Future<int> insertTrack(AnnotationTrack track) {
    return _db.insert('annotation_tracks', track.toMap());
  }

  @override
  Future<AnnotationTrack?> findTrackById(int id) async {
    final rows = await _db.query(
      'annotation_tracks',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : AnnotationTrack.fromMap(rows.first);
  }

  @override
  Future<List<AnnotationTrack>> findTracksByVideoAsset(
    int videoAssetId,
  ) async {
    final rows = await _db.query(
      'annotation_tracks',
      where: 'video_asset_id = ?',
      whereArgs: [videoAssetId],
      orderBy: 'created_at ASC',
    );
    return rows.map(AnnotationTrack.fromMap).toList();
  }

  @override
  Future<void> updateTrack(AnnotationTrack track) async {
    await _db.update(
      'annotation_tracks',
      track.toMap(),
      where: 'id = ?',
      whereArgs: [track.id],
    );
  }

  @override
  Future<void> deleteTrack(int id) async {
    await _db.delete('annotation_tracks', where: 'id = ?', whereArgs: [id]);
  }

  // -- Keyframes --------------------------------------------------------------

  @override
  Future<int> insertKeyframe(TrackKeyframe keyframe) {
    return _db.insert('track_keyframes', keyframe.toMap());
  }

  @override
  Future<List<TrackKeyframe>> findKeyframesByTrack(int trackId) async {
    final rows = await _db.query(
      'track_keyframes',
      where: 'track_id = ?',
      whereArgs: [trackId],
      orderBy: 'frame_id ASC',
    );
    return rows.map(TrackKeyframe.fromMap).toList();
  }

  @override
  Future<TrackKeyframe?> findKeyframeByTrackAndFrame(
    int trackId,
    int frameId,
  ) async {
    final rows = await _db.query(
      'track_keyframes',
      where: 'track_id = ? AND frame_id = ?',
      whereArgs: [trackId, frameId],
      limit: 1,
    );
    return rows.isEmpty ? null : TrackKeyframe.fromMap(rows.first);
  }

  @override
  Future<void> updateKeyframe(TrackKeyframe keyframe) async {
    await _db.update(
      'track_keyframes',
      keyframe.toMap(),
      where: 'id = ?',
      whereArgs: [keyframe.id],
    );
  }

  @override
  Future<void> deleteKeyframe(int id) async {
    await _db.delete('track_keyframes', where: 'id = ?', whereArgs: [id]);
  }

  // -- Composite queries ------------------------------------------------------

  /// Returns all tracks that have at least one keyframe at [frameId].
  @override
  Future<List<AnnotationTrack>> findTracksAtFrame(
    int videoAssetId,
    int frameId,
  ) async {
    final rows = await _db.rawQuery('''
      SELECT DISTINCT t.*
      FROM annotation_tracks t
      INNER JOIN track_keyframes kf ON kf.track_id = t.id
      WHERE t.video_asset_id = ? AND kf.frame_id = ?
      ORDER BY t.created_at ASC
    ''', [videoAssetId, frameId]);
    return rows.map(AnnotationTrack.fromMap).toList();
  }

  // -- Review workflow --------------------------------------------------------

  @override
  Future<void> updateTrackReview({
    required int trackId,
    required String reviewStatus,
    int? reviewedBy,
    DateTime? reviewedAt,
    String? reviewComment,
  }) async {
    final now = DateTime.now();
    await _db.update(
      'annotation_tracks',
      {
        'review_status': reviewStatus,
        'reviewed_by': reviewedBy,
        'reviewed_at': (reviewedAt ?? now).toIso8601String(),
        'review_comment': reviewComment,
        'updated_at': now.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  @override
  Future<int> bulkUpdateReviewByFrameRange({
    required int videoAssetId,
    required int startFrameId,
    required int endFrameId,
    required String reviewStatus,
    int? reviewedBy,
    String? reviewComment,
  }) async {
    final now = DateTime.now().toIso8601String();
    final result = await _db.rawUpdate('''
      UPDATE annotation_tracks
      SET review_status = ?,
          reviewed_by = ?,
          reviewed_at = ?,
          review_comment = ?,
          updated_at = ?
      WHERE video_asset_id = ?
        AND id IN (
          SELECT DISTINCT kf.track_id
          FROM track_keyframes kf
          WHERE kf.frame_id >= ? AND kf.frame_id <= ?
        )
    ''', [
      reviewStatus,
      reviewedBy,
      now,
      reviewComment,
      now,
      videoAssetId,
      startFrameId,
      endFrameId,
    ]);
    return result;
  }

  @override
  Future<List<AnnotationTrack>> findTracksByReviewStatus(
    int videoAssetId,
    String reviewStatus,
  ) async {
    final rows = await _db.query(
      'annotation_tracks',
      where: 'video_asset_id = ? AND review_status = ?',
      whereArgs: [videoAssetId, reviewStatus],
      orderBy: 'created_at ASC',
    );
    return rows.map(AnnotationTrack.fromMap).toList();
  }
}
