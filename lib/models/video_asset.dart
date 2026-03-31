/// A source video file registered in the project, with its probed metadata.
class VideoAsset {
  final int? id;
  final String uuid;
  final int? mediaItemId;
  final int projectId;
  final String filePath;
  final String fileName;
  final int width;
  final int height;
  final double durationSec;
  final double fpsNominal;
  final int frameCountEstimate;
  final String codec;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VideoAsset({
    this.id,
    required this.uuid,
    this.mediaItemId,
    required this.projectId,
    required this.filePath,
    required this.fileName,
    this.width = 0,
    this.height = 0,
    this.durationSec = 0.0,
    this.fpsNominal = 0.0,
    this.frameCountEstimate = 0,
    this.codec = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'uuid': uuid,
    'media_item_id': mediaItemId,
    'project_id': projectId,
    'file_path': filePath,
    'file_name': fileName,
    'width': width,
    'height': height,
    'duration_sec': durationSec,
    'fps_nominal': fpsNominal,
    'frame_count_estimate': frameCountEstimate,
    'codec': codec,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory VideoAsset.fromMap(Map<String, dynamic> map) {
    return VideoAsset(
      id: map['id'] as int?,
      uuid: map['uuid'] as String,
      mediaItemId: map['media_item_id'] as int?,
      projectId: map['project_id'] as int,
      filePath: map['file_path'] as String,
      fileName: map['file_name'] as String,
      width: (map['width'] as int?) ?? 0,
      height: (map['height'] as int?) ?? 0,
      durationSec: (map['duration_sec'] as num?)?.toDouble() ?? 0.0,
      fpsNominal: (map['fps_nominal'] as num?)?.toDouble() ?? 0.0,
      frameCountEstimate: (map['frame_count_estimate'] as int?) ?? 0,
      codec: (map['codec'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  VideoAsset copyWith({
    int? id,
    String? uuid,
    int? mediaItemId,
    int? projectId,
    String? filePath,
    String? fileName,
    int? width,
    int? height,
    double? durationSec,
    double? fpsNominal,
    int? frameCountEstimate,
    String? codec,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VideoAsset(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      projectId: projectId ?? this.projectId,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      width: width ?? this.width,
      height: height ?? this.height,
      durationSec: durationSec ?? this.durationSec,
      fpsNominal: fpsNominal ?? this.fpsNominal,
      frameCountEstimate: frameCountEstimate ?? this.frameCountEstimate,
      codec: codec ?? this.codec,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'VideoAsset(id=$id, uuid=$uuid, $fileName, '
      '${width}x$height, ${durationSec}s, ${fpsNominal}fps)';
}
