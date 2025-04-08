class Label {
  final int? id;
  final int projectId;
  final String name;
  final String color;

  Label({
    this.id,
    required this.projectId,
    required this.name,
    required this.color,
  });

  Label copyWith({
    int? id,
    int? projectId,
    String? name,
    String? color,
  }) {
    return Label(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      name: map['name'] as String,
      color: map['color'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'project_id': projectId,
      'name': name,
      'color': color,
    };
  }

  @override
  String toString() {
    return 'Label(id: $id, projectId: $projectId, name: $name, color: $color)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Label &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          color == other.color &&
          projectId == other.projectId;

  @override
  int get hashCode => name.hashCode ^ color.hashCode ^ projectId.hashCode;
}
