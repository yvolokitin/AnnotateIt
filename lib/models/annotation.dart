import 'package:flutter/material.dart';
import 'dart:convert';

import 'shape/shape.dart';
import 'shape/rect_shape.dart';
import 'shape/polygon_shape.dart';
import 'shape/circle_shape.dart';
import 'shape/rotated_rect_shape.dart';

class Annotation {
  final int? id;
  final int mediaItemId;
  final int? labelId;

  // e.g., 'bbox', 'polygon', 'classification'/'label'
  // Datumaro and CVAT use type = "label" for classification.
  final String annotationType;         
  
  // flexible payload
  final Map<String, dynamic> data;

  final double? confidence;
  final int? annotatorId;
  final String? comment;
  final String? status;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  String? name;
  Color? color;

  Annotation({
    this.id,
    required this.mediaItemId,
    this.labelId,
    required this.annotationType,
    required this.data,
    this.confidence,
    this.annotatorId,
    this.comment,
    this.status,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String toString() {
    return 'Annotation('
      'id: $id, '
      'mediaItemId: $mediaItemId, '
      'labelId: $labelId, '
      'annotationType: $annotationType, '
      'data: $data, '
      'confidence: $confidence, '
      'annotatorId: $annotatorId, '
      'comment: $comment, '
      'status: $status, '
      'version: $version, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'name: $name, '
      'color: ${color?.value.toRadixString(16)})';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'media_item_id': mediaItemId,
      'label_id': labelId,
      'annotation_type': annotationType,
      'data': jsonEncode(data),
      'confidence': confidence,
      'annotator_id': annotatorId,
      'comment': comment,
      'status': status,
      'version': version,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Annotation.fromMap(Map<String, dynamic> map) {
    return Annotation(
      id: map['id'] as int?,
      mediaItemId: map['media_item_id'] as int,
      labelId: map['label_id'] as int?,
      annotationType: map['annotation_type'] as String,
      data: jsonDecode(map['data'] as String),
      confidence: map['confidence'] != null ? (map['confidence'] as num).toDouble() : null,
      annotatorId: map['annotator_id'] as int?,
      comment: map['comment'] as String?,
      status: map['status'] as String?,
      version: map['version'] ?? 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}

extension AnnotationCopy on Annotation {
  Annotation copyWith({
    int? mediaItemId,
    int? labelId,
    String? annotationType,
    Map<String, dynamic>? data,
    double? confidence,
    int? annotatorId,
    String? comment,
    String? status,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    Color? color,
  }) {
    return Annotation(
      id: id,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      labelId: labelId ?? this.labelId,
      annotationType: annotationType ?? this.annotationType,
      data: data ?? this.data,
      confidence: confidence ?? this.confidence,
      annotatorId: annotatorId ?? this.annotatorId,
      comment: comment ?? this.comment,
      status: status ?? this.status,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    )
    ..name = name ?? this.name
    ..color = color ?? this.color;
  }
}

extension AnnotationShapeExt on Annotation {
  /// Returns the shape object from annotation data.
  Shape? get shape {
    switch (annotationType.toLowerCase()) {
      case 'bbox':
        return RectShape.fromJson(data);
      case 'polygon':
        return PolygonShape.fromJson(data);
      case 'circle':
        return CircleShape.fromJson(data);
      case 'rotated_rect':
        return RotatedRectShape.fromJson(data);
      // You can extend easily here for future types
      default:
        return null;
    }
  }

  /// Returns true if annotation has a reviewer comment
  bool get hasComment => comment != null && comment!.trim().isNotEmpty;

  /// Returns true if annotation has status info
  bool get hasStatus => status != null && status!.trim().isNotEmpty;

  /// Convenience: Returns human readable summary
  String get summary => '[$annotationType] '
      '${hasStatus ? "Status: $status, " : ""}'
      '${hasComment ? "Comment: ${comment!}" : ""}';
}
