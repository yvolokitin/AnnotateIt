import 'dart:ui';

import 'package:google_ml_kit/google_ml_kit.dart' as ml_kit;

import '../models/ai_result_envelope.dart';
import '../models/annotation.dart';
import '../models/annotation_review.dart';

class OcrTextBlock {
  final String text;
  final Rect bbox;

  const OcrTextBlock({required this.text, required this.bbox});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'text': text,
      'bbox': <String, double>{
        'x': bbox.left,
        'y': bbox.top,
        'width': bbox.width,
        'height': bbox.height,
      },
    };
  }
}

class OcrResult {
  final String fullText;
  final List<OcrTextBlock> blocks;
  final String engine;
  final String modelVersion;

  const OcrResult({
    required this.fullText,
    required this.blocks,
    required this.engine,
    required this.modelVersion,
  });
}

abstract class OcrEngine {
  Future<OcrResult> recognizeText(String imagePath);
}

class MlKitOcrEngine implements OcrEngine {
  final ml_kit.TextRecognizer _recognizer;

  MlKitOcrEngine({
    ml_kit.TextRecognitionScript script = ml_kit.TextRecognitionScript.latin,
  }) : _recognizer = ml_kit.TextRecognizer(script: script);

  @override
  Future<OcrResult> recognizeText(String imagePath) async {
    final inputImage = ml_kit.InputImage.fromFilePath(imagePath);
    final recognized = await _recognizer.processImage(inputImage);
    final blocks = recognized.blocks
        .map((b) => OcrTextBlock(text: b.text, bbox: b.boundingBox))
        .toList(growable: false);

    return OcrResult(
      fullText: recognized.text,
      blocks: blocks,
      engine: 'mlkit_text_recognition',
      modelVersion: 'mlkit-latin-v1',
    );
  }

  Future<void> dispose() => _recognizer.close();
}

class OcrAnnotationService {
  final OcrEngine _ocrEngine;

  const OcrAnnotationService({required OcrEngine ocrEngine})
    : _ocrEngine = ocrEngine;

  /// Runs OCR and wraps the result in an [AiResultEnvelope].
  Future<AiResultEnvelope<OcrResult>> recognizeWithEnvelope(
    String imagePath,
  ) async {
    final sw = Stopwatch()..start();
    try {
      final result = await _ocrEngine.recognizeText(imagePath);
      sw.stop();

      if (result.blocks.isEmpty) {
        return AiResultEnvelope.empty(
          modelName: result.engine,
          modelVersion: result.modelVersion,
          totalLatencyMs: sw.elapsedMilliseconds,
          provenance: {'sourceImage': imagePath},
        );
      }

      return AiResultEnvelope.success(
        modelName: result.engine,
        modelVersion: result.modelVersion,
        inferenceLatencyMs: sw.elapsedMilliseconds,
        totalLatencyMs: sw.elapsedMilliseconds,
        payload: result,
        provenance: {'sourceImage': imagePath},
      );
    } catch (e) {
      sw.stop();
      return AiResultEnvelope.error(
        modelName: 'ocr_engine',
        modelVersion: 'unknown',
        totalLatencyMs: sw.elapsedMilliseconds,
        errorMessage: e.toString(),
        provenance: {'sourceImage': imagePath},
      );
    }
  }

  Future<Annotation> createOcrAnnotation({
    required int mediaItemId,
    required String imagePath,
    int? labelId,
    int? annotatorId,
  }) async {
    final now = DateTime.now();
    final envelope = await recognizeWithEnvelope(imagePath);
    final result = envelope.payload;
    final blocksJson = result?.blocks.map((b) => b.toJson()).toList() ?? [];

    return Annotation(
      mediaItemId: mediaItemId,
      labelId: labelId,
      annotationType: 'ocr_text',
      data: <String, dynamic>{
        'schema': 'ocr.v1',
        'fullText': result?.fullText ?? '',
        'blocks': blocksJson,
      },
      annotatorId: annotatorId,
      status: 'pending',
      annotationSchemaVersion: AnnotationSchema.currentVersion,
      provenance: <String, dynamic>{
        ...envelope.toMetadataMap(),
        'sourceImage': imagePath,
        'generatedAt': now.toIso8601String(),
      },
      reviewStatus: AnnotationReviewStatus.draft,
      createdAt: now,
      updatedAt: now,
    );
  }
}
