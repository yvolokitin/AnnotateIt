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
  final Shape shape; // Changed: Now holds a Shape object directly
  final double? confidence;
  final int? annotatorId;
  final String? comment;
  final String? status;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  Annotation({
    this.id,
    required this.mediaItemId,
    this.labelId,
    required this.shape, // Changed: Expects a Shape object
    this.confidence,
    this.annotatorId,
    this.comment,
    this.status,
    this.version = 1,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    String shapeType;
    if (shape is RectShape) {
      shapeType = 'bbox';
    } else if (shape is PolygonShape) {
      shapeType = 'polygon';
    } else if (shape is CircleShape) {
      shapeType = 'circle';
    } else if (shape is RotatedRectShape) {
      shapeType = 'rotated_rect';
    } else {
      throw Exception('Unknown shape type: ${shape.runtimeType}');
    }

    return {
      'id': id,
      'media_item_id': mediaItemId,
      'label_id': labelId,
      'shape_type': shapeType, // Added shape_type field
      'shape_data': shape.toJson(), // Serialize shape object
      'confidence': confidence,
      'annotator_id': annotatorId,
      'comment': comment,
      'status': status,
      'version': version,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Annotation.fromJson(Map<String, dynamic> map) {
    final shapeType = map['shape_type'] as String?;
    final shapeData = map['shape_data'] as Map<String, dynamic>?;

    if (shapeType == null || shapeData == null) {
      throw FormatException("Missing shape_type or shape_data in Annotation JSON");
    }

    Shape decodedShape;
    switch (shapeType.toLowerCase()) {
      case 'bbox':
        decodedShape = RectShape.fromJson(shapeData);
        break;
      case 'polygon':
        decodedShape = PolygonShape.fromJson(shapeData);
        break;
      case 'circle':
        decodedShape = CircleShape.fromJson(shapeData);
        break;
      case 'rotated_rect':
        decodedShape = RotatedRectShape.fromJson(shapeData);
        break;
      default:
        throw Exception('Unknown shape_type: $shapeType');
    }

    return Annotation(
      id: map['id'] as int?,
      mediaItemId: map['media_item_id'] as int,
      labelId: map['label_id'] as int?,
      shape: decodedShape, // Assign decoded shape
      confidence: map['confidence'] != null ? (map['confidence'] as num).toDouble() : null,
      annotatorId: map['annotator_id'] as int?,
      comment: map['comment'] as String?,
      status: map['status'] as String?,
      version: map['version'] ?? 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  /// Returns true if annotation has a reviewer comment
  bool get hasComment => comment != null && comment!.trim().isNotEmpty;

  /// Returns true if annotation has status info
  bool get hasStatus => status != null && status!.trim().isNotEmpty;

  /// Convenience: Returns human readable summary
  String get summary {
    String shapeTypeStr = 'unknown_shape';
    if (shape is RectShape) shapeTypeStr = 'bbox';
    if (shape is PolygonShape) shapeTypeStr = 'polygon';
    if (shape is CircleShape) shapeTypeStr = 'circle';
    if (shape is RotatedRectShape) shapeTypeStr = 'rotated_rect';

    return '[$shapeTypeStr] '
      '${hasStatus ? "Status: $status, " : ""}'
      '${hasComment ? "Comment: ${comment!}" : ""}';
  }
}
