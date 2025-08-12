import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'sam_web_ffi.dart';

/// SAM (Segment Anything) segmentation service API.
///
/// NOTE:
/// - This implementation provides a functional API and a content-aware fallback
///   so the end-to-end flow works immediately and produces variable masks.
/// - It is structured to allow plugging a real MobileSAM ONNX encoder/decoder
///   inference later without changing the app code. The real inference part
///   should replace the fallback implementation below.
class SamSegmentationService {
  static final SamSegmentationService _instance = SamSegmentationService._internal();
  factory SamSegmentationService() => _instance;
  SamSegmentationService._internal();

  bool _initialized = false;
  bool _closed = false;
  bool _webSamReady = false;

  /// Whether real SAM inference is available on this platform/build.
  /// On Web, we use onnxruntime-web via JS; otherwise fallback.
  bool get hasRealSamSupport => kIsWeb && _webSamReady;

  Future<void> initialize() async {
    // Allow re-initialization after a previous close()
    if (_initialized && !_closed) return;
    _initialized = true;
    _closed = false;

    // Initialize Web SAM (onnxruntime-web) if available
    if (kIsWeb) {
      try {
        _webSamReady = await samInit(
          encoderUrl: 'assets/assets/models_sam/mobile_sam.encoder.onnx',
          decoderUrl: 'assets/assets/models_sam/mobile_sam.decoder.onnx',
        );
      } catch (_) {
        _webSamReady = false;
      }
    }
  }

  Future<void> close() async {
    _closed = true;
  }

