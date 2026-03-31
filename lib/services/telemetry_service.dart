import 'dart:collection';

import 'package:logging/logging.dart';

final _log = Logger('TelemetryService');

/// Severity / category of a telemetry event.
enum TelemetrySeverity { info, warning, error }

/// A structured telemetry event with typed properties.
///
/// Each event has a fixed [name] (e.g. `media_import_started`), a
/// [timestamp], a [severity], and an arbitrary [properties] bag for
/// domain-specific context.
class TelemetryEvent {
  final String name;
  final DateTime timestamp;
  final TelemetrySeverity severity;
  final Map<String, dynamic> properties;
  final String? errorMessage;
  final String? stackTrace;

  TelemetryEvent({
    required this.name,
    DateTime? timestamp,
    this.severity = TelemetrySeverity.info,
    Map<String, dynamic>? properties,
    this.errorMessage,
    this.stackTrace,
  })  : timestamp = timestamp ?? DateTime.now(),
        properties = properties ?? {};

  Map<String, dynamic> toMap() => {
        'name': name,
        'timestamp': timestamp.toIso8601String(),
        'severity': severity.name,
        if (properties.isNotEmpty) 'properties': properties,
        if (errorMessage != null) 'error': errorMessage,
        if (stackTrace != null) 'stackTrace': stackTrace,
      };

  @override
  String toString() {
    final buf = StringBuffer('[${timestamp.toIso8601String()}] '
        '${severity.name.toUpperCase()} $name');
    if (properties.isNotEmpty) {
      buf.write(' ${_flattenProps(properties)}');
    }
    if (errorMessage != null) buf.write(' ERROR=$errorMessage');
    return buf.toString();
  }

  static String _flattenProps(Map<String, dynamic> props) {
    return props.entries
        .map((e) => '${e.key}=${e.value}')
        .join(', ');
  }
}

/// Central telemetry bus.
///
/// - Accepts [TelemetryEvent]s from anywhere in the app.
/// - Stores them in a bounded in-memory ring buffer.
/// - Forwards to [Logger] for console / file output.
/// - Supports listeners for real-time consumption.
class TelemetryService {
  TelemetryService._();
  static final TelemetryService instance = TelemetryService._();

  /// Visible-for-testing constructor.
  TelemetryService.create();

  static const int maxEvents = 2000;

  final Queue<TelemetryEvent> _events = Queue<TelemetryEvent>();
  final List<void Function(TelemetryEvent)> _listeners = [];

  /// Emit a telemetry event.
  void track(TelemetryEvent event) {
    _events.addLast(event);
    while (_events.length > maxEvents) {
      _events.removeFirst();
    }

    _logEvent(event);

    for (final listener in _listeners) {
      try {
        listener(event);
      } catch (e) {
        _log.warning('Telemetry listener error: $e');
      }
    }
  }

  /// Convenience: track with a name and optional properties.
  void trackEvent(
    String name, {
    Map<String, dynamic>? properties,
    TelemetrySeverity severity = TelemetrySeverity.info,
    String? error,
  }) {
    track(TelemetryEvent(
      name: name,
      properties: properties,
      severity: severity,
      errorMessage: error,
    ));
  }

  /// All events in the buffer (oldest first).
  List<TelemetryEvent> get events => _events.toList();

  /// Events filtered by name prefix.
  List<TelemetryEvent> eventsByPrefix(String prefix) =>
      _events.where((e) => e.name.startsWith(prefix)).toList();

  /// Event count.
  int get eventCount => _events.length;

  /// Add a listener called on each new event.
  void addListener(void Function(TelemetryEvent) listener) {
    _listeners.add(listener);
  }

  /// Remove a previously added listener.
  void removeListener(void Function(TelemetryEvent) listener) {
    _listeners.remove(listener);
  }

  /// Clear the event buffer.
  void clear() => _events.clear();

  void _logEvent(TelemetryEvent event) {
    Level level;
    switch (event.severity) {
      case TelemetrySeverity.info:
        level = Level.INFO;
        break;
      case TelemetrySeverity.warning:
        level = Level.WARNING;
        break;
      case TelemetrySeverity.error:
        level = Level.SEVERE;
        break;
    }
    _log.log(level, event.toString());
  }
}

// ---------------------------------------------------------------------------
// Domain-specific telemetry helpers
// ---------------------------------------------------------------------------

/// Media import telemetry.
class MediaImportTelemetry {
  static void started({
    required String source,
    required int fileCount,
    String? projectId,
  }) {
    TelemetryService.instance.trackEvent(
      'media_import_started',
      properties: {
        'source': source,
        'file_count': fileCount,
        if (projectId != null) 'project_id': projectId,
      },
    );
  }

  static void finished({
    required int importedCount,
    required int skippedCount,
    required int durationMs,
    String? projectId,
  }) {
    TelemetryService.instance.trackEvent(
      'media_import_finished',
      properties: {
        'imported': importedCount,
        'skipped': skippedCount,
        'duration_ms': durationMs,
        if (projectId != null) 'project_id': projectId,
      },
    );
  }

  static void failed({
    required String reason,
    String? filePath,
    String? projectId,
  }) {
    TelemetryService.instance.trackEvent(
      'media_import_failed',
      severity: TelemetrySeverity.error,
      error: reason,
      properties: {
        if (filePath != null) 'file': filePath,
        if (projectId != null) 'project_id': projectId,
      },
    );
  }
}

/// Frame extraction telemetry.
class FrameExtractionTelemetry {
  static void stats({
    required String videoId,
    required int frameCount,
    required int durationMs,
    required double fps,
    String? ffmpegSource,
  }) {
    TelemetryService.instance.trackEvent(
      'frame_extraction_stats',
      properties: {
        'video_id': videoId,
        'frame_count': frameCount,
        'duration_ms': durationMs,
        'fps': fps,
        if (ffmpegSource != null) 'ffmpeg_source': ffmpegSource,
        if (durationMs > 0)
          'frames_per_sec':
              (frameCount / (durationMs / 1000.0)).toStringAsFixed(1),
      },
    );
  }
}

/// AI job state change telemetry.
class AiJobTelemetry {
  static void stateChanged({
    required String jobId,
    required String capability,
    required String fromStatus,
    required String toStatus,
    double? progress,
    String? errorCode,
  }) {
    final severity = toStatus == 'failed'
        ? TelemetrySeverity.error
        : TelemetrySeverity.info;

    TelemetryService.instance.trackEvent(
      'ai_job_state_changed',
      severity: severity,
      error: errorCode,
      properties: {
        'job_id': jobId,
        'capability': capability,
        'from': fromStatus,
        'to': toStatus,
        if (progress != null) 'progress': progress,
      },
    );
  }
}

/// Annotation review metrics telemetry.
class ReviewMetricsTelemetry {
  static void reviewed({
    required String trackId,
    required String fromStatus,
    required String toStatus,
    required String reviewerRole,
    int? annotationCount,
  }) {
    TelemetryService.instance.trackEvent(
      'annotation_review_status_changed',
      properties: {
        'track_id': trackId,
        'from': fromStatus,
        'to': toStatus,
        'reviewer_role': reviewerRole,
        if (annotationCount != null) 'annotation_count': annotationCount,
      },
    );
  }

  static void batchReviewed({
    required int trackCount,
    required String toStatus,
    required int durationMs,
  }) {
    TelemetryService.instance.trackEvent(
      'annotation_review_batch',
      properties: {
        'track_count': trackCount,
        'to_status': toStatus,
        'duration_ms': durationMs,
      },
    );
  }
}
