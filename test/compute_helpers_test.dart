import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:annotateit/utils/compute_helpers.dart';

void main() {
  // -----------------------------------------------------------------------
  // Image decoding in isolate
  // -----------------------------------------------------------------------

  group('decodeImageInIsolate', () {
    test('decodes a valid PNG', () async {
      final image = img.Image(width: 10, height: 10);
      final bytes = Uint8List.fromList(img.encodePng(image));

      final decoded = await decodeImageInIsolate(bytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, 10);
      expect(decoded.height, 10);
    });

    test('returns null for invalid bytes', () async {
      final result = await decodeImageInIsolate(Uint8List.fromList([0, 1, 2, 3]));
      expect(result, isNull);
    });
  });

  group('decodeAndResizeInIsolate', () {
    test('decodes and resizes to target width', () async {
      final image = img.Image(width: 200, height: 100);
      final bytes = Uint8List.fromList(img.encodePng(image));

      final resized = await decodeAndResizeInIsolate(bytes, targetWidth: 50);
      expect(resized, isNotNull);

      final decoded = img.decodeJpg(resized!);
      expect(decoded, isNotNull);
      expect(decoded!.width, 50);
    });

    test('returns null for invalid bytes', () async {
      final result = await decodeAndResizeInIsolate(
        Uint8List.fromList([0, 1]),
        targetWidth: 50,
      );
      expect(result, isNull);
    });
  });

  // -----------------------------------------------------------------------
  // File IO in isolate
  // -----------------------------------------------------------------------

  group('file IO in isolate', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('compute_helpers_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('readFileBytesInIsolate reads file contents', () async {
      final file = File('${tempDir.path}/test.txt');
      await file.writeAsBytes([72, 101, 108, 108, 111]);

      final bytes = await readFileBytesInIsolate(file.path);
      expect(bytes, [72, 101, 108, 108, 111]);
    });

    test('writeFileBytesInIsolate writes to file', () async {
      final path = '${tempDir.path}/output.bin';
      await writeFileBytesInIsolate(path, Uint8List.fromList([1, 2, 3]));

      final file = File(path);
      expect(await file.exists(), true);
      expect(await file.readAsBytes(), [1, 2, 3]);
    });

    test('hashFileInIsolate returns hex string', () async {
      final file = File('${tempDir.path}/hash.dat');
      await file.writeAsBytes([1, 2, 3, 4, 5]);

      final hash = await hashFileInIsolate(file.path);
      expect(hash.length, 8);
      expect(RegExp(r'^[0-9a-f]+$').hasMatch(hash), true);
    });
  });

  // -----------------------------------------------------------------------
  // Batch copy
  // -----------------------------------------------------------------------

  group('batchCopyFiles', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('batch_copy_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('copies multiple files', () async {
      final src1 = File('${tempDir.path}/a.txt');
      final src2 = File('${tempDir.path}/b.txt');
      await src1.writeAsString('aaa');
      await src2.writeAsString('bbb');

      final results = await batchCopyFiles([
        FileCopyTask(
          sourcePath: src1.path,
          destinationPath: '${tempDir.path}/a_copy.txt',
        ),
        FileCopyTask(
          sourcePath: src2.path,
          destinationPath: '${tempDir.path}/b_copy.txt',
        ),
      ]);

      expect(results.length, 2);
      expect(File('${tempDir.path}/a_copy.txt').readAsStringSync(), 'aaa');
      expect(File('${tempDir.path}/b_copy.txt').readAsStringSync(), 'bbb');
    });

    test('skips files that fail to copy', () async {
      final results = await batchCopyFiles([
        FileCopyTask(
          sourcePath: '${tempDir.path}/nonexistent.txt',
          destinationPath: '${tempDir.path}/out.txt',
        ),
      ]);

      expect(results, isEmpty);
    });
  });

  // -----------------------------------------------------------------------
  // Image dimensions in isolate
  // -----------------------------------------------------------------------

  group('getImageDimensionsInIsolate', () {
    test('extracts dimensions', () async {
      final image = img.Image(width: 320, height: 240);
      final bytes = Uint8List.fromList(img.encodePng(image));

      final dims = await getImageDimensionsInIsolate(bytes);
      expect(dims, isNotNull);
      expect(dims!.width, 320);
      expect(dims.height, 240);
    });

    test('returns null for invalid data', () async {
      final dims = await getImageDimensionsInIsolate(Uint8List.fromList([0]));
      expect(dims, isNull);
    });
  });
}
