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

        // Improve SAM mask -> binary: use Otsu threshold and keep only the component
        // connected to the tapped point (in 256-grid), then fill holes and smooth.
        final tapGx = (tapX1024 / 4.0).floor().clamp(0, gw - 1).toInt();
        final tapGy = (tapY1024 / 4.0).floor().clamp(0, gh - 1).toInt();
        final _RefinedMask refined = _refineSamMask(
          mask: mask,
          gw: gw,
          gh: gh,
          seedX: tapGx,
          seedY: tapGy,
        );

        final lowresGrid = _MaskGrid(
          m: refined.m,
          gw: gw,
          gh: gh,
          step: 4, // 256 -> 1024
          width: 1024,
          height: 1024,
          totalOn: refined.count,
        );

        // Extract polygon in 1024 space and scale back to original image coords
        final poly1024 = _marchingSquaresPolygon(lowresGrid);
        if (poly1024.isEmpty) return _fallbackEllipse(image: image, center: tapPoint);

        final inv = 1.0 / scale;
        final scaled = poly1024.map((p) => Offset(p.dx * inv, p.dy * inv)).toList();
        final simplified = _rdpSimplifyAdaptive(scaled);
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
      final poly = await _multiScaleFallback(image: image, tapPoint: tapPoint);
      if (poly.isNotEmpty) return poly;
    } catch (_) {}

    // Legacy coarse-grid fallback as last resort
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

      final simplified = _rdpSimplifyAdaptive(polygon);

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

  List<List<bool>> _smoothMask3x3(List<List<bool>> m, int gw, int gh) {
    // Perform closing (dilate -> erode) then opening (erode -> dilate) with 3x3 kernel
    List<List<bool>> _dilate3x3(List<List<bool>> src) {
      final out = List.generate(gh, (_) => List<bool>.filled(gw, false));
      for (int y = 0; y < gh; y++) {
        for (int x = 0; x < gw; x++) {
          bool anyOn = false;
          for (int dy = -1; dy <= 1 && !anyOn; dy++) {
            final yy = y + dy;
            if (yy < 0 || yy >= gh) continue;
            for (int dx = -1; dx <= 1; dx++) {
              final xx = x + dx;
              if (xx < 0 || xx >= gw) continue;
              if (src[yy][xx]) { anyOn = true; break; }
            }
          }
          out[y][x] = anyOn;
        }
      }
      return out;
    }

    List<List<bool>> _erode3x3(List<List<bool>> src) {
      final out = List.generate(gh, (_) => List<bool>.filled(gw, false));
      for (int y = 0; y < gh; y++) {
        for (int x = 0; x < gw; x++) {
          bool allOn = true;
          for (int dy = -1; dy <= 1 && allOn; dy++) {
            final yy = y + dy;
            if (yy < 0 || yy >= gh) { allOn = false; break; }
            for (int dx = -1; dx <= 1; dx++) {
              final xx = x + dx;
              if (xx < 0 || xx >= gw) { allOn = false; break; }
              if (!src[yy][xx]) { allOn = false; break; }
            }
          }
          out[y][x] = allOn;
        }
      }
      return out;
    }

    final d = _dilate3x3(m);
    final c = _erode3x3(d); // closing
    final e = _erode3x3(c);
    final o = _dilate3x3(e); // opening
    return o;
  }

  /// Refine raw 256x256 SAM mask into a clean binary grid keeping the component
  /// connected to the user's tap. Applies Otsu threshold, connected component
  /// selection, hole filling, and light morphology. Returns a boolean grid and
  /// the count of on pixels.
  _RefinedMask _refineSamMask({
    required List<int> mask,
    required int gw,
    required int gh,
    required int seedX,
    required int seedY,
  }) {
    // Convert to 0..255 intensity
    int maxVal = 0;
    for (int i = 0; i < mask.length; i++) {
      final v = mask[i];
      if (v > maxVal) maxVal = v;
    }
    final vals = List<int>.filled(mask.length, 0);
    if (maxVal <= 1) {
      for (int i = 0; i < mask.length; i++) {
        vals[i] = (mask[i] * 255).clamp(0, 255);
      }
    } else {
      for (int i = 0; i < mask.length; i++) {
        int v = mask[i];
        if (v < 0) v = 0; if (v > 255) v = 255;
        vals[i] = v;
      }
    }

    // Build histogram and compute Otsu threshold
    final hist = List<int>.filled(256, 0);
    for (final v in vals) { hist[v]++; }
    final thr = _otsuThreshold(hist);

    List<List<bool>> bin = List.generate(gh, (_) => List<bool>.filled(gw, false));
    for (int y = 0; y < gh; y++) {
      final off = y * gw;
      for (int x = 0; x < gw; x++) {
        bin[y][x] = vals[off + x] >= thr;
      }
    }

    // Choose best seed near the tapped grid coordinate by highest value within r=6
    int sx = seedX.clamp(0, gw - 1);
    int sy = seedY.clamp(0, gh - 1);
    int bestX = sx, bestY = sy, bestVal = -1;
    const int r = 6;
    for (int dy = -r; dy <= r; dy++) {
      final yy = sy + dy; if (yy < 0 || yy >= gh) continue;
      for (int dx = -r; dx <= r; dx++) {
        final xx = sx + dx; if (xx < 0 || xx >= gw) continue;
        final v = vals[yy * gw + xx];
        if (v > bestVal) { bestVal = v; bestX = xx; bestY = yy; }
      }
    }
    sx = bestX; sy = bestY;

    // If the seed isn't inside foreground with current threshold, look for nearest true cell
    if (!bin[sy][sx]) {
      bool found = false;
      const int r2 = 8;
      int nx = sx, ny = sy;
      outer: for (int rad = 1; rad <= r2; rad++) {
        for (int dy = -rad; dy <= rad; dy++) {
          final yy = sy + dy; if (yy < 0 || yy >= gh) continue;
          for (int dx = -rad; dx <= rad; dx++) {
            final xx = sx + dx; if (xx < 0 || xx >= gw) continue;
            if (bin[yy][xx]) { nx = xx; ny = yy; found = true; break outer; }
          }
        }
      }
      if (found) { sx = nx; sy = ny; }
    }

    // Keep only component connected to (sx,sy); if not in fg, fall back to >0 mask
    List<List<bool>> comp;
    if (bin[sy][sx]) {
      comp = _keepConnectedComponentFromSeed(bin, gw, gh, sx, sy);
    } else {
      // build bin2 as >0
      final bin2 = List.generate(gh, (_) => List<bool>.filled(gw, false));
      for (int y = 0; y < gh; y++) {
        final off = y * gw;
        for (int x = 0; x < gw; x++) {
          bin2[y][x] = vals[off + x] > 0;
        }
      }
      if (bin2[sy][sx]) {
        comp = _keepConnectedComponentFromSeed(bin2, gw, gh, sx, sy);
      } else {
        // nothing around seed, return empty
        return _RefinedMask(m: List.generate(gh, (_) => List<bool>.filled(gw, false)), count: 0);
      }
    }

    // Fill holes in the kept component
    comp = _fillHoles(comp, gw, gh);

    // Light morphology to remove single-pixel artifacts
    comp = _smoothMask3x3(comp, gw, gh);

    // Re-enforce seed component after smoothing
    if (!comp[sy][sx]) {
      // choose nearest true again
      bool found = false; int nx = sx, ny = sy;
      for (int rad = 1; rad <= 8 && !found; rad++) {
        for (int dy = -rad; dy <= rad && !found; dy++) {
          final yy = sy + dy; if (yy < 0 || yy >= gh) continue;
          for (int dx = -rad; dx <= rad; dx++) {
            final xx = sx + dx; if (xx < 0 || xx >= gw) continue;
            if (comp[yy][xx]) { nx = xx; ny = yy; found = true; break; }
          }
        }
      }
      if (found) {
        comp = _keepConnectedComponentFromSeed(comp, gw, gh, nx, ny);
      }
    }

    int count = 0;
    for (int y = 0; y < gh; y++) {
      for (int x = 0; x < gw; x++) { if (comp[y][x]) count++; }
    }

    return _RefinedMask(m: comp, count: count);
  }

  int _otsuThreshold(List<int> hist) {
    final total = hist.reduce((a, b) => a + b);
    if (total == 0) return 128;
    double sum = 0.0;
    for (int i = 0; i < 256; i++) { sum += i * hist[i]; }
    double sumB = 0.0;
    int wB = 0;
    int wF;
    double maxBetween = -1.0;
    int threshold = 128;
    for (int t = 0; t < 256; t++) {
      wB += hist[t];
      if (wB == 0) continue;
      wF = total - wB;
      if (wF == 0) break;
      sumB += t * hist[t];
      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;
      final between = wB * wF * (mB - mF) * (mB - mF);
      if (between > maxBetween) { maxBetween = between; threshold = t; }
    }
    // bias slightly towards foreground to avoid missing fine edges
    return (threshold - 1).clamp(0, 255);
  }

  List<List<bool>> _keepConnectedComponentFromSeed(List<List<bool>> bin, int gw, int gh, int sx, int sy) {
    final out = List.generate(gh, (_) => List<bool>.filled(gw, false));
    if (!bin[sy][sx]) return out;
    final qx = <int>[]; final qy = <int>[];
    qx.add(sx); qy.add(sy); out[sy][sx] = true;
    const dx8 = [-1, 0, 1, -1, 1, -1, 0, 1];
    const dy8 = [-1, -1, -1, 0, 0, 1, 1, 1];
    bool inside(int x, int y) => x >= 0 && y >= 0 && x < gw && y < gh;
    while (qx.isNotEmpty) {
      final x = qx.removeLast();
      final y = qy.removeLast();
      for (int k = 0; k < 8; k++) {
        final nx = x + dx8[k]; final ny = y + dy8[k];
        if (!inside(nx, ny)) continue;
        if (bin[ny][nx] && !out[ny][nx]) { out[ny][nx] = true; qx.add(nx); qy.add(ny); }
      }
    }
    return out;
  }

  List<List<bool>> _fillHoles(List<List<bool>> bin, int gw, int gh) {
    final visited = List.generate(gh, (_) => List<bool>.filled(gw, false));
    final qx = <int>[]; final qy = <int>[];
    bool inside(int x, int y) => x >= 0 && y >= 0 && x < gw && y < gh;
    void tryPush(int x, int y) {
      if (!inside(x, y)) return;
      if (visited[y][x]) return;
      if (!bin[y][x]) { visited[y][x] = true; qx.add(x); qy.add(y); }
    }
    // push all border background pixels
    for (int x = 0; x < gw; x++) { tryPush(x, 0); tryPush(x, gh - 1); }
    for (int y = 0; y < gh; y++) { tryPush(0, y); tryPush(gw - 1, y); }
    const dx4 = [1, -1, 0, 0];
    const dy4 = [0, 0, 1, -1];
    while (qx.isNotEmpty) {
      final x = qx.removeLast(); final y = qy.removeLast();
      for (int k = 0; k < 4; k++) { tryPush(x + dx4[k], y + dy4[k]); }
    }
    // cells that are background but not visited are holes -> fill them
    for (int y = 0; y < gh; y++) {
      for (int x = 0; x < gw; x++) {
        if (!bin[y][x] && !visited[y][x]) { bin[y][x] = true; }
      }
    }
    return bin;
  }

  /// Marching Squares on the coarse mask grid to get a polygon in image coords
  List<Offset> _marchingSquaresPolygon(_MaskGrid grid) {
    final gw = grid.gw;
    final gh = grid.gh;

    // Smooth mask to reduce jagged edges and small holes
    final mm = _smoothMask3x3(grid.m, gw, gh);

    // Represent edge midpoints with integer coordinates scaled by 2 to avoid
    // floating point matching issues.
    List<List<int>> segments = [];

    int _key(int x, int y) => (x << 16) ^ y; // pack two 16-bit ints

    // Iterate each cell
    for (int y = 0; y < gh - 1; y++) {
      for (int x = 0; x < gw - 1; x++) {
        final tl = mm[y][x] ? 1 : 0;
        final tr = mm[y][x + 1] ? 1 : 0;
        final br = mm[y + 1][x + 1] ? 1 : 0;
        final bl = mm[y + 1][x] ? 1 : 0;
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

  List<Offset> _rdpSimplifyAdaptive(List<Offset> points, {double minEpsilon = 0.6, double maxEpsilon = 1.6}) {
    if (points.length < 3) return points;
    final bool closed = (points.first - points.last).distance < 1e-6;
    final List<Offset> work = closed ? points.sublist(0, points.length - 1) : points;
    double perim = 0.0;
    for (int i = 0; i < work.length; i++) {
      final a = work[i];
      final b = work[(i + 1) % work.length];
      perim += (b - a).distance;
    }
    final num neps = (perim * 0.004).clamp(minEpsilon, maxEpsilon);
    final double eps = neps.toDouble();
    return _rdpSimplify(points, epsilon: eps);
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

class _RefinedMask {
  final List<List<bool>> m;
  final int count;
  _RefinedMask({required this.m, required this.count});
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

/// ===================== Multi-scale optimized fallback =====================

Future<List<Offset>> _multiScaleFallback({
  required ui.Image image,
  required Offset tapPoint,
  bool refineLocally = true,
}) async {
  final bd = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (bd == null) return <Offset>[];
  final src = bd.buffer.asUint8List();
  final w = image.width;
  final h = image.height;

  final longest = math.max(w, h).toDouble();
  final targetLongest = _chooseTargetLongest(longest: longest);
  final scale = targetLongest / longest;
  final rw = math.max(1, (w * scale).round());
  final rh = math.max(1, (h * scale).round());

  // Downscale to reduced RGBA
  final reduced = _downscaleRgbaBilinear(src, w, h, rw, rh);

  // Seed at reduced coordinates
  final sx = (tapPoint.dx * scale).clamp(0.0, (rw - 1).toDouble()).round();
  final sy = (tapPoint.dy * scale).clamp(0.0, (rh - 1).toDouble()).round();

  // Region grow on reduced image (flat arrays + bbox-limited)
  final growR = _regionGrowFlat(
    rgba: reduced,
    width: rw,
    height: rh,
    seedX: sx,
    seedY: sy,
    bboxRadius: (math.min(rw, rh) * 0.45).round().clamp(24, 512),
  );
  if (growR == null || growR.count < 12) return <Offset>[];

  // Marching Squares on reduced mask
  final m2d = List.generate(rh, (y) {
    final row = List<bool>.filled(rw, false);
    final off = y * rw;
    for (int x = 0; x < rw; x++) {
      row[x] = growR.mask[off + x] != 0;
    }
    return row;
  });
  final grid = _MaskGrid(
    m: m2d,
    gw: rw,
    gh: rh,
    step: 1, // reduced pixel grid
    width: rw,
    height: rh,
    totalOn: growR.count,
  );
  var polyReduced = _marchingSquaresPolygon(grid);
  if (polyReduced.isEmpty) return <Offset>[];

  // Scale back to original coordinates
  final inv = 1.0 / scale;
  var poly = polyReduced.map((p) => Offset(p.dx * inv, p.dy * inv)).toList();
  poly = _rdpSimplifyAdaptive(poly);
  poly = poly
      .map((p) => Offset(
            p.dx.clamp(0.0, w.toDouble()),
            p.dy.clamp(0.0, h.toDouble()),
          ))
      .toList();
  if (poly.isNotEmpty && (poly.first - poly.last).distance > 0.01) {
    poly.add(poly.first);
  }

  if (!refineLocally) return poly;

  // Optional local refinement at full resolution around the clicked area
  final roiPoly = _refineLocalFullRes(
    rgba: src,
    width: w,
    height: h,
    tapPoint: tapPoint,
    coarsePoly: poly,
  );
  if (roiPoly != null && roiPoly.isNotEmpty) return roiPoly;

  return poly;
}

int _chooseTargetLongest({required double longest}) {
  // Heuristic: balance speed/detail for large images
  if (longest >= 6000) return 640;
  if (longest >= 4000) return 768;
  if (longest >= 2500) return 896;
  return 1024; // smaller images can use 1024 without heavy cost
}

Uint8List _downscaleRgbaBilinear(Uint8List src, int sw, int sh, int dw, int dh) {
  final out = Uint8List(dw * dh * 4);
  final sx = sw.toDouble();
  final sy = sh.toDouble();
  final scaleX = sx / dw;
  final scaleY = sy / dh;

  int idx(int x, int y) => (y * sw + x) * 4;

  for (int y = 0; y < dh; y++) {
    final fy = (y + 0.5) * scaleY - 0.5;
    int y0 = fy.floor();
    int y1 = y0 + 1;
    final wy1 = fy - y0;
    final wy0 = 1.0 - wy1;
    if (y0 < 0) y0 = 0;
    if (y1 >= sh) y1 = sh - 1;

    for (int x = 0; x < dw; x++) {
      final fx = (x + 0.5) * scaleX - 0.5;
      int x0 = fx.floor();
      int x1 = x0 + 1;
      final wx1 = fx - x0;
      final wx0 = 1.0 - wx1;
      if (x0 < 0) x0 = 0;
      if (x1 >= sw) x1 = sw - 1;

      final i00 = idx(x0, y0);
      final i10 = idx(x1, y0);
      final i01 = idx(x0, y1);
      final i11 = idx(x1, y1);

      double r0 = src[i00] * wx0 + src[i10] * wx1;
      double g0 = src[i00 + 1] * wx0 + src[i10 + 1] * wx1;
      double b0 = src[i00 + 2] * wx0 + src[i10 + 2] * wx1;
      double a0 = src[i00 + 3] * wx0 + src[i10 + 3] * wx1;

      double r1 = src[i01] * wx0 + src[i11] * wx1;
      double g1 = src[i01 + 1] * wx0 + src[i11 + 1] * wx1;
      double b1 = src[i01 + 2] * wx0 + src[i11 + 2] * wx1;
      double a1 = src[i01 + 3] * wx0 + src[i11 + 3] * wx1;

      final r = (r0 * wy0 + r1 * wy1).round();
      final g = (g0 * wy0 + g1 * wy1).round();
      final b = (b0 * wy0 + b1 * wy1).round();
      final a = (a0 * wy0 + a1 * wy1).round();

      final o = (y * dw + x) * 4;
      out[o] = r.clamp(0, 255);
      out[o + 1] = g.clamp(0, 255);
      out[o + 2] = b.clamp(0, 255);
      out[o + 3] = a.clamp(0, 255);
    }
  }
  return out;
}

class _GrowResult {
  final Uint8List mask; // 0/1 per pixel
  final int width;
  final int height;
  final int count;
  final int minX;
  final int minY;
  final int maxX;
  final int maxY;
  _GrowResult({
    required this.mask,
    required this.width,
    required this.height,
    required this.count,
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });
}

_GrowResult? _regionGrowFlat({
  required Uint8List rgba,
  required int width,
  required int height,
  required int seedX,
  required int seedY,
  int? bboxRadius,
}) {
  final int n = width * height;
  final mask = Uint8List(n); // 0/1 visited & accepted

  int idx(int x, int y) => (y * width + x) * 4;
  int flat(int x, int y) => y * width + x;

  int clampi(int v, int lo, int hi) => v < lo ? lo : (v > hi ? hi : v);

  // ROI bounds (bbox-limited search)
  int minX = 0, minY = 0, maxX = width - 1, maxY = height - 1;
  if (bboxRadius != null) {
    minX = clampi(seedX - bboxRadius, 0, width - 1);
    maxX = clampi(seedX + bboxRadius, 0, width - 1);
    minY = clampi(seedY - bboxRadius, 0, height - 1);
    maxY = clampi(seedY + bboxRadius, 0, height - 1);
  }

  // Seed color
  final si = idx(seedX, seedY);
  double meanR = rgba[si].toDouble();
  double meanG = rgba[si + 1].toDouble();
  double meanB = rgba[si + 2].toDouble();

  // Queue
  final qx = List<int>.filled(n, 0);
  final qy = List<int>.filled(n, 0);
  int head = 0, tail = 0;

  // Thresholds (squared distances to avoid sqrt)
  double baseThr = 22.0;
  double maxThr = 62.0;
  double baseThr2 = baseThr * baseThr;
  double maxThr2 = maxThr * maxThr;

  // Early stop cap
  final maxCells = math.min(n, math.max(200, (n * 0.22).floor()));

  // 8-neighborhood
  const dx8 = [-1, 0, 1, -1, 1, -1, 0, 1];
  const dy8 = [-1, -1, -1, 0, 0, 1, 1, 1];

  // Enqueue seed
  mask[flat(seedX, seedY)] = 1;
  qx[tail] = seedX;
  qy[tail] = seedY;
  tail++;
  int count = 1;

  int growMinX = seedX, growMaxX = seedX, growMinY = seedY, growMaxY = seedY;

  while (head < tail) {
    final x = qx[head];
    final y = qy[head];
    head++;

    // Update mean (online)
    final ii = idx(x, y);
    final r = rgba[ii].toDouble();
    final g = rgba[ii + 1].toDouble();
    final b = rgba[ii + 2].toDouble();
    final inv = 1.0 / count;
    meanR = meanR + (r - meanR) * inv;
    meanG = meanG + (g - meanG) * inv;
    meanB = meanB + (b - meanB) * inv;

    // Relax threshold over time (squared)
    final t = (count / maxCells).clamp(0.0, 1.0);
    final currThr2 = baseThr2 + (maxThr2 - baseThr2) * t;

    for (int k = 0; k < 8; k++) {
      final nx = x + dx8[k];
      final ny = y + dy8[k];
      if (nx < minX || ny < minY || nx > maxX || ny > maxY) continue;
      final fi = flat(nx, ny);
      if (mask[fi] != 0) continue;

      final pi = idx(nx, ny);
      final dr = rgba[pi].toDouble() - meanR;
      final dg = rgba[pi + 1].toDouble() - meanG;
      final db = rgba[pi + 2].toDouble() - meanB;
      final dist2 = dr * dr + dg * dg + db * db;
      if (dist2 <= currThr2) {
        mask[fi] = 1;
        qx[tail] = nx;
        qy[tail] = ny;
        tail++;
        count++;
        if (nx < growMinX) growMinX = nx;
        if (nx > growMaxX) growMaxX = nx;
        if (ny < growMinY) growMinY = ny;
        if (ny > growMaxY) growMaxY = ny;
        if (count >= maxCells) break;
      }
    }
    if (count >= maxCells) break;
  }

  if (count < 8) return null;

  return _GrowResult(
    mask: mask,
    width: width,
    height: height,
    count: count,
    minX: growMinX,
    minY: growMinY,
    maxX: growMaxX,
    maxY: growMaxY,
  );
}

List<Offset>? _refineLocalFullRes({
  required Uint8List rgba,
  required int width,
  required int height,
  required Offset tapPoint,
  required List<Offset> coarsePoly,
}) {
  if (coarsePoly.length < 4) return null;
  // Compute bbox of coarse poly
  double minX = double.infinity, minY = double.infinity, maxX = -1e9, maxY = -1e9;
  for (final p in coarsePoly) {
    if (p.dx < minX) minX = p.dx;
    if (p.dy < minY) minY = p.dy;
    if (p.dx > maxX) maxX = p.dx;
    if (p.dy > maxY) maxY = p.dy;
  }
  final margin = (math.max(8.0, 0.05 * math.max(width, height))).round();
  int bx0 = (minX.floor() - margin).clamp(0, width - 1);
  int by0 = (minY.floor() - margin).clamp(0, height - 1);
  int bx1 = (maxX.ceil() + margin).clamp(0, width - 1);
  int by1 = (maxY.ceil() + margin).clamp(0, height - 1);

  // Ensure the seed lies within ROI
  final sx = tapPoint.dx.round().clamp(bx0, bx1);
  final sy = tapPoint.dy.round().clamp(by0, by1);

  final roiW = bx1 - bx0 + 1;
  final roiH = by1 - by0 + 1;
  if (roiW <= 2 || roiH <= 2) return null;

  // Region grow limited to ROI
  int idxRoi(int x, int y) => ((y + by0) * width + (x + bx0)) * 4;
  final roiRgba = Uint8List(roiW * roiH * 4);
  for (int y = 0; y < roiH; y++) {
    for (int x = 0; x < roiW; x++) {
      final srcI = idxRoi(x, y);
      final dstI = (y * roiW + x) * 4;
      roiRgba[dstI] = rgba[srcI];
      roiRgba[dstI + 1] = rgba[srcI + 1];
      roiRgba[dstI + 2] = rgba[srcI + 2];
      roiRgba[dstI + 3] = rgba[srcI + 3];
    }
  }

  final seedXRoi = (sx - bx0).clamp(0, roiW - 1);
  final seedYRoi = (sy - by0).clamp(0, roiH - 1);

  final grow = _regionGrowFlat(
    rgba: roiRgba,
    width: roiW,
    height: roiH,
    seedX: seedXRoi,
    seedY: seedYRoi,
    bboxRadius: (math.min(roiW, roiH) * 0.5).round(),
  );
  if (grow == null || grow.count < 12) return null;

  // Marching squares inside ROI and shift to image coords
  final m2d = List.generate(roiH, (y) {
    final row = List<bool>.filled(roiW, false);
    final off = y * roiW;
    for (int x = 0; x < roiW; x++) {
      row[x] = grow.mask[off + x] != 0;
    }
    return row;
  });
  final grid = _MaskGrid(
    m: m2d,
    gw: roiW,
    gh: roiH,
    step: 1,
    width: roiW,
    height: roiH,
    totalOn: grow.count,
  );
  var poly = _marchingSquaresPolygon(grid).map((p) => Offset(p.dx + bx0, p.dy + by0)).toList();
  if (poly.isEmpty) return null;
  poly = _rdpSimplifyAdaptive(poly);
  poly = poly
      .map((p) => Offset(
            p.dx.clamp(0.0, width.toDouble()),
            p.dy.clamp(0.0, height.toDouble()),
          ))
      .toList();
  if (poly.isNotEmpty && (poly.first - poly.last).distance > 0.01) {
    poly.add(poly.first);
  }
  return poly;
}


// Top-level wrappers to allow calling from top-level helpers
// These forward to the singleton instance methods defined inside SamSegmentationService.
List<Offset> _marchingSquaresPolygon(_MaskGrid grid) {
  return SamSegmentationService()._marchingSquaresPolygon(grid);
}

List<Offset> _rdpSimplify(List<Offset> points, {double epsilon = 1.5}) {
  return SamSegmentationService()._rdpSimplify(points, epsilon: epsilon);
}


// Top-level adaptive simplification wrapper
List<Offset> _rdpSimplifyAdaptive(List<Offset> points, {double minEpsilon = 0.6, double maxEpsilon = 1.6}) {
  return SamSegmentationService()._rdpSimplifyAdaptive(points, minEpsilon: minEpsilon, maxEpsilon: maxEpsilon);
}
