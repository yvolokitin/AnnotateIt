enum MediaType { image, video }

class MediaItem {
  final int? id;
  final String uuid;
  final String datasetId;
  final String filePath;
  final String extension;
  final MediaType type;
  final int? width;
  final int? height;
  final double? duration;
  final double? fps;
  final String? source;
  final DateTime uploadDate;
  final int ownerId;
  final String? lastAnnotator;
  final DateTime? lastAnnotatedDate;
  final int? numberOfFrames;

  MediaItem({
    this.id,
    required this.uuid,
    required this.datasetId,
    required this.filePath,
    required this.extension,
    required this.type,
    this.width,
    this.height,
    this.duration,
    this.fps,
    this.source,
    required this.uploadDate,
    required this.ownerId,
    this.lastAnnotator,
    this.lastAnnotatedDate,
    this.numberOfFrames,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'datasetId': datasetId,
      'filePath': filePath,
      'extension': extension,
      'type': type.name,
      'width': width,
      'height': height,
      'duration': duration,
      'fps': fps,
      'source': source,
      'uploadDate': uploadDate.toIso8601String(),
      'owner_id': ownerId,
      'lastAnnotator': lastAnnotator,
      'lastAnnotatedDate': lastAnnotatedDate?.toIso8601String(),
      'numberOfFrames': numberOfFrames,
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'],
      uuid: map['uuid'],
      datasetId: map['datasetId'],
      filePath: map['filePath'],
      extension: map['extension'],
      type: MediaType.values.firstWhere((e) => e.name == map['type']),
      width: map['width'],
      height: map['height'],
      duration: (map['duration'] as num?)?.toDouble(),
      fps: (map['fps'] as num?)?.toDouble(),
      source: map['source'],
      uploadDate: DateTime.parse(map['uploadDate']),
      ownerId: map['owner_id'],
      lastAnnotator: map['lastAnnotator'],
      lastAnnotatedDate: map['lastAnnotatedDate'] != null
          ? DateTime.parse(map['lastAnnotatedDate'])
          : null,
      numberOfFrames: map['numberOfFrames'],
    );
  }

  @override
  String toString() {
    return 'MediaItem('
        'id: $id, '
        'uuid: $uuid, '
        'datasetId: $datasetId, '
        'filePath: $filePath, '
        'extension: $extension, '
        'type: ${type.name}, '
        'width: $width, '
        'height: $height, '
        'duration: $duration, '
        'fps: $fps, '
        'source: $source, '
        'uploadDate: ${uploadDate.toIso8601String()}, '
        'ownerId: $ownerId, '
        'lastAnnotator: $lastAnnotator, '
        'lastAnnotatedDate: ${lastAnnotatedDate?.toIso8601String()}, '
        'numberOfFrames: $numberOfFrames, '
      ')';
  }

  bool get isVideo => type == MediaType.video;
  bool get isImage => type == MediaType.image;

  MediaItem updateAnnotationSummary({
    required int newCount,
    String? newLabel,
    String? newColor,
  }) {
    return MediaItem(
      id: id,
      uuid: uuid,
      datasetId: datasetId,
      filePath: filePath,
      extension: extension,
      type: type,
      width: width,
      height: height,
      duration: duration,
      fps: fps,
      source: source,
      uploadDate: uploadDate,
      ownerId: ownerId,
      lastAnnotator: lastAnnotator,
      lastAnnotatedDate: lastAnnotatedDate,
      numberOfFrames: numberOfFrames,
    );
  }
}
