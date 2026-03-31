import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../utils/platform_utils.dart';

final _log = Logger('MediaDropZone');

/// Accepted media file extensions.
const Set<String> kImageExtensions = {
  '.jpg', '.jpeg', '.png', '.bmp', '.gif', '.webp', '.tiff', '.tif',
};

const Set<String> kVideoExtensions = {
  '.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v',
};

/// Result of validating a dropped file.
class DroppedMediaFile {
  final String path;
  final String extension;
  final DroppedMediaType type;
  final int sizeBytes;

  const DroppedMediaFile({
    required this.path,
    required this.extension,
    required this.type,
    required this.sizeBytes,
  });

  @override
  String toString() => 'DroppedMediaFile($path, ${type.name})';
}

enum DroppedMediaType { image, video, unsupported }

/// Validates a list of file paths from a drag-and-drop operation.
///
/// Filters out unsupported types and non-existent files. Returns
/// [DroppedMediaFile] entries with resolved type and size.
Future<List<DroppedMediaFile>> validateDroppedFiles(
  List<String> paths,
) async {
  final results = <DroppedMediaFile>[];

  for (final p in paths) {
    final file = File(p);
    if (!await file.exists()) {
      _log.fine('Dropped path does not exist: $p');
      continue;
    }

    final ext = p.contains('.') ? '.${p.split('.').last.toLowerCase()}' : '';
    final stat = await file.stat();

    DroppedMediaType type;
    if (kImageExtensions.contains(ext)) {
      type = DroppedMediaType.image;
    } else if (kVideoExtensions.contains(ext)) {
      type = DroppedMediaType.video;
    } else {
      type = DroppedMediaType.unsupported;
      _log.fine('Unsupported extension: $ext ($p)');
      continue;
    }

    results.add(DroppedMediaFile(
      path: p,
      extension: ext,
      type: type,
      sizeBytes: stat.size,
    ));
  }

  return results;
}

/// A visual drop zone overlay for drag-and-drop media import.
///
/// Wraps a [child] widget and shows a visual indicator when files
/// are being dragged over it. Works on macOS and Windows desktop
/// where native drag-and-drop is supported.
///
/// On platforms without drop support, the zone is inert and just
/// renders the child.
class MediaDropZone extends StatefulWidget {
  final Widget child;
  final void Function(List<DroppedMediaFile> files) onFilesDropped;
  final String? hintText;

  const MediaDropZone({
    super.key,
    required this.child,
    required this.onFilesDropped,
    this.hintText,
  });

  @override
  State<MediaDropZone> createState() => _MediaDropZoneState();
}

class _MediaDropZoneState extends State<MediaDropZone> {
  bool _isDragOver = false;

  bool get _isDesktop =>
      !PlatformUtils.isWeb &&
      (PlatformUtils.isMacOS || PlatformUtils.isWindows || PlatformUtils.isLinux);

  @override
  Widget build(BuildContext context) {
    if (!_isDesktop) return widget.child;

    return Stack(
      children: [
        widget.child,
        if (_isDragOver)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.blue.withValues(alpha: 0.6),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.file_download_outlined,
                        size: 48,
                        color: Colors.blue.withValues(alpha: 0.8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.hintText ?? 'Drop images or videos here',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Call this when the platform drag-enter event fires.
  void onDragEnter() {
    if (!mounted) return;
    setState(() => _isDragOver = true);
  }

  /// Call this when the platform drag-leave event fires.
  void onDragLeave() {
    if (!mounted) return;
    setState(() => _isDragOver = false);
  }

  /// Call this when files are dropped. Validates and filters them
  /// before invoking the callback.
  Future<void> onDrop(List<String> paths) async {
    if (!mounted) return;
    setState(() => _isDragOver = false);

    final validated = await validateDroppedFiles(paths);
    if (validated.isNotEmpty) {
      widget.onFilesDropped(validated);
    }
  }
}
