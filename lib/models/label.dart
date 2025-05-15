class Label {
  final int? id;
  final int projectId;
  final String name;
  final String color;
  final String? description;

  Label({
    this.id,
    required this.projectId,
    required this.name,
    required this.color,
    this.description,
  });

  Label copyWith({
    int? id,
    int? projectId,
    String? name,
    String? color,
    String? description,
  }) {
    return Label(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      name: map['name'] as String,
      color: map['color'] as String,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'project_id': projectId,
      'name': name,
      'color': color,
      if (description != null) 'description': description,
    };
  }

  @override
  String toString() {
    return 'Label(id: $id, projectId: $projectId, name: $name, color: $color, description: $description)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Label &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          color == other.color &&
          projectId == other.projectId &&
          description == other.description;

  @override
  int get hashCode =>
      name.hashCode ^ color.hashCode ^ projectId.hashCode ^ description.hashCode;
}
