class MediaFolder {
  final int id;
  final String datasetId;
  final String path;
  final String name;
  final DateTime createdAt;

  MediaFolder({
    required this.id,
    required this.datasetId,
    required this.path,
    required this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'datasetId': datasetId,
      'path': path,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MediaFolder.fromMap(Map<String, dynamic> map) {
    return MediaFolder(
      id: map['id'],
      datasetId: map['datasetId'],
      path: map['path'],
      name: map['name'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  @override
  String toString() {
    return 'MediaFolder(id: $id, datasetId: $datasetId, path: $path, name: $name, createdAt: $createdAt)';
  }
}
