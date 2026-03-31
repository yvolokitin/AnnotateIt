import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:annotateit/services/telemetry_service.dart';
import 'package:annotateit/services/diagnostic_report.dart';

void main() {
  // ---------------------------------------------------------------------------
  // TelemetryEvent
  // ---------------------------------------------------------------------------
  group('TelemetryEvent', () {
    test('toMap includes all fields', () {
      final event = TelemetryEvent(
        name: 'test_event',
        severity: TelemetrySeverity.error,
        properties: {'key': 'value', 'count': 42},
        errorMessage: 'something broke',
        stackTrace: 'at line 5',
      );
      final map = event.toMap();
      expect(map['name'], 'test_event');
      expect(map['severity'], 'error');
      expect(map['properties'], {'key': 'value', 'count': 42});
      expect(map['error'], 'something broke');
      expect(map['stackTrace'], 'at line 5');
      expect(map.containsKey('timestamp'), isTrue);
    });

    test('toMap omits null/empty optional fields', () {
      final event = TelemetryEvent(name: 'simple');
      final map = event.toMap();
      expect(map.containsKey('error'), isFalse);
      expect(map.containsKey('stackTrace'), isFalse);
      expect(map.containsKey('properties'), isFalse);
    });

    test('toString includes name and severity', () {
      final event = TelemetryEvent(
        name: 'test_event',
        severity: TelemetrySeverity.warning,
        properties: {'x': 1},
      );
      final s = event.toString();
      expect(s, contains('WARNING'));
      expect(s, contains('test_event'));
      expect(s, contains('x=1'));
    });

    test('timestamp defaults to now', () {
      final before = DateTime.now();
      final event = TelemetryEvent(name: 'ts_test');
      final after = DateTime.now();
      expect(event.timestamp.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(event.timestamp.isBefore(after.add(const Duration(seconds: 1))), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // TelemetryService
  // ---------------------------------------------------------------------------
  group('TelemetryService', () {
    late TelemetryService service;

    setUp(() {
      service = TelemetryService.create();
    });

    test('track stores events in order', () {
      service.trackEvent('a');
      service.trackEvent('b');
      service.trackEvent('c');
      expect(service.eventCount, 3);
      expect(service.events.map((e) => e.name).toList(), ['a', 'b', 'c']);
    });

    test('respects maxEvents ring buffer', () {
      for (int i = 0; i < TelemetryService.maxEvents + 50; i++) {
        service.trackEvent('event_$i');
      }
      expect(service.eventCount, TelemetryService.maxEvents);
      // Oldest events dropped
      expect(service.events.first.name, 'event_50');
    });

    test('trackEvent with severity and error', () {
      service.trackEvent(
        'fail_event',
        severity: TelemetrySeverity.error,
        error: 'oops',
        properties: {'code': 500},
      );
      final event = service.events.last;
      expect(event.name, 'fail_event');
      expect(event.severity, TelemetrySeverity.error);
      expect(event.errorMessage, 'oops');
      expect(event.properties['code'], 500);
    });

    test('eventsByPrefix filters correctly', () {
      service.trackEvent('media_import_started');
      service.trackEvent('media_import_finished');
      service.trackEvent('ai_job_state_changed');

      final mediaEvents = service.eventsByPrefix('media_import');
      expect(mediaEvents.length, 2);

      final aiEvents = service.eventsByPrefix('ai_job');
      expect(aiEvents.length, 1);
    });

    test('listeners are called on each event', () {
      final received = <String>[];
      service.addListener((e) => received.add(e.name));

      service.trackEvent('first');
      service.trackEvent('second');

      expect(received, ['first', 'second']);
    });

    test('removeListener stops callbacks', () {
      final received = <String>[];
      void listener(TelemetryEvent e) => received.add(e.name);
      service.addListener(listener);

      service.trackEvent('a');
      service.removeListener(listener);
      service.trackEvent('b');

      expect(received, ['a']);
    });

    test('listener exceptions do not break tracking', () {
      service.addListener((_) => throw Exception('bad listener'));
      service.addListener((e) {});

      // Should not throw
      service.trackEvent('safe');
      expect(service.eventCount, 1);
    });

    test('clear empties the buffer', () {
      service.trackEvent('a');
      service.trackEvent('b');
      service.clear();
      expect(service.eventCount, 0);
      expect(service.events, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Domain-specific telemetry helpers
  // ---------------------------------------------------------------------------
  group('Domain telemetry helpers', () {
    setUp(() {
      // Use the singleton for domain helpers, but clear it first.
      TelemetryService.instance.clear();
    });

    test('MediaImportTelemetry.started', () {
      MediaImportTelemetry.started(
        source: 'file_picker',
        fileCount: 5,
        projectId: 'proj_123',
      );
      final events = TelemetryService.instance.eventsByPrefix('media_import');
      expect(events.length, 1);
      expect(events.first.name, 'media_import_started');
      expect(events.first.properties['source'], 'file_picker');
      expect(events.first.properties['file_count'], 5);
    });

    test('MediaImportTelemetry.finished', () {
      MediaImportTelemetry.finished(
        importedCount: 3,
        skippedCount: 2,
        durationMs: 1500,
      );
      final e = TelemetryService.instance.events.last;
      expect(e.name, 'media_import_finished');
      expect(e.properties['imported'], 3);
      expect(e.properties['skipped'], 2);
      expect(e.properties['duration_ms'], 1500);
    });

    test('MediaImportTelemetry.failed', () {
      MediaImportTelemetry.failed(
        reason: 'file not found',
        filePath: '/tmp/missing.jpg',
      );
      final e = TelemetryService.instance.events.last;
      expect(e.name, 'media_import_failed');
      expect(e.severity, TelemetrySeverity.error);
      expect(e.errorMessage, 'file not found');
    });

    test('FrameExtractionTelemetry.stats', () {
      FrameExtractionTelemetry.stats(
        videoId: 'vid_1',
        frameCount: 120,
        durationMs: 4000,
        fps: 30.0,
        ffmpegSource: 'wellKnownPath',
      );
      final e = TelemetryService.instance.events.last;
      expect(e.name, 'frame_extraction_stats');
      expect(e.properties['frame_count'], 120);
      expect(e.properties['ffmpeg_source'], 'wellKnownPath');
      expect(e.properties['frames_per_sec'], isNotNull);
    });

    test('AiJobTelemetry.stateChanged', () {
      AiJobTelemetry.stateChanged(
        jobId: 'job_42',
        capability: 'detection',
        fromStatus: 'queued',
        toStatus: 'running',
        progress: 0.5,
      );
      final e = TelemetryService.instance.events.last;
      expect(e.name, 'ai_job_state_changed');
      expect(e.properties['job_id'], 'job_42');
      expect(e.properties['from'], 'queued');
      expect(e.properties['to'], 'running');
      expect(e.properties['progress'], 0.5);
    });

    test('AiJobTelemetry.stateChanged with failed status sets error severity', () {
      AiJobTelemetry.stateChanged(
        jobId: 'job_99',
        capability: 'classification',
        fromStatus: 'running',
        toStatus: 'failed',
        errorCode: 'timeout',
      );
      final e = TelemetryService.instance.events.last;
      expect(e.severity, TelemetrySeverity.error);
      expect(e.errorMessage, 'timeout');
    });

    test('ReviewMetricsTelemetry.reviewed', () {
      ReviewMetricsTelemetry.reviewed(
        trackId: 'track_7',
        fromStatus: 'draft',
        toStatus: 'approved',
        reviewerRole: 'senior',
        annotationCount: 15,
      );
      final e = TelemetryService.instance.events.last;
      expect(e.name, 'annotation_review_status_changed');
      expect(e.properties['track_id'], 'track_7');
      expect(e.properties['to'], 'approved');
      expect(e.properties['annotation_count'], 15);
    });

    test('ReviewMetricsTelemetry.batchReviewed', () {
      ReviewMetricsTelemetry.batchReviewed(
        trackCount: 10,
        toStatus: 'approved',
        durationMs: 800,
      );
      final e = TelemetryService.instance.events.last;
      expect(e.name, 'annotation_review_batch');
      expect(e.properties['track_count'], 10);
    });
  });

  // ---------------------------------------------------------------------------
  // DiagnosticReport
  // ---------------------------------------------------------------------------
  group('DiagnosticReport', () {
    setUp(() {
      TelemetryService.instance.clear();
    });

    test('generate produces a valid report', () {
      TelemetryService.instance.trackEvent('test_event');
      TelemetryService.instance.trackEvent(
        'test_error',
        severity: TelemetrySeverity.error,
        error: 'boom',
      );

      final report = DiagnosticReport.generate();
      expect(report.generatedAt, isNotNull);
      expect(report.platform['os'], isA<String>());
      expect(report.features, isNotEmpty);
      expect(report.recentEvents, isNotEmpty);
      expect(report.errors.length, 1);
      expect(report.eventCounts['test_event'], 1);
    });

    test('toMap is JSON-serializable', () {
      TelemetryService.instance.trackEvent('x');
      final report = DiagnosticReport.generate();
      final jsonStr = jsonEncode(report.toMap());
      expect(jsonStr, isNotEmpty);
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded['generated_at'], isNotNull);
    });

    test('toJson produces pretty-printed output', () {
      TelemetryService.instance.trackEvent('y');
      final report = DiagnosticReport.generate();
      final json = report.toJson();
      expect(json, contains('\n'));
      expect(json, contains('"generated_at"'));
    });

    test('toTextSummary produces readable output', () {
      TelemetryService.instance.trackEvent('z');
      final report = DiagnosticReport.generate();
      final text = report.toTextSummary();
      expect(text, contains('AnnotateIt Diagnostic Report'));
      expect(text, contains('Platform'));
      expect(text, contains('Features'));
      expect(text, contains('Event Histogram'));
    });

    test('errorCount and warningCount', () {
      TelemetryService.instance.trackEvent(
        'err1', severity: TelemetrySeverity.error, error: 'e1',
      );
      TelemetryService.instance.trackEvent(
        'warn1', severity: TelemetrySeverity.warning,
      );
      TelemetryService.instance.trackEvent('info1');

      final report = DiagnosticReport.generate();
      expect(report.errorCount, 1);
      expect(report.warningCount, 1);
    });

    test('empty telemetry produces valid report', () {
      final report = DiagnosticReport.generate();
      expect(report.recentEvents, isEmpty);
      expect(report.errors, isEmpty);
      expect(report.eventCounts, isEmpty);
      // Should still have platform and feature data
      expect(report.platform, isNotEmpty);
      expect(report.features, isNotEmpty);
    });

    test('generateDiagnosticReport convenience function works', () {
      final report = generateDiagnosticReport();
      expect(report, isA<DiagnosticReport>());
      expect(report.toJson(), isNotEmpty);
    });
  });
}
