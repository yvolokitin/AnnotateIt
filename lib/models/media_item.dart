enum MediaType { image, video }

class MediaItem {
  final String? id;
  final String datasetId; // 👈 Foreign key to Dataset
  final String filePath; // Path to asset or file
  final MediaType type; // image or video

  MediaItem({
    this.id,
    required this.datasetId,
    required this.filePath,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'datasetId': datasetId,
      'filePath': filePath,
      'type': type.name, // 'image' or 'video'
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'],
      datasetId: map['datasetId'],
      filePath: map['filePath'],
      type: MediaType.values.firstWhere((e) => e.name == map['type']),
    );
  }
}
