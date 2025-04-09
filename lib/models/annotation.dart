class Annotation {
  final int? id;
  final String mediaItemId;
  final int labelId;
  final double x;
  final double y;
  final double width;
  final double height;
  final double? confidence;
  final String annotator;
  final DateTime createdAt;

  Annotation({
    this.id,
    required this.mediaItemId,
    required this.labelId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.confidence,
    required this.annotator,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'media_item_id': mediaItemId,
      'label_id': labelId,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'confidence': confidence,
      'annotator': annotator,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Annotation.fromMap(Map<String, dynamic> map) {
    return Annotation(
      id: map['id'],
      mediaItemId: map['media_item_id'],
      labelId: map['label_id'],
      x: map['x'],
      y: map['y'],
      width: map['width'],
      height: map['height'],
      confidence: map['confidence'],
      annotator: map['annotator'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
