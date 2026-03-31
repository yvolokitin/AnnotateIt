import '../utils/platform_utils.dart';

/// Individual browser/platform capabilities that the app depends on.
enum WebCapability {
  /// Local file system access (e.g. File API / dart:io).
  fileSystem,

  /// Camera / MediaDevices access.
  camera,

  /// WebAssembly support (required for ONNX Runtime Web).
  webAssembly,

  /// WebGL for GPU-accelerated rendering.
  webGl,

  /// IndexedDB for client-side persistent storage.
  indexedDb,

  /// SharedArrayBuffer (required by some WASM threading).
  sharedArrayBuffer,

  /// Web Workers for background computation.
  webWorkers,

  /// Native video frame extraction (ffmpeg CLI — desktop only).
  ffmpegCli,

  /// Google ML Kit (Android/iOS only).
  mlKit,

  /// TFLite native inference (mobile/desktop).
  tfliteNative,
}

/// The result of probing a single capability.
class CapabilityStatus {
  final WebCapability capability;
  final bool available;
  final String reason;

  const CapabilityStatus({
    required this.capability,
    required this.available,
    required this.reason,
  });

  @override
  String toString() =>
      'CapabilityStatus(${capability.name}, available=$available)';
}

/// Probes the current runtime environment and reports which features
/// are available.
///
/// On native platforms most capabilities resolve statically. On web
/// the detection uses feature flags exposed by the Dart web runtime.
class BrowserCapabilities {
  BrowserCapabilities._();

  static final BrowserCapabilities instance = BrowserCapabilities._();

  Map<WebCapability, CapabilityStatus>? _cache;

  /// Probe all capabilities and return a snapshot map.
  Map<WebCapability, CapabilityStatus> detect() {
    if (_cache != null) return _cache!;
    _cache = _probe();
    return _cache!;
  }

  /// Force re-detection (e.g. after a permission change).
  void invalidate() => _cache = null;

  /// Convenience: check a single capability.
  bool isAvailable(WebCapability cap) =>
      detect()[cap]?.available ?? false;

  /// All capabilities that are NOT available.
  List<CapabilityStatus> unavailable() =>
      detect().values.where((s) => !s.available).toList();

  /// Human-readable summary for debugging.
  String summary() {
    final d = detect();
    final buf = StringBuffer('Browser Capabilities:\n');
    for (final cap in WebCapability.values) {
      final s = d[cap]!;
      buf.writeln('  ${cap.name}: ${s.available ? "YES" : "NO"} — ${s.reason}');
    }
    return buf.toString();
  }

  // -----------------------------------------------------------------------

  Map<WebCapability, CapabilityStatus> _probe() {
    final isWeb = PlatformUtils.isWeb;
    final isMobile = PlatformUtils.isMobile;
    final isDesktop = PlatformUtils.isDesktop;

    return {
      WebCapability.fileSystem: CapabilityStatus(
        capability: WebCapability.fileSystem,
        available: !isWeb,
        reason: isWeb
            ? 'dart:io unavailable on web; use File Picker instead'
            : 'Native file system access available',
      ),
      WebCapability.camera: CapabilityStatus(
        capability: WebCapability.camera,
        available: true,
        reason: isWeb
            ? 'MediaDevices API assumed available'
            : 'Native camera plugin available',
      ),
      WebCapability.webAssembly: CapabilityStatus(
        capability: WebCapability.webAssembly,
        available: isWeb,
        reason: isWeb
            ? 'WASM available in modern browsers'
            : 'Not applicable on native',
      ),
      WebCapability.webGl: CapabilityStatus(
        capability: WebCapability.webGl,
        available: isWeb,
        reason: isWeb
            ? 'WebGL assumed available in modern browsers'
            : 'Not applicable on native (uses Skia/Impeller)',
      ),
      WebCapability.indexedDb: CapabilityStatus(
        capability: WebCapability.indexedDb,
        available: isWeb,
        reason: isWeb
            ? 'IndexedDB available for sqflite_common_ffi_web'
            : 'Uses native SQLite',
      ),
      WebCapability.sharedArrayBuffer: CapabilityStatus(
        capability: WebCapability.sharedArrayBuffer,
        available: false,
        reason: isWeb
            ? 'Requires COOP/COEP headers; assume unavailable by default'
            : 'Not applicable on native',
      ),
      WebCapability.webWorkers: CapabilityStatus(
        capability: WebCapability.webWorkers,
        available: isWeb,
        reason: isWeb
            ? 'Web Workers available in all modern browsers'
            : 'Uses Isolates on native',
      ),
      WebCapability.ffmpegCli: CapabilityStatus(
        capability: WebCapability.ffmpegCli,
        available: isDesktop,
        reason: isWeb
            ? 'CLI tools unavailable on web'
            : (isDesktop
                ? 'ffmpeg CLI available on desktop'
                : 'Not available on mobile'),
      ),
      WebCapability.mlKit: CapabilityStatus(
        capability: WebCapability.mlKit,
        available: isMobile,
        reason: isMobile
            ? 'Google ML Kit available on mobile'
            : 'ML Kit requires Android or iOS',
      ),
      WebCapability.tfliteNative: CapabilityStatus(
        capability: WebCapability.tfliteNative,
        available: !isWeb,
        reason: isWeb
            ? 'TFLite native unavailable on web; use ONNX Runtime Web'
            : 'TFLite native available',
      ),
    };
  }
}
