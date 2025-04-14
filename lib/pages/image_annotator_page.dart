// image_annotator_page.dart
import 'dart:io';
import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../models/annotation.dart';
import '../models/project.dart';
import '../data/annotation_database.dart';
import '../session/user_session.dart';

import '../widgets/imageannotator/annotation_canvas.dart';
import '../widgets/imageannotator/annotation_rect.dart';
import '../widgets/imageannotator/left_toolbar.dart';
import '../widgets/imageannotator/right_sidebar.dart';
import '../widgets/imageannotator/bottom_toolbar.dart';
import '../widgets/imageannotator/top_toolbar.dart';

class ImageAnnotatorPage extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final int initialIndex;
  final Project project;

  const ImageAnnotatorPage({
    super.key,
    required this.mediaItems,
    required this.initialIndex,
    required this.project,
  });

  @override
  State<ImageAnnotatorPage> createState() => _ImageAnnotatorPageState();
}

class _ImageAnnotatorPageState extends State<ImageAnnotatorPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _sidebarCollapsed = false;
  double _scale = 1.0;
  List<AnnotationRect> _annotations = [];
  Offset? _startPoint;
  Offset? _currentPoint;
  bool _isDrawing = false;
  String _currentLabel = "Label";
  int? _selectedLabelId;
  bool _mouseInsideImage = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadBoundingBoxAnnotations();
  }

  void _loadBoundingBoxAnnotations() async {
    final mediaId = widget.mediaItems[_currentIndex].id!;
    final loaded = await AnnotationDatabase.instance.fetchAnnotations(mediaId, type: 'bbox');

    setState(() {
      _annotations = loaded
          .where((a) => a.annotationType == 'bbox')
          .map((a) {
        final data = a.data;
        final x = (data['x'] as num?)?.toDouble() ?? 0.0;
        final y = (data['y'] as num?)?.toDouble() ?? 0.0;
        final width = (data['width'] as num?)?.toDouble() ?? 0.0;
        final height = (data['height'] as num?)?.toDouble() ?? 0.0;

        return AnnotationRect(
          rect: Rect.fromLTWH(x, y, width, height),
          label: "Label",
        );
      }).toList();
    });
  }

  Future<void> _saveAnnotations() async {
    final mediaId = widget.mediaItems[_currentIndex].id!;
    final currentUser = UserSession.instance.getUser();

    if (_selectedLabelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a label')),
      );
      return;
    }

    for (final ann in _annotations) {
      final annotation = Annotation(
        mediaItemId: mediaId,
        labelId: _selectedLabelId,
        annotationType: 'bbox',
        data: {
          'x': ann.rect.left,
          'y': ann.rect.top,
          'width': ann.rect.width,
          'height': ann.rect.height,
        },
        confidence: 1.0,
        annotatorId: currentUser.id,
        createdAt: DateTime.now(),
      );

      await AnnotationDatabase.instance.insertAnnotation(annotation);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Annotations saved to database')),
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

  @override
  Widget build(BuildContext context) {
    final currentMedia = widget.mediaItems[_currentIndex];
    final file = File(currentMedia.filePath);
    double _fillOpacity = 0.1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          TopToolbar(
            projectName: widget.project.name,
            projectType: widget.project.type,
            onBack: () => Navigator.pop(context),
            onHelp: () => _showHelpDialog(context),
          ),
          Expanded(
            child: Row(
              children: [
                LeftToolbar(
                  opacity: _fillOpacity,
                  onOpacityChanged: (value) => setState(() => _fillOpacity = value),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: widget.mediaItems.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                              _annotations.clear();
                            });
                            _loadBoundingBoxAnnotations();
                          },
                          itemBuilder: (context, index) {
                            final media = widget.mediaItems[index];
                            final file = File(media.filePath);

                            return MouseRegion(
                              onEnter: (_) => setState(() => _mouseInsideImage = true),
                              onExit: (_) => setState(() {
                                _mouseInsideImage = false;
                                _isDrawing = false;
                                _startPoint = null;
                                _currentPoint = null;
                              }),
                              cursor: _mouseInsideImage
                                ? SystemMouseCursors.precise
                                : SystemMouseCursors.basic,
                              child: GestureDetector(
                                onPanStart: (details) {
                                  if (_mouseInsideImage) {
                                    setState(() {
                                      _isDrawing = true;
                                      _startPoint = details.localPosition;
                                      _currentPoint = _startPoint;
                                    });
                                  }
                                },
                                onPanUpdate: (details) {
                                  if (_isDrawing && _mouseInsideImage) {
                                    setState(() {
                                      _currentPoint = details.localPosition;
                                    });
                                  }
                                },
                                onPanEnd: (details) {
                                  if (_isDrawing && _startPoint != null && _currentPoint != null) {
                                    final rect = Rect.fromPoints(_startPoint!, _currentPoint!);
                                    setState(() {
                                      _annotations.add(AnnotationRect(rect: rect, label: _currentLabel));
                                      _isDrawing = false;
                                      _startPoint = null;
                                      _currentPoint = null;
                                    });
                                  }
                                },
                                child: AnnotationCanvas(
                                  imageFile: file,
                                  annotations: _annotations,
                                  startPoint: _startPoint,
                                  currentPoint: _currentPoint,
                                  isDrawing: _isDrawing,
                                  label: _currentLabel,
                                  fillOpacity: _fillOpacity,
                                  labels: widget.project.labels ?? [],
                                  onLabelSelected: (ann, newLabel) {
                                    setState(() {
                                      ann.label = newLabel;
                                    });
                                  },
                                ),
                              ),
                            );

/*
                            return GestureDetector(
                              onPanStart: (details) {
                                setState(() {
                                  _isDrawing = true;
                                  _startPoint = details.localPosition;
                                  _currentPoint = _startPoint;
                                });
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  _currentPoint = details.localPosition;
                                });
                              },
                              onPanEnd: (details) {
                                if (_startPoint != null && _currentPoint != null) {
                                  final rect = Rect.fromPoints(_startPoint!, _currentPoint!);
                                  setState(() {
                                    _annotations.add(AnnotationRect(rect: rect, label: _currentLabel));
                                    _isDrawing = false;
                                    _startPoint = null;
                                    _currentPoint = null;
                                  });
                                }
                              },
                              child: AnnotationCanvas(
                                imageFile: file,
                                annotations: _annotations,
                                startPoint: _startPoint,
                                currentPoint: _currentPoint,
                                isDrawing: _isDrawing,
                                label: _currentLabel,
                                fillOpacity: _fillOpacity,
                                labels: widget.project.labels ?? [],
                                onLabelSelected: (ann, newLabel) {
                                  setState(() {
                                    // assuming label is mutable
                                    ann.label = newLabel;
                                  });
                                }
                              ),
                            );
*/
                          },
                        ),
                      ),
                      BottomToolbar(
                        scale: _scale,
                        onZoomIn: () => setState(() => _scale = (_scale + 0.1).clamp(0.5, 3.0)),
                        onZoomOut: () => setState(() => _scale = (_scale - 0.1).clamp(0.5, 3.0)),
                      ),
                    ],
                  ),
                ),
                RightSidebar(
                  collapsed: _sidebarCollapsed,
                  annotations: _annotations,
                  onToggleCollapse: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                  onSubmit: _saveAnnotations,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
