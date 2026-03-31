import 'browser_capabilities.dart';

/// Application-level features that can be progressively enabled or
/// disabled based on the detected platform capabilities.
enum AppFeature {
  /// Video timeline scrubber and frame-by-frame navigation.
  videoTimeline,

  /// SAM (Segment Anything) polygon auto-generation.
  samSegmentation,

  /// TFLite-based image classification / detection.
  tfliteInference,

  /// ML Kit labeling (Android/iOS).
  mlKitLabeling,

  /// Drag-and-drop media import (desktop).
  dragAndDrop,

  /// Video frame extraction via ffmpeg.
  videoFrameExtraction,

  /// Export project as ZIP archive.
  exportZip,

  /// Stream inference from external API.
  externalStreamInference,
}

/// Maps [AppFeature]s to [WebCapability] requirements and provides
/// a single point of truth for "is this feature usable right now?".
class FeatureGate {
  FeatureGate._();

  static final FeatureGate instance = FeatureGate._();

  final Map<AppFeature, bool> _overrides = {};

  /// Required capabilities per feature.
  static const Map<AppFeature, List<WebCapability>> _requirements = {
    AppFeature.videoTimeline: [],
    AppFeature.samSegmentation: [WebCapability.webAssembly],
    AppFeature.tfliteInference: [WebCapability.tfliteNative],
    AppFeature.mlKitLabeling: [WebCapability.mlKit],
    AppFeature.dragAndDrop: [WebCapability.fileSystem],
    AppFeature.videoFrameExtraction: [WebCapability.ffmpegCli],
    AppFeature.exportZip: [WebCapability.fileSystem],
    AppFeature.externalStreamInference: [],
  };

  /// Check whether [feature] is available on the current platform.
  bool isEnabled(AppFeature feature) {
    if (_overrides.containsKey(feature)) return _overrides[feature]!;

    final caps = BrowserCapabilities.instance;
    final reqs = _requirements[feature] ?? [];

    // On native, samSegmentation doesn't need WASM — it uses the
    // heuristic fallback. Only block features whose requirements are
    // hard dependencies on the *current* platform.
    if (reqs.isEmpty) return true;

    for (final req in reqs) {
      if (!caps.isAvailable(req)) return false;
    }
    return true;
  }

  /// Human-readable explanation of why a feature is unavailable.
  String disabledReason(AppFeature feature) {
    if (_overrides.containsKey(feature)) {
      return _overrides[feature]!
          ? 'Manually enabled'
          : 'Manually disabled';
    }

    final caps = BrowserCapabilities.instance;
    final reqs = _requirements[feature] ?? [];
    final missing = reqs
        .where((r) => !caps.isAvailable(r))
        .map((r) => caps.detect()[r]!.reason)
        .toList();

    if (missing.isEmpty) return 'Available';
    return missing.join('; ');
  }

  /// Manually override a feature's availability (e.g. from settings).
  void setOverride(AppFeature feature, bool enabled) {
    _overrides[feature] = enabled;
  }

  /// Remove a manual override, reverting to capability detection.
  void clearOverride(AppFeature feature) {
    _overrides.remove(feature);
  }

  /// Clear all overrides.
  void clearAllOverrides() => _overrides.clear();

  /// Returns all features with their current enabled/disabled state.
  Map<AppFeature, bool> snapshot() {
    return {
      for (final f in AppFeature.values) f: isEnabled(f),
    };
  }
}
