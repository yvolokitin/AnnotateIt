import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:annotateit/services/frame_thumbnail_cache.dart';
import 'package:annotateit/utils/concurrency_limiter.dart';
import 'package:annotateit/utils/permission_guard.dart';

void main() {
  // -----------------------------------------------------------------------
  // FrameThumbnailCache
  // -----------------------------------------------------------------------

  group('FrameThumbnailCache', () {
    late FrameThumbnailCache cache;

    setUp(() {
      cache = FrameThumbnailCache.create(maxMemoryBytes: 1024 * 100);
    });

    test('put and get return the same bytes', () async {
      final bytes = Uint8List.fromList(List.filled(100, 42));
      cache.put('frame_1', bytes);

      final result = await cache.get('frame_1');
      expect(result, bytes);
      expect(cache.length, 1);
      expect(cache.currentBytes, 100);
    });

    test('get returns null for missing key without filePath', () async {
      final result = await cache.get('missing');
      expect(result, isNull);
    });

    test('containsKey reports correctly', () {
      expect(cache.containsKey('x'), false);
      cache.put('x', Uint8List(10));
      expect(cache.containsKey('x'), true);
    });

    test('remove decrements memory', () {
      cache.put('a', Uint8List(50));
      cache.put('b', Uint8List(30));
      expect(cache.currentBytes, 80);

      cache.remove('a');
      expect(cache.currentBytes, 30);
      expect(cache.length, 1);
    });

    test('clear resets everything', () {
      cache.put('a', Uint8List(10));
      cache.put('b', Uint8List(20));
      cache.clear();

      expect(cache.length, 0);
      expect(cache.currentBytes, 0);
      expect(cache.hitRate, 0.0);
    });

    test('LRU eviction removes oldest entries when over budget', () {
      final smallCache = FrameThumbnailCache.create(maxMemoryBytes: 100);

      smallCache.put('a', Uint8List(40));
      smallCache.put('b', Uint8List(40));
      expect(smallCache.length, 2);
      expect(smallCache.currentBytes, 80);

      smallCache.put('c', Uint8List(40));
      // 'a' should be evicted (LRU)
      expect(smallCache.currentBytes, lessThanOrEqualTo(100));
      expect(smallCache.containsKey('a'), false);
      expect(smallCache.containsKey('b'), true);
      expect(smallCache.containsKey('c'), true);
    });

    test('accessing an entry moves it to end of LRU', () async {
      final smallCache = FrameThumbnailCache.create(maxMemoryBytes: 100);

      smallCache.put('a', Uint8List(40));
      smallCache.put('b', Uint8List(40));

      // Touch 'a' to make it recently used
      await smallCache.get('a');

      // Insert 'c' — 'b' should be evicted (oldest untouched)
      smallCache.put('c', Uint8List(40));

      expect(smallCache.containsKey('a'), true);
      expect(smallCache.containsKey('b'), false);
      expect(smallCache.containsKey('c'), true);
    });

    test('evictTo reduces memory to target', () {
      cache.put('a', Uint8List(300));
      cache.put('b', Uint8List(300));
      cache.put('c', Uint8List(300));

      cache.evictTo(400);
      expect(cache.currentBytes, lessThanOrEqualTo(400));
    });

    test('hit rate tracks correctly', () async {
      cache.put('x', Uint8List(10));

      await cache.get('x'); // hit
      await cache.get('y'); // miss
      await cache.get('x'); // hit

      expect(cache.hitRate, closeTo(2 / 3, 0.01));
    });

    test('lazy load from file path', () async {
      final tempDir = await Directory.systemTemp.createTemp('thumb_cache_test_');
      try {
        final image = img.Image(width: 100, height: 100);
        final pngBytes = img.encodePng(image);
        final filePath = '${tempDir.path}/frame.png';
        await File(filePath).writeAsBytes(pngBytes);

        final result = await cache.get('lazy_1', filePath: filePath);
        expect(result, isNotNull);
        expect(result!.length, greaterThan(0));
        expect(cache.containsKey('lazy_1'), true);

        // Second get should be a cache hit
        final result2 = await cache.get('lazy_1');
        expect(result2, result);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('lazy load returns null for nonexistent file', () async {
      final result = await cache.get(
        'bad_file',
        filePath: '/tmp/nonexistent_frame_abc123.png',
      );
      expect(result, isNull);
      expect(cache.containsKey('bad_file'), false);
    });

    test('replacing existing key updates memory accounting', () {
      cache.put('x', Uint8List(50));
      expect(cache.currentBytes, 50);

      cache.put('x', Uint8List(80));
      expect(cache.currentBytes, 80);
      expect(cache.length, 1);
    });
  });

  // -----------------------------------------------------------------------
  // ConcurrencyLimiter
  // -----------------------------------------------------------------------

  group('ConcurrencyLimiter', () {
    test('allows up to maxConcurrent tasks', () async {
      final limiter = ConcurrencyLimiter(maxConcurrent: 2);
      var maxSeen = 0;
      var current = 0;

      final tasks = List.generate(5, (i) => () async {
        current++;
        if (current > maxSeen) maxSeen = current;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        current--;
        return i;
      });

      final results = await limiter.runAll(tasks);
      expect(results, [0, 1, 2, 3, 4]);
      expect(maxSeen, lessThanOrEqualTo(2));
    });

    test('hasCapacity reflects current state', () async {
      final limiter = ConcurrencyLimiter(maxConcurrent: 1);
      expect(limiter.hasCapacity, true);

      final future = limiter.run(() async {
        expect(limiter.hasCapacity, false);
        expect(limiter.running, 1);
        return 'done';
      });

      await future;
      expect(limiter.hasCapacity, true);
      expect(limiter.running, 0);
    });

    test('waiting tracks queued tasks', () async {
      final limiter = ConcurrencyLimiter(maxConcurrent: 1);

      final c1 = Completer<void>();
      final f1 = limiter.run(() => c1.future);

      // Start a second task that should wait
      final f2 = limiter.run(() async => 'second');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(limiter.waiting, 1);

      c1.complete();
      await f1;
      await f2;
      expect(limiter.waiting, 0);
    });

    test('exceptions propagate and release the slot', () async {
      final limiter = ConcurrencyLimiter(maxConcurrent: 1);

      try {
        await limiter.run(() async => throw Exception('fail'));
      } catch (_) {}

      expect(limiter.running, 0);
      expect(limiter.hasCapacity, true);

      // Next task should still work
      final result = await limiter.run(() async => 42);
      expect(result, 42);
    });

    test('runAll preserves order', () async {
      final limiter = ConcurrencyLimiter(maxConcurrent: 3);

      final results = await limiter.runAll([
        () async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return 'a';
        },
        () async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return 'b';
        },
        () async => 'c',
      ]);

      expect(results, ['a', 'b', 'c']);
    });

    test('single concurrency acts as a mutex', () async {
      final limiter = ConcurrencyLimiter(maxConcurrent: 1);
      final order = <int>[];

      await Future.wait([
        limiter.run(() async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          order.add(1);
        }),
        limiter.run(() async {
          order.add(2);
        }),
      ]);

      expect(order, [1, 2]);
    });
  });

  // -----------------------------------------------------------------------
  // PermissionGuard (non-mobile — should always return granted)
  // -----------------------------------------------------------------------

  group('PermissionGuard on desktop/test', () {
    test('check returns granted on non-mobile', () async {
      final result = await PermissionGuard.check(AppPermission.camera);
      expect(result.granted, true);
    });

    test('request returns granted on non-mobile', () async {
      final result = await PermissionGuard.request(AppPermission.photos);
      expect(result.granted, true);
    });

    test('requestAll returns all granted on non-mobile', () async {
      final results = await PermissionGuard.requestAll([
        AppPermission.camera,
        AppPermission.photos,
        AppPermission.microphone,
      ]);

      expect(results.length, 3);
      for (final r in results.values) {
        expect(r.granted, true);
      }
    });

    test('auditAll returns empty on non-mobile (all granted)', () async {
      final denied = await PermissionGuard.auditAll();
      expect(denied, isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // PermissionCheckResult
  // -----------------------------------------------------------------------

  group('PermissionCheckResult', () {
    test('toString includes key fields', () {
      const r = PermissionCheckResult(
        permission: AppPermission.camera,
        granted: false,
        message: 'denied',
        canOpenSettings: true,
      );
      expect(r.toString(), contains('camera'));
      expect(r.toString(), contains('granted=false'));
    });

    test('canOpenSettings defaults to false', () {
      const r = PermissionCheckResult(
        permission: AppPermission.storage,
        granted: true,
        message: 'ok',
      );
      expect(r.canOpenSettings, false);
    });
  });

  // -----------------------------------------------------------------------
  // AppPermission enum
  // -----------------------------------------------------------------------

  group('AppPermission', () {
    test('has all expected values', () {
      expect(AppPermission.values.length, 4);
      expect(AppPermission.values, contains(AppPermission.camera));
      expect(AppPermission.values, contains(AppPermission.photos));
      expect(AppPermission.values, contains(AppPermission.microphone));
      expect(AppPermission.values, contains(AppPermission.storage));
    });
  });
}
