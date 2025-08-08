import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:sam_onnx/sam_onnx.dart';
import 'image_preprocess.dart';
import 'mask_post.dart';

class SamPrompt {
  final List<Offset> points;
  final List<int> labels;
  final Rect? box;
  const SamPrompt({this.points = const [], this.labels = const [], this.box});
}

class SamResult {
  final Uint8List mask256;
  final double iou;
  const SamResult(this.mask256, this.iou);
}

class SamService {
  final SamOnnx _onnx = SamOnnx.instance;
  final String encoderPath;
  final String decoderPath;
  final SamProvider provider;
  SamService({required this.encoderPath, required this.decoderPath, this.provider = SamProvider.auto});

  final _embeddingCache = <int, Float32List>{};

  Future<void> load() async {
    await _onnx.init(encoderPath: encoderPath, decoderPath: decoderPath, provider: provider);
  }

  Future<Float32List> getEmbedding(ImageData img) async {
    final proc = await compute(preprocessToSamInput, img);
    return _onnx.runEncoder(proc.tensor);
  }

  Future<SamResult> decode({
    required int mediaItemId,
    required ImageData img,
    required SamPrompt prompt,
    Float32List? prevMask,
  }) async {
    final emb = _embeddingCache[mediaItemId] ??= await getEmbedding(img);

    final toSam = buildToSamSpace(img.width, img.height);
    final pointsSam = <double>[];
    for (final p in prompt.points) {
      final sp = toSam(p.dx, p.dy);
      pointsSam..add(sp.dx)..add(sp.dy);
    }
    final labels = Int32List.fromList(prompt.labels);

    Float32List? box4;
    if (prompt.box != null) {
      final a = toSam(prompt.box!.left, prompt.box!.top);
      final b = toSam(prompt.box!.right, prompt.box!.bottom);
      box4 = Float32List.fromList([a.dx, a.dy, b.dx, b.dy]);
    }

    final (mask256, iou) = _onnx.runDecoder(
      embedding: emb,
      points: Float32List.fromList(pointsSam),
      labels: labels,
      box: box4,
      prevMask: prevMask,
      origH: img.height,
      origW: img.width,
    );

    return SamResult(mask256, iou);
  }
}
