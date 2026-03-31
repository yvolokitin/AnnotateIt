import 'package:flutter_test/flutter_test.dart';
import 'package:annotateit/models/ai_result_envelope.dart';

void main() {
  group('AiBackendType', () {
    test('has expected values', () {
      expect(AiBackendType.values.length, 3);
      expect(AiBackendType.values, contains(AiBackendType.local));
      expect(AiBackendType.values, contains(AiBackendType.onprem));
      expect(AiBackendType.values, contains(AiBackendType.external));
    });
  });

  group('AiFinishReason', () {
    test('has expected values', () {
      expect(AiFinishReason.values.length, 5);
      expect(AiFinishReason.values, contains(AiFinishReason.success));
      expect(AiFinishReason.values, contains(AiFinishReason.empty));
      expect(AiFinishReason.values, contains(AiFinishReason.timeout));
      expect(AiFinishReason.values, contains(AiFinishReason.error));
      expect(AiFinishReason.values, contains(AiFinishReason.cancelled));
    });
  });

  group('AiResultEnvelope', () {
    test('success factory sets correct fields', () {
      final e = AiResultEnvelope<String>.success(
        modelName: 'test-model',
        modelVersion: '2.0',
        backendType: AiBackendType.onprem,
        inferenceLatencyMs: 42,
        totalLatencyMs: 100,
        payload: 'hello',
        provenance: {'key': 'val'},
      );

      expect(e.modelName, 'test-model');
      expect(e.modelVersion, '2.0');
      expect(e.backendType, AiBackendType.onprem);
      expect(e.inferenceLatencyMs, 42);
      expect(e.totalLatencyMs, 100);
      expect(e.finishReason, AiFinishReason.success);
      expect(e.payload, 'hello');
      expect(e.provenance['key'], 'val');
      expect(e.isSuccess, true);
      expect(e.hasPayload, true);
      expect(e.errorMessage, isNull);
    });

    test('error factory sets correct fields', () {
      final e = AiResultEnvelope<String>.error(
        modelName: 'fail-model',
        modelVersion: '1.0',
        totalLatencyMs: 50,
        errorMessage: 'something broke',
      );

      expect(e.finishReason, AiFinishReason.error);
      expect(e.isSuccess, false);
      expect(e.hasPayload, false);
      expect(e.errorMessage, 'something broke');
    });

    test('empty factory sets correct fields', () {
      final e = AiResultEnvelope<List<int>>.empty(
        modelName: 'empty-model',
        modelVersion: '0.1',
        totalLatencyMs: 10,
      );

      expect(e.finishReason, AiFinishReason.empty);
      expect(e.isSuccess, false);
      expect(e.hasPayload, false);
    });

    test('default constructor defaults', () {
      final e = AiResultEnvelope<int>(
        modelName: 'm',
        modelVersion: 'v',
        backendType: AiBackendType.local,
        finishReason: AiFinishReason.success,
        payload: 42,
      );

      expect(e.inferenceLatencyMs, -1);
      expect(e.totalLatencyMs, -1);
      expect(e.provenance, isEmpty);
    });

    test('toMetadataMap contains all metadata fields', () {
      final e = AiResultEnvelope<String>.success(
        modelName: 'ocr_engine',
        modelVersion: 'v1',
        backendType: AiBackendType.external,
        inferenceLatencyMs: 200,
        totalLatencyMs: 300,
        payload: 'data',
        provenance: {'src': '/img.png'},
      );

      final map = e.toMetadataMap();
      expect(map['modelName'], 'ocr_engine');
      expect(map['modelVersion'], 'v1');
      expect(map['backendType'], 'external');
      expect(map['inferenceLatencyMs'], 200);
      expect(map['totalLatencyMs'], 300);
      expect(map['finishReason'], 'success');
      expect(map['provenance'], {'src': '/img.png'});
      expect(map.containsKey('errorMessage'), false);
    });

    test('toMetadataMap includes errorMessage when present', () {
      final e = AiResultEnvelope<String>.error(
        modelName: 'm',
        modelVersion: 'v',
        errorMessage: 'fail',
      );

      final map = e.toMetadataMap();
      expect(map['errorMessage'], 'fail');
    });

    test('toMetadataJson roundtrip', () {
      final e = AiResultEnvelope<String>.success(
        modelName: 'test',
        modelVersion: '1.0',
        inferenceLatencyMs: 10,
        totalLatencyMs: 20,
        payload: 'data',
      );

      final json = e.toMetadataJson();
      expect(json, contains('"modelName":"test"'));
      expect(json, contains('"finishReason":"success"'));
    });

    test('fromMetadataMap reconstructs envelope', () {
      final map = {
        'modelName': 'test-model',
        'modelVersion': '2.0',
        'backendType': 'onprem',
        'inferenceLatencyMs': 42,
        'totalLatencyMs': 100,
        'finishReason': 'success',
        'provenance': {'key': 'val'},
      };

      final e = AiResultEnvelope.fromMetadataMap<String>(
        map,
        payload: 'restored',
      );

      expect(e.modelName, 'test-model');
      expect(e.modelVersion, '2.0');
      expect(e.backendType, AiBackendType.onprem);
      expect(e.inferenceLatencyMs, 42);
      expect(e.totalLatencyMs, 100);
      expect(e.finishReason, AiFinishReason.success);
      expect(e.payload, 'restored');
      expect(e.provenance['key'], 'val');
    });

    test('fromMetadataMap handles missing/invalid fields gracefully', () {
      final e = AiResultEnvelope.fromMetadataMap<int>({});
      expect(e.modelName, '');
      expect(e.modelVersion, '');
      expect(e.backendType, AiBackendType.local);
      expect(e.finishReason, AiFinishReason.success);
      expect(e.inferenceLatencyMs, -1);
    });

    test('fromMetadataMap handles unknown enum values', () {
      final e = AiResultEnvelope.fromMetadataMap<int>({
        'backendType': 'quantum',
        'finishReason': 'warp',
      });
      expect(e.backendType, AiBackendType.local);
      expect(e.finishReason, AiFinishReason.success);
    });

    test('copyWith preserves and overrides fields', () {
      final original = AiResultEnvelope<String>.success(
        modelName: 'a',
        modelVersion: '1',
        payload: 'data',
        inferenceLatencyMs: 10,
        totalLatencyMs: 20,
      );

      final modified = original.copyWith(
        modelName: 'b',
        totalLatencyMs: 50,
      );

      expect(modified.modelName, 'b');
      expect(modified.modelVersion, '1');
      expect(modified.totalLatencyMs, 50);
      expect(modified.inferenceLatencyMs, 10);
      expect(modified.payload, 'data');
    });

    test('toString includes key info', () {
      final e = AiResultEnvelope<String>.success(
        modelName: 'test',
        modelVersion: '1.0',
        payload: 'x',
        inferenceLatencyMs: 5,
        totalLatencyMs: 10,
      );

      final s = e.toString();
      expect(s, contains('test'));
      expect(s, contains('1.0'));
      expect(s, contains('success'));
      expect(s, contains('local'));
    });

    test('typed payload works with complex types', () {
      final e = AiResultEnvelope<List<Map<String, double>>>.success(
        modelName: 'detector',
        modelVersion: '1.0',
        payload: [
          {'x': 1.0, 'y': 2.0},
          {'x': 3.0, 'y': 4.0},
        ],
      );

      expect(e.payload!.length, 2);
      expect(e.payload![0]['x'], 1.0);
    });

    test('provenance defaults to empty map', () {
      final e = AiResultEnvelope<String>.success(
        modelName: 'm',
        modelVersion: 'v',
        payload: 'p',
      );
      expect(e.provenance, isEmpty);
    });
  });
}
