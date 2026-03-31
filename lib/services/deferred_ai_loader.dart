import 'dart:async';

import 'package:logging/logging.dart';

import 'feature_gate.dart';
import 'perf_counters.dart';

final _log = Logger('DeferredAiLoader');

/// Load status for a deferred AI module.
enum AiModuleStatus {
  notLoaded,
  loading,
  ready,
  failed,
  unavailable,
}

/// Tracks the load state of a single AI module.
class AiModuleInfo {
  final String name;
  AiModuleStatus status;
  String? errorMessage;
  int loadTimeMs;

  AiModuleInfo({
    required this.name,
    this.status = AiModuleStatus.notLoaded,
    this.errorMessage,
    this.loadTimeMs = 0,
  });

  @override
  String toString() => 'AiModuleInfo($name, ${status.name})';
}

/// Centralized lazy/deferred loader for AI modules.
///
/// On web, AI modules like ONNX Runtime or TFLite can be very large.
/// This loader:
///
/// 1. Only initializes modules when first requested (lazy).
/// 2. Skips initialization entirely if the platform lacks required
///    capabilities (e.g. TFLite on web).
/// 3. Reports load progress/status for UI consumption.
/// 4. Records load times via [PerfCounters].
///
/// Usage:
/// ```dart
/// final loader = DeferredAiLoader.instance;
/// final status = await loader.ensureLoaded(AiModule.samOnnx);
/// if (status == AiModuleStatus.ready) { /* use SAM */ }
/// ```
class DeferredAiLoader {
  DeferredAiLoader._();
  static final DeferredAiLoader instance = DeferredAiLoader._();

  final Map<AiModule, AiModuleInfo> _modules = {};
  final Map<AiModule, Completer<AiModuleStatus>> _inflight = {};

  /// Check the current status of a module without triggering a load.
  AiModuleInfo status(AiModule module) =>
      _modules[module] ?? AiModuleInfo(name: module.name);

  /// All modules and their current status.
  Map<AiModule, AiModuleInfo> get allModules =>
      Map.unmodifiable(_modules);

  /// Ensure a module is loaded. If already loaded, returns immediately.
  /// If loading is in progress, waits for the same future.
  Future<AiModuleStatus> ensureLoaded(AiModule module) async {
    final info = _modules.putIfAbsent(
      module,
      () => AiModuleInfo(name: module.name),
    );

    if (info.status == AiModuleStatus.ready ||
        info.status == AiModuleStatus.unavailable) {
      return info.status;
    }

    // De-duplicate concurrent loads.
    if (_inflight.containsKey(module)) {
      return _inflight[module]!.future;
    }

    final completer = Completer<AiModuleStatus>();
    _inflight[module] = completer;

    try {
      info.status = AiModuleStatus.loading;

      // Check platform capability first.
      if (!_meetsRequirements(module)) {
        info.status = AiModuleStatus.unavailable;
        info.errorMessage = 'Platform lacks required capabilities';
        _log.info('$module unavailable on this platform');
        completer.complete(AiModuleStatus.unavailable);
        return AiModuleStatus.unavailable;
      }

      final sw = Stopwatch()..start();

      // Simulated initialization — in production, each branch would
      // call the actual init function (e.g. samInit, TfliteFlutter.loadModel).
      await _initModule(module);

      sw.stop();
      info.loadTimeMs = sw.elapsedMilliseconds;
      info.status = AiModuleStatus.ready;
      PerfCounters.instance.record(
        'ai_module_load_${module.name}',
        sw.elapsedMilliseconds.toDouble(),
      );
      _log.info('$module loaded in ${sw.elapsedMilliseconds}ms');

      completer.complete(AiModuleStatus.ready);
      return AiModuleStatus.ready;
    } catch (e) {
      info.status = AiModuleStatus.failed;
      info.errorMessage = e.toString();
      _log.warning('$module load failed: $e');
      completer.complete(AiModuleStatus.failed);
      return AiModuleStatus.failed;
    } finally {
      _inflight.remove(module);
    }
  }

  /// Unload a module, freeing resources.
  void unload(AiModule module) {
    final info = _modules[module];
    if (info == null) return;
    info.status = AiModuleStatus.notLoaded;
    info.errorMessage = null;
    info.loadTimeMs = 0;
    _log.info('$module unloaded');
  }

  /// Unload all modules.
  void unloadAll() {
    for (final module in AiModule.values) {
      unload(module);
    }
  }

  // ------------------------------------------------------------------

  bool _meetsRequirements(AiModule module) {
    final gate = FeatureGate.instance;
    switch (module) {
      case AiModule.samOnnx:
        return gate.isEnabled(AppFeature.samSegmentation);
      case AiModule.tfliteClassification:
      case AiModule.tfliteDetection:
        return gate.isEnabled(AppFeature.tfliteInference);
      case AiModule.mlKit:
        return gate.isEnabled(AppFeature.mlKitLabeling);
      case AiModule.externalStream:
        return gate.isEnabled(AppFeature.externalStreamInference);
    }
  }

  Future<void> _initModule(AiModule module) async {
    // Each module's actual initialization hook goes here.
    // Kept as a no-op placeholder to allow the loader to be tested
    // and wired into the UI independently of heavy native deps.
    switch (module) {
      case AiModule.samOnnx:
        _log.fine('SAM ONNX: initialization deferred to SamSegmentationService');
        break;
      case AiModule.tfliteClassification:
        _log.fine('TFLite classification: initialization deferred');
        break;
      case AiModule.tfliteDetection:
        _log.fine('TFLite detection: initialization deferred');
        break;
      case AiModule.mlKit:
        _log.fine('ML Kit: initialization deferred');
        break;
      case AiModule.externalStream:
        _log.fine('External stream: initialization deferred');
        break;
    }
  }
}

/// AI modules that can be lazily loaded.
enum AiModule {
  samOnnx,
  tfliteClassification,
  tfliteDetection,
  mlKit,
  externalStream,
}
