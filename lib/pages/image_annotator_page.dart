import 'dart:io';
import 'package:flutter/material.dart';

import '../models/annotated_labeled_media.dart';
import '../models/project.dart';
import '../models/media_item.dart';

import '../widgets/imageannotator/annotator_file_canvas_loader.dart';
import '../widgets/imageannotator/annotator_left_toolbar.dart';
import '../widgets/imageannotator/annotator_right_sidebar.dart';
import '../widgets/imageannotator/annotator_bottom_toolbar.dart';
import '../widgets/imageannotator/annotator_top_toolbar.dart';

class ImageAnnotatorPage extends StatefulWidget {
  final AnnotatedLabeledMedia mediaItem;
  final int initialIndex;
  final Project project;

  const ImageAnnotatorPage({
    required this.mediaItem,
    required this.initialIndex,
    required this.project,
    super.key,
  });

  @override
  State<ImageAnnotatorPage> createState() => _ImageAnnotatorPageState();
}

class _ImageAnnotatorPageState extends State<ImageAnnotatorPage> {
  MouseCursor _cursorIcon = SystemMouseCursors.basic;

  late PageController _pageController;
  late MediaItem _currentMedia;
  late double _currentZoom = 1.0;
  late int _currentIndex;
  late int _resetZoomCount = 0;

  bool _sidebarCollapsed = false;
  bool _mouseInsideImage = false;
  
  @override
  void initState() {
    super.initState();
    _currentMedia = widget.mediaItem.mediaItem;
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }


  void _getNextMedia() async {
    setState(() {
      _currentMedia = widget.mediaItem.mediaItem;
      _currentIndex = _currentIndex + 1;
    });
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to use annotation tool'),
        content: const Text(
          'Use the left toolbar to draw annotations.\n'
          'Use the right panel to review and submit them.\n'
          'Zoom controls are at the bottom.\n\n'
          '← returns to project details.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double fillOpacity = 0.1;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          AnnotatorTopToolbar(
            project: widget.project,
            onBack: () => Navigator.pop(context),
            onHelp: () => _showHelpDialog(context),
          ),
          Expanded(
            child: Row(
              children: [
                AnnotatorLeftToolbar(
                  type: widget.project.type,
                  opacity: fillOpacity,
                  onOpacityChanged: (value) => setState(() => fillOpacity = value),
                  onMouseIconChanged: (value) => setState(() => _cursorIcon = value),
                  onResetZoomPressed: () => setState(() => _resetZoomCount++),
                ),

                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemBuilder: (context, index) {
                            final mediaItem = widget.mediaItem;
                            final file = File(mediaItem.mediaItem.filePath);
                            return MouseRegion(
                              onEnter: (_) => setState(() => _mouseInsideImage = true),
                              onExit: (_) => setState(() {
                                _mouseInsideImage = false;
                              }),
                              cursor: _mouseInsideImage
                                ? _cursorIcon // SystemMouseCursors.precise
                                : SystemMouseCursors.basic,
                              child: AnnotatorFileCanvasLoader(
                                file: file,
                                cursor: _cursorIcon,
                                labels: mediaItem.labels,
                                annotations: mediaItem.annotations,
                                resetZoomCount: _resetZoomCount,
                                onZoomChanged: (zoom) => setState(() => _currentZoom = zoom),
                              ),
                            );
                          },
                          onPageChanged: (index) {
                            _getNextMedia();
                          },
                        ),
                      ),

                      AnnotatorBottomToolbar(
                        currentZoom: _currentZoom,
                        currentMedia: _currentMedia,
                        onZoomIn: () { print('onZoomIn'); },
                        onZoomOut: () { print('onZoomOut'); },
                        onPrevImg: () { print('onPrevImg'); },
                        onNextImg: () { print('onNextImg'); },
                        onSaveAnnotations: () { print('onSaveAnnotations'); },
                      ),
                    ],
                  ),
                ),

                AnnotatorRightSidebar(
                  collapsed: _sidebarCollapsed,
                  labels: widget.mediaItem.labels,
                  annotations: widget.mediaItem.annotations,
                  onToggleCollapse: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
