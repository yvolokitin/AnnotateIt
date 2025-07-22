import 'package:flutter/material.dart';

class Label {
  final int id;
  final int labelOrder;
  final int projectId;
  final String name;
  final String color;
  final bool isDefault;
  final String? description;
  final DateTime createdAt;

  Label({
    required this.id,
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
      id: map['id'] as int,
      labelOrder: map['label_order'] as int,
      projectId: map['project_id'] as int,
      name: map['name'] as String,
      color: map['color'] as String,
      isDefault: map['is_default'] != null ? map['is_default'] == 1 : false,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  /// Factory for safe import from user JSON (ignores id and forces projectId + labelOrder)
  factory Label.fromJsonForImport(Map<String, dynamic> map, int projectId, int labelOrder) {
    return Label(
      id: -1, // Always -1 for import
      labelOrder: labelOrder,
      projectId: projectId,
      name: map['name'] as String,
      color: map['color'] as String,
      isDefault: map['is_default'] == true || map['is_default'] == 1,
      description: map['description'] as String?,
      createdAt: map['createdAt'] != null
        ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
        : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    final map = {
      //  Skip id from the toMap() if it's -1
      // This allows the database to auto-generate the ID.
      // 'id': id,
      'label_order': labelOrder,
      'project_id': projectId,
      'name': name,
      'color': color,
      'is_default': isDefault ? 1 : 0,
      if (description != null) 'description': description,
      'createdAt': createdAt.toIso8601String(),
    };

    if (id != -1) {
      map['id'] = id;
    }

    return map;
  }

  @override
  String toString() {
    return 'Label(id: $id, labelOrder: $labelOrder, projectId: $projectId, name: $name, color: $color, isDefault: $isDefault, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Label &&
      runtimeType == other.runtimeType &&
      name == other.name &&
      projectId == other.projectId;
  }

  @override
  int get hashCode => Object.hash(name, projectId);

/*
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
*/
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
