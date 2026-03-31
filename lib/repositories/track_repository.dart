import '../models/annotation_track.dart';
import '../models/track_keyframe.dart';

abstract class TrackRepository {
  // -- Tracks --
  Future<int> insertTrack(AnnotationTrack track);
  Future<AnnotationTrack?> findTrackById(int id);
  Future<List<AnnotationTrack>> findTracksByVideoAsset(int videoAssetId);
  Future<void> updateTrack(AnnotationTrack track);
  Future<void> deleteTrack(int id);

  // -- Keyframes --
  Future<int> insertKeyframe(TrackKeyframe keyframe);
  Future<List<TrackKeyframe>> findKeyframesByTrack(int trackId);
  Future<TrackKeyframe?> findKeyframeByTrackAndFrame(int trackId, int frameId);
  Future<void> updateKeyframe(TrackKeyframe keyframe);
  Future<void> deleteKeyframe(int id);

  // -- Query: tracks visible at a specific frame --
  Future<List<AnnotationTrack>> findTracksAtFrame(int videoAssetId, int frameId);

  // -- Review workflow --
  Future<void> updateTrackReview({
    required int trackId,
    required String reviewStatus,
    int? reviewedBy,
    DateTime? reviewedAt,
    String? reviewComment,
  });

  /// Bulk-update review status for tracks whose keyframes fall within
  /// [startFrameId]..[endFrameId] (inclusive).
  Future<int> bulkUpdateReviewByFrameRange({
    required int videoAssetId,
    required int startFrameId,
    required int endFrameId,
    required String reviewStatus,
    int? reviewedBy,
    String? reviewComment,
  });

  /// Filter tracks by review status.
  Future<List<AnnotationTrack>> findTracksByReviewStatus(
    int videoAssetId,
    String reviewStatus,
  );
}
