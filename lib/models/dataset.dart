class Dataset {
  final String id;
  final int projectId;
  final String name;
  final String description;
  final DateTime createdAt;

  Dataset({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Dataset.fromMap(Map<String, dynamic> map) {
    return Dataset(
      id: map['id'],
      projectId: map['projectId'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Dataset copyWith({
    String? id,
    int? projectId,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return Dataset(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Dataset(id: $id, projectId: $projectId, name: $name, description: $description, createdAt: $createdAt)';
  }
}
