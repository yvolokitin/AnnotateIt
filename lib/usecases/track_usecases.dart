import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../models/annotation_track.dart';
import '../models/bbox_geometry.dart';
import '../models/polygon_geometry.dart';
import '../models/track_keyframe.dart';
import '../repositories/track_repository.dart';
import '../repositories/video_frame_repository.dart';

final _log = Logger('TrackUseCases');

/// Creates a new annotation track for a video asset.
///
/// Returns the inserted track with its database-assigned [id].
class CreateTrack {
  final TrackRepository _trackRepo;

  const CreateTrack(this._trackRepo);

  Future<AnnotationTrack> call({
    required int videoAssetId,
    int? labelId,
    String annotationType = 'bbox',
  }) async {
    final now = DateTime.now();
    final track = AnnotationTrack(
      uuid: const Uuid().v4(),
      videoAssetId: videoAssetId,
      labelId: labelId,
      status: AnnotationTrack.statusActive,
      annotationType: annotationType,
      createdAt: now,
      updatedAt: now,
    );
    final id = await _trackRepo.insertTrack(track);
    _log.fine('Created track ${track.uuid} for video asset $videoAssetId');
    return track.copyWith(id: id);
  }
}

/// Adds (or replaces) a keyframe at a given frame position in a track.
///
/// If a keyframe already exists at [frameId] for this track, it is updated
/// rather than duplicated.
class AddKeyframe {
  final TrackRepository _trackRepo;

  const AddKeyframe(this._trackRepo);

  Future<TrackKeyframe> call({
    required int trackId,
    required int frameId,
    required Map<String, dynamic> geometry,
    double confidence = 1.0,
    bool isManual = true,
  }) async {
    final geometryJson = jsonEncode(geometry);
    final now = DateTime.now();

    final existing = await _trackRepo.findKeyframeByTrackAndFrame(
      trackId,
      frameId,
    );
    if (existing != null) {
      final updated = existing.copyWith(
        geometry: geometryJson,
        confidence: confidence,
        isManual: isManual,
        updatedAt: now,
      );
      await _trackRepo.updateKeyframe(updated);
      _log.fine('Updated keyframe at frame $frameId for track $trackId');
      return updated;
    }

    final keyframe = TrackKeyframe(
      trackId: trackId,
      frameId: frameId,
      geometry: geometryJson,
      confidence: confidence,
      isManual: isManual,
      createdAt: now,
      updatedAt: now,
    );
    final id = await _trackRepo.insertKeyframe(keyframe);
    _log.fine('Added keyframe at frame $frameId for track $trackId');
    return keyframe.copyWith(id: id);
  }
}

/// Geometry at a frame position — either a manual keyframe or an
/// interpolated in-between.
class InterpolatedFrame {
  final int frameId;
  final Map<String, dynamic> geometry;
  final double confidence;

  /// `true` for user-placed keyframes, `false` for interpolated frames.
  final bool isManual;

  /// Interpolation quality rating. [InterpolationQuality.high] for manual
  /// keyframes and bbox interpolation; may be lower for polygon tracks
  /// where vertex counts differ.
  final InterpolationQuality quality;

  const InterpolatedFrame({
    required this.frameId,
    required this.geometry,
    required this.confidence,
    required this.isManual,
    this.quality = InterpolationQuality.high,
  });

  /// Convenience: parse [geometry] as a [BboxGeometry].
  BboxGeometry get bbox => BboxGeometry.fromMap(geometry);

  /// Convenience: parse [geometry] as a [PolygonGeometry].
  PolygonGeometry get polygon => PolygonGeometry.fromMap(geometry);

  /// Whether this frame should show a low-confidence warning badge.
  bool get showWarningBadge =>
      quality == InterpolationQuality.low && !isManual;
}

/// Interpolates geometry for a track between two keyframes, producing
/// linearly interpolated values for each intermediate frame.
///
/// Returns keyframe-level geometry at anchor positions and interpolated
/// geometry at in-between positions.
class InterpolateTrackSegment {
  final TrackRepository _trackRepo;
  final VideoFrameRepository _frameRepo;

