import 'dart:convert';

import 'package:logging/logging.dart';

import '../utils/platform_utils.dart';
import 'browser_capabilities.dart';
import 'feature_gate.dart';
import 'perf_counters.dart';
import 'telemetry_service.dart';

final _log = Logger('DiagnosticReport');

/// A self-contained diagnostic report that bundles:
///
/// - Platform/environment info
/// - Browser capabilities snapshot
/// - Feature gate state
/// - Performance counter snapshots
/// - Recent telemetry events
/// - Error/warning events summary
///
/// Can be serialised to JSON for file export or support submission.
class DiagnosticReport {
  final DateTime generatedAt;
  final Map<String, dynamic> platform;
  final Map<String, dynamic> capabilities;
  final Map<String, bool> features;
  final Map<String, Map<String, dynamic>> perfCounters;
  final List<Map<String, dynamic>> recentEvents;
  final List<Map<String, dynamic>> errors;
  final Map<String, int> eventCounts;

  DiagnosticReport({
    required this.generatedAt,
    required this.platform,
    required this.capabilities,
    required this.features,
    required this.perfCounters,
    required this.recentEvents,
    required this.errors,
    required this.eventCounts,
  });

  /// Generate a full diagnostic report from current app state.
  factory DiagnosticReport.generate() {
    final now = DateTime.now();

    // Platform info
    final platform = <String, dynamic>{
      'os': PlatformUtils.operatingSystem,
      'isWeb': PlatformUtils.isWeb,
      'isDesktop': PlatformUtils.isDesktop,
      'isMobile': PlatformUtils.isMobile,
      'processors': PlatformUtils.numberOfProcessors,
    };

    // Browser/platform capabilities
    final capsMap = <String, dynamic>{};
    for (final entry in BrowserCapabilities.instance.detect().entries) {
      capsMap[entry.key.name] = {
        'available': entry.value.available,
        'reason': entry.value.reason,
      };
    }

    // Feature gate
    final featureMap = FeatureGate.instance.snapshot();
    final features = <String, bool>{
      for (final e in featureMap.entries) e.key.name: e.value,
    };

    // Perf counters
    final perfMap = <String, Map<String, dynamic>>{};
    for (final e in PerfCounters.instance.allSnapshots().entries) {
      perfMap[e.key] = e.value.toMap();
    }

    // Telemetry events
    final telemetry = TelemetryService.instance;
    final allEvents = telemetry.events;

    final recentEvents = allEvents
        .reversed
        .take(200)
        .map((e) => e.toMap())
        .toList();

    final errors = allEvents
        .where((e) =>
            e.severity == TelemetrySeverity.error ||
            e.severity == TelemetrySeverity.warning)
        .map((e) => e.toMap())
        .toList();

    // Event frequency histogram
    final eventCounts = <String, int>{};
    for (final e in allEvents) {
      eventCounts[e.name] = (eventCounts[e.name] ?? 0) + 1;
    }

    return DiagnosticReport(
      generatedAt: now,
      platform: platform,
      capabilities: capsMap,
      features: features,
      perfCounters: perfMap,
      recentEvents: recentEvents,
      errors: errors,
      eventCounts: eventCounts,
    );
  }

  /// Serialize to a JSON map.
  Map<String, dynamic> toMap() => {
        'generated_at': generatedAt.toIso8601String(),
        'platform': platform,
        'capabilities': capabilities,
        'features': features,
        'perf_counters': perfCounters,
        'event_counts': eventCounts,
        'errors': errors,
        'recent_events': recentEvents,
      };

  /// Pretty-printed JSON string suitable for file export.
  String toJson() =>
      const JsonEncoder.withIndent('  ').convert(toMap());

  /// Human-readable plain-text summary for quick inspection.
  String toTextSummary() {
    final buf = StringBuffer();
    buf.writeln('=== AnnotateIt Diagnostic Report ===');
    buf.writeln('Generated: ${generatedAt.toIso8601String()}');
    buf.writeln();

    buf.writeln('--- Platform ---');
    for (final e in platform.entries) {
      buf.writeln('  ${e.key}: ${e.value}');
    }
    buf.writeln();

    buf.writeln('--- Features ---');
    for (final e in features.entries) {
      buf.writeln('  ${e.key}: ${e.value ? "ENABLED" : "DISABLED"}');
    }
    buf.writeln();

    buf.writeln('--- Performance Counters ---');
    if (perfCounters.isEmpty) {
      buf.writeln('  (none recorded)');
    }
    for (final e in perfCounters.entries) {
      buf.writeln('  ${e.key}: ${e.value}');
    }
    buf.writeln();

    buf.writeln('--- Event Histogram ---');
    if (eventCounts.isEmpty) {
      buf.writeln('  (no events)');
    }
    final sorted = eventCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final e in sorted) {
      buf.writeln('  ${e.key}: ${e.value}');
    }
    buf.writeln();

    buf.writeln('--- Errors (${errors.length}) ---');
    for (final e in errors) {
      buf.writeln('  [${e['timestamp']}] ${e['name']}'
          '${e['error'] != null ? " — ${e['error']}" : ""}');
    }

    return buf.toString();
  }

  /// Total number of error-level events.
  int get errorCount =>
      errors.where((e) => e['severity'] == 'error').length;

  /// Total number of warning-level events.
  int get warningCount =>
      errors.where((e) => e['severity'] == 'warning').length;
}

/// Generates a diagnostic report and returns it.
///
/// On native platforms this can be saved to a file via the caller;
/// the report itself is platform-agnostic.
DiagnosticReport generateDiagnosticReport() {
  _log.info('Generating diagnostic report');
  return DiagnosticReport.generate();
}
