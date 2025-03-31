enum MediaType { image, video }

class MediaItem {
  final String? id;
  final String datasetId;
  final String filePath;
  final MediaType type;

  final DateTime uploadDate;
  final String owner;
  final String? lastAnnotator;
  final DateTime? lastAnnotatedDate;

  // Only for videos
  final int? numberOfFrames;

  MediaItem({
    this.id,
    required this.datasetId,
    required this.filePath,
    required this.type,
    required this.uploadDate,
    required this.owner,
    this.lastAnnotator,
    this.lastAnnotatedDate,
    this.numberOfFrames,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'datasetId': datasetId,
      'filePath': filePath,
      'type': type.name,
      'uploadDate': uploadDate.toIso8601String(),
      'owner': owner,
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
      type: MediaType.values.firstWhere((e) => e.name == map['type']),
      uploadDate: DateTime.parse(map['uploadDate']),
      owner: map['owner'],
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
      'type: ${type.name}, '
      'uploadDate: ${uploadDate.toIso8601String()}, '
      'owner: $owner, '
      'lastAnnotator: $lastAnnotator, '
      'lastAnnotatedDate: ${lastAnnotatedDate?.toIso8601String()}, '
      'numberOfFrames: $numberOfFrames'
      ')';
  }

}
