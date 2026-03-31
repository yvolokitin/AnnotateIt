import 'package:flutter_test/flutter_test.dart';
import 'package:annotateit/services/video_metadata.dart';
import 'package:annotateit/services/media_metadata_service.dart';

// ---------------------------------------------------------------------------
// Mock engine for testing
// ---------------------------------------------------------------------------

class MockVideoProbeEngine implements VideoProbeEngine {
  final VideoMetadata result;
  int callCount = 0;
  String? lastPath;

  MockVideoProbeEngine(this.result);

  @override
  Future<VideoMetadata> probe(String videoPath) async {
    callCount++;
    lastPath = videoPath;
    return result;
  }
}

class FailingVideoProbeEngine implements VideoProbeEngine {
  @override
  Future<VideoMetadata> probe(String videoPath) async {
    throw Exception('Probe engine failure');
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('VideoMetadata', () {
    test('empty constant has zero values', () {
      const meta = VideoMetadata.empty;
      expect(meta.width, 0);
      expect(meta.height, 0);
      expect(meta.durationSec, 0.0);
      expect(meta.fpsNominal, 0.0);
      expect(meta.frameCountEstimate, 0);
      expect(meta.codec, '');
      expect(meta.isValid, false);
    });

    test('isValid returns true for non-zero metadata', () {
      const meta = VideoMetadata(
        width: 1920,
        height: 1080,
        durationSec: 10.5,
        fpsNominal: 29.97,
        frameCountEstimate: 315,
        codec: 'h264',
      );
      expect(meta.isValid, true);
    });

    test('isValid returns false when width is zero', () {
      const meta = VideoMetadata(
        width: 0,
        height: 1080,
        durationSec: 10.0,
        fpsNominal: 30.0,
        frameCountEstimate: 300,
        codec: 'h264',
      );
      expect(meta.isValid, false);
    });

    test('toMap produces expected keys', () {
      const meta = VideoMetadata(
        width: 1280,
        height: 720,
        durationSec: 60.0,
        fpsNominal: 25.0,
        frameCountEstimate: 1500,
        codec: 'hevc',
      );
      final map = meta.toMap();
      expect(map['width'], 1280);
      expect(map['height'], 720);
      expect(map['duration'], 60.0);
      expect(map['fps'], 25.0);
      expect(map['frameCount'], 1500);
      expect(map['codec'], 'hevc');
    });

    test('toString contains dimensions and codec', () {
      const meta = VideoMetadata(
        width: 3840,
        height: 2160,
        durationSec: 120.0,
        fpsNominal: 60.0,
        frameCountEstimate: 7200,
        codec: 'av1',
      );
      final s = meta.toString();
      expect(s, contains('3840x2160'));
      expect(s, contains('av1'));
      expect(s, contains('60.0fps'));
    });
  });

  group('MediaMetadataService with mock engine', () {
    test('getVideoMetadataTyped returns metadata from engine', () async {
      const expected = VideoMetadata(
        width: 1920,
        height: 1080,
        durationSec: 42.5,
        fpsNominal: 29.97,
        frameCountEstimate: 1274,
        codec: 'h264',
      );
      final mock = MockVideoProbeEngine(expected);
      final service = MediaMetadataService.withEngine(mock);

      final result = await service.getVideoMetadataTyped('/test/video.mp4');

      expect(result.width, 1920);
      expect(result.height, 1080);
      expect(result.durationSec, 42.5);
      expect(result.fpsNominal, 29.97);
      expect(result.frameCountEstimate, 1274);
      expect(result.codec, 'h264');
      expect(result.isValid, true);
      expect(mock.callCount, 1);
      expect(mock.lastPath, '/test/video.mp4');
    });

    test('getVideoMetadata returns backward-compatible map', () async {
      const expected = VideoMetadata(
        width: 1280,
        height: 720,
        durationSec: 10.0,
        fpsNominal: 30.0,
        frameCountEstimate: 300,
        codec: 'vp9',
      );
      final service = MediaMetadataService.withEngine(
        MockVideoProbeEngine(expected),
      );

      final map = await service.getVideoMetadata('/test/clip.webm');

      expect(map['width'], 1280);
      expect(map['height'], 720);
      expect(map['duration'], 10.0);
      expect(map['fps'], 30.0);
    });

    test('graceful fallback on engine failure', () async {
      final service = MediaMetadataService.withEngine(
        FailingVideoProbeEngine(),
      );

      final result = await service.getVideoMetadataTyped('/bad/path.mp4');

      expect(result.isValid, false);
      expect(result.width, 0);
      expect(result.height, 0);
    });

    test('graceful fallback on engine failure (map API)', () async {
      final service = MediaMetadataService.withEngine(
        FailingVideoProbeEngine(),
      );

      final map = await service.getVideoMetadata('/bad/path.mp4');

      expect(map['width'], 0);
      expect(map['height'], 0);
      expect(map['duration'], 0.0);
      expect(map['fps'], 0.0);
    });

    test('multiple calls forward to engine each time', () async {
      const meta = VideoMetadata(
        width: 640,
        height: 480,
        durationSec: 5.0,
        fpsNominal: 24.0,
        frameCountEstimate: 120,
        codec: 'mpeg4',
      );
      final mock = MockVideoProbeEngine(meta);
      final service = MediaMetadataService.withEngine(mock);

      await service.getVideoMetadataTyped('/a.mp4');
      await service.getVideoMetadataTyped('/b.mp4');
      await service.getVideoMetadataTyped('/c.mp4');

      expect(mock.callCount, 3);
      expect(mock.lastPath, '/c.mp4');
    });
  });
}
