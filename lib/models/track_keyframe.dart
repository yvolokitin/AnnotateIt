import 'dart:convert';

/// A keyframe anchor point within an [AnnotationTrack].
///
/// [geometry] stores the shape data as a JSON string (bbox, polygon, etc.)
/// that can be interpolated between keyframes at non-keyframe positions.
class TrackKeyframe {
  final int? id;
  final int trackId;
  final int frameId;
  final String geometry;
  final double confidence;
  final bool isManual;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrackKeyframe({
    this.id,
    required this.trackId,
    required this.frameId,
    required this.geometry,
    this.confidence = 1.0,
    this.isManual = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'track_id': trackId,
    'frame_id': frameId,
    'geometry': geometry,
    'confidence': confidence,
    'is_manual': isManual ? 1 : 0,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory TrackKeyframe.fromMap(Map<String, dynamic> map) {
    return TrackKeyframe(
      id: map['id'] as int?,
      trackId: map['track_id'] as int,
      frameId: map['frame_id'] as int,
      geometry: map['geometry'] as String,
      confidence: (map['confidence'] as num?)?.toDouble() ?? 1.0,
      isManual: (map['is_manual'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Decode [geometry] into a typed map for direct access to coordinates.
  Map<String, dynamic> get geometryMap =>
      jsonDecode(geometry) as Map<String, dynamic>;

  TrackKeyframe copyWith({
    int? id,
    int? trackId,
    int? frameId,
    String? geometry,
    double? confidence,
    bool? isManual,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrackKeyframe(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      frameId: frameId ?? this.frameId,
      geometry: geometry ?? this.geometry,
      confidence: confidence ?? this.confidence,
      isManual: isManual ?? this.isManual,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'TrackKeyframe(id=$id, track=$trackId, frame=$frameId, '
      'conf=${confidence.toStringAsFixed(2)}, manual=$isManual)';
}
