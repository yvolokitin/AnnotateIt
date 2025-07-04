import 'package:flutter/material.dart';

class Label {
  final int? id;
  final int labelOrder;
  final int projectId;
  final String name;
  final String color;
  final bool isDefault;
  final String? description;
  final DateTime createdAt;

  Label({
    this.id,
    required this.labelOrder,
    required this.projectId,
    required this.name,
    required this.color,
    this.isDefault = false,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Label copyWith({
    int? id,
    int? labelOrder,
    int? projectId,
    String? name,
    String? color,
    bool? isDefault,
    String? description,
    DateTime? createdAt,
  }) {
    return Label(
      id: id ?? this.id,
      labelOrder: labelOrder ?? this.labelOrder,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Label.fromMap(Map<String, dynamic> map) {
    return Label(
      id: map['id'] as int?,
      labelOrder: map['label_order'] as int,
      projectId: map['project_id'] as int,
      name: map['name'] as String,
      color: map['color'] as String,
      isDefault: map['is_default'] != null ? map['is_default'] == 1 : false,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'label_order': labelOrder,
      'project_id': projectId,
      'name': name,
      'color': color,
      'is_default': isDefault ? 1 : 0,
      if (description != null) 'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Label(id: $id, labelOrder: $labelOrder, projectId: $projectId, name: $name, color: $color, isDefault: $isDefault, description: $description)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Label &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          color == other.color &&
          projectId == other.projectId &&
          description == other.description &&
          isDefault == other.isDefault;

  @override
  int get hashCode =>
      name.hashCode ^
      color.hashCode ^
      projectId.hashCode ^
      description.hashCode ^
      isDefault.hashCode;
}

extension LabelColorParser on Label {
  Color toColor() {
    String hexColor = color.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
