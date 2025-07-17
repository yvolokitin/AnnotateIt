import 'dart:io';
import 'package:flutter/material.dart';

import '../../models/media_item.dart';
import 'annotator_icon_button.dart';

class AnnotatorBottomToolbar extends StatefulWidget {
  final double currentZoom;
  final MediaItem currentMedia;
  final bool showUnknownWarning;

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  final VoidCallback onPrevImg;
  final VoidCallback onNextImg;
  final VoidCallback onWarning;

  const AnnotatorBottomToolbar({
    super.key,
    required this.currentZoom,
    required this.currentMedia,
    required this.showUnknownWarning,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onPrevImg,
    required this.onNextImg,
    required this.onWarning,
  });

  @override
  State<AnnotatorBottomToolbar> createState() => _AnnotatorBottomToolbarState();
}

class _AnnotatorBottomToolbarState extends State<AnnotatorBottomToolbar> {
  @override
  Widget build(BuildContext context) {
    final String fileName = '${widget.currentMedia.filePath.split(Platform.pathSeparator).last}, ';
    final String widthHeight = '${widget.currentMedia.width} px x ${widget.currentMedia.height} px';
    final String percent = '${(widget.currentZoom * 100).toStringAsFixed(0)}%';
    final bool isCompact = MediaQuery.of(context).size.width < 1300;
    final bool isMinimal = MediaQuery.of(context).size.width < 860;

    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: const Border(
          top: BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
      ),      
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              AnnotatorIconButton(
                onPressed: widget.onZoomOut,
                icon: const Icon(Icons.remove, color: Colors.white70, size: 32),                
              ),
              const SizedBox(width: 8),
              Text(percent, style: const TextStyle(color: Colors.white70, fontSize: 20)),
              const SizedBox(width: 8),
              AnnotatorIconButton(
                onPressed: widget.onZoomIn,
                icon: const Icon(Icons.add, color: Colors.white70, size: 32),
              ),
            ],
          ),

          if (!isCompact) ...[
            const SizedBox(width: 25),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(color: Colors.white70, fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (!isMinimal)
            Text(widthHeight, style: const TextStyle(color: Colors.white70, fontSize: 20)),

          const Spacer(),
          Row(
            children: [
              AnnotatorIconButton(
                onPressed: widget.onPrevImg,
                icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white70, size: 36),
              ),
              const SizedBox(width: 6),
              AnnotatorIconButton(
                onPressed: widget.onNextImg,
                icon: const Icon(Icons.keyboard_arrow_right, color: Colors.white70, size: 36),
              ),

              if (widget.showUnknownWarning)...[
                const SizedBox(width: 20),
                AnnotatorIconButton(
                  onPressed: widget.onWarning,
                  icon: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
