import 'dart:async';
import 'dart:collection';

/// Async semaphore that limits the number of concurrent tasks.
///
/// Use this to prevent memory spikes on iOS when multiple heavy
/// operations (frame decoding, TFLite inference, file I/O) run
/// simultaneously.
///
/// ```dart
/// final limiter = ConcurrencyLimiter(maxConcurrent: 3);
/// final results = await Future.wait(
///   items.map((item) => limiter.run(() => processItem(item))),
/// );
/// ```
class ConcurrencyLimiter {
  final int maxConcurrent;
  int _running = 0;
  final Queue<Completer<void>> _queue = Queue();

  ConcurrencyLimiter({this.maxConcurrent = 4});

  /// Number of tasks currently executing.
  int get running => _running;

  /// Number of tasks waiting in the queue.
  int get waiting => _queue.length;

  /// Whether a slot is available immediately.
  bool get hasCapacity => _running < maxConcurrent;

  /// Run [task] when a slot is available. Returns the task's result.
  Future<T> run<T>(Future<T> Function() task) async {
    await _acquire();
    try {
      return await task();
    } finally {
      _release();
    }
  }

  /// Run all [tasks] with concurrency limiting.
  /// Returns results in the same order as the input.
  Future<List<T>> runAll<T>(List<Future<T> Function()> tasks) {
    return Future.wait(tasks.map((t) => run(t)));
  }

  Future<void> _acquire() async {
    if (_running < maxConcurrent) {
      _running++;
      return;
    }
    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
  }

  void _release() {
    if (_queue.isNotEmpty) {
      final next = _queue.removeFirst();
      next.complete();
    } else {
      _running--;
    }
  }
}
