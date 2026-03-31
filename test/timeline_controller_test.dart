import 'package:flutter_test/flutter_test.dart';
import 'package:annotateit/controllers/timeline_controller.dart';

void main() {
  group('TimelineController', () {
    late TimelineController ctrl;

    setUp(() {
      ctrl = TimelineController(
        totalFrames: 100,
        sourceFps: 30.0,
        currentFrame: 0,
      );
    });

    tearDown(() => ctrl.dispose());

    test('initial state is correct', () {
      expect(ctrl.currentFrame, 0);
      expect(ctrl.totalFrames, 100);
      expect(ctrl.sourceFps, 30.0);
      expect(ctrl.isAtStart, true);
      expect(ctrl.isAtEnd, false);
      expect(ctrl.hasFrames, true);
      expect(ctrl.keyframeIndices, isEmpty);
    });

    test('jumpToFrame clamps within bounds', () {
      ctrl.jumpToFrame(50);
      expect(ctrl.currentFrame, 50);

      ctrl.jumpToFrame(-5);
      expect(ctrl.currentFrame, 0);

      ctrl.jumpToFrame(999);
      expect(ctrl.currentFrame, 99);
    });

    test('nextFrame advances by one', () {
      ctrl.jumpToFrame(0);
      ctrl.nextFrame();
      expect(ctrl.currentFrame, 1);
    });

    test('previousFrame goes back by one', () {
      ctrl.jumpToFrame(10);
      ctrl.previousFrame();
      expect(ctrl.currentFrame, 9);
    });

    test('nextFrame does nothing at end', () {
      ctrl.jumpToFrame(99);
      expect(ctrl.isAtEnd, true);
      ctrl.nextFrame();
      expect(ctrl.currentFrame, 99);
    });

    test('previousFrame does nothing at start', () {
      ctrl.jumpToFrame(0);
      expect(ctrl.isAtStart, true);
      ctrl.previousFrame();
      expect(ctrl.currentFrame, 0);
    });

    test('isAtEnd is true at last frame', () {
      ctrl.jumpToFrame(99);
      expect(ctrl.isAtEnd, true);
    });

    test('currentTimestampSec computes correctly', () {
      ctrl.jumpToFrame(30);
      expect(ctrl.currentTimestampSec, closeTo(1.0, 0.001));
    });

    test('durationSec computes correctly', () {
      expect(ctrl.durationSec, closeTo(100 / 30, 0.001));
    });
  });

  group('TimelineController keyframe navigation', () {
    late TimelineController ctrl;

    setUp(() {
      ctrl = TimelineController(
        totalFrames: 100,
        sourceFps: 30.0,
        keyframeIndices: {10, 30, 60, 90},
      );
    });

    tearDown(() => ctrl.dispose());

    test('isCurrentKeyframe returns true on keyframe', () {
      ctrl.jumpToFrame(30);
      expect(ctrl.isCurrentKeyframe, true);
    });

    test('isCurrentKeyframe returns false between keyframes', () {
      ctrl.jumpToFrame(15);
      expect(ctrl.isCurrentKeyframe, false);
    });

    test('jumpToNextKeyframe jumps to nearest keyframe after current', () {
      ctrl.jumpToFrame(0);
      final jumped = ctrl.jumpToNextKeyframe();
      expect(jumped, true);
      expect(ctrl.currentFrame, 10);
    });

    test('jumpToNextKeyframe from between keyframes', () {
      ctrl.jumpToFrame(15);
      ctrl.jumpToNextKeyframe();
      expect(ctrl.currentFrame, 30);
    });

    test('jumpToNextKeyframe returns false when no keyframe ahead', () {
      ctrl.jumpToFrame(90);
      final jumped = ctrl.jumpToNextKeyframe();
      expect(jumped, false);
      expect(ctrl.currentFrame, 90);
    });

    test('jumpToPreviousKeyframe jumps to nearest keyframe before current', () {
      ctrl.jumpToFrame(50);
      final jumped = ctrl.jumpToPreviousKeyframe();
      expect(jumped, true);
      expect(ctrl.currentFrame, 30);
    });

    test('jumpToPreviousKeyframe returns false when no keyframe behind', () {
      ctrl.jumpToFrame(5);
      final jumped = ctrl.jumpToPreviousKeyframe();
      expect(jumped, false);
      expect(ctrl.currentFrame, 5);
    });

    test('jumpToPreviousKeyframe from first keyframe', () {
      ctrl.jumpToFrame(10);
      final jumped = ctrl.jumpToPreviousKeyframe();
      expect(jumped, false);
      expect(ctrl.currentFrame, 10);
    });
  });

  group('TimelineController keyframe markers', () {
    late TimelineController ctrl;

    setUp(() {
      ctrl = TimelineController(totalFrames: 50, sourceFps: 24.0);
    });

    tearDown(() => ctrl.dispose());

    test('addKeyframeMarker adds a marker', () {
      ctrl.addKeyframeMarker(5);
      expect(ctrl.keyframeIndices, contains(5));
    });

    test('addKeyframeMarker is idempotent', () {
      int notifyCount = 0;
      ctrl.addListener(() => notifyCount++);
      ctrl.addKeyframeMarker(5);
      ctrl.addKeyframeMarker(5);
      expect(notifyCount, 1);
    });

    test('removeKeyframeMarker removes a marker', () {
      ctrl.addKeyframeMarker(5);
      ctrl.removeKeyframeMarker(5);
      expect(ctrl.keyframeIndices, isNot(contains(5)));
    });

    test('setKeyframeMarkers replaces all markers', () {
      ctrl.addKeyframeMarker(1);
      ctrl.addKeyframeMarker(2);
      ctrl.setKeyframeMarkers({10, 20, 30});
      expect(ctrl.keyframeIndices, equals({10, 20, 30}));
    });
  });

  group('TimelineController configure()', () {
    late TimelineController ctrl;

    setUp(() {
      ctrl = TimelineController();
    });

    tearDown(() => ctrl.dispose());

    test('configure sets all fields', () {
      ctrl.configure(
        totalFrames: 200,
        sourceFps: 60.0,
        startFrame: 10,
        keyframeIndices: {5, 50, 150},
      );
      expect(ctrl.totalFrames, 200);
      expect(ctrl.sourceFps, 60.0);
      expect(ctrl.currentFrame, 10);
      expect(ctrl.keyframeIndices, equals({5, 50, 150}));
    });

    test('configure clamps startFrame', () {
      ctrl.configure(totalFrames: 10, sourceFps: 30.0, startFrame: 100);
      expect(ctrl.currentFrame, 9);
    });

    test('hasFrames is false for zero-frame controller', () {
      expect(ctrl.hasFrames, false);
    });
  });

  group('TimelineController notifications', () {
    late TimelineController ctrl;

    setUp(() {
      ctrl = TimelineController(totalFrames: 50, sourceFps: 30.0);
    });

    tearDown(() => ctrl.dispose());

    test('notifies on jumpToFrame', () {
      int count = 0;
      ctrl.addListener(() => count++);
      ctrl.jumpToFrame(10);
      expect(count, 1);
    });

    test('does not notify on same frame jump', () {
      ctrl.jumpToFrame(0);
      int count = 0;
      ctrl.addListener(() => count++);
      ctrl.jumpToFrame(0);
      expect(count, 0);
    });

    test('notifies on configure', () {
      int count = 0;
      ctrl.addListener(() => count++);
      ctrl.configure(totalFrames: 100, sourceFps: 24.0);
      expect(count, 1);
    });
  });
}
