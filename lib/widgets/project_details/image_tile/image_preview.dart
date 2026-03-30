import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../utils/media_bytes_helper.dart';

class ImagePreview extends StatefulWidget {
  final String filePath;
  final int? mediaItemId;
  final VoidCallback onTap;
  final bool hovered;

  const ImagePreview({
    required this.filePath,
    this.mediaItemId,
    required this.onTap,
    required this.hovered,
    super.key,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  Uint8List? _bytes;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath ||
        oldWidget.mediaItemId != widget.mediaItemId) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final bytes = await loadMediaBytes(
        widget.filePath,
        mediaItemId: widget.mediaItemId,
      );
      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _loading = false;
        _failed = bytes == null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transform =
        widget.hovered ? (Matrix4.identity()..scale(1.15)) : Matrix4.identity();

    Widget child;
    if (_loading) {
      child = const Center(child: CircularProgressIndicator(strokeWidth: 2));
    } else if (_failed || _bytes == null) {
      child = const Center(
        child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
      );
    } else {
      child = Image.memory(
        _bytes!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: transform,
      transformAlignment: Alignment.center,
      child: GestureDetector(onTap: widget.onTap, child: child),
    );
  }
}
