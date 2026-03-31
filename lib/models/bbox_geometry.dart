import 'dart:convert';
import 'dart:math' as math;

/// A bounding-box geometry with optional rotation, suitable for storage
/// in [TrackKeyframe.geometry] as JSON and for linear interpolation between
/// keyframe positions.
class BboxGeometry {
  final double x;
  final double y;
  final double width;
  final double height;

  /// Rotation in radians (0 = no rotation). Interpolated via shortest-arc.
  final double rotation;

  const BboxGeometry({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.rotation = 0.0,
  });

  static const BboxGeometry zero = BboxGeometry(
    x: 0, y: 0, width: 0, height: 0,
  );

  // -- Serialisation ----------------------------------------------------------

  Map<String, dynamic> toMap() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'rotation': rotation,
  };

  String toJson() => jsonEncode(toMap());

  factory BboxGeometry.fromMap(Map<String, dynamic> map) {
    return BboxGeometry(
      x: (map['x'] as num?)?.toDouble() ?? 0.0,
      y: (map['y'] as num?)?.toDouble() ?? 0.0,
      width: (map['width'] as num?)?.toDouble() ?? 0.0,
      height: (map['height'] as num?)?.toDouble() ?? 0.0,
      rotation: (map['rotation'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory BboxGeometry.fromJson(String json) =>
      BboxGeometry.fromMap(jsonDecode(json) as Map<String, dynamic>);

  // -- Interpolation ----------------------------------------------------------

  /// Linearly interpolate between [a] and [b] at parameter [t] ∈ [0, 1].
  ///
  /// Rotation uses shortest-arc interpolation so that e.g. lerping from
  /// 350° to 10° goes through 0° rather than the long way around.
  static BboxGeometry lerp(BboxGeometry a, BboxGeometry b, double t) {
    return BboxGeometry(
      x: _lerp(a.x, b.x, t),
      y: _lerp(a.y, b.y, t),
      width: _lerp(a.width, b.width, t),
      height: _lerp(a.height, b.height, t),
      rotation: _lerpAngle(a.rotation, b.rotation, t),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// Shortest-arc angle interpolation (radians).
  static double _lerpAngle(double a, double b, double t) {
    double delta = (b - a) % (2 * math.pi);
    if (delta > math.pi) delta -= 2 * math.pi;
    if (delta < -math.pi) delta += 2 * math.pi;
    return a + delta * t;
  }

  // -- Helpers ----------------------------------------------------------------

  double get centerX => x + width / 2;
  double get centerY => y + height / 2;

  double get area => width * height;

  bool get isValid => width > 0 && height > 0;

  BboxGeometry copyWith({
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
  }) {
    return BboxGeometry(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BboxGeometry &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height &&
          rotation == other.rotation;

  @override
  int get hashCode => Object.hash(x, y, width, height, rotation);

  @override
  String toString() =>
      'BboxGeometry(x=${x.toStringAsFixed(1)}, y=${y.toStringAsFixed(1)}, '
      '${width.toStringAsFixed(1)}x${height.toStringAsFixed(1)}, '
      'rot=${(rotation * 180 / math.pi).toStringAsFixed(1)}°)';
}
