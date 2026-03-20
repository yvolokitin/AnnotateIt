import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:annotateit/services/ai_job_lifecycle.dart';

void main() {
  group('AiJobRunner', () {
    test(
      'deduplicates concurrent jobs with the same idempotency key',
      () async {
        final runner = AiJobRunner();
        var executions = 0;

        Future<dynamic> execute() async {
          executions += 1;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return <String, dynamic>{'ok': true};
        }

        final first = runner.runJob(
          capability: 'classification',
          idempotencyKey: 'same-key',
          execute: execute,
        );
        final second = runner.runJob(
          capability: 'classification',
          idempotencyKey: 'same-key',
          execute: execute,
        );

        final results = await Future.wait([first, second]);
        expect(executions, 1);
        expect(results[0].id, results[1].id);
        expect(results[0].status, AiJobStatus.succeeded);
        expect(results[1].status, AiJobStatus.succeeded);
      },
    );

    test('marks job as failed on timeout', () async {
      final runner = AiJobRunner();

      final result = await runner.runJob(
        capability: 'segmentation',
        timeout: const Duration(milliseconds: 5),
        execute: () async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return 'done';
        },
      );

      expect(result.status, AiJobStatus.failed);
      expect(result.error, isA<TimeoutException>());
    });

    test('allows markApplied only from succeeded status', () async {
      final runner = AiJobRunner();
      final succeeded = await runner.runJob(
        capability: 'ocr',
        execute: () async => <String, dynamic>{'text': 'hello'},
      );

      final applied = await runner.markApplied(succeeded);
      expect(applied.status, AiJobStatus.applied);
    });

    test('markApplied rejects non-succeeded status', () async {
      final runner = AiJobRunner();
      final failed = await runner.runJob(
        capability: 'ocr',
        timeout: const Duration(milliseconds: 1),
        execute: () async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return 'never';
        },
      );

      expect(() => runner.markApplied(failed), throwsA(isA<StateError>()));
    });
  });
}
