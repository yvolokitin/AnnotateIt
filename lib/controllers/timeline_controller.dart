import 'package:flutter/foundation.dart';

/// State controller for the video frame timeline / scrubber.
///
/// Keeps track of the current frame index, total frame count, source FPS,
/// and which frames have keyframe annotations. Notifies listeners on change
/// so the scrubber and dependent widgets can rebuild.
class TimelineController extends ChangeNotifier {
  int _currentFrame;
  int _totalFrames;
  double _sourceFps;
  final Set<int> _keyframeIndices;
  bool _showInterpolated;

  TimelineController({
    int currentFrame = 0,
    int totalFrames = 0,
    double sourceFps = 30.0,
    Set<int>? keyframeIndices,
    bool showInterpolated = true,
  })  : _currentFrame = currentFrame,
        _totalFrames = totalFrames,
        _sourceFps = sourceFps,
        _keyframeIndices = keyframeIndices ?? {},
        _showInterpolated = showInterpolated;

  // -- Getters ----------------------------------------------------------------

  int get currentFrame => _currentFrame;
  int get totalFrames => _totalFrames;
  double get sourceFps => _sourceFps;
  Set<int> get keyframeIndices => Set.unmodifiable(_keyframeIndices);

  bool get isAtStart => _currentFrame <= 0;
  bool get isAtEnd => _totalFrames == 0 || _currentFrame >= _totalFrames - 1;
  bool get hasFrames => _totalFrames > 0;

  /// Current frame's estimated timestamp in seconds.
  double get currentTimestampSec =>
      _sourceFps > 0 ? _currentFrame / _sourceFps : 0.0;

  /// Total duration in seconds.
  double get durationSec =>
      _sourceFps > 0 ? _totalFrames / _sourceFps : 0.0;

  /// Whether the current frame is a keyframe.
  bool get isCurrentKeyframe => _keyframeIndices.contains(_currentFrame);

  /// Whether interpolated (non-keyframe) bbox overlays should be shown.
  bool get showInterpolated => _showInterpolated;

  set showInterpolated(bool value) {
    if (_showInterpolated != value) {
      _showInterpolated = value;
      notifyListeners();
    }
  }

  void toggleShowInterpolated() {
    _showInterpolated = !_showInterpolated;
    notifyListeners();
  }

  // -- Navigation -------------------------------------------------------------

  void jumpToFrame(int index) {
    final clamped = index.clamp(0, (_totalFrames - 1).clamp(0, _totalFrames));
    if (clamped != _currentFrame) {
      _currentFrame = clamped;
      notifyListeners();
    }
  }

  void nextFrame() {
    if (!isAtEnd) jumpToFrame(_currentFrame + 1);
  }

  void previousFrame() {
    if (!isAtStart) jumpToFrame(_currentFrame - 1);
  }

  /// Jump to the next keyframe after the current position.
  /// Returns true if a jump occurred.
  bool jumpToNextKeyframe() {
    final next = _keyframeIndices
        .where((i) => i > _currentFrame)
        .fold<int?>(null, (closest, i) =>
            closest == null || i < closest ? i : closest);
    if (next != null) {
      jumpToFrame(next);
      return true;
    }
    return false;
  }

  /// Jump to the previous keyframe before the current position.
  /// Returns true if a jump occurred.
  bool jumpToPreviousKeyframe() {
    final prev = _keyframeIndices
        .where((i) => i < _currentFrame)
        .fold<int?>(null, (closest, i) =>
            closest == null || i > closest ? i : closest);
    if (prev != null) {
      jumpToFrame(prev);
      return true;
    }
    return false;
  }

  // -- Keyframe management ----------------------------------------------------

  void addKeyframeMarker(int frameIndex) {
    if (_keyframeIndices.add(frameIndex)) {
      notifyListeners();
    }
  }

  void removeKeyframeMarker(int frameIndex) {
    if (_keyframeIndices.remove(frameIndex)) {
      notifyListeners();
    }
  }

  void setKeyframeMarkers(Set<int> indices) {
    _keyframeIndices
      ..clear()
      ..addAll(indices);
    notifyListeners();
  }

  // -- Bulk configuration -----------------------------------------------------

  void configure({
    required int totalFrames,
    required double sourceFps,
    int startFrame = 0,
    Set<int>? keyframeIndices,
  }) {
    _totalFrames = totalFrames;
    _sourceFps = sourceFps;
    _currentFrame = startFrame.clamp(0, (totalFrames - 1).clamp(0, totalFrames));
    _keyframeIndices
      ..clear()
      ..addAll(keyframeIndices ?? {});
    notifyListeners();
  }
}
