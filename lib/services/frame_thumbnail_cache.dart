import 'dart:collection';
import 'dart:typed_data';

import 'package:logging/logging.dart';

import '../utils/compute_helpers.dart';
import 'perf_counters.dart';

final _log = Logger('FrameThumbnailCache');

/// Memory-bounded LRU cache for decoded frame thumbnails.
///
/// Designed to prevent memory spikes on iOS when scrolling through
/// extracted video frames. Thumbnails are loaded lazily on first
/// access and evicted LRU-first when the cache exceeds
/// [maxMemoryBytes].
///
/// Each entry stores a compressed JPEG [Uint8List] rather than a
/// decoded `ui.Image`, keeping per-entry cost low (~20–80 KB vs
/// several MB for a decoded RGBA bitmap).
class FrameThumbnailCache {
  /// Singleton for app-wide use.
  static final FrameThumbnailCache instance = FrameThumbnailCache._();

  FrameThumbnailCache._({int? maxMemoryBytes, int? thumbnailWidth})
      : maxMemoryBytes = maxMemoryBytes ?? _defaultMaxMemory,
        thumbnailWidth = thumbnailWidth ?? _defaultThumbnailWidth;

  /// Visible-for-testing constructor.
  FrameThumbnailCache.create({
    int? maxMemoryBytes,
    int? thumbnailWidth,
  })  : maxMemoryBytes = maxMemoryBytes ?? _defaultMaxMemory,
        thumbnailWidth = thumbnailWidth ?? _defaultThumbnailWidth;

  static const int _defaultMaxMemory = 64 * 1024 * 1024; // 64 MB
  static const int _defaultThumbnailWidth = 320;

  /// Maximum total bytes before LRU eviction kicks in.
  final int maxMemoryBytes;

  /// Target width for thumbnails generated from source frames.
  final int thumbnailWidth;

  final LinkedHashMap<String, _CacheEntry> _entries = LinkedHashMap();
  int _currentBytes = 0;

  /// Number of entries currently in cache.
  int get length => _entries.length;

  /// Current estimated memory usage in bytes.
  int get currentBytes => _currentBytes;

  /// Cache hit rate (0.0–1.0). Returns 0 if no requests yet.
  double get hitRate =>
      _totalRequests == 0 ? 0.0 : _hits / _totalRequests;

  int _hits = 0;
  int _totalRequests = 0;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Get a thumbnail, loading lazily from [filePath] if not cached.
  ///
  /// Returns compressed JPEG bytes suitable for `Image.memory()`.
  /// Returns `null` if the file cannot be read or decoded.
  Future<Uint8List?> get(String key, {String? filePath}) async {
    _totalRequests++;

    final existing = _entries.remove(key);
    if (existing != null) {
      _hits++;
      _entries[key] = existing; // move to end (most recently used)
      return existing.bytes;
    }

    if (filePath == null) return null;

    final timer = PerfCounters.instance.startTimer('thumbnail_cache_load');
    try {
      final sourceBytes = await readFileBytesInIsolate(filePath);
      final thumb = await decodeAndResizeInIsolate(
        sourceBytes,
        targetWidth: thumbnailWidth,
      );
      timer.stop();

      if (thumb == null) return null;

      _put(key, thumb);
      return thumb;
    } catch (e) {
      timer.stop();
      _log.fine('Failed to load thumbnail for $key: $e');
      return null;
    }
  }

  /// Pre-populate the cache with already-encoded bytes.
  void put(String key, Uint8List bytes) {
    _put(key, bytes);
  }

  /// Check if a key is in cache without affecting LRU order.
  bool containsKey(String key) => _entries.containsKey(key);

  /// Remove a specific entry.
  void remove(String key) {
    final entry = _entries.remove(key);
    if (entry != null) {
      _currentBytes -= entry.bytes.length;
    }
  }

  /// Clear all entries.
  void clear() {
    _entries.clear();
    _currentBytes = 0;
    _hits = 0;
    _totalRequests = 0;
  }

  /// Evict entries until memory usage is at or below [targetBytes].
  void evictTo(int targetBytes) {
    while (_currentBytes > targetBytes && _entries.isNotEmpty) {
      final oldest = _entries.keys.first;
      final entry = _entries.remove(oldest)!;
      _currentBytes -= entry.bytes.length;
    }
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _put(String key, Uint8List bytes) {
    final existing = _entries.remove(key);
    if (existing != null) {
      _currentBytes -= existing.bytes.length;
    }

    _currentBytes += bytes.length;
    _entries[key] = _CacheEntry(bytes);

    _evictIfNeeded();
  }

  void _evictIfNeeded() {
    while (_currentBytes > maxMemoryBytes && _entries.isNotEmpty) {
      final oldest = _entries.keys.first;
      final entry = _entries.remove(oldest)!;
      _currentBytes -= entry.bytes.length;
      _log.finest('Evicted thumbnail $oldest (${entry.bytes.length} bytes)');
    }
  }
}

class _CacheEntry {
  final Uint8List bytes;
  const _CacheEntry(this.bytes);
}
