import 'dart:ui';

class AnnotationRect {
  Rect rect;
  String label;
  double opacity;

  AnnotationRect({
    required this.rect,
    this.label = '',
    this.opacity = 0.2,
  });

  AnnotationRect copyWith({
    Rect? rect,
    String? label,
    double? opacity,
  }) {
    return AnnotationRect(
      rect: rect ?? this.rect,
      label: label ?? this.label,
      opacity: opacity ?? this.opacity,
    );
  }
}

class Label {
  final String name;
  final String color; // e.g. "#FF0000"

  Label({required this.name, required this.color});
}
