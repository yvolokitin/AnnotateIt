import 'package:flutter_test/flutter_test.dart';

import 'package:annotateit/models/ai_result_envelope.dart';
import 'package:annotateit/services/inference_routing_policy.dart';

void main() {
  // -----------------------------------------------------------------------
  // RoutingDecision
  // -----------------------------------------------------------------------

  group('RoutingDecision', () {
    test('toString includes backend and reason', () {
      const d = RoutingDecision(
        backend: AiBackendType.local,
        reason: 'test reason',
      );
      expect(d.toString(), contains('local'));
      expect(d.toString(), contains('test reason'));
    });

    test('isUserOverride defaults to false', () {
      const d = RoutingDecision(
        backend: AiBackendType.onprem,
        reason: 'auto',
      );
      expect(d.isUserOverride, false);
    });
  });

  // -----------------------------------------------------------------------
  // DefaultInferenceRoutingPolicy — platform capability routing
  // -----------------------------------------------------------------------

  group('DefaultInferenceRoutingPolicy platform rules', () {
    DefaultInferenceRoutingPolicy policyWith({
      bool local = true,
      bool onprem = false,
      bool external = false,
    }) {
      return DefaultInferenceRoutingPolicy(
        availability: BackendAvailability(
          localAvailable: local,
          onpremAvailable: onprem,
          externalAvailable: external,
        ),
      );
    }

    // -- Classification / Detection --

    test('classification on iOS → local', () {
      final p = policyWith(local: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.ios,
      ));
      expect(d.backend, AiBackendType.local);
      expect(d.reason, contains('On-device'));
    });

    test('classification on Windows → local', () {
      final p = policyWith(local: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.windows,
      ));
      expect(d.backend, AiBackendType.local);
    });

    test('classification on Web → onprem when available', () {
      final p = policyWith(local: false, onprem: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.web,
      ));
      expect(d.backend, AiBackendType.onprem);
    });

    test('classification on Web → external when only external', () {
      final p = policyWith(local: false, onprem: false, external: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.web,
      ));
      expect(d.backend, AiBackendType.external);
    });

    test('detection on macOS → local', () {
      final p = policyWith(local: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.detection,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.macos,
      ));
      expect(d.backend, AiBackendType.local);
    });

    // -- OCR / Image labeling --

    test('OCR on iOS → local (ML Kit)', () {
      final p = policyWith(local: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.ocr,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.ios,
      ));
      expect(d.backend, AiBackendType.local);
    });

    test('OCR on Windows → onprem (no ML Kit)', () {
      final p = policyWith(local: true, onprem: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.ocr,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.windows,
      ));
      expect(d.backend, AiBackendType.onprem);
    });

    test('OCR on macOS → external when only external', () {
      final p = policyWith(local: false, onprem: false, external: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.ocr,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.macos,
      ));
      expect(d.backend, AiBackendType.external);
    });

    test('imageLabeling on Web → onprem', () {
      final p = policyWith(onprem: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.imageLabeling,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.web,
      ));
      expect(d.backend, AiBackendType.onprem);
    });

    // -- Segmentation (SAM) --

    test('segmentation on Web → local (ONNX/WASM)', () {
      final p = policyWith(local: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.segmentation,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.web,
      ));
      expect(d.backend, AiBackendType.local);
    });

    test('segmentation on Windows → onprem (heuristic fallback only)', () {
      final p = policyWith(local: true, onprem: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.segmentation,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.windows,
      ));
      expect(d.backend, AiBackendType.onprem);
    });

    test('segmentation on iOS → external when no onprem', () {
      final p = policyWith(local: true, onprem: false, external: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.segmentation,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.ios,
      ));
      expect(d.backend, AiBackendType.external);
    });

    // -- Custom --

    test('custom with batch latency → external', () {
      final p = policyWith(local: true, external: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.custom,
        mediaType: InferenceMediaType.image,
        latencyTarget: LatencyTarget.batch,
        platform: InferencePlatform.ios,
      ));
      expect(d.backend, AiBackendType.external);
    });

    test('custom with realtime latency → local', () {
      final p = policyWith(local: true, external: true);
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.custom,
        mediaType: InferenceMediaType.image,
        latencyTarget: LatencyTarget.realtime,
        platform: InferencePlatform.ios,
      ));
      expect(d.backend, AiBackendType.local);
    });
  });

  // -----------------------------------------------------------------------
  // Privacy filtering
  // -----------------------------------------------------------------------

  group('Privacy filtering', () {
    test('strict privacy → only local', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: true,
          onpremAvailable: true,
          externalAvailable: true,
        ),
      );
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        privacyLevel: PrivacyLevel.strict,
        platform: InferencePlatform.ios,
      ));
      expect(d.backend, AiBackendType.local);
      expect(d.reason, contains('strict'));
    });

    test('strict privacy with no local → fallback with warning', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: false,
          onpremAvailable: true,
          externalAvailable: true,
        ),
      );
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        privacyLevel: PrivacyLevel.strict,
        platform: InferencePlatform.ios,
      ));
      expect(d.backend, AiBackendType.local);
      expect(d.reason, contains('No backend available'));
    });

    test('onprem privacy → local or onprem, not external', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: false,
          onpremAvailable: true,
          externalAvailable: true,
        ),
      );
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        privacyLevel: PrivacyLevel.onprem,
        platform: InferencePlatform.web,
      ));
      expect(d.backend, AiBackendType.onprem);
    });

    test('relaxed privacy → any backend', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: false,
          onpremAvailable: false,
          externalAvailable: true,
        ),
      );
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        privacyLevel: PrivacyLevel.relaxed,
        platform: InferencePlatform.web,
      ));
      expect(d.backend, AiBackendType.external);
    });
  });

  // -----------------------------------------------------------------------
  // User override
  // -----------------------------------------------------------------------

  group('User override', () {
    test('user override forces backend', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: true,
          onpremAvailable: true,
          externalAvailable: true,
        ),
        userOverride: AiBackendType.external,
      );

      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.ios,
      ));

      expect(d.backend, AiBackendType.external);
      expect(d.isUserOverride, true);
      expect(d.reason, contains('User selected'));
    });

    test('user override falls through when backend unavailable', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: true,
          onpremAvailable: false,
          externalAvailable: false,
        ),
        userOverride: AiBackendType.external,
      );

      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.ios,
      ));

      expect(d.backend, AiBackendType.local);
      expect(d.isUserOverride, false);
    });

    test('userOverride can be changed at runtime', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: true,
          onpremAvailable: true,
          externalAvailable: true,
        ),
      );

      var d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.ios,
      ));
      expect(d.backend, AiBackendType.local);
      expect(d.isUserOverride, false);

      p.userOverride = AiBackendType.onprem;
      d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.ios,
      ));
      expect(d.backend, AiBackendType.onprem);
      expect(d.isUserOverride, true);

      p.userOverride = null;
      d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.ios,
      ));
      expect(d.isUserOverride, false);
    });
  });

  // -----------------------------------------------------------------------
  // Candidates list
  // -----------------------------------------------------------------------

  group('Candidates', () {
    test('decision includes full candidate list', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: true,
          onpremAvailable: true,
          externalAvailable: true,
        ),
      );

      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.detection,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.windows,
      ));

      expect(d.candidates, [
        AiBackendType.local,
        AiBackendType.onprem,
        AiBackendType.external,
      ]);
    });

    test('web detection candidates exclude local', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: false,
          onpremAvailable: true,
          externalAvailable: true,
        ),
      );

      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.detection,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.web,
      ));

      expect(d.candidates, [AiBackendType.onprem, AiBackendType.external]);
    });
  });

  // -----------------------------------------------------------------------
  // Reason text
  // -----------------------------------------------------------------------

  group('Reason text', () {
    test('reason mentions task and platform', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(localAvailable: true),
      );
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.ocr,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.ios,
      ));
      expect(d.reason, contains('ocr'));
      expect(d.reason, contains('ios'));
    });

    test('reason notes when preferred backend was unavailable', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: false,
          onpremAvailable: false,
          externalAvailable: true,
        ),
      );
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.detection,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.ios,
      ));
      expect(d.reason, contains('unavailable'));
    });
  });

  // -----------------------------------------------------------------------
  // Edge cases
  // -----------------------------------------------------------------------

  group('Edge cases', () {
    test('no backends available → local fallback with warning', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: false,
          onpremAvailable: false,
          externalAvailable: false,
        ),
      );
      final d = p.route(const RoutingRequest(
        taskType: InferenceTaskType.classification,
        mediaType: InferenceMediaType.image,
        platform: InferencePlatform.windows,
      ));
      expect(d.backend, AiBackendType.local);
      expect(d.reason, contains('No backend available'));
    });

    test('all platforms produce a decision', () {
      final p = DefaultInferenceRoutingPolicy(
        availability: const BackendAvailability(
          localAvailable: true,
          onpremAvailable: true,
          externalAvailable: true,
        ),
      );

      for (final platform in InferencePlatform.values) {
        for (final task in InferenceTaskType.values) {
          final d = p.route(RoutingRequest(
            taskType: task,
            mediaType: InferenceMediaType.image,
            platform: platform,
          ));
          expect(d.backend, isNotNull);
          expect(d.reason, isNotEmpty);
        }
      }
    });
  });
}
