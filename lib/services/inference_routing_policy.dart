import '../models/ai_result_envelope.dart';

// ---------------------------------------------------------------------------
// Input domain types
// ---------------------------------------------------------------------------

/// The kind of AI task to route.
enum InferenceTaskType {
  classification,
  detection,
  ocr,
  imageLabeling,
  segmentation,
  custom,
}

/// The media being processed.
enum InferenceMediaType {
  image,
  video,
  text,
  audio,
}

/// Latency tolerance for the inference request.
enum LatencyTarget {
  /// Real-time / interactive (< 100 ms).
  realtime,

  /// Near-real-time (< 1 s).
  fast,

  /// Batch / background (seconds–minutes acceptable).
  batch,
}

/// Data privacy requirement.
enum PrivacyLevel {
  /// Data must never leave the device.
  strict,

  /// Data may be sent to a self-hosted (on-prem) server.
  onprem,

  /// Data may be sent to any backend (including third-party cloud).
  relaxed,
}

/// Abstracted runtime platform for routing decisions.
enum InferencePlatform {
  windows,
  ios,
  macos,
  android,
  linux,
  web,
}

// ---------------------------------------------------------------------------
// Output
// ---------------------------------------------------------------------------

/// The routing decision: which backend to use and why.
class RoutingDecision {
  /// The selected backend.
  final AiBackendType backend;

  /// Human-readable explanation of why this backend was chosen.
  final String reason;

  /// Whether the decision was made by the policy engine or overridden
  /// by the user.
  final bool isUserOverride;

  /// Ordered list of backends that were considered, best-first.
  /// The first entry that was available was selected.
  final List<AiBackendType> candidates;

  const RoutingDecision({
    required this.backend,
    required this.reason,
    this.isUserOverride = false,
    this.candidates = const [],
  });

  @override
  String toString() =>
      'RoutingDecision(backend=${backend.name}, '
      'override=$isUserOverride, reason="$reason")';
}

/// Full routing request context.
class RoutingRequest {
  final InferenceTaskType taskType;
  final InferenceMediaType mediaType;
  final LatencyTarget latencyTarget;
  final PrivacyLevel privacyLevel;
  final InferencePlatform platform;

  const RoutingRequest({
    required this.taskType,
    required this.mediaType,
    this.latencyTarget = LatencyTarget.fast,
    this.privacyLevel = PrivacyLevel.relaxed,
    required this.platform,
  });
}

// ---------------------------------------------------------------------------
// Policy interface
// ---------------------------------------------------------------------------

/// Determines which AI backend to use for a given request.
///
/// Implementations encode the routing rules. The default
/// [DefaultInferenceRoutingPolicy] uses the platform capability matrix
/// and user preferences.
abstract class InferenceRoutingPolicy {
  RoutingDecision route(RoutingRequest request);
}

// ---------------------------------------------------------------------------
// Default rules engine
// ---------------------------------------------------------------------------

/// Capability probe — tells the policy which backends are available
/// at runtime. Override in tests or when on-prem/external availability
/// changes dynamically.
class BackendAvailability {
  final bool localAvailable;
  final bool onpremAvailable;
  final bool externalAvailable;

  const BackendAvailability({
    this.localAvailable = true,
    this.onpremAvailable = false,
    this.externalAvailable = false,
  });
}

/// Default routing policy implementing the platform capability matrix.
///
/// Priority chain (subject to privacy and availability):
///   1. Local (fastest, most private)
///   2. On-prem (moderate latency, private)
///   3. External (cloud, least private)
///
/// Per-platform overrides match the known capability gaps
/// (see `docs/platform_capability_matrix.md` §3):
///   - Web has no local TFLite/ML Kit → route to API
///   - Windows/macOS have no ML Kit → route OCR/labeling to API
///   - Only Web has real SAM → local on web, fallback elsewhere
class DefaultInferenceRoutingPolicy implements InferenceRoutingPolicy {
  final BackendAvailability availability;

  /// User-override backend. When set, [route] returns this backend
  /// directly (if available), skipping the rules engine.
  AiBackendType? userOverride;

  DefaultInferenceRoutingPolicy({
    this.availability = const BackendAvailability(),
    this.userOverride,
  });

