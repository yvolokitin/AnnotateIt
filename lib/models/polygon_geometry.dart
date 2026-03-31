import 'dart:convert';
import 'dart:math' as math;

/// Quality/confidence tier for polygon interpolation. Derived from vertex
/// count compatibility and geometric similarity between source and target.
enum InterpolationQuality {
  /// Vertex counts match or are very close — interpolation is reliable.
  high,

  /// Vertex counts differ moderately — resampled to match, acceptable result.
  medium,

  /// Vertex counts differ significantly or shapes are very different —
  /// the interpolation is speculative, user should verify.
  low,
}

/// A closed polygon defined as an ordered list of 2D vertices.
///
/// Stored in [TrackKeyframe.geometry] as JSON with a `"points"` key
/// containing a flat `[x0, y0, x1, y1, …]` list, plus an optional
/// `"closed"` boolean (default true).
class PolygonGeometry {
  final List<Point2D> vertices;
  final bool closed;

  const PolygonGeometry({required this.vertices, this.closed = true});

  static const PolygonGeometry empty =
      PolygonGeometry(vertices: []);

  int get vertexCount => vertices.length;
  bool get isValid => vertices.length >= 3;

  // -- Serialisation ----------------------------------------------------------

  Map<String, dynamic> toMap() {
    final flat = <double>[];
    for (final v in vertices) {
      flat.add(v.x);
      flat.add(v.y);
    }
    return {'points': flat, 'closed': closed};
  }

  String toJson() => jsonEncode(toMap());

  factory PolygonGeometry.fromMap(Map<String, dynamic> map) {
    final raw = map['points'] as List<dynamic>? ?? [];
    final flat = raw.map((e) => (e as num).toDouble()).toList();
    final verts = <Point2D>[];
    for (int i = 0; i + 1 < flat.length; i += 2) {
      verts.add(Point2D(flat[i], flat[i + 1]));
    }
    return PolygonGeometry(
      vertices: verts,
      closed: (map['closed'] as bool?) ?? true,
    );
  }

  factory PolygonGeometry.fromJson(String json) =>
      PolygonGeometry.fromMap(jsonDecode(json) as Map<String, dynamic>);

  // -- Resampling -------------------------------------------------------------

  /// Resample the polygon to exactly [targetCount] vertices by distributing
  /// them uniformly along the polygon's perimeter.
  PolygonGeometry resample(int targetCount) {
    if (targetCount <= 0 || vertices.isEmpty) return empty;
    if (vertices.length == targetCount) return this;
    if (vertices.length == 1) {
      return PolygonGeometry(
        vertices: List.filled(targetCount, vertices.first),
        closed: closed,
      );
    }

    final lengths = _edgeLengths();
    final totalLen = lengths.fold(0.0, (s, l) => s + l);
    if (totalLen == 0) {
      return PolygonGeometry(
        vertices: List.filled(targetCount, vertices.first),
        closed: closed,
      );
    }

    final result = <Point2D>[];
    final step = totalLen / targetCount;
    double accumulated = 0;
    int edgeIdx = 0;
    double edgeProgress = 0;

    for (int i = 0; i < targetCount; i++) {
      final target = i * step;

      while (edgeIdx < lengths.length - 1 &&
          accumulated + lengths[edgeIdx] - edgeProgress < target - accumulated) {
        accumulated += lengths[edgeIdx] - edgeProgress;
        edgeIdx++;
        edgeProgress = 0;
      }

      final remain = target - accumulated;
      final edgeLen = lengths[edgeIdx];
      final t = edgeLen > 0 ? (edgeProgress + remain) / edgeLen : 0.0;
      final clamped = t.clamp(0.0, 1.0);

      final a = vertices[edgeIdx];
      final b = vertices[(edgeIdx + 1) % vertices.length];
      result.add(Point2D.lerp(a, b, clamped));

      edgeProgress += remain;
      accumulated = target;
    }

    return PolygonGeometry(vertices: result, closed: closed);
  }

  List<double> _edgeLengths() {
    final lens = <double>[];
    for (int i = 0; i < vertices.length; i++) {
      final next = (i + 1) % vertices.length;
      lens.add(vertices[i].distanceTo(vertices[next]));
    }
    return lens;
  }

  // -- Interpolation ----------------------------------------------------------

  /// Linearly interpolate between two polygons at parameter [t] ∈ [0, 1].
  ///
  /// If vertex counts differ, both polygons are resampled to the maximum
  /// vertex count first. Returns a quality rating based on how much
  /// resampling was needed.
  static PolygonLerpResult lerp(PolygonGeometry a, PolygonGeometry b, double t) {
    if (a.vertices.isEmpty && b.vertices.isEmpty) {
      return const PolygonLerpResult(
        polygon: PolygonGeometry.empty,
        quality: InterpolationQuality.high,
      );
    }

    final quality = assessQuality(a.vertexCount, b.vertexCount);

    final targetN = math.max(a.vertexCount, b.vertexCount);
    final ra = a.vertexCount == targetN ? a : a.resample(targetN);
    final rb = b.vertexCount == targetN ? b : b.resample(targetN);

    final result = <Point2D>[];
    for (int i = 0; i < targetN; i++) {
      result.add(Point2D.lerp(ra.vertices[i], rb.vertices[i], t));
    }

    return PolygonLerpResult(
      polygon: PolygonGeometry(vertices: result, closed: a.closed || b.closed),
      quality: quality,
    );
  }

  /// Assess interpolation quality from vertex count difference.
  static InterpolationQuality assessQuality(int countA, int countB) {
    if (countA == 0 || countB == 0) return InterpolationQuality.low;
    final ratio = math.min(countA, countB) / math.max(countA, countB);
    if (ratio >= 0.9) return InterpolationQuality.high;
    if (ratio >= 0.5) return InterpolationQuality.medium;
    return InterpolationQuality.low;
  }

  // -- Helpers ----------------------------------------------------------------

  double get perimeter {
    if (vertices.length < 2) return 0;
    return _edgeLengths().fold(0.0, (s, l) => s + l);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PolygonGeometry &&
          closed == other.closed &&
          _verticesEqual(other.vertices);

  bool _verticesEqual(List<Point2D> other) {
    if (vertices.length != other.length) return false;
    for (int i = 0; i < vertices.length; i++) {
      if (vertices[i] != other[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(closed, Object.hashAll(vertices));

  @override
  String toString() =>
      'PolygonGeometry(${vertices.length} vertices, '
      'closed=$closed)';
}

/// Result of polygon interpolation, including the quality rating.
class PolygonLerpResult {
  final PolygonGeometry polygon;
  final InterpolationQuality quality;

  const PolygonLerpResult({required this.polygon, required this.quality});
}

/// Simple 2D point with lerp support.
class Point2D {
  final double x;
  final double y;

  const Point2D(this.x, this.y);

  static Point2D lerp(Point2D a, Point2D b, double t) =>
      Point2D(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);

  double distanceTo(Point2D other) {
    final dx = other.x - x;
    final dy = other.y - y;
    return math.sqrt(dx * dx + dy * dy);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Point2D && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x, $y)';
}
