import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:annotateit/models/ai_result_envelope.dart';
import 'package:annotateit/models/annotation_review.dart';
import 'package:annotateit/services/ocr_annotation_service.dart';

class _FakeOcrEngine implements OcrEngine {
  final OcrResult result;

  _FakeOcrEngine(this.result);

  @override
  Future<OcrResult> recognizeText(String imagePath) async => result;
}

void main() {
  group('OcrAnnotationService', () {
    test('builds structured OCR annotation envelope', () async {
      final service = OcrAnnotationService(
        ocrEngine: _FakeOcrEngine(
          OcrResult(
            fullText: 'hello world',
            blocks: const <OcrTextBlock>[
              OcrTextBlock(text: 'hello', bbox: Rect.fromLTWH(1, 2, 30, 10)),
            ],
            engine: 'test_engine',
            modelVersion: 'v1',
          ),
        ),
      );

      final annotation = await service.createOcrAnnotation(
        mediaItemId: 42,
        imagePath: '/tmp/image.png',
        annotatorId: 7,
      );

      expect(annotation.annotationType, 'ocr_text');
      expect(
        annotation.annotationSchemaVersion,
        AnnotationSchema.currentVersion,
      );
      expect(annotation.reviewStatus, AnnotationReviewStatus.draft);
      expect(annotation.data['schema'], 'ocr.v1');
      expect(annotation.data['fullText'], 'hello world');
      expect((annotation.data['blocks'] as List).length, 1);
      final provenance = annotation.provenance!;
      expect(provenance['modelName'], 'test_engine');
      expect(provenance['modelVersion'], 'v1');
      expect(provenance['sourceImage'], '/tmp/image.png');
      expect(provenance['finishReason'], 'success');
      expect(provenance['backendType'], 'local');
    });

    test('supports empty OCR result safely', () async {
      final service = OcrAnnotationService(
        ocrEngine: _FakeOcrEngine(
          const OcrResult(
            fullText: '',
            blocks: <OcrTextBlock>[],
            engine: 'test_engine',
            modelVersion: 'v1',
          ),
        ),
      );

      final annotation = await service.createOcrAnnotation(
        mediaItemId: 99,
        imagePath: '/tmp/empty.png',
      );

      expect(annotation.data['fullText'], '');
      expect(annotation.data['blocks'], isEmpty);
      final provenance = annotation.provenance!;
      expect(provenance['finishReason'], 'empty');
    });

    test('recognizeWithEnvelope returns success envelope', () async {
      final service = OcrAnnotationService(
        ocrEngine: _FakeOcrEngine(
          OcrResult(
            fullText: 'test',
            blocks: const [OcrTextBlock(text: 'test', bbox: Rect.fromLTWH(0, 0, 10, 10))],
            engine: 'test_engine',
            modelVersion: 'v1',
          ),
        ),
      );

      final envelope = await service.recognizeWithEnvelope('/tmp/test.png');
      expect(envelope.isSuccess, true);
      expect(envelope.modelName, 'test_engine');
      expect(envelope.modelVersion, 'v1');
      expect(envelope.backendType, AiBackendType.local);
      expect(envelope.payload!.fullText, 'test');
      expect(envelope.totalLatencyMs, greaterThanOrEqualTo(0));
    });

    test('recognizeWithEnvelope returns empty for no blocks', () async {
      final service = OcrAnnotationService(
        ocrEngine: _FakeOcrEngine(
          const OcrResult(
            fullText: '',
            blocks: [],
            engine: 'e',
            modelVersion: 'v',
          ),
        ),
      );

      final envelope = await service.recognizeWithEnvelope('/tmp/empty.png');
      expect(envelope.finishReason, AiFinishReason.empty);
      expect(envelope.hasPayload, false);
    });
  });
}
