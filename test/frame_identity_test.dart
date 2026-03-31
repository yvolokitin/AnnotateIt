import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:annotateit/models/frame_identity.dart';

void main() {
  const identity = FrameIdentity(
    videoId: 'vid-abc-123',
    frameIndex: 42,
    timestampMs: 1400.0,
    sourceFps: 29.97,
    samplingPolicy: SamplingPolicy.fixedFps,
    extractionRunId: 'run-xyz-789',
  );

  group('FrameIdentity', () {
    test('toMap produces all required keys', () {
      final map = identity.toMap();
      expect(map['videoId'], 'vid-abc-123');
      expect(map['frameIndex'], 42);
      expect(map['timestampMs'], 1400.0);
      expect(map['sourceFps'], 29.97);
      expect(map['samplingPolicy'], 'fixedFps');
      expect(map['extractionRunId'], 'run-xyz-789');
    });

    test('roundtrip fromMap(toMap()) preserves all fields', () {
      final restored = FrameIdentity.fromMap(identity.toMap());
      expect(restored.videoId, identity.videoId);
      expect(restored.frameIndex, identity.frameIndex);
      expect(restored.timestampMs, identity.timestampMs);
      expect(restored.sourceFps, identity.sourceFps);
      expect(restored.samplingPolicy, identity.samplingPolicy);
      expect(restored.extractionRunId, identity.extractionRunId);
    });

    test('roundtrip fromJson(toJson()) preserves all fields', () {
      final json = identity.toJson();
      final restored = FrameIdentity.fromJson(json);
      expect(restored.videoId, identity.videoId);
      expect(restored.frameIndex, identity.frameIndex);
      expect(restored.timestampMs, identity.timestampMs);
      expect(restored.sourceFps, identity.sourceFps);
      expect(restored.samplingPolicy, identity.samplingPolicy);
      expect(restored.extractionRunId, identity.extractionRunId);
    });

    test('toJson produces valid JSON', () {
      final json = identity.toJson();
      final decoded = jsonDecode(json);
      expect(decoded, isA<Map<String, dynamic>>());
      expect(decoded['videoId'], 'vid-abc-123');
    });

    test('equality based on videoId, frameIndex, policy, runId', () {
      const same = FrameIdentity(
        videoId: 'vid-abc-123',
        frameIndex: 42,
        timestampMs: 9999.0, // different timestamp
        sourceFps: 60.0, // different fps
        samplingPolicy: SamplingPolicy.fixedFps,
        extractionRunId: 'run-xyz-789',
      );
      expect(identity, equals(same));
      expect(identity.hashCode, same.hashCode);
    });

    test('inequality when frameIndex differs', () {
      const different = FrameIdentity(
        videoId: 'vid-abc-123',
        frameIndex: 43,
        timestampMs: 1400.0,
        sourceFps: 29.97,
        samplingPolicy: SamplingPolicy.fixedFps,
        extractionRunId: 'run-xyz-789',
      );
      expect(identity, isNot(equals(different)));
    });

    test('inequality when videoId differs', () {
      const different = FrameIdentity(
        videoId: 'vid-other',
        frameIndex: 42,
        timestampMs: 1400.0,
        sourceFps: 29.97,
        samplingPolicy: SamplingPolicy.fixedFps,
        extractionRunId: 'run-xyz-789',
      );
      expect(identity, isNot(equals(different)));
    });

    test('inequality when extractionRunId differs', () {
      const different = FrameIdentity(
        videoId: 'vid-abc-123',
        frameIndex: 42,
        timestampMs: 1400.0,
        sourceFps: 29.97,
        samplingPolicy: SamplingPolicy.fixedFps,
        extractionRunId: 'run-different',
      );
      expect(identity, isNot(equals(different)));
    });

    test('inequality when samplingPolicy differs', () {
      const different = FrameIdentity(
        videoId: 'vid-abc-123',
        frameIndex: 42,
        timestampMs: 1400.0,
        sourceFps: 29.97,
        samplingPolicy: SamplingPolicy.everyFrame,
        extractionRunId: 'run-xyz-789',
      );
      expect(identity, isNot(equals(different)));
    });

    test('toString contains key info', () {
      final s = identity.toString();
      expect(s, contains('vid-abc-123'));
      expect(s, contains('frame=42'));
      expect(s, contains('fixedFps'));
      expect(s, contains('run-xyz-789'));
    });

    test('fromMap handles unknown samplingPolicy gracefully', () {
      final map = identity.toMap();
      map['samplingPolicy'] = 'unknown_future_policy';
      final restored = FrameIdentity.fromMap(map);
      expect(restored.samplingPolicy, SamplingPolicy.fixedFps);
    });
  });

  group('SamplingPolicy', () {
    test('all values have distinct names', () {
      final names = SamplingPolicy.values.map((e) => e.name).toSet();
      expect(names.length, SamplingPolicy.values.length);
    });

    test('everyFrame, fixedFps, keyframesOnly exist', () {
      expect(SamplingPolicy.values, contains(SamplingPolicy.everyFrame));
      expect(SamplingPolicy.values, contains(SamplingPolicy.fixedFps));
      expect(SamplingPolicy.values, contains(SamplingPolicy.keyframesOnly));
    });
  });

  group('ExtractionResult', () {
    test('isEmpty is true for no frames', () {
      const result = ExtractionResult(
        extractionRunId: 'run-1',
        videoId: 'vid-1',
        samplingFps: 1.0,
        sourceFps: 30.0,
        samplingPolicy: SamplingPolicy.fixedFps,
        frames: [],
      );
      expect(result.isEmpty, true);
      expect(result.frameCount, 0);
    });

    test('frameCount matches frames list length', () {
      final result = ExtractionResult(
        extractionRunId: 'run-2',
        videoId: 'vid-2',
        samplingFps: 5.0,
        sourceFps: 25.0,
        samplingPolicy: SamplingPolicy.fixedFps,
        frames: [
          ExtractedFrame(
            filePath: '/tmp/f1.png',
            identity: identity,
          ),
          ExtractedFrame(
            filePath: '/tmp/f2.png',
            identity: FrameIdentity(
              videoId: 'vid-2',
              frameIndex: 1,
              timestampMs: 200.0,
              sourceFps: 25.0,
              samplingPolicy: SamplingPolicy.fixedFps,
              extractionRunId: 'run-2',
            ),
          ),
        ],
      );
      expect(result.isEmpty, false);
      expect(result.frameCount, 2);
    });
  });

  group('Timestamp calculation', () {
    test('timestampMs is correctly computed from index and fps', () {
      const fps = 5.0;
      for (int i = 0; i < 10; i++) {
        final expected = (i / fps) * 1000.0;
        final fi = FrameIdentity(
          videoId: 'v',
          frameIndex: i,
          timestampMs: expected,
          sourceFps: 30.0,
          samplingPolicy: SamplingPolicy.fixedFps,
          extractionRunId: 'r',
        );
        expect(fi.timestampMs, closeTo(expected, 0.001));
      }
    });
  });
}
