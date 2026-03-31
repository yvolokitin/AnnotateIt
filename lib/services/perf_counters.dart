import 'dart:collection';

import 'package:logging/logging.dart';

final _log = Logger('PerfCounters');

/// Lightweight performance measurement service.
///
/// Tracks named counters with running statistics (count, min, max, mean,
/// p95) — no external dependencies. Designed for hot paths: measurement
/// overhead is a few microseconds per call.
///
/// Usage:
/// ```dart
/// final timer = PerfCounters.instance.startTimer('frame_extraction');
/// // … work …
/// timer.stop();
///
/// PerfCounters.instance.record('annotation_count', annotations.length);
/// ```
class PerfCounters {
  static final PerfCounters instance = PerfCounters._();
  PerfCounters._();

  /// Visible-for-testing constructor.
  PerfCounters.create();

  final Map<String, PerfSeries> _series = {};

  /// Start a new timer. Call [PerfTimer.stop] when done.
  PerfTimer startTimer(String name) {
    return PerfTimer._(name, this);
  }

  /// Record a single numeric sample for [name].
  void record(String name, double value) {
    _seriesFor(name).add(value);
  }

  /// Record duration in milliseconds.
  void recordMs(String name, int ms) {
    _seriesFor(name).add(ms.toDouble());
  }

  /// Measure an async function and record its duration.
  Future<T> measureAsync<T>(String name, Future<T> Function() fn) async {
    final sw = Stopwatch()..start();
    try {
      return await fn();
    } finally {
      sw.stop();
      recordMs(name, sw.elapsedMilliseconds);
    }
  }

  /// Measure a sync function and record its duration.
  T measureSync<T>(String name, T Function() fn) {
    final sw = Stopwatch()..start();
    try {
      return fn();
    } finally {
      sw.stop();
      recordMs(name, sw.elapsedMilliseconds);
    }
  }

  /// Get snapshot of a named series.
  PerfSnapshot? snapshot(String name) => _series[name]?.snapshot();

  /// Get snapshots for all tracked series.
  Map<String, PerfSnapshot> allSnapshots() {
    return {
      for (final e in _series.entries) e.key: e.value.snapshot(),
    };
  }

  /// Log all counters at INFO level.
  void logAll() {
    for (final e in _series.entries) {
      _log.info('${e.key}: ${e.value.snapshot()}');
    }
  }

  /// Reset a specific counter.
  void reset(String name) => _series.remove(name);

  /// Reset all counters.
  void resetAll() => _series.clear();

  /// Names of all tracked series.
  List<String> get names => _series.keys.toList();

  PerfSeries _seriesFor(String name) {
    return _series.putIfAbsent(name, () => PerfSeries._());
  }
}

/// A running statistical series. Keeps the last [maxSamples] values
/// for percentile calculation while maintaining O(1) running stats.
class PerfSeries {
  static const int maxSamples = 1000;

  int _count = 0;
  double _sum = 0;
  double _min = double.infinity;
  double _max = double.negativeInfinity;
  final Queue<double> _recent = Queue<double>();

  PerfSeries._();

  void add(double value) {
    _count++;
    _sum += value;
    if (value < _min) _min = value;
    if (value > _max) _max = value;

    _recent.addLast(value);
    if (_recent.length > maxSamples) _recent.removeFirst();
  }

  PerfSnapshot snapshot() {
    if (_count == 0) return PerfSnapshot.empty;

    double p95 = _max;
    if (_recent.length >= 20) {
      final sorted = _recent.toList()..sort();
      final idx = ((sorted.length - 1) * 0.95).floor();
      p95 = sorted[idx];
    }

    return PerfSnapshot(
      count: _count,
      sum: _sum,
      min: _min,
      max: _max,
      mean: _sum / _count,
      p95: p95,
      lastN: _recent.length,
    );
  }
}

/// Immutable snapshot of a performance series.
class PerfSnapshot {
  final int count;
  final double sum;
  final double min;
  final double max;
  final double mean;
  final double p95;
  final int lastN;

  const PerfSnapshot({
    required this.count,
    required this.sum,
    required this.min,
    required this.max,
    required this.mean,
    required this.p95,
    required this.lastN,
  });

  static const PerfSnapshot empty = PerfSnapshot(
    count: 0, sum: 0, min: 0, max: 0, mean: 0, p95: 0, lastN: 0,
  );

  Map<String, dynamic> toMap() => {
    'count': count,
    'sum': sum,
    'min': min,
    'max': max,
    'mean': mean.toStringAsFixed(2),
    'p95': p95.toStringAsFixed(2),
    'lastN': lastN,
  };

  @override
  String toString() =>
      'n=$count, mean=${mean.toStringAsFixed(1)}ms, '
      'p95=${p95.toStringAsFixed(1)}ms, '
      'min=${min.toStringAsFixed(1)}, max=${max.toStringAsFixed(1)}';
}

/// RAII-style timer returned by [PerfCounters.startTimer].
class PerfTimer {
  final String _name;
  final PerfCounters _counters;
  final Stopwatch _sw = Stopwatch();
  bool _stopped = false;

  PerfTimer._(this._name, this._counters) {
    _sw.start();
  }

  /// Stop the timer and record the elapsed time.
  /// Returns elapsed milliseconds.
  int stop() {
    if (_stopped) return _sw.elapsedMilliseconds;
    _stopped = true;
    _sw.stop();
    _counters.recordMs(_name, _sw.elapsedMilliseconds);
    return _sw.elapsedMilliseconds;
  }

  int get elapsedMs => _sw.elapsedMilliseconds;
}
