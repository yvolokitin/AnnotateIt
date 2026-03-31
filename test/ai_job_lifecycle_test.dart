import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:annotateit/services/ai_job_lifecycle.dart';
import 'package:annotateit/repositories/sqlite_ai_job_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<Database> openTestDb() async {
    final db = await openDatabase(inMemoryDatabasePath, version: 1);
    await db.execute('''
      CREATE TABLE ai_jobs (
        id TEXT PRIMARY KEY NOT NULL,
        capability TEXT NOT NULL,
        idempotency_key TEXT,
        status TEXT NOT NULL DEFAULT 'queued',
        progress INTEGER NOT NULL DEFAULT -1,
        started_at TEXT,
        finished_at TEXT,
        error_code TEXT,
        error_message TEXT,
        payload TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_ai_jobs_status ON ai_jobs(status)');
    return db;
  }

  // -----------------------------------------------------------------------
  // AiJobSnapshot serialisation
  // -----------------------------------------------------------------------

  group('AiJobSnapshot', () {
    test('toMap / fromMap roundtrip', () {
      final now = DateTime.now();
      final snap = AiJobSnapshot(
        id: 'j1',
        capability: 'ocr',
        idempotencyKey: 'key1',
        status: AiJobStatus.running,
        progress: 42,
        startedAt: now,
        createdAt: now,
        updatedAt: now,
      );

      final restored = AiJobSnapshot.fromMap(snap.toMap());
      expect(restored.id, 'j1');
      expect(restored.capability, 'ocr');
      expect(restored.idempotencyKey, 'key1');
      expect(restored.status, AiJobStatus.running);
      expect(restored.progress, 42);
      expect(restored.startedAt, isNotNull);
    });

    test('fromMap defaults missing fields gracefully', () {
      final now = DateTime.now().toIso8601String();
      final snap = AiJobSnapshot.fromMap({
        'id': 'j2',
        'capability': 'detect',
        'status': 'succeeded',
        'created_at': now,
        'updated_at': now,
      });
      expect(snap.progress, -1);
      expect(snap.startedAt, isNull);
      expect(snap.finishedAt, isNull);
      expect(snap.errorCode, isNull);
    });

    test('fromMap handles unknown status', () {
      final now = DateTime.now().toIso8601String();
      final snap = AiJobSnapshot.fromMap({
        'id': 'j3',
        'capability': 'x',
        'status': 'unknown_status',
        'created_at': now,
        'updated_at': now,
      });
      expect(snap.status, AiJobStatus.failed);
    });

    test('isTerminal flags', () {
      final now = DateTime.now();
      final base = AiJobSnapshot(
        id: 'j', capability: 'c', idempotencyKey: null,
        status: AiJobStatus.queued, createdAt: now, updatedAt: now,
      );

      expect(base.isTerminal, false);
      expect(base.copyWith(status: AiJobStatus.running).isTerminal, false);
      expect(base.copyWith(status: AiJobStatus.succeeded).isTerminal, true);
      expect(base.copyWith(status: AiJobStatus.failed).isTerminal, true);
      expect(base.copyWith(status: AiJobStatus.canceled).isTerminal, true);
      expect(base.copyWith(status: AiJobStatus.applied).isTerminal, true);
    });

    test('isResumable only for running', () {
      final now = DateTime.now();
      final base = AiJobSnapshot(
        id: 'j', capability: 'c', idempotencyKey: null,
        status: AiJobStatus.running, createdAt: now, updatedAt: now,
      );
      expect(base.isResumable, true);
      expect(base.copyWith(status: AiJobStatus.queued).isResumable, false);
    });

    test('copyWith preserves and overrides', () {
      final now = DateTime.now();
      final snap = AiJobSnapshot(
        id: 'j', capability: 'c', idempotencyKey: 'k',
        status: AiJobStatus.queued, progress: 10,
        createdAt: now, updatedAt: now,
      );
      final updated = snap.copyWith(status: AiJobStatus.running, progress: 50);
      expect(updated.status, AiJobStatus.running);
      expect(updated.progress, 50);
      expect(updated.id, 'j');
      expect(updated.idempotencyKey, 'k');
    });
  });

  // -----------------------------------------------------------------------
  // SqliteAiJobRepository
  // -----------------------------------------------------------------------

  group('SqliteAiJobRepository', () {
    late Database db;
    late SqliteAiJobRepository repo;

    setUp(() async {
      db = await openTestDb();
      repo = SqliteAiJobRepository(db);
    });
    tearDown(() async => await db.close());

    test('insert and findById', () async {
      final now = DateTime.now();
      final snap = AiJobSnapshot(
        id: 'test-1', capability: 'ocr', idempotencyKey: null,
        status: AiJobStatus.queued, createdAt: now, updatedAt: now,
      );
      await repo.insert(snap);
      final found = await repo.findById('test-1');
      expect(found, isNotNull);
      expect(found!.capability, 'ocr');
    });

    test('update changes status', () async {
      final now = DateTime.now();
      final snap = AiJobSnapshot(
        id: 'test-2', capability: 'detect', idempotencyKey: null,
        status: AiJobStatus.queued, createdAt: now, updatedAt: now,
      );
      await repo.insert(snap);
      await repo.update(snap.copyWith(status: AiJobStatus.running, progress: 50));
      final updated = await repo.findById('test-2');
      expect(updated!.status, AiJobStatus.running);
      expect(updated.progress, 50);
    });

    test('findByStatus', () async {
      final now = DateTime.now();
      await repo.insert(AiJobSnapshot(
        id: 'a', capability: 'c', idempotencyKey: null,
        status: AiJobStatus.queued, createdAt: now, updatedAt: now,
      ));
      await repo.insert(AiJobSnapshot(
        id: 'b', capability: 'c', idempotencyKey: null,
        status: AiJobStatus.succeeded, createdAt: now, updatedAt: now,
      ));
      await repo.insert(AiJobSnapshot(
        id: 'c', capability: 'c', idempotencyKey: null,
        status: AiJobStatus.queued, createdAt: now, updatedAt: now,
      ));

      final queued = await repo.findByStatus(AiJobStatus.queued);
      expect(queued.length, 2);
      final succeeded = await repo.findByStatus(AiJobStatus.succeeded);
      expect(succeeded.length, 1);
    });

    test('findResumable returns queued and running', () async {
      final now = DateTime.now();
      await repo.insert(AiJobSnapshot(
        id: 'r1', capability: 'c', idempotencyKey: null,
        status: AiJobStatus.running, createdAt: now, updatedAt: now,
      ));
      await repo.insert(AiJobSnapshot(
        id: 'r2', capability: 'c', idempotencyKey: null,
        status: AiJobStatus.queued, createdAt: now, updatedAt: now,
      ));
      await repo.insert(AiJobSnapshot(
        id: 'r3', capability: 'c', idempotencyKey: null,
        status: AiJobStatus.succeeded, createdAt: now, updatedAt: now,
      ));

      final resumable = await repo.findResumable();
      expect(resumable.length, 2);
      expect(resumable.map((j) => j.id), containsAll(['r1', 'r2']));
    });

    test('delete removes job', () async {
      final now = DateTime.now();
      await repo.insert(AiJobSnapshot(
        id: 'del-1', capability: 'c', idempotencyKey: null,
        status: AiJobStatus.queued, createdAt: now, updatedAt: now,
      ));
      await repo.delete('del-1');
      expect(await repo.findById('del-1'), isNull);
    });

    test('findAll returns all jobs', () async {
      final now = DateTime.now();
      await repo.insert(AiJobSnapshot(
        id: 'all-1', capability: 'a', idempotencyKey: null,
        status: AiJobStatus.queued, createdAt: now, updatedAt: now,
      ));
      await repo.insert(AiJobSnapshot(
        id: 'all-2', capability: 'b', idempotencyKey: null,
        status: AiJobStatus.failed, createdAt: now, updatedAt: now,
      ));
      final all = await repo.findAll();
      expect(all.length, 2);
    });
  });

  // -----------------------------------------------------------------------
  // AiJobRunner (persistent)
  // -----------------------------------------------------------------------

  group('AiJobRunner', () {
    late Database db;
    late SqliteAiJobRepository repo;
    late AiJobRunner runner;

    setUp(() async {
      db = await openTestDb();
      repo = SqliteAiJobRepository(db);
      runner = AiJobRunner(repository: repo);
    });
    tearDown(() async => await db.close());

    test('runJob persists job and returns succeeded', () async {
      final result = await runner.runJob(
        capability: 'ocr',
        execute: () async => {'text': 'hello'},
      );

      expect(result.status, AiJobStatus.succeeded);
      expect(result.progress, 100);
      expect(result.startedAt, isNotNull);
      expect(result.finishedAt, isNotNull);

      final persisted = await repo.findById(result.id);
      expect(persisted, isNotNull);
      expect(persisted!.status, AiJobStatus.succeeded);
    });

    test('runJob records error on failure', () async {
      final result = await runner.runJob(
        capability: 'detect',
        execute: () async => throw Exception('model not found'),
      );

      expect(result.status, AiJobStatus.failed);
      expect(result.errorCode, 'exception');
      expect(result.finishedAt, isNotNull);

      final persisted = await repo.findById(result.id);
      expect(persisted!.errorCode, 'exception');
    });

    test('runJob records timeout errorCode', () async {
      final result = await runner.runJob(
        capability: 'seg',
        timeout: const Duration(milliseconds: 5),
        execute: () async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return 'done';
        },
      );

      expect(result.status, AiJobStatus.failed);
      expect(result.errorCode, 'timeout');
    });

    test('deduplicates concurrent jobs with same idempotency key', () async {
      var executions = 0;

      Future<dynamic> execute() async {
        executions++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return {'ok': true};
      }

      final first = runner.runJob(
        capability: 'cls',
        idempotencyKey: 'same-key',
        execute: execute,
      );
      final second = runner.runJob(
        capability: 'cls',
        idempotencyKey: 'same-key',
        execute: execute,
      );

      final results = await Future.wait([first, second]);
      expect(executions, 1);
      expect(results[0].id, results[1].id);
    });

    test('markApplied transitions succeeded → applied', () async {
      final succeeded = await runner.runJob(
        capability: 'ocr',
        execute: () async => 'data',
      );

      final applied = await runner.markApplied(succeeded);
      expect(applied.status, AiJobStatus.applied);

      final persisted = await repo.findById(applied.id);
      expect(persisted!.status, AiJobStatus.applied);
    });

    test('markApplied rejects non-succeeded', () async {
      final failed = await runner.runJob(
        capability: 'x',
        execute: () async => throw Exception('fail'),
      );
      expect(() => runner.markApplied(failed), throwsA(isA<StateError>()));
    });

    test('cancelJob transitions to canceled', () async {
      final now = DateTime.now();
      final snap = AiJobSnapshot(
        id: 'cancel-me', capability: 'long',
        idempotencyKey: null, status: AiJobStatus.queued,
        createdAt: now, updatedAt: now,
      );
      await repo.insert(snap);

      final canceled = await runner.cancelJob('cancel-me');
      expect(canceled.status, AiJobStatus.canceled);
      expect(canceled.finishedAt, isNotNull);
    });

    test('cancelJob rejects already terminal job', () async {
      final succeeded = await runner.runJob(
        capability: 'x',
        execute: () async => 'done',
      );
      expect(
        () => runner.cancelJob(succeeded.id),
        throwsA(isA<StateError>()),
      );
    });

    test('progress callback updates persisted progress', () async {
      final progressValues = <int>[];

      final result = await runner.runJob(
        capability: 'video_process',
        execute: () async {
          return 'done';
        },
        onProgress: (p) => progressValues.add(p),
      );

      expect(result.status, AiJobStatus.succeeded);
      expect(result.progress, 100);
    });

    test('listJobs returns all or filtered by status', () async {
      await runner.runJob(capability: 'a', execute: () async => 1);
      await runner.runJob(capability: 'b', execute: () async => throw Exception('x'));

      final all = await runner.listJobs();
      expect(all.length, 2);

      final succeeded = await runner.listJobs(status: AiJobStatus.succeeded);
      expect(succeeded.length, 1);
      expect(succeeded.first.capability, 'a');

      final failed = await runner.listJobs(status: AiJobStatus.failed);
      expect(failed.length, 1);
      expect(failed.first.capability, 'b');
    });
  });

  // -----------------------------------------------------------------------
  // Resume after restart
  // -----------------------------------------------------------------------

  group('AiJobRunner resume', () {
    late Database db;
    late SqliteAiJobRepository repo;

    setUp(() async {
      db = await openTestDb();
      repo = SqliteAiJobRepository(db);
    });
    tearDown(() async => await db.close());

    test('resumeInterruptedJobs re-executes running jobs', () async {
      final now = DateTime.now();
      await repo.insert(AiJobSnapshot(
        id: 'interrupted-1', capability: 'ocr', idempotencyKey: null,
        status: AiJobStatus.running, startedAt: now,
        createdAt: now, updatedAt: now,
      ));

      final runner = AiJobRunner(repository: repo);
      runner.registerExecutor('ocr', (snap, onProgress) async {
        onProgress(50);
        return {'resumed': true};
      });

      final results = await runner.resumeInterruptedJobs();
      expect(results.length, 1);
      expect(results.first.status, AiJobStatus.succeeded);
      expect(results.first.progress, 100);

      final persisted = await repo.findById('interrupted-1');
      expect(persisted!.status, AiJobStatus.succeeded);
    });

    test('resumeInterruptedJobs marks no_executor jobs as failed', () async {
      final now = DateTime.now();
      await repo.insert(AiJobSnapshot(
        id: 'no-exec-1', capability: 'unknown_cap', idempotencyKey: null,
        status: AiJobStatus.running, createdAt: now, updatedAt: now,
      ));

      final runner = AiJobRunner(repository: repo);
      final results = await runner.resumeInterruptedJobs();
      expect(results.length, 1);
      expect(results.first.status, AiJobStatus.failed);
      expect(results.first.errorCode, 'no_executor');
    });

    test('resumeInterruptedJobs picks up queued jobs too', () async {
      final now = DateTime.now();
      await repo.insert(AiJobSnapshot(
        id: 'queued-1', capability: 'detect', idempotencyKey: null,
        status: AiJobStatus.queued, createdAt: now, updatedAt: now,
      ));

      final runner = AiJobRunner(repository: repo);
      runner.registerExecutor('detect', (snap, onProgress) async {
        return [1, 2, 3];
      });

      final results = await runner.resumeInterruptedJobs();
      expect(results.length, 1);
      expect(results.first.status, AiJobStatus.succeeded);
    });

    test('resumeInterruptedJobs returns empty when nothing to resume', () async {
      final now = DateTime.now();
      await repo.insert(AiJobSnapshot(
        id: 'done-1', capability: 'x', idempotencyKey: null,
        status: AiJobStatus.succeeded, createdAt: now, updatedAt: now,
      ));

      final runner = AiJobRunner(repository: repo);
      final results = await runner.resumeInterruptedJobs();
      expect(results, isEmpty);
    });

    test('resumed job that fails gets persisted error', () async {
      final now = DateTime.now();
      await repo.insert(AiJobSnapshot(
        id: 'fail-resume', capability: 'seg', idempotencyKey: null,
        status: AiJobStatus.running, createdAt: now, updatedAt: now,
      ));

      final runner = AiJobRunner(repository: repo);
      runner.registerExecutor('seg', (snap, onProgress) async {
        throw Exception('GPU OOM');
      });

      final results = await runner.resumeInterruptedJobs();
      expect(results.first.status, AiJobStatus.failed);
      expect(results.first.errorCode, 'exception');

      final persisted = await repo.findById('fail-resume');
      expect(persisted!.status, AiJobStatus.failed);
    });
  });
}
