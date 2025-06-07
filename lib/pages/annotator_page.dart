import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../data/dataset_database.dart';

import '../../models/project.dart';
import '../models/annotated_labeled_media.dart';

import '../widgets/imageannotator/annotator_left_toolbar.dart';
import '../widgets/imageannotator/annotator_right_sidebar.dart';
import '../widgets/imageannotator/annotator_bottom_toolbar.dart';
import '../widgets/imageannotator/annotator_top_toolbar.dart';
import '../widgets/imageannotator/canvas.dart';

class AnnotatorPage extends StatefulWidget {
  final Project project;
  final AnnotatedLabeledMedia mediaItem;
  final String datasetId;
  final int pageIndex, pageSize, localIndex;
  final int totalMediaCount;

  const AnnotatorPage({
    required this.project,
    required this.mediaItem,
    required this.datasetId,
    required this.pageIndex,
    required this.pageSize,
    required this.localIndex,
    required this.totalMediaCount,
    super.key,
  });

  @override
  State<AnnotatorPage> createState() => _AnnotatorPageState();
}

class _AnnotatorPageState extends State<AnnotatorPage> {
  MouseCursor _cursorIcon = SystemMouseCursors.basic;

  late final String datasetId;

  late AnnotatedLabeledMedia currentMediaItem;
  late PageController _pageController;
  late double _currentZoom = 1.0;
  late int _resetZoomCount = 0;
  late int _currentIndex = 0;
  bool _sidebarCollapsed = false;
  bool _mouseInsideImage = false;

  AnnotatedLabeledMedia? _firstMedia;

  @override
  void initState() {
    super.initState();
    currentMediaItem = widget.mediaItem;
    _currentIndex = widget.localIndex;
    _firstMedia = widget.mediaItem;
    _pageController = PageController(initialPage: _currentIndex);
  }

  Future<AnnotatedLabeledMedia?> loadMediaAtIndex(int index) async {
    // int globalIndex = (pageIndex * pageSize) + localIndex;

    if (index == widget.localIndex) {
      return _firstMedia;
    }

    final annotated = await DatasetDatabase.instance.loadMediaAtIndex(datasetId, index);
    if (annotated != null) {
      setState(() {
        currentMediaItem = annotated;
      });
    }
  }

  Future<ui.Image> _loadImageFromFile(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
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
                          itemCount: widget.totalMediaCount,
                          onPageChanged: (index) => setState(() {
                            _currentIndex = index;
                          }),                          
                          itemBuilder: (context, index) {
                            return FutureBuilder<AnnotatedLabeledMedia?>(
                              future: loadMediaAtIndex(index),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                final media = snapshot.data!;

                                return FutureBuilder<ui.Image>(
                                  future: _loadImageFromFile(File(currentMediaItem.mediaItem.filePath)),
                                  builder: (context, imageSnap) {
                                    if (!imageSnap.hasData) {
                                      return const Center(child: CircularProgressIndicator());
                                    }
                                    return MouseRegion(
                                      onEnter: (_) => setState(() => _mouseInsideImage = true),
                                      onExit: (_) => setState(() => _mouseInsideImage = false),
                                      cursor: _mouseInsideImage ? _cursorIcon : SystemMouseCursors.basic,
                                      child: Canvas(
                                        image: imageSnap.data!,
                                        labels: currentMediaItem.labels,
                                        annotations: currentMediaItem.annotations,
                                        resetZoomCount: _resetZoomCount,
                                        onZoomChanged: (zoom) => setState(() => _currentZoom = zoom),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                      AnnotatorBottomToolbar(
                        currentZoom: _currentZoom,
                        currentMedia: _firstMedia!.mediaItem, // May need to update per page
                        onZoomIn: () {},
                        onZoomOut: () {},
                        onPrevImg: () {
                          final newPage = _pageController.page!.toInt() - 1;
                          if (newPage >= 0) _pageController.jumpToPage(newPage);
                        },
                        onNextImg: () {
                          final newPage = _pageController.page!.toInt() + 1;
                          _pageController.jumpToPage(newPage);
                        },
                        onSaveAnnotations: () {},
                      ),
                    ],
                  ),
                ),
                AnnotatorRightSidebar(
                  collapsed: _sidebarCollapsed,
                  labels: _firstMedia!.labels,
                  annotations: _firstMedia!.annotations,
                  onToggleCollapse: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}
