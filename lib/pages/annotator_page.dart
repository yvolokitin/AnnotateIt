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
import '../widgets/imageannotator/annotator_canvas.dart';

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

  final Map<int, AnnotatedLabeledMedia> _mediaCache = {};
  final Map<int, Future<AnnotatedLabeledMedia?>> _mediaFutures = {};

  late PageController _pageController;
  late double _currentZoom = 1.0;
  late int _resetZoomCount = 0;
  bool showRightSidebar = false;
  bool _mouseInsideImage = false;
  double labelOpacity = 0.35;
  ui.Image? _cachedImage;

  @override
  void initState() {
    super.initState();
    final initialIndex = (widget.pageIndex * widget.pageSize) + widget.localIndex;
    _pageController = PageController(initialPage: initialIndex);
  }

  Future<AnnotatedLabeledMedia?> getMediaFuture(int index) {
    if (_mediaCache.containsKey(index)) {
      return Future.value(_mediaCache[index]);
    }
    if (_mediaFutures.containsKey(index)) {
      return _mediaFutures[index]!;
    }

    final future = DatasetDatabase.instance.loadMediaAtIndex(widget.datasetId, index).then((media) {
      if (media != null) _mediaCache[index] = media;
      return media;
    });

    _mediaFutures[index] = future;
    return future;
  }

  Future<ui.Image> _loadImageFromFile(File file) async {
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          AnnotatorTopToolbar(
            project: widget.project,
            onBack: () => Navigator.pop(context),
            onHelp: () {},
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.totalMediaCount,
              onPageChanged: (_) => setState(() => _cachedImage = null),
              itemBuilder: (context, index) {
                return FutureBuilder<AnnotatedLabeledMedia?>(
                  future: getMediaFuture(index),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final media = snapshot.data!;
                    return FutureBuilder<ui.Image>(
                      future: _cachedImage != null
                          ? Future.value(_cachedImage)
                          : _loadImageFromFile(File(media.mediaItem.filePath)).then((image) {
                              _cachedImage = image;
                              return image;
                            }),
                      builder: (context, imageSnap) {
                        if (!imageSnap.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        return Row(
                          children: [
                            AnnotatorLeftToolbar(
                              type: widget.project.type,
                              opacity: labelOpacity,
                              onOpacityChanged: (value) => setState(() => labelOpacity = value),
                              onMouseIconChanged: (value) => setState(() => _cursorIcon = value),
                              onResetZoomPressed: () => setState(() => _resetZoomCount++),
                              onShowDatasetGridChanged: (value) => setState(() => showRightSidebar = value),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: MouseRegion(
                                      onEnter: (_) => setState(() => _mouseInsideImage = true),
                                      onExit: (_) => setState(() => _mouseInsideImage = false),
                                      cursor: _mouseInsideImage ? _cursorIcon : SystemMouseCursors.basic,
                                      child: AnnotatorCanvas(
                                        image: imageSnap.data!,
                                        labels: widget.project.labels!,
                                        annotations: media.annotations,
                                        resetZoomCount: _resetZoomCount,
                                        opacity: labelOpacity,
                                        onZoomChanged: (zoom) => setState(() => _currentZoom = zoom),
                                      ),
                                    ),
                                  ),
                                  AnnotatorBottomToolbar(
                                    currentZoom: _currentZoom,
                                    currentMedia: media.mediaItem,
                                    onZoomIn: () {}, // implement
                                    onZoomOut: () {}, // implement
                                    onPrevImg: () {
                                      final newPage = _pageController.page!.toInt() - 1;
                                      _pageController.jumpToPage(newPage >= 0 ? newPage : widget.totalMediaCount - 1);
                                    },
                                    onNextImg: () {
                                      final newPage = _pageController.page!.toInt() + 1;
                                      _pageController.jumpToPage(newPage < widget.totalMediaCount ? newPage : 0);
                                    },
                                    onSaveAnnotations: () {
                                      // TODO: save annotations
                                    },
                                  ),
                                ],
                              ),
                            ),
                            AnnotatorRightSidebar(
                              collapsed: showRightSidebar,
                              annotations: media.annotations,
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}