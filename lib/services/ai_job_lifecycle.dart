import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:logging/logging.dart';

import '../repositories/ai_job_repository.dart';

final _log = Logger('AiJobLifecycle');

enum AiJobStatus { queued, running, succeeded, failed, canceled, applied }

/// Persistent snapshot of an AI job's state.
///
/// Extended with [progress], [startedAt], [finishedAt], and [errorCode]
/// to support long-running tasks and resume after app restart.
class AiJobSnapshot {
  final String id;
  final String capability;
  final String? idempotencyKey;
  final AiJobStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Progress percentage 0–100. -1 if unknown.
  final int progress;

  /// When the job started executing (status transitioned to [running]).
  final DateTime? startedAt;

  /// When the job finished (succeeded, failed, or canceled).
  final DateTime? finishedAt;

  /// Machine-readable error code (e.g. "timeout", "oom", "model_not_found").
  final String? errorCode;

  /// Serialised payload (JSON string for persistence, or a typed object
  /// when held in memory). `null` until the job succeeds.
  final dynamic payload;

  /// Error object (only in-memory; not persisted as-is).
  final Object? error;

  const AiJobSnapshot({
    required this.id,
    required this.capability,
    required this.idempotencyKey,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.progress = -1,
    this.startedAt,
    this.finishedAt,
    this.errorCode,
    this.payload,
    this.error,
  });

  bool get isTerminal =>
      status == AiJobStatus.succeeded ||
      status == AiJobStatus.failed ||
      status == AiJobStatus.canceled ||
      status == AiJobStatus.applied;

  bool get isResumable => status == AiJobStatus.running;

  AiJobSnapshot copyWith({
    AiJobStatus? status,
    DateTime? updatedAt,
    int? progress,
    DateTime? startedAt,
    DateTime? finishedAt,
    String? errorCode,
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
      progress: progress ?? this.progress,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      errorCode: errorCode ?? this.errorCode,
      payload: payload ?? this.payload,
      error: clearError ? null : (error ?? this.error),
    );
  }

  // -- Serialisation (for DB persistence) ------------------------------------

  Map<String, dynamic> toMap() => {
    'id': id,
    'capability': capability,
    'idempotency_key': idempotencyKey,
    'status': status.name,
    'progress': progress,
    'started_at': startedAt?.toIso8601String(),
    'finished_at': finishedAt?.toIso8601String(),
    'error_code': errorCode,
    'error_message': error?.toString(),
    'payload': payload is String ? payload : (payload != null ? jsonEncode(payload) : null),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory AiJobSnapshot.fromMap(Map<String, dynamic> map) {
    return AiJobSnapshot(
      id: map['id'] as String,
      capability: map['capability'] as String,
      idempotencyKey: map['idempotency_key'] as String?,
      status: AiJobStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String?),
        orElse: () => AiJobStatus.failed,
      ),
      progress: (map['progress'] as int?) ?? -1,
      startedAt: map['started_at'] != null
          ? DateTime.parse(map['started_at'] as String)
          : null,
      finishedAt: map['finished_at'] != null
          ? DateTime.parse(map['finished_at'] as String)
          : null,
      errorCode: map['error_code'] as String?,
      payload: map['payload'] as String?,
      error: map['error_message'] != null
          ? Exception(map['error_message'] as String)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  @override
  String toString() =>
      'AiJobSnapshot(id=$id, cap=$capability, status=${status.name}, '
      'progress=$progress%)';
}

/// Callback signature for resumable job executors.
///
/// When a job is resumed after app restart, the runner calls the registered
/// executor for the job's [capability] with the original snapshot, so the
/// executor can decide whether to restart or continue.
typedef AiJobExecutor = Future<dynamic> Function(
  AiJobSnapshot snapshot,
  void Function(int progress) onProgress,
);

/// Persistent AI job runner that stores job state in the database.
///
/// Jobs survive app restarts: on startup, call [resumeInterruptedJobs]
/// to re-execute any jobs that were in `running` or `queued` state.
class AiJobRunner {
  final AiJobRepository _repo;
  final Map<String, Future<AiJobSnapshot>> _inFlightByKey = {};
  final Map<String, AiJobExecutor> _executors = {};
  final Random _random;

  AiJobRunner({
    required AiJobRepository repository,
    Random? random,
  })  : _repo = repository,
        _random = random ?? Random.secure();

  /// Register an executor for a given capability so it can be resumed.
  void registerExecutor(String capability, AiJobExecutor executor) {
    _executors[capability] = executor;
  }

  /// Run a new job, persisting its state at each transition.
  Future<AiJobSnapshot> runJob({
    required String capability,
    String? idempotencyKey,
    Duration? timeout,
    required Future<dynamic> Function() execute,
    void Function(int progress)? onProgress,
  }) {
    final normalizedKey = _normalizeIdempotencyKey(idempotencyKey);
    if (normalizedKey != null && _inFlightByKey.containsKey(normalizedKey)) {
      return _inFlightByKey[normalizedKey]!;
    }

    final future = _runJobInternal(
      capability: capability,
      idempotencyKey: normalizedKey,
      timeout: timeout,
      execute: (_, onProg) async => await execute(),
      onProgress: onProgress,
    );

    if (normalizedKey != null) {
      _inFlightByKey[normalizedKey] = future;
      future.whenComplete(() => _inFlightByKey.remove(normalizedKey));
    }
    return future;
  }

