import 'package:flutter_test/flutter_test.dart';

import 'package:annotateit/services/perf_counters.dart';

void main() {
  late PerfCounters counters;

  setUp(() {
    counters = PerfCounters.create();
  });

  // -----------------------------------------------------------------------
  // PerfCounters basic recording
  // -----------------------------------------------------------------------

  group('PerfCounters recording', () {
    test('record adds samples to a named series', () {
      counters.record('metric_a', 10);
      counters.record('metric_a', 20);
      counters.record('metric_a', 30);

      final snap = counters.snapshot('metric_a')!;
      expect(snap.count, 3);
      expect(snap.sum, 60);
      expect(snap.min, 10);
      expect(snap.max, 30);
      expect(snap.mean, 20);
    });

    test('recordMs records integer milliseconds', () {
      counters.recordMs('latency', 42);
      final snap = counters.snapshot('latency')!;
      expect(snap.count, 1);
      expect(snap.sum, 42);
    });

    test('snapshot returns null for unknown name', () {
      expect(counters.snapshot('nonexistent'), isNull);
    });

    test('names lists all tracked series', () {
      counters.record('a', 1);
      counters.record('b', 2);
      expect(counters.names, containsAll(['a', 'b']));
    });

    test('reset clears a specific counter', () {
      counters.record('x', 1);
      counters.reset('x');
      expect(counters.snapshot('x'), isNull);
    });

    test('resetAll clears everything', () {
      counters.record('a', 1);
      counters.record('b', 2);
      counters.resetAll();
      expect(counters.names, isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // PerfTimer
  // -----------------------------------------------------------------------

  group('PerfTimer', () {
    test('startTimer records elapsed time on stop', () async {
      final timer = counters.startTimer('op');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      final elapsed = timer.stop();

      expect(elapsed, greaterThanOrEqualTo(5));
      final snap = counters.snapshot('op')!;
      expect(snap.count, 1);
      expect(snap.min, greaterThanOrEqualTo(5));
    });

    test('double stop is idempotent', () async {
      final timer = counters.startTimer('op');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final e1 = timer.stop();
      final e2 = timer.stop();
      expect(e1, e2);

      final snap = counters.snapshot('op')!;
      expect(snap.count, 1);
    });

    test('elapsedMs is available before stop', () async {
      final timer = counters.startTimer('op');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(timer.elapsedMs, greaterThanOrEqualTo(3));
      timer.stop();
    });
  });

  // -----------------------------------------------------------------------
  // measureAsync / measureSync
  // -----------------------------------------------------------------------

  group('measure helpers', () {
    test('measureAsync records duration and returns value', () async {
      final result = await counters.measureAsync('async_op', () async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return 42;
      });

      expect(result, 42);
      final snap = counters.snapshot('async_op')!;
      expect(snap.count, 1);
      expect(snap.min, greaterThanOrEqualTo(5));
    });

    test('measureAsync records on exception', () async {
      try {
        await counters.measureAsync('fail_op', () async {
          throw Exception('boom');
        });
      } catch (_) {}

      final snap = counters.snapshot('fail_op')!;
      expect(snap.count, 1);
    });

    test('measureSync records duration', () {
      final result = counters.measureSync('sync_op', () {
        var x = 0;
        for (int i = 0; i < 100000; i++) {
          x += i;
        }
        return x;
      });

      expect(result, isNotNull);
      final snap = counters.snapshot('sync_op')!;
      expect(snap.count, 1);
    });
  });

  // -----------------------------------------------------------------------
  // PerfSnapshot
  // -----------------------------------------------------------------------

  group('PerfSnapshot', () {
    test('toMap includes all fields', () {
      final snap = PerfSnapshot(
        count: 10, sum: 100, min: 5, max: 20,
        mean: 10, p95: 18, lastN: 10,
      );
      final map = snap.toMap();
      expect(map['count'], 10);
      expect(map['sum'], 100);
      expect(map['min'], 5.0);
      expect(map['max'], 20.0);
      expect(map['lastN'], 10);
    });

    test('toString is readable', () {
      final snap = PerfSnapshot(
        count: 5, sum: 50, min: 8, max: 12,
        mean: 10, p95: 11.5, lastN: 5,
      );
      final s = snap.toString();
      expect(s, contains('n=5'));
      expect(s, contains('mean=10.0ms'));
    });

    test('empty snapshot has zeroes', () {
      expect(PerfSnapshot.empty.count, 0);
      expect(PerfSnapshot.empty.mean, 0);
    });
  });

  // -----------------------------------------------------------------------
  // PerfSeries statistics
  // -----------------------------------------------------------------------

  group('PerfSeries statistics', () {
    test('p95 is computed from recent samples', () {
      for (int i = 1; i <= 100; i++) {
        counters.record('dist', i.toDouble());
      }

      final snap = counters.snapshot('dist')!;
      expect(snap.count, 100);
      expect(snap.min, 1);
      expect(snap.max, 100);
      expect(snap.p95, greaterThanOrEqualTo(94));
      expect(snap.p95, lessThanOrEqualTo(96));
    });

    test('series with fewer than 20 samples uses max for p95', () {
      for (int i = 1; i <= 10; i++) {
        counters.record('small', i.toDouble());
      }

      final snap = counters.snapshot('small')!;
      expect(snap.p95, snap.max);
    });

    test('recent window is bounded', () {
      for (int i = 0; i < 1500; i++) {
        counters.record('overflow', i.toDouble());
      }

      final snap = counters.snapshot('overflow')!;
      expect(snap.count, 1500);
      expect(snap.lastN, PerfSeries.maxSamples);
    });
  });

  // -----------------------------------------------------------------------
  // allSnapshots
  // -----------------------------------------------------------------------

  group('allSnapshots', () {
    test('returns all tracked series', () {
      counters.record('a', 1);
      counters.record('b', 2);
      counters.record('c', 3);

      final all = counters.allSnapshots();
      expect(all.length, 3);
      expect(all.keys, containsAll(['a', 'b', 'c']));
    });

    test('logAll does not throw', () {
      counters.record('x', 42);
      counters.logAll();
    });
  });
}
