import 'package:flutter/material.dart';

class Label {
  final int? id;
  final int projectId;
  final String name;
  final String color;
  final String? description;
  final DateTime createdAt;

  Label({
    this.id,
    required this.projectId,
    required this.name,
    required this.color,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Label copyWith({
    int? id,
    int? projectId,
    String? name,
    String? color,
    String? description,
    DateTime? createdAt,
  }) {
    return Label(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      color: color ?? this.color,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      id: map['id'] as int?,
      projectId: map['project_id'] as int,
      name: map['name'] as String,
      color: map['color'] as String,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'project_id': projectId,
      'name': name,
      'color': color,
      if (description != null) 'description': description,
      'createdAt': createdAt.toIso8601String(),
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

extension LabelColorParser on Label {
  Color toColor() {
    String hexColor = color.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor"; // Add opacity if missing
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
