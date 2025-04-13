enum MediaType { image, video }

class MediaItem {
  final int? id;
  final String datasetId;
  final String filePath;
  final String extension;
  final MediaType type;
  final DateTime uploadDate;
  final int ownerId; // Foreign key to users(id)
  final String? lastAnnotator; // Could be user ID in future
  final DateTime? lastAnnotatedDate;
  final int? numberOfFrames; // Only for video

  MediaItem({
    this.id,
    required this.datasetId,
    required this.filePath,
    required this.extension,
    required this.type,
    required this.uploadDate,
    required this.ownerId,
    this.lastAnnotator,
    this.lastAnnotatedDate,
    this.numberOfFrames,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'datasetId': datasetId,
      'filePath': filePath,
      'extension': extension,
      'type': type.name,
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
      datasetId: map['datasetId'],
      filePath: map['filePath'],
      extension: map['extension'],
      type: MediaType.values.firstWhere((e) => e.name == map['type']),
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
      'datasetId: $datasetId, '
      'filePath: $filePath, '
      'extension: $extension, '
      'type: ${type.name}, '
      'uploadDate: ${uploadDate.toIso8601String()}, '
      'ownerId: $ownerId, '
      'lastAnnotator: $lastAnnotator, '
      'lastAnnotatedDate: ${lastAnnotatedDate?.toIso8601String()}, '
      'numberOfFrames: $numberOfFrames'
      ')';
  }
}
