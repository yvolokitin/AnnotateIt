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
  final String annotationType; // 'bbox', 'classification', 'segmentation', 'keypoints', etc.
  final Map<String, dynamic> data; // Annotation-specific data stored as JSON
  final double? confidence;
  final int? annotatorId;
  final DateTime createdAt;

  Annotation({
    this.id,
    required this.mediaItemId,
    this.labelId,
    required this.annotationType,
    required this.data,
    this.confidence,
    required this.annotatorId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'media_item_id': mediaItemId,
      'label_id': labelId,
      'annotation_type': annotationType,
      'data': jsonEncode(data),
      'confidence': confidence,
      'annotator_id': annotatorId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Annotation.fromMap(Map<String, dynamic> map) {
    return Annotation(
      id: map['id'],
      mediaItemId: map['media_item_id'],
      labelId: map['label_id'],
      annotationType: map['annotation_type'],
      data: jsonDecode(map['data']),
      confidence: map['confidence'],
      annotatorId: map['annotator_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  @override
  String toString() {
    return 'Annotation(id: \$id, mediaItemId: \$mediaItemId, labelId: \$labelId, '
           'annotationType: \$annotationType, data: \$data, confidence: \$confidence, '
           'annotator_id: \$annotatorId, createdAt: \$createdAt)';
  }
}

extension AnnotationShapeExt on Annotation {
  Shape? get shape {
    switch (annotationType) {
      case 'bbox':
        return RectShape.fromJson(data);
      case 'polygon':
        return PolygonShape.fromJson(data);
      case 'circle':
        return CircleShape.fromJson(data);
      case 'rotated_rect':
        return RotatedRectShape.fromJson(data);      
      default:
        return null;
    }
  }
}