  /// Generates a segmentation polygon for a single-point prompt.
  ///
  /// If a real SAM runtime is not available, a content-aware segmentation
  /// (seeded region growing + contour extraction) is used as a fallback.
  ///
  /// Returns a list of Offsets in image coordinate space (not canvas space),
  /// suitable for storing as a 'polygon' annotation (close the polygon by
  /// repeating the first point at the end).
  Future<List<Offset>> generateMaskPolygon({
    required ui.Image image,
    required Offset tapPoint,
  }) async {
    assert(_initialized && !_closed);

    if (hasRealSamSupport) {
      try {
        final prep = await _preprocessImageTo1024(image);
        if (prep == null) return _fallbackEllipse(image: image, center: tapPoint);
        final Float32List nchw = prep.nchw;
        final double scale = prep.scale;
        final double tapX1024 = tapPoint.dx * scale;
        final double tapY1024 = tapPoint.dy * scale;

        final mask = await samRun(
          nchw,
          image.width,
          image.height,
          tapX1024,
          tapY1024,
        );
        if (mask == null || mask.length != 256 * 256) {
          // Fallback to heuristic
          return _fallbackEllipse(image: image, center: tapPoint);
        }

        // Build low-res grid (256x256) mapping to 1024 space via step=4
        final gh = 256;
        final gw = 256;
        int idx = 0;
        final gridMask = List.generate(gh, (_) => List<bool>.filled(gw, false));
        for (int y = 0; y < gh; y++) {
          for (int x = 0; x < gw; x++) {
            gridMask[y][x] = mask[idx++] != 0;
          }
        }
        final lowresGrid = _MaskGrid(
          m: gridMask,
          gw: gw,
          gh: gh,
          step: 4, // 256 -> 1024
          width: 1024,
          height: 1024,
          totalOn: mask.where((e) => e != 0).length,
        );

        // Extract polygon in 1024 space and scale back to original image coords
        final poly1024 = _marchingSquaresPolygon(lowresGrid);
        if (poly1024.isEmpty) return _fallbackEllipse(image: image, center: tapPoint);

        final inv = 1.0 / scale;
        final scaled = poly1024.map((p) => Offset(p.dx * inv, p.dy * inv)).toList();
        final simplified = _rdpSimplify(scaled, epsilon: 1.5);
        final clamped = simplified.map((p) => Offset(
              p.dx.clamp(0.0, image.width.toDouble()),
              p.dy.clamp(0.0, image.height.toDouble()),
            )).toList();
        if (clamped.isNotEmpty && (clamped.first - clamped.last).distance > 0.01) {
          clamped.add(clamped.first);
        }
        return clamped;
      } catch (_) {
        // Fall through to heuristic fallback
      }
    }

    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (bytes == null) return _fallbackEllipse(image: image, center: tapPoint);

      final mask = _regionGrowMask(
        width: image.width,
        height: image.height,
        rgbaBytes: bytes.buffer.asUint8List(),
        tapPoint: tapPoint,
      );

      if (mask == null || mask.totalOn < 12) {
        return _fallbackEllipse(image: image, center: tapPoint);
      }

      final polygon = _marchingSquaresPolygon(mask);
      if (polygon.isEmpty) {
        return _fallbackEllipse(image: image, center: tapPoint);
      }

      final simplified = _rdpSimplify(polygon, epsilon: 1.5);

      // Ensure closed and clamped to image bounds
      final clamped = simplified.map((p) => Offset(
            p.dx.clamp(0.0, image.width.toDouble()),
            p.dy.clamp(0.0, image.height.toDouble()),
          )).toList();
      if (clamped.isNotEmpty && (clamped.first - clamped.last).distance > 0.01) {
        clamped.add(clamped.first);
      }
      return clamped;
    } catch (_) {
      return _fallbackEllipse(image: image, center: tapPoint);
    }
  }

  /// Preprocess ui.Image into MobileSAM NCHW (1x3x1024x1024) Float32 input.
  /// Returns the tensor and the scale factor from original -> 1024 space.
  Future<_Preprocessed?> _preprocessImageTo1024(ui.Image image) async {
    final w = image.width;
    final h = image.height;
    final longest = math.max(w, h).toDouble();
    if (longest <= 0) return null;
    final scale = 1024.0 / longest;
    final tw = math.max(1, (w * scale).round());
    final th = math.max(1, (h * scale).round());

    final bd = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (bd == null) return null;
    final src = bd.buffer.asUint8List();

    // Means and stds for SAM/MobileSAM
    const mr = 123.675, mg = 116.28, mb = 103.53;
    const sr = 58.395, sg = 57.12, sb = 57.375;

    final out = Float32List(3 * 1024 * 1024);

    // Helper to read RGBA at (x,y)
    int idx(int x, int y) => (y * w + x) * 4;

    // Bilinear resize into the top-left (tw x th) region of the 1024 canvas.
    for (int y = 0; y < th; y++) {
      final sy = (y + 0.5) / scale - 0.5;
      int y0 = sy.floor();
      int y1 = y0 + 1;
      final wy1 = sy - y0;
      final wy0 = 1.0 - wy1;
      if (y0 < 0) { y0 = 0; }
      if (y1 >= h) { y1 = h - 1; }

      for (int x = 0; x < tw; x++) {
        final sx = (x + 0.5) / scale - 0.5;
        int x0 = sx.floor();
        int x1 = x0 + 1;
        final wx1 = sx - x0;
        final wx0 = 1.0 - wx1;
        if (x0 < 0) { x0 = 0; }
        if (x1 >= w) { x1 = w - 1; }

        final i00 = idx(x0, y0);
        final i10 = idx(x1, y0);
        final i01 = idx(x0, y1);
        final i11 = idx(x1, y1);

        double r = 0, g = 0, b = 0;
        // Top row
        final r00 = src[i00].toDouble();
        final g00 = src[i00 + 1].toDouble();
        final b00 = src[i00 + 2].toDouble();
        final r10 = src[i10].toDouble();
        final g10 = src[i10 + 1].toDouble();
        final b10 = src[i10 + 2].toDouble();
        // Bottom row
        final r01 = src[i01].toDouble();
        final g01 = src[i01 + 1].toDouble();
        final b01 = src[i01 + 2].toDouble();
        final r11 = src[i11].toDouble();
        final g11 = src[i11 + 1].toDouble();
        final b11 = src[i11 + 2].toDouble();

        final r0 = r00 * wx0 + r10 * wx1;
        final g0 = g00 * wx0 + g10 * wx1;
        final b0 = b00 * wx0 + b10 * wx1;
        final r1 = r01 * wx0 + r11 * wx1;
        final g1 = g01 * wx0 + g11 * wx1;
        final b1 = b01 * wx0 + b11 * wx1;

        r = r0 * wy0 + r1 * wy1;
        g = g0 * wy0 + g1 * wy1;
        b = b0 * wy0 + b1 * wy1;

        final oy = y;
        final ox = x;
        final base = oy * 1024 + ox;
        out[0 * 1024 * 1024 + base] = ((r - mr) / sr).toDouble();
        out[1 * 1024 * 1024 + base] = ((g - mg) / sg).toDouble();
        out[2 * 1024 * 1024 + base] = ((b - mb) / sb).toDouble();
      }
    }

    // The remaining padded region stays zeros (which equals zero after normalization pad in SAM pipeline)
    return _Preprocessed(nchw: out, scale: scale);
  }

  /// ========================= CONTENT-AWARE FALLBACK =========================
  /// Region growing on a downsampled grid + Marching Squares contour extraction


  _MaskGrid? _regionGrowMask({
    required int width,
    required int height,
    required Uint8List rgbaBytes,
    required Offset tapPoint,
  }) {
    // Choose a sampling step so the longest side ~= 256 cells
    final longest = math.max(width, height).toDouble();
    final target = 256.0;
    final step = math.max(1, (longest / target).floor());
    final gw = ((width + step - 1) / step).floor();
    final gh = ((height + step - 1) / step).floor();

    List<List<bool>> mask = List.generate(gh, (_) => List<bool>.filled(gw, false));

    // Seed in grid coordinates
    final sx = (tapPoint.dx / step).clamp(0, (gw - 1).toDouble()).floor();
    final sy = (tapPoint.dy / step).clamp(0, (gh - 1).toDouble()).floor();

    // Helper to read RGB at original pixel coordinates
    int _idx(int x, int y) => (y * width + x) * 4;
    int _clampi(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);
    List<int> _rgbAtGrid(int gx, int gy) {
      final px = _clampi(gx * step, 0, width - 1);
      final py = _clampi(gy * step, 0, height - 1);
      final i = _idx(px, py);
      final r = rgbaBytes[i];
      final g = rgbaBytes[i + 1];
      final b = rgbaBytes[i + 2];
      return [r, g, b];
    }

    // Seed color and dynamic region stats
    final seed = _rgbAtGrid(sx, sy);
    double meanR = seed[0].toDouble();
    double meanG = seed[1].toDouble();
    double meanB = seed[2].toDouble();

    // BFS queue
    final qx = <int>[];
    final qy = <int>[];

    mask[sy][sx] = true;
    qx.add(sx);
    qy.add(sy);

    int count = 1;
    final maxCells = (gw * gh * 0.18).floor().clamp(200, 1000000); // up to ~18% of grid
    double baseThr = 22.0; // starting threshold (color distance to mean)
    double maxThr = 62.0;  // cap threshold

    // 8-neighborhood
    const dx8 = [-1, 0, 1, -1, 1, -1, 0, 1];
    const dy8 = [-1, -1, -1, 0, 0, 1, 1, 1];

    bool _inside(int x, int y) => x >= 0 && y >= 0 && x < gw && y < gh;

    double _distToMean(List<int> c) {
      final dr = c[0] - meanR;
      final dg = c[1] - meanG;
      final db = c[2] - meanB;
      return math.sqrt(dr * dr + dg * dg + db * db);
    }

    while (qx.isNotEmpty) {
      final x = qx.removeLast();
      final y = qy.removeLast();

      // Update mean towards current pixel (online mean)
      final c = _rgbAtGrid(x, y);
      final w = 1.0 / count;
      meanR = meanR + (c[0] - meanR) * w;
      meanG = meanG + (c[1] - meanG) * w;
      meanB = meanB + (c[2] - meanB) * w;

      // Gradually relax threshold as region grows
      final currThr = (baseThr + (maxThr - baseThr) * (count / maxCells)).clamp(baseThr, maxThr);

      for (int k = 0; k < 8; k++) {
        final nx = x + dx8[k];
        final ny = y + dy8[k];
        if (!_inside(nx, ny) || mask[ny][nx]) continue;
        final col = _rgbAtGrid(nx, ny);
        if (_distToMean(col) <= currThr) {
          mask[ny][nx] = true;
          qx.add(nx);
          qy.add(ny);
          count++;
          if (count >= maxCells) break;
        }
      }
      if (count >= maxCells) break;
    }

    // Small-region guard
    if (count < 16) return null;

    return _MaskGrid(
      m: mask,
      gw: gw,
      gh: gh,
      step: step,
      width: width,
      height: height,
      totalOn: count,
    );
  }

  /// Marching Squares on the coarse mask grid to get a polygon in image coords
  List<Offset> _marchingSquaresPolygon(_MaskGrid grid) {
    final gw = grid.gw;
    final gh = grid.gh;

    // Represent edge midpoints with integer coordinates scaled by 2 to avoid
    // floating point matching issues.
    List<List<int>> segments = [];

    int _key(int x, int y) => (x << 16) ^ y; // pack two 16-bit ints

    // Iterate each cell
    for (int y = 0; y < gh - 1; y++) {
      for (int x = 0; x < gw - 1; x++) {
        final tl = grid.m[y][x] ? 1 : 0;
        final tr = grid.m[y][x + 1] ? 1 : 0;
        final br = grid.m[y + 1][x + 1] ? 1 : 0;
        final bl = grid.m[y + 1][x] ? 1 : 0;
        final idx = (tl << 3) | (tr << 2) | (br << 1) | bl;
        if (idx == 0 || idx == 15) continue;

        // Edge midpoints in doubled grid coordinates
        final top = [2 * x + 1, 2 * y];
        final right = [2 * x + 2, 2 * y + 1];
        final bottom = [2 * x + 1, 2 * y + 2];
        final left = [2 * x, 2 * y + 1];

        // Cases (no ambiguity handling beyond simple splits)
        switch (idx) {
          case 1: // 0001
            segments.add([_key(left[0], left[1]), _key(bottom[0], bottom[1])]);
            break;
          case 2: // 0010
            segments.add([_key(bottom[0], bottom[1]), _key(right[0], right[1])]);
            break;
          case 3: // 0011
            segments.add([_key(left[0], left[1]), _key(right[0], right[1])]);
            break;
          case 4: // 0100
            segments.add([_key(top[0], top[1]), _key(right[0], right[1])]);
            break;
          case 5: // 0101 (ambiguous) -> split into two small segments
            segments.add([_key(left[0], left[1]), _key(top[0], top[1])]);
            segments.add([_key(bottom[0], bottom[1]), _key(right[0], right[1])]);
            break;
          case 6: // 0110
            segments.add([_key(top[0], top[1]), _key(bottom[0], bottom[1])]);
            break;
          case 7: // 0111
            segments.add([_key(left[0], left[1]), _key(top[0], top[1])]);
            break;
          case 8: // 1000
            segments.add([_key(left[0], left[1]), _key(top[0], top[1])]);
            break;
          case 9: // 1001
            segments.add([_key(top[0], top[1]), _key(bottom[0], bottom[1])]);
            break;
          case 10: // 1010 (ambiguous)
            segments.add([_key(left[0], left[1]), _key(bottom[0], bottom[1])]);
            segments.add([_key(top[0], top[1]), _key(right[0], right[1])]);
            break;
          case 11: // 1011
            segments.add([_key(top[0], top[1]), _key(right[0], right[1])]);
            break;
          case 12: // 1100
            segments.add([_key(left[0], left[1]), _key(right[0], right[1])]);
            break;
          case 13: // 1101
            segments.add([_key(bottom[0], bottom[1]), _key(right[0], right[1])]);
            break;
          case 14: // 1110
            segments.add([_key(left[0], left[1]), _key(bottom[0], bottom[1])]);
            break;
        }
      }
    }

    if (segments.isEmpty) return [];

    // Build adjacency map to chain segments into a loop
    final Map<int, List<int>> adj = {};
    for (final seg in segments) {
      final a = seg[0];
      final b = seg[1];
      adj.putIfAbsent(a, () => []).add(b);
      adj.putIfAbsent(b, () => []).add(a);
    }

    // Find the longest closed loop
    List<int> bestLoop = [];

    final visitedEdge = <String>{};
    for (final start in adj.keys) {
      if ((adj[start]?.length ?? 0) == 0) continue;
      // Try to walk a loop greedily
      int current = start;
      int? prev;
      final path = <int>[];
      for (int steps = 0; steps < segments.length * 2; steps++) {
        path.add(current);
        final neighbors = adj[current]!;
        int? next;
        for (final nb in neighbors) {
          final edgeKey = current < nb ? '$current-$nb' : '$nb-$current';
          if (edgeKey == (prev == null ? '' : (prev! < current ? '${prev!}-$current' : '$current-${prev!}'))) {
            // avoid immediately going back
            continue;
          }
          if (!visitedEdge.contains(edgeKey)) {
            next = nb;
            visitedEdge.add(edgeKey);
            break;
          }
        }
        if (next == null) break;
        prev = current;
        current = next;
        if (current == start) {
          // closed
          if (path.length > bestLoop.length) bestLoop = List<int>.from(path);
          break;
        }
      }
    }

    if (bestLoop.isEmpty) return [];

    // Convert doubled-grid integer coords to image pixel coords
    List<Offset> poly = bestLoop.map((k) {
      final x2 = (k >> 16) & 0xFFFF;
      final y2 = k & 0xFFFF;
      final gx = x2 / 2.0;
      final gy = y2 / 2.0;
      return Offset(grid.gxToX(gx.floor(), sub: gx - gx.floor()), grid.gyToY(gy.floor(), sub: gy - gy.floor()));
    }).toList();

    if (poly.isNotEmpty && (poly.first - poly.last).distance > 0.01) {
      poly.add(poly.first);
    }
    return poly;
  }

  /// Ramer–Douglas–Peucker polyline simplification
  List<Offset> _rdpSimplify(List<Offset> points, {double epsilon = 1.5}) {
    if (points.length < 3) return points;

    double _perpDist(Offset p, Offset a, Offset b) {
      final dx = b.dx - a.dx;
      final dy = b.dy - a.dy;
      if (dx == 0 && dy == 0) return (p - a).distance;
      final t = ((p.dx - a.dx) * dx + (p.dy - a.dy) * dy) / (dx * dx + dy * dy);
      final tClamped = t.clamp(0.0, 1.0);
      final proj = Offset(a.dx + tClamped * dx, a.dy + tClamped * dy);
      return (p - proj).distance;
    }

    List<Offset> _rdp(List<Offset> pts) {
      double dmax = 0.0;
      int index = 0;
      for (int i = 1; i < pts.length - 1; i++) {
        final d = _perpDist(pts[i], pts.first, pts.last);
        if (d > dmax) {
          index = i;
          dmax = d;
        }
      }
      if (dmax > epsilon) {
        final rec1 = _rdp(pts.sublist(0, index + 1));
        final rec2 = _rdp(pts.sublist(index, pts.length));
        return [...rec1.sublist(0, rec1.length - 1), ...rec2];
      } else {
        return [pts.first, pts.last];
      }
    }

    final closed = (points.first - points.last).distance < 1e-6;
    final work = closed ? points.sublist(0, points.length - 1) : points;
    final simplified = _rdp(work);
    if (closed && simplified.isNotEmpty) {
      simplified.add(simplified.first);
    }
    return simplified;
  }

  /// Legacy ellipse fallback retained as a last resort
  List<Offset> _fallbackEllipse({required ui.Image image, required Offset center}) {
    final w = image.width.toDouble();
    final h = image.height.toDouble();

    // Make the size weakly dependent on image dimensions to stay reasonable
    final baseRadius = 0.06 * math.min(w, h); // ~6%
    final rx = baseRadius * 1.25;
    final ry = baseRadius * 0.95;

    final cx = center.dx.clamp(0.0, w);
    final cy = center.dy.clamp(0.0, h);

    const n = 48;
    final points = <Offset>[];
    for (int i = 0; i < n; i++) {
      final t = 2 * math.pi * (i / n);
      final dx = rx * math.cos(t);
      final dy = ry * math.sin(t);
      points.add(Offset(cx + dx, cy + dy));
    }
    if (points.isNotEmpty) points.add(points.first);
    return points;
  }
}


/// Holder for a boolean mask on a coarse grid and metadata for mapping
/// back to original image coordinates.
class _Preprocessed {
  final Float32List nchw;
  final double scale;
  _Preprocessed({required this.nchw, required this.scale});
}

class _MaskGrid {
  final List<List<bool>> m; // [gh][gw]
  final int gw;
  final int gh;
  final int step; // sampling step in source pixels
  final int width;
  final int height;
  final int totalOn;

  _MaskGrid({
    required this.m,
    required this.gw,
    required this.gh,
    required this.step,
    required this.width,
    required this.height,
    required this.totalOn,
  });

  double gxToX(int gx, {double sub = 0.0}) => ((gx + sub) * step).clamp(0, width - 1).toDouble();
  double gyToY(int gy, {double sub = 0.0}) => ((gy + sub) * step).clamp(0, height - 1).toDouble();
}
