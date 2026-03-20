import 'dart:async';
import 'dart:math';

enum AiJobStatus { queued, running, succeeded, failed, applied, canceled }

class AiJobSnapshot {
  final String id;
  final String capability;
  final String? idempotencyKey;
  final AiJobStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic payload;
  final Object? error;

  const AiJobSnapshot({
    required this.id,
    required this.capability,
    required this.idempotencyKey,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.payload,
    this.error,
  });

  AiJobSnapshot copyWith({
    AiJobStatus? status,
    DateTime? updatedAt,
    dynamic payload,
    Object? error,
    bool clearError = false,
  }) {
    return AiJobSnapshot(
      id: id,
      capability: capability,
      idempotencyKey: idempotencyKey,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      payload: payload ?? this.payload,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AiJobRunner {
  final Map<String, Future<AiJobSnapshot>> _inFlightByKey =
      <String, Future<AiJobSnapshot>>{};
  final Random _random;

  AiJobRunner({Random? random}) : _random = random ?? Random.secure();

  Future<AiJobSnapshot> runJob({
    required String capability,
    String? idempotencyKey,
    Duration? timeout,
    required Future<dynamic> Function() execute,
  }) {
    final normalizedKey = _normalizeIdempotencyKey(idempotencyKey);
    if (normalizedKey != null && _inFlightByKey.containsKey(normalizedKey)) {
      return _inFlightByKey[normalizedKey]!;
    }

    final future = _runJobInternal(
      capability: capability,
      idempotencyKey: normalizedKey,
      timeout: timeout,
      execute: execute,
    );

    if (normalizedKey != null) {
      _inFlightByKey[normalizedKey] = future;
      future.whenComplete(() {
        _inFlightByKey.remove(normalizedKey);
      });
    }
    return future;
  }

  Future<AiJobSnapshot> markApplied(AiJobSnapshot snapshot) async {
    if (snapshot.status != AiJobStatus.succeeded) {
      throw StateError(
        'Only succeeded jobs can be marked as applied. Current status: ${snapshot.status.name}',
      );
    }
    return snapshot.copyWith(
      status: AiJobStatus.applied,
      updatedAt: DateTime.now(),
    );
  }

  Future<AiJobSnapshot> _runJobInternal({
    required String capability,
    required String? idempotencyKey,
    required Duration? timeout,
    required Future<dynamic> Function() execute,
  }) async {
    var snapshot = AiJobSnapshot(
      id: _newJobId(),
      capability: capability,
      idempotencyKey: idempotencyKey,
      status: AiJobStatus.queued,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    snapshot = snapshot.copyWith(
      status: AiJobStatus.running,
      updatedAt: DateTime.now(),
    );

    try {
      final execution =
          timeout == null ? execute() : execute().timeout(timeout);
      final payload = await execution;
      snapshot = snapshot.copyWith(
        status: AiJobStatus.succeeded,
        payload: payload,
        updatedAt: DateTime.now(),
      );
    } on TimeoutException catch (e) {
      snapshot = snapshot.copyWith(
        status: AiJobStatus.failed,
        error: e,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      snapshot = snapshot.copyWith(
        status: AiJobStatus.failed,
        error: e,
        updatedAt: DateTime.now(),
      );
    }
    return snapshot;
  }

  String _newJobId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final salt = _random.nextInt(1 << 20).toRadixString(16).padLeft(5, '0');
    return 'job_${ts}_$salt';
  }

  String? _normalizeIdempotencyKey(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