  const InterpolateTrackSegment(this._trackRepo, this._frameRepo);

  /// Interpolate between keyframes of [trackId] across all frames of
  /// [videoAssetId].
  ///
  /// For `bbox` annotation types, uses [BboxGeometry.lerp] which includes
  /// shortest-arc rotation interpolation. For other types, numeric values
  /// are lerped generically; non-numeric values carry forward.
  ///
  /// Each result carries [InterpolatedFrame.isManual] so callers can
  /// visually distinguish keyframes from interpolated in-betweens.
  Future<List<InterpolatedFrame>> call({
    required int trackId,
    required int videoAssetId,
    String annotationType = 'bbox',
  }) async {
    final keyframes = await _trackRepo.findKeyframesByTrack(trackId);
    if (keyframes.isEmpty) return [];

    final allFrames = await _frameRepo.findByVideoAsset(videoAssetId);
    if (allFrames.isEmpty) return [];

    final frameIdToIndex = {
      for (final f in allFrames) f.id!: f.frameIndex,
    };

    final sorted = List<TrackKeyframe>.from(keyframes)
      ..sort((a, b) =>
          (frameIdToIndex[a.frameId] ?? 0).compareTo(
            frameIdToIndex[b.frameId] ?? 0,
          ));

    final useBboxLerp = annotationType == 'bbox';
    final usePolygonLerp = annotationType == 'polygon';
    final results = <InterpolatedFrame>[];

    for (int i = 0; i < sorted.length; i++) {
      final kf = sorted[i];
      results.add(InterpolatedFrame(
        frameId: kf.frameId,
        geometry: kf.geometryMap,
        confidence: kf.confidence,
        isManual: kf.isManual,
      ));

      if (i + 1 >= sorted.length) break;

      final next = sorted[i + 1];
      final startIdx = frameIdToIndex[kf.frameId] ?? 0;
      final endIdx = frameIdToIndex[next.frameId] ?? 0;
      if (endIdx - startIdx <= 1) continue;

      final startGeo = kf.geometryMap;
      final endGeo = next.geometryMap;

      BboxGeometry? startBbox;
      BboxGeometry? endBbox;
      if (useBboxLerp &&
          startGeo.containsKey('width') && endGeo.containsKey('width')) {
        startBbox = BboxGeometry.fromMap(startGeo);
        endBbox = BboxGeometry.fromMap(endGeo);
      }

      PolygonGeometry? startPoly;
      PolygonGeometry? endPoly;
      if (usePolygonLerp &&
          startGeo.containsKey('points') && endGeo.containsKey('points')) {
        startPoly = PolygonGeometry.fromMap(startGeo);
        endPoly = PolygonGeometry.fromMap(endGeo);
      }

      for (final frame in allFrames) {
        final idx = frame.frameIndex;
        if (idx <= startIdx || idx >= endIdx) continue;

        final t = (idx - startIdx) / (endIdx - startIdx);

        final Map<String, dynamic> interpolatedGeo;
        InterpolationQuality frameQuality = InterpolationQuality.high;

        if (useBboxLerp && startBbox != null && endBbox != null) {
          interpolatedGeo = BboxGeometry.lerp(startBbox, endBbox, t).toMap();
        } else if (usePolygonLerp && startPoly != null && endPoly != null) {
          final lerpResult = PolygonGeometry.lerp(startPoly, endPoly, t);
          interpolatedGeo = lerpResult.polygon.toMap();
          frameQuality = lerpResult.quality;
        } else {
          interpolatedGeo = _lerpGeometry(startGeo, endGeo, t);
        }

        results.add(InterpolatedFrame(
          frameId: frame.id!,
          geometry: interpolatedGeo,
          confidence: _lerp(kf.confidence, next.confidence, t),
          isManual: false,
          quality: frameQuality,
        ));
      }
    }

    results.sort((a, b) =>
        (frameIdToIndex[a.frameId] ?? 0).compareTo(
          frameIdToIndex[b.frameId] ?? 0,
        ));

    return results;
  }

