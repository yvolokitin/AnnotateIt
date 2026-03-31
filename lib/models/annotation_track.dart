/// Review status lifecycle for video annotation tracks.
///
/// Mirrors [AnnotationReviewStatus] from image annotations:
///   draft → proposed → accepted | rejected
///   rejected → draft | proposed
///   accepted → draft (re-open)
class TrackReviewStatus {
  static const String draft = 'draft';
  static const String proposed = 'proposed';
  static const String accepted = 'accepted';
  static const String rejected = 'rejected';

  static const Set<String> values = {draft, proposed, accepted, rejected};

  const TrackReviewStatus._();

  static String normalize(String? raw) {
    final value = raw?.trim().toLowerCase();
    if (value != null && values.contains(value)) return value;
    return draft;
  }

  static bool isValid(String value) => values.contains(value);

  static bool canTransition(String from, String to) {
    if (from == to) return true;
    switch (from) {
      case draft:
        return to == proposed;
      case proposed:
        return to == draft || to == accepted || to == rejected;
      case rejected:
        return to == draft || to == proposed;
      case accepted:
        return to == draft;
      default:
        return false;
    }
  }
}

/// A temporal annotation track spanning multiple frames of a video.
///
/// Tracks group keyframes together under a single label and annotation type,
/// enabling interpolation between user-defined anchor points.
class AnnotationTrack {
  final int? id;
  final String uuid;
  final int videoAssetId;
  final int? labelId;
  final String status;
  final String annotationType;
  final String reviewStatus;
  final int? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AnnotationTrack({
    this.id,
    required this.uuid,
    required this.videoAssetId,
    this.labelId,
    this.status = 'active',
    this.annotationType = 'bbox',
    this.reviewStatus = TrackReviewStatus.draft,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewComment,
    required this.createdAt,
    required this.updatedAt,
  });

  static const statusActive = 'active';
  static const statusCompleted = 'completed';
  static const statusArchived = 'archived';

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'uuid': uuid,
    'video_asset_id': videoAssetId,
    'label_id': labelId,
    'status': status,
    'annotation_type': annotationType,
    'review_status': reviewStatus,
    'reviewed_by': reviewedBy,
    'reviewed_at': reviewedAt?.toIso8601String(),
    'review_comment': reviewComment,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory AnnotationTrack.fromMap(Map<String, dynamic> map) {
    return AnnotationTrack(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      videoAssetId: map['video_asset_id'] as int,
      labelId: map['label_id'] as int?,
      status: (map['status'] as String?) ?? statusActive,
      annotationType: (map['annotation_type'] as String?) ?? 'bbox',
      reviewStatus: TrackReviewStatus.normalize(
        map['review_status'] as String?,
      ),
      reviewedBy: map['reviewed_by'] as int?,
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.parse(map['reviewed_at'] as String)
          : null,
      reviewComment: map['review_comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  AnnotationTrack copyWith({
    int? id,
    String? uuid,
    int? videoAssetId,
    int? labelId,
    String? status,
    String? annotationType,
    String? reviewStatus,
    int? reviewedBy,
    DateTime? reviewedAt,
    String? reviewComment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnnotationTrack(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      videoAssetId: videoAssetId ?? this.videoAssetId,
      labelId: labelId ?? this.labelId,
      status: status ?? this.status,
      annotationType: annotationType ?? this.annotationType,
      reviewStatus: reviewStatus ?? this.reviewStatus,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewComment: reviewComment ?? this.reviewComment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'AnnotationTrack(id=$id, uuid=$uuid, video=$videoAssetId, '
      'label=$labelId, status=$status, type=$annotationType, '
      'review=$reviewStatus)';
}
