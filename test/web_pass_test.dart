import 'package:flutter_test/flutter_test.dart';

import 'package:annotateit/services/browser_capabilities.dart';
import 'package:annotateit/services/feature_gate.dart';
import 'package:annotateit/services/deferred_ai_loader.dart';

void main() {
  // ---------------------------------------------------------------------------
  // BrowserCapabilities
  // ---------------------------------------------------------------------------
  group('BrowserCapabilities', () {
    setUp(() {
      BrowserCapabilities.instance.invalidate();
    });

    test('detect returns a status for every WebCapability', () {
      final caps = BrowserCapabilities.instance.detect();
      for (final cap in WebCapability.values) {
        expect(caps.containsKey(cap), isTrue,
            reason: '${cap.name} missing from detection result');
        expect(caps[cap]!.reason, isNotEmpty);
      }
    });

    test('isAvailable delegates to detect map', () {
      final caps = BrowserCapabilities.instance.detect();
      for (final cap in WebCapability.values) {
        expect(
          BrowserCapabilities.instance.isAvailable(cap),
          caps[cap]!.available,
        );
      }
    });

    test('unavailable returns only false entries', () {
      final missing = BrowserCapabilities.instance.unavailable();
      for (final s in missing) {
        expect(s.available, isFalse);
      }
    });

    test('summary produces non-empty output', () {
      final s = BrowserCapabilities.instance.summary();
      expect(s, contains('Browser Capabilities'));
      expect(s, contains('fileSystem'));
    });

    test('invalidate forces re-detection', () {
      BrowserCapabilities.instance.detect();
      BrowserCapabilities.instance.invalidate();
      // Should not throw.
      final caps = BrowserCapabilities.instance.detect();
      expect(caps, isNotEmpty);
    });

    test('CapabilityStatus toString', () {
      const s = CapabilityStatus(
        capability: WebCapability.camera,
        available: true,
        reason: 'test',
      );
      expect(s.toString(), contains('camera'));
      expect(s.toString(), contains('true'));
    });

    test('native platform: fileSystem available, webAssembly not', () {
      // Running tests on native (desktop) → fileSystem should be true,
      // webAssembly should be false (it's web-only).
      expect(
        BrowserCapabilities.instance.isAvailable(WebCapability.fileSystem),
        isTrue,
      );
      expect(
        BrowserCapabilities.instance.isAvailable(WebCapability.webAssembly),
        isFalse,
      );
    });

    test('native platform: ffmpegCli available', () {
      expect(
        BrowserCapabilities.instance.isAvailable(WebCapability.ffmpegCli),
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // FeatureGate
  // ---------------------------------------------------------------------------
  group('FeatureGate', () {
    setUp(() {
      BrowserCapabilities.instance.invalidate();
      FeatureGate.instance.clearAllOverrides();
    });

    test('snapshot returns an entry for every AppFeature', () {
      final snap = FeatureGate.instance.snapshot();
      for (final f in AppFeature.values) {
        expect(snap.containsKey(f), isTrue);
      }
    });

    test('features with no requirements are always enabled', () {
      expect(
        FeatureGate.instance.isEnabled(AppFeature.videoTimeline),
        isTrue,
      );
      expect(
        FeatureGate.instance.isEnabled(AppFeature.externalStreamInference),
        isTrue,
      );
    });

    test('setOverride forces a feature on or off', () {
      FeatureGate.instance.setOverride(AppFeature.videoTimeline, false);
      expect(FeatureGate.instance.isEnabled(AppFeature.videoTimeline), isFalse);
      expect(
        FeatureGate.instance.disabledReason(AppFeature.videoTimeline),
        'Manually disabled',
      );

      FeatureGate.instance.setOverride(AppFeature.videoTimeline, true);
      expect(FeatureGate.instance.isEnabled(AppFeature.videoTimeline), isTrue);
      expect(
        FeatureGate.instance.disabledReason(AppFeature.videoTimeline),
        'Manually enabled',
      );
    });

    test('clearOverride reverts to capability detection', () {
      FeatureGate.instance.setOverride(AppFeature.dragAndDrop, false);
      expect(FeatureGate.instance.isEnabled(AppFeature.dragAndDrop), isFalse);

      FeatureGate.instance.clearOverride(AppFeature.dragAndDrop);
      // On native, fileSystem is available so dragAndDrop should be enabled.
      expect(FeatureGate.instance.isEnabled(AppFeature.dragAndDrop), isTrue);
    });

    test('clearAllOverrides removes all overrides', () {
      FeatureGate.instance.setOverride(AppFeature.videoTimeline, false);
      FeatureGate.instance.setOverride(AppFeature.dragAndDrop, false);
      FeatureGate.instance.clearAllOverrides();
      expect(FeatureGate.instance.isEnabled(AppFeature.videoTimeline), isTrue);
      expect(FeatureGate.instance.isEnabled(AppFeature.dragAndDrop), isTrue);
    });

    test('disabledReason returns capability reason for disabled features', () {
      // On native, samSegmentation requires webAssembly which is false.
      // But samSegmentation's requirement is webAssembly, which is
      // only available on web. On native, the feature gate says webAssembly
      // is not available, so samSegmentation is disabled.
      final reason = FeatureGate.instance.disabledReason(
        AppFeature.samSegmentation,
      );
      // On native this will mention WASM not applicable.
      expect(reason, isNot('Available'));
    });

    test('native platform enables dragAndDrop and exportZip', () {
      expect(FeatureGate.instance.isEnabled(AppFeature.dragAndDrop), isTrue);
      expect(FeatureGate.instance.isEnabled(AppFeature.exportZip), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // DeferredAiLoader
  // ---------------------------------------------------------------------------
  group('DeferredAiLoader', () {
    late DeferredAiLoader loader;

    setUp(() {
      BrowserCapabilities.instance.invalidate();
      FeatureGate.instance.clearAllOverrides();
      loader = DeferredAiLoader.instance;
      loader.unloadAll();
    });

    test('status returns notLoaded for unknown module', () {
      final info = loader.status(AiModule.samOnnx);
      expect(info.status, AiModuleStatus.notLoaded);
      expect(info.name, 'samOnnx');
    });

    test('ensureLoaded returns unavailable when platform lacks capability', () async {
      // On native desktop, samSegmentation requires webAssembly → unavailable.
      final result = await loader.ensureLoaded(AiModule.samOnnx);
      expect(result, AiModuleStatus.unavailable);
      expect(loader.status(AiModule.samOnnx).status,
          AiModuleStatus.unavailable);
    });

    test('ensureLoaded succeeds for externalStream (no requirements)', () async {
      final result = await loader.ensureLoaded(AiModule.externalStream);
      expect(result, AiModuleStatus.ready);
      expect(loader.status(AiModule.externalStream).loadTimeMs,
          greaterThanOrEqualTo(0));
    });

    test('ensureLoaded is idempotent', () async {
      await loader.ensureLoaded(AiModule.externalStream);
      final second = await loader.ensureLoaded(AiModule.externalStream);
      expect(second, AiModuleStatus.ready);
    });

    test('unload resets module to notLoaded', () async {
      await loader.ensureLoaded(AiModule.externalStream);
      loader.unload(AiModule.externalStream);
      expect(loader.status(AiModule.externalStream).status,
          AiModuleStatus.notLoaded);
    });

    test('unloadAll resets all modules', () async {
      await loader.ensureLoaded(AiModule.externalStream);
      loader.unloadAll();
      for (final m in AiModule.values) {
        final info = loader.status(m);
        expect(
          info.status,
          anyOf(AiModuleStatus.notLoaded, AiModuleStatus.unavailable),
        );
      }
    });

    test('concurrent ensureLoaded calls share the same future', () async {
      final futures = [
        loader.ensureLoaded(AiModule.externalStream),
        loader.ensureLoaded(AiModule.externalStream),
        loader.ensureLoaded(AiModule.externalStream),
      ];
      final results = await Future.wait(futures);
      expect(results, everyElement(AiModuleStatus.ready));
    });

    test('AiModuleInfo toString is descriptive', () {
      final info = AiModuleInfo(
        name: 'test',
        status: AiModuleStatus.ready,
      );
      expect(info.toString(), contains('test'));
      expect(info.toString(), contains('ready'));
    });

    test('allModules returns loaded modules', () async {
      await loader.ensureLoaded(AiModule.externalStream);
      final all = loader.allModules;
      expect(all.containsKey(AiModule.externalStream), isTrue);
      expect(all[AiModule.externalStream]!.status, AiModuleStatus.ready);
    });

    test('mlKit module is unavailable on desktop', () async {
      final result = await loader.ensureLoaded(AiModule.mlKit);
      expect(result, AiModuleStatus.unavailable);
    });
  });
}