  @override
  RoutingDecision route(RoutingRequest request) {
    // ---- User override ----
    if (userOverride != null) {
      if (_isAvailable(userOverride!)) {
        return RoutingDecision(
          backend: userOverride!,
          reason: 'User selected ${userOverride!.name} backend manually.',
          isUserOverride: true,
          candidates: [userOverride!],
        );
      }
      // Override requested but unavailable → fall through to auto
    }

    // ---- Build candidate list based on platform capabilities ----
    final candidates = _candidatesFor(request);

    // ---- Privacy filter ----
    final filtered = _applyPrivacyFilter(candidates, request.privacyLevel);

    // ---- Availability filter ----
    final available = filtered.where(_isAvailable).toList();

    if (available.isEmpty) {
      return RoutingDecision(
        backend: AiBackendType.local,
        reason: 'No backend available for ${request.taskType.name} '
            'on ${request.platform.name}. Falling back to local (may fail).',
        candidates: candidates,
      );
    }

    final chosen = available.first;
    return RoutingDecision(
      backend: chosen,
      reason: _buildReason(chosen, request, candidates),
      candidates: candidates,
    );
  }

  /// Determine the preferred backend ordering for this request.
  List<AiBackendType> _candidatesFor(RoutingRequest request) {
    final p = request.platform;
    final t = request.taskType;

    // -- SAM segmentation: only real on Web --
    if (t == InferenceTaskType.segmentation) {
      if (p == InferencePlatform.web) {
        return [AiBackendType.local, AiBackendType.onprem, AiBackendType.external];
      }
      return [AiBackendType.onprem, AiBackendType.external, AiBackendType.local];
    }

    // -- OCR / Image labeling: ML Kit only on iOS --
    if (t == InferenceTaskType.ocr || t == InferenceTaskType.imageLabeling) {
      if (p == InferencePlatform.ios) {
        return [AiBackendType.local, AiBackendType.onprem, AiBackendType.external];
      }
      return [AiBackendType.onprem, AiBackendType.external, AiBackendType.local];
    }

    // -- TFLite classification/detection: available on native, not on web --
    if (t == InferenceTaskType.classification || t == InferenceTaskType.detection) {
      if (p == InferencePlatform.web) {
        return [AiBackendType.onprem, AiBackendType.external];
      }
      return [AiBackendType.local, AiBackendType.onprem, AiBackendType.external];
    }

    // -- Custom / other: prefer external (most capable), then on-prem --
    if (t == InferenceTaskType.custom) {
      if (request.latencyTarget == LatencyTarget.realtime) {
        return [AiBackendType.local, AiBackendType.onprem, AiBackendType.external];
      }
      return [AiBackendType.external, AiBackendType.onprem, AiBackendType.local];
    }

    // Fallback: local first
    return [AiBackendType.local, AiBackendType.onprem, AiBackendType.external];
  }

  List<AiBackendType> _applyPrivacyFilter(
    List<AiBackendType> candidates,
    PrivacyLevel privacy,
  ) {
    switch (privacy) {
      case PrivacyLevel.strict:
        return candidates.where((b) => b == AiBackendType.local).toList();
      case PrivacyLevel.onprem:
        return candidates
            .where((b) => b == AiBackendType.local || b == AiBackendType.onprem)
            .toList();
      case PrivacyLevel.relaxed:
        return candidates;
    }
  }

  bool _isAvailable(AiBackendType backend) {
    switch (backend) {
      case AiBackendType.local:
        return availability.localAvailable;
      case AiBackendType.onprem:
        return availability.onpremAvailable;
      case AiBackendType.external:
        return availability.externalAvailable;
    }
  }

  String _buildReason(
    AiBackendType chosen,
    RoutingRequest request,
    List<AiBackendType> candidates,
  ) {
    final parts = <String>[];

    switch (chosen) {
      case AiBackendType.local:
        parts.add('On-device inference selected');
      case AiBackendType.onprem:
        parts.add('On-premises server selected');
      case AiBackendType.external:
        parts.add('External cloud API selected');
    }

    parts.add('for ${request.taskType.name} on ${request.platform.name}');

    if (request.privacyLevel == PrivacyLevel.strict) {
      parts.add('(privacy: strict — data stays on device)');
    } else if (request.privacyLevel == PrivacyLevel.onprem) {
      parts.add('(privacy: on-prem — no third-party cloud)');
    }

    if (chosen != candidates.first) {
      parts.add(
        '— preferred ${candidates.first.name} was unavailable or filtered',
      );
    }

    return parts.join(' ');
  }
}
