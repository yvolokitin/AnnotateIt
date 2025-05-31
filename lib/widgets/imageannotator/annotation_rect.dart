import 'dart:ui';
import '../../models/label.dart';

class AnnotationRect {
  Rect rect;
  Label label;
  double opacity;

  AnnotationRect({
    required this.rect,
    required this.label,
    this.opacity = 0.2,
  });

  AnnotationRect copyWith({
    Rect? rect,
    Label? label,
    double? opacity,
  }) {
    return AnnotationRect(
      rect: rect ?? this.rect,
      label: label ?? this.label,
      opacity: opacity ?? this.opacity,
    );
  }
}