  /// Mark a succeeded job as applied.
  Future<AiJobSnapshot> markApplied(AiJobSnapshot snapshot) async {
    if (snapshot.status != AiJobStatus.succeeded) {
      throw StateError(
        'Only succeeded jobs can be marked as applied. '
        'Current status: ${snapshot.status.name}',
      );
    }
    final updated = snapshot.copyWith(
      status: AiJobStatus.applied,
      updatedAt: DateTime.now(),
    );
    await _repo.update(updated);
    return updated;
  }

  /// Cancel a queued or running job.
  Future<AiJobSnapshot> cancelJob(String jobId) async {
    final snapshot = await _repo.findById(jobId);
    if (snapshot == null) throw StateError('Job $jobId not found');
    if (snapshot.isTerminal) {
      throw StateError('Cannot cancel a ${snapshot.status.name} job');
    }
    final now = DateTime.now();
    final updated = snapshot.copyWith(
      status: AiJobStatus.canceled,
      finishedAt: now,
      updatedAt: now,
    );
    await _repo.update(updated);
    return updated;
  }

  /// Resume all interrupted (running/queued) jobs from the database.
  ///
  /// Call this at app startup. Jobs without a registered executor are
  /// marked as failed with errorCode `no_executor`.
  Future<List<AiJobSnapshot>> resumeInterruptedJobs() async {
    final interrupted = await _repo.findResumable();
    final results = <AiJobSnapshot>[];

    for (final job in interrupted) {
      final executor = _executors[job.capability];
      if (executor == null) {
        _log.warning(
          'No executor for capability "${job.capability}", '
          'marking job ${job.id} as failed',
        );
        final failed = job.copyWith(
          status: AiJobStatus.failed,
          errorCode: 'no_executor',
          finishedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _repo.update(failed);
        results.add(failed);
        continue;
      }

      final future = _runJobInternal(
        capability: job.capability,
        idempotencyKey: job.idempotencyKey,
        existingSnapshot: job,
        execute: executor,
      );
      results.add(await future);
    }

    return results;
  }

  /// List all jobs, optionally filtered by status.
  Future<List<AiJobSnapshot>> listJobs({AiJobStatus? status}) {
    if (status != null) return _repo.findByStatus(status);
    return _repo.findAll();
  }

  // -- Internal ---------------------------------------------------------------

  Future<AiJobSnapshot> _runJobInternal({
    required String capability,
    required String? idempotencyKey,
    Duration? timeout,
    AiJobSnapshot? existingSnapshot,
    required AiJobExecutor execute,
    void Function(int progress)? onProgress,
  }) async {
    final now = DateTime.now();

    var snapshot = existingSnapshot ??
        AiJobSnapshot(
          id: _newJobId(),
          capability: capability,
          idempotencyKey: idempotencyKey,
          status: AiJobStatus.queued,
          createdAt: now,
          updatedAt: now,
        );

    if (existingSnapshot == null) {
      await _repo.insert(snapshot);
    }

    snapshot = snapshot.copyWith(
      status: AiJobStatus.running,
      startedAt: snapshot.startedAt ?? now,
      progress: 0,
      updatedAt: now,
    );
    await _repo.update(snapshot);

    void handleProgress(int p) {
      snapshot = snapshot.copyWith(
        progress: p.clamp(0, 100),
        updatedAt: DateTime.now(),
      );
      _repo.update(snapshot);
      onProgress?.call(p);
    }

    try {
      final execution = timeout == null
          ? execute(snapshot, handleProgress)
          : execute(snapshot, handleProgress).timeout(timeout);
      final payload = await execution;
      final fin = DateTime.now();
      snapshot = snapshot.copyWith(
        status: AiJobStatus.succeeded,
        payload: payload,
        progress: 100,
        finishedAt: fin,
        updatedAt: fin,
      );
    } on TimeoutException catch (e) {
      final fin = DateTime.now();
      snapshot = snapshot.copyWith(
        status: AiJobStatus.failed,
        error: e,
        errorCode: 'timeout',
        finishedAt: fin,
        updatedAt: fin,
      );
    } catch (e) {
      final fin = DateTime.now();
      snapshot = snapshot.copyWith(
        status: AiJobStatus.failed,
        error: e,
        errorCode: 'exception',
        finishedAt: fin,
        updatedAt: fin,
      );
    }

    await _repo.update(snapshot);
    _log.fine('Job ${snapshot.id} finished: ${snapshot.status.name}');
    return snapshot;
  }

  String _newJobId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final salt = _random.nextInt(1 << 20).toRadixString(16).padLeft(5, '0');
    return 'job_${ts}_$salt';
  }

  String? _normalizeIdempotencyKey(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
