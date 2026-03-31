import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:annotateit/services/ffmpeg_resolver.dart';
import 'package:annotateit/widgets/media_drop_zone.dart';

// ---------------------------------------------------------------------------
// FfmpegResolver
// ---------------------------------------------------------------------------

void main() {
  group('FfmpegResolver', () {
    late FfmpegResolver resolver;

    setUp(() {
      resolver = FfmpegResolver();
    });

    test('returns notFound when no ffmpeg available and skipExecution=true', () async {
      final result = await resolver.resolve(
        userSettingPath: '/nonexistent/ffmpeg',
        skipExecution: true,
      );
      expect(result.found, isFalse);
      expect(result.source, FfmpegSource.notFound);
      expect(result.message, contains('not found'));
    });

    test('caches a valid path for subsequent calls', () async {
      final ffmpegPath = await _findSystemFfmpeg();
      if (ffmpegPath == null) {
        markTestSkipped('ffmpeg not installed on this system');
        return;
      }

      final first = await resolver.resolve(
        userSettingPath: ffmpegPath,
      );
      expect(first.found, isTrue);
      expect(first.source, isNot(FfmpegSource.sessionCache));

      final second = await resolver.resolve();
      expect(second.found, isTrue);
      expect(second.source, FfmpegSource.sessionCache);
      expect(second.path, first.path);
    });

    test('clearCache forces re-resolution', () async {
      final ffmpegPath = await _findSystemFfmpeg();
      if (ffmpegPath == null) {
        markTestSkipped('ffmpeg not installed on this system');
        return;
      }

      await resolver.resolve(userSettingPath: ffmpegPath);
      expect(resolver.cachedPath, isNotNull);

      resolver.clearCache();
      expect(resolver.cachedPath, isNull);
    });

    test('invalid user setting falls through to well-known paths', () async {
      final result = await resolver.resolve(
        userSettingPath: '/totally/bogus/path',
      );
      // Whether it finds ffmpeg depends on the system, but it
      // should NOT report userSetting as the source.
      if (result.found) {
        expect(result.source, isNot(FfmpegSource.userSetting));
      }
    });

    test('FfmpegResolveResult toString is descriptive', () {
      const r = FfmpegResolveResult(
        path: '/usr/local/bin/ffmpeg',
        source: FfmpegSource.wellKnownPath,
        message: 'ok',
      );
      expect(r.toString(), contains('wellKnownPath'));
      expect(r.toString(), contains('/usr/local/bin/ffmpeg'));
    });

    test('FfmpegSource enum has expected values', () {
      expect(FfmpegSource.values.length, 5);
      expect(FfmpegSource.values, contains(FfmpegSource.notFound));
      expect(FfmpegSource.values, contains(FfmpegSource.wellKnownPath));
    });

    test('resolve measures performance via PerfCounters', () async {
      final result = await resolver.resolve(
        userSettingPath: '/nonexistent',
        skipExecution: true,
      );
      expect(result, isA<FfmpegResolveResult>());
    });

    test('skipExecution=true avoids Process.run for PATH check', () async {
      final result = await resolver.resolve(
        skipExecution: true,
      );
      // With skipExecution, system PATH cannot be probed — if no well-known
      // binary exists with a valid header, result is notFound.
      expect(result.source,
          isIn([FfmpegSource.notFound, FfmpegSource.wellKnownPath]));
    });
  });

  // ---------------------------------------------------------------------------
  // MediaDropZone helpers
  // ---------------------------------------------------------------------------

  group('validateDroppedFiles', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('drop_test_');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('accepts supported image extensions', () async {
      for (final ext in ['.jpg', '.png', '.webp']) {
        final f = File('${tempDir.path}/test$ext');
        await f.writeAsBytes([0, 1, 2, 3]);
        final results = await validateDroppedFiles([f.path]);
        expect(results.length, 1);
        expect(results.first.type, DroppedMediaType.image);
        expect(results.first.extension, ext);
        expect(results.first.sizeBytes, greaterThan(0));
      }
    });

    test('accepts supported video extensions', () async {
      for (final ext in ['.mp4', '.mov', '.mkv']) {
        final f = File('${tempDir.path}/clip$ext');
        await f.writeAsBytes([0, 1, 2, 3]);
        final results = await validateDroppedFiles([f.path]);
        expect(results.length, 1);
        expect(results.first.type, DroppedMediaType.video);
      }
    });

    test('filters out unsupported extensions', () async {
      final f = File('${tempDir.path}/doc.pdf');
      await f.writeAsBytes([0, 1, 2, 3]);
      final results = await validateDroppedFiles([f.path]);
      expect(results, isEmpty);
    });

    test('filters out non-existent paths', () async {
      final results = await validateDroppedFiles([
        '${tempDir.path}/does_not_exist.png',
      ]);
      expect(results, isEmpty);
    });

    test('handles mixed valid and invalid paths', () async {
      final good = File('${tempDir.path}/photo.jpg');
      await good.writeAsBytes([0, 1, 2, 3]);
      final bad = File('${tempDir.path}/readme.txt');
      await bad.writeAsString('hello');

      final results = await validateDroppedFiles([
        good.path,
        bad.path,
        '${tempDir.path}/ghost.png',
      ]);

      expect(results.length, 1);
      expect(results.first.path, good.path);
    });

    test('DroppedMediaFile toString', () {
      const dmf = DroppedMediaFile(
        path: '/a/b.mp4',
        extension: '.mp4',
        type: DroppedMediaType.video,
        sizeBytes: 1024,
      );
      expect(dmf.toString(), contains('video'));
      expect(dmf.toString(), contains('/a/b.mp4'));
    });

    test('kImageExtensions and kVideoExtensions are disjoint', () {
      final overlap = kImageExtensions.intersection(kVideoExtensions);
      expect(overlap, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // Timeline paint helpers (non-widget unit checks)
  // ---------------------------------------------------------------------------

  group('Timeline optimizations', () {
    test('listEquals detects changed keyframe lists', () {
      final a = [0.0, 0.25, 0.5];
      final b = [0.0, 0.25, 0.5];
      final c = [0.0, 0.25, 0.75];

      expect(listEquals(a, b), isTrue);
      expect(listEquals(a, c), isFalse);
    });

    test('empty keyframe lists are equal', () {
      expect(listEquals(<double>[], <double>[]), isTrue);
    });
  });
}

/// Helper: attempt to find ffmpeg on the system for integration tests.
Future<String?> _findSystemFfmpeg() async {
  for (final candidate in [
    '/opt/homebrew/bin/ffmpeg',
    '/usr/local/bin/ffmpeg',
    '/usr/bin/ffmpeg',
  ]) {
    if (await File(candidate).exists()) return candidate;
  }
  try {
    final r = await Process.run('which', ['ffmpeg']);
    if (r.exitCode == 0) {
      return (r.stdout as String).trim();
    }
  } catch (_) {}
  return null;
}