  static Map<String, dynamic> _lerpGeometry(
    Map<String, dynamic> a,
    Map<String, dynamic> b,
    double t,
  ) {
    final result = <String, dynamic>{};
    for (final key in a.keys) {
      final va = a[key];
      final vb = b[key];
      if (va is num && vb is num) {
        result[key] = _lerp(va.toDouble(), vb.toDouble(), t);
      } else {
        result[key] = va;
      }
    }
    return result;
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}

/// Lists all tracks (with their keyframes) that are visible at a specific
/// video frame.
class ListTracksAtFrame {
  final TrackRepository _trackRepo;

  const ListTracksAtFrame(this._trackRepo);

  /// Returns all active tracks for [videoAssetId] that have a keyframe at
  /// [frameId].
  Future<List<AnnotationTrack>> call({
    required int videoAssetId,
    required int frameId,
  }) {
    return _trackRepo.findTracksAtFrame(videoAssetId, frameId);
  }
}

// =========================================================================
// Review workflow use cases
// =========================================================================

/// Transitions a single track to a new review status, validating the
/// transition against [TrackReviewStatus.canTransition].
class ReviewTrack {
  final TrackRepository _trackRepo;

  const ReviewTrack(this._trackRepo);

  /// Transitions track [trackId] to [newStatus].
  ///
  /// Throws [StateError] if the transition is not allowed.
  Future<AnnotationTrack> call({
    required int trackId,
    required String newStatus,
    int? reviewedBy,
    String? comment,
  }) async {
    if (!TrackReviewStatus.isValid(newStatus)) {
      throw ArgumentError('Invalid review status: $newStatus');
    }

    final track = await _trackRepo.findTrackById(trackId);
    if (track == null) {
      throw StateError('Track $trackId not found');
    }

    if (!TrackReviewStatus.canTransition(track.reviewStatus, newStatus)) {
      throw StateError(
        'Cannot transition from ${track.reviewStatus} to $newStatus',
      );
    }

    final now = DateTime.now();
    await _trackRepo.updateTrackReview(
      trackId: trackId,
      reviewStatus: newStatus,
      reviewedBy: reviewedBy,
      reviewedAt: now,
      reviewComment: comment,
    );

    _log.fine('Track $trackId review: ${track.reviewStatus} → $newStatus');
    return track.copyWith(
      reviewStatus: newStatus,
      reviewedBy: reviewedBy,
      reviewedAt: now,
      reviewComment: comment,
      updatedAt: now,
    );
  }
}

/// Bulk-reviews all tracks that have keyframes in a given frame range.
///
/// Skips transition validation — this is an administrative operation for
/// batch-approving or rejecting a range of frames.
class BulkReviewByFrameRange {
  final TrackRepository _trackRepo;

  const BulkReviewByFrameRange(this._trackRepo);

  /// Updates review status for all tracks whose keyframes fall within
  /// [startFrameId]..[endFrameId]. Returns the number of tracks updated.
  Future<int> call({
    required int videoAssetId,
    required int startFrameId,
    required int endFrameId,
    required String reviewStatus,
    int? reviewedBy,
    String? comment,
  }) async {
    if (!TrackReviewStatus.isValid(reviewStatus)) {
      throw ArgumentError('Invalid review status: $reviewStatus');
    }

    final count = await _trackRepo.bulkUpdateReviewByFrameRange(
      videoAssetId: videoAssetId,
      startFrameId: startFrameId,
      endFrameId: endFrameId,
      reviewStatus: reviewStatus,
      reviewedBy: reviewedBy,
      reviewComment: comment,
    );
    _log.fine(
      'Bulk review: $count tracks set to $reviewStatus '
      '(frames $startFrameId..$endFrameId)',
    );
    return count;
  }
}

/// Lists tracks filtered by review status.
class ListTracksByReviewStatus {
  final TrackRepository _trackRepo;

  const ListTracksByReviewStatus(this._trackRepo);

  Future<List<AnnotationTrack>> call({
    required int videoAssetId,
    required String reviewStatus,
  }) {
    return _trackRepo.findTracksByReviewStatus(videoAssetId, reviewStatus);
  }
}
