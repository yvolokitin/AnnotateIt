import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:async/async.dart';

import '../data/dataset_database.dart';

import '../models/project.dart';
import '../models/annotation.dart';
import '../models/annotated_labeled_media.dart';

import '../widgets/imageannotator/annotator_left_toolbar.dart';
import '../widgets/imageannotator/annotator_right_sidebar.dart';
import '../widgets/imageannotator/annotator_bottom_toolbar.dart';
import '../widgets/imageannotator/annotator_top_toolbar.dart';
import '../widgets/imageannotator/annotator_canvas.dart';
import '../widgets/imageannotator/user_action.dart';

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
  late PageController _pageController;
  late double _currentZoom = 1.0;
  late int _resetZoomCount = 0;
  int _currentIndex = 0;

  MouseCursor cursorIcon = SystemMouseCursors.basic;
  UserAction userAction = UserAction.navigation;

  bool showAnnotationNames = true;
  bool showRightSidebar = false;
  bool _mouseInsideImage = false;
  double labelOpacity = 0.35;

  final Map<int, AnnotatedLabeledMedia> _mediaCache = {};
  final Map<int, ui.Image> _imageCache = {};

  @override
  void initState() {
    print("AnnotatorPage labels: ${widget.project.labels?.length}");

    super.initState();
    _currentIndex = (widget.pageIndex * widget.pageSize) + widget.localIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _preloadInitialMedia();
  }

  void _preloadInitialMedia() {
    // Preload current, previous and next media
    final indicesToPreload = {
      _currentIndex,
      _currentIndex - 1,
      _currentIndex + 1,
    }.where((i) => i >= 0 && i < widget.totalMediaCount);

    for (final index in indicesToPreload) {
      _loadMedia(index);
    }
  }

Future<void> _loadMedia(int index) async {
  if (_mediaCache.containsKey(index)) return;

  final media = await DatasetDatabase.instance.loadMediaAtIndex(widget.datasetId, index);
  if (media != null) {
    _mediaCache[index] = media;
    await _loadImage(index, media.mediaItem.filePath);
    if (mounted) setState(() {}); // ✅ trigger rebuild
  }
}

Future<void> _loadImage(int index, String filePath) async {
  if (_imageCache.containsKey(index)) return;

  final file = File(filePath);
  if (!file.existsSync()) return;

  final bytes = await file.readAsBytes();
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  _imageCache[index] = frame.image;
  if (mounted) setState(() {}); // ✅ trigger rebuild
}

  void _handlePageChange(int index) {
    setState(() => _currentIndex = index);
    _preloadAdjacentImages(index);
  }

  void _preloadAdjacentImages(int currentIndex) {
    final indicesToPreload = {
      currentIndex - 1,
      currentIndex + 1,
    }.where((i) => i >= 0 && i < widget.totalMediaCount);

    for (final index in indicesToPreload) {
      if (_mediaCache.containsKey(index)) {
        _loadImage(index, _mediaCache[index]!.mediaItem.filePath);
      } else {
        _loadMedia(index);
      }
    }
  }

  void _handleAnnotationUpdated(Annotation updatedAnnotation) {
    setState(() {
      final currentMedia = _mediaCache[_currentIndex];
      if (currentMedia != null) {
        final index = currentMedia.annotations?.indexWhere(
          (a) => a.id == updatedAnnotation.id
        ) ?? -1;

        if (index != -1) {
          currentMedia.annotations?[index] = updatedAnnotation;
        }
      }
    });
  
    // Optionally save immediately - not needed due to save button
  }

  void _handleActionSelected(UserAction action) {
    setState(() {
      userAction = action;
      cursorIcon = action == UserAction.navigation
          ? SystemMouseCursors.basic
          : SystemMouseCursors.precise;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose all cached images
    for (final image in _imageCache.values) {
      image.dispose();
    }
    super.dispose();
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
              onPageChanged: _handlePageChange,
              itemBuilder: (context, index) {
                final media = _mediaCache[index];
                final image = _imageCache[index];

                if (media == null || image == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Row(
                  children: [
                    AnnotatorLeftToolbar(
                      type: widget.project.type,
                      opacity: labelOpacity,
                      selectedAction: userAction,
                      showAnnotationNames: showAnnotationNames,
                      onOpacityChanged: (v) => setState(() => labelOpacity = v),
                      onResetZoomPressed: () => setState(() => _resetZoomCount++),
                      onShowDatasetGridChanged: (v) => setState(() => showRightSidebar = v),
                      onActionSelected: _handleActionSelected,
                      onShowAnnotationNames: (v) => setState(() => showAnnotationNames = v),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: MouseRegion(
                              onEnter: (_) => setState(() => _mouseInsideImage = true),
                              onExit: (_) => setState(() => _mouseInsideImage = false),
                              cursor: _mouseInsideImage ? cursorIcon : SystemMouseCursors.basic,
                              child: AnnotatorCanvas(
                                image: image,
                                labels: widget.project.labels ?? [],
                                annotations: media.annotations,
                                resetZoomCount: _resetZoomCount,
                                showAnnotationNames: showAnnotationNames,
                                opacity: labelOpacity,
                                userAction: userAction,
                                onZoomChanged: (zoom) {
                                  if (mounted) {
                                    setState(() => _currentZoom = zoom);
                                  }
                                },
                                onAnnotationUpdated: _handleAnnotationUpdated,
                              ),
                            ),
                          ),
                          AnnotatorBottomToolbar(
                            currentZoom: _currentZoom,
                            currentMedia: media.mediaItem,
                            onZoomIn: () {},
                            onZoomOut: () {},
                            onPrevImg: () {
                              final newPage = _currentIndex - 1;
                              _pageController.jumpToPage(newPage >= 0 ? newPage : widget.totalMediaCount - 1);
                            },
                            onNextImg: () {
                              final newPage = _currentIndex + 1;
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
            ),
          ),
        ],
      ),
    );
  }
}