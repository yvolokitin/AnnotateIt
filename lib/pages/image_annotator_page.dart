import 'dart:io';
import 'package:flutter/material.dart';

import '../models/annotated_labeled_media.dart';
// import '../models/media_item.dart'; // Not directly used, Annotation holds mediaItemId
import '../models/annotation.dart';
import '../models/shape/rect_shape.dart'; // Import RectShape
import '../models/project.dart';
import '../data/annotation_database.dart';
import '../session/user_session.dart';

import '../widgets/imageannotator/annotation_canvas_from_file.dart';
import '../widgets/imageannotator/annotation_rect.dart';
import '../widgets/imageannotator/left_toolbar.dart';
import '../widgets/imageannotator/right_sidebar.dart';
import '../widgets/imageannotator/bottom_toolbar.dart';
import '../widgets/imageannotator/top_toolbar.dart';

class ImageAnnotatorPage extends StatefulWidget {
  final List<AnnotatedLabeledMedia> mediaItems;
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
  final String _currentLabel = "Label";
  int? _selectedLabelId;
  bool _mouseInsideImage = false;
  String? _activeTool; // Added state for active tool

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadBoundingBoxAnnotations();
  }

  void _loadBoundingBoxAnnotations() async {
    final mediaId = widget.mediaItems[_currentIndex].mediaItem.id!;
    final loaded = await AnnotationDatabase.instance.fetchAnnotations(mediaId, type: 'bbox');

    setState(() {
      _annotations = loaded
          .where((a) => a.shape is RectShape) // Check shape type
          .map((a) {
        final shape = a.shape as RectShape; // Cast to RectShape
        return AnnotationRect(
          rect: Rect.fromLTWH(shape.x, shape.y, shape.width, shape.height),
          label: "Label",
        );
      }).toList();
    });
  }

  Future<void> _saveAnnotations() async {
    final mediaId = widget.mediaItems[_currentIndex].mediaItem.id!;
    final currentUser = UserSession.instance.getUser();

    if (_selectedLabelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a label')),
      );
      return;
    }

    for (final ann in _annotations) {
      final rectShape = RectShape( // Create RectShape object
        ann.rect.left,
        ann.rect.top,
        ann.rect.width,
        ann.rect.height,
      );
      final annotation = Annotation(
        mediaItemId: mediaId,
        labelId: _selectedLabelId,
        shape: rectShape, // Assign RectShape object
        confidence: 1.0,
        annotatorId: currentUser.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
    final currentMedia = widget.mediaItems[_currentIndex].mediaItem;
    final file = File(currentMedia.filePath);
    double fillOpacity = 0.1;

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
                  opacity: fillOpacity,
                  onOpacityChanged: (value) => setState(() => fillOpacity = value),
                  onToolSelected: (toolName) { // Added onToolSelected callback
                    setState(() {
                      _activeTool = toolName;
                      // Potentially reset other drawing states if necessary
                      _isDrawing = false;
                      _startPoint = null;
                      _currentPoint = null;
                    });
                  },
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
                            final media = widget.mediaItems[index].mediaItem;
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
                                child: AnnotationCanvasFromFile(
                                  file: file,
                                  annotations: _annotations, // These are existing, displayed annotations
                                  labelDefinitions: [], // Pass actual label definitions if available
                                  activeTool: _activeTool, // Pass active tool
                                  onAnnotationCreated: (newAnnotation) {
                                    if (newAnnotation.shape is RectShape) {
                                      final rectShape = newAnnotation.shape as RectShape;
                                      setState(() {
                                        _annotations.add(
                                          AnnotationRect(
                                            rect: rectShape.toRect(),
                                            // TODO: Get label from current selection or default
                                            label: _currentLabel,
                                          ),
                                        );
                                      });
                                    } else {
                                      // Handle other shapes or log if not expected
                                      print("New annotation created with shape: ${newAnnotation.shape.runtimeType}");
                                    }
                                  },
                                ),
                            );
                          },
                        ),
                      ),
                      
                      BottomToolbar(
                        scale: _scale,
                        onZoomIn: () {
                          setState(() {
                            _scale = (_scale + 0.1).clamp(0.5, 5.0);
                          });
                        },
                        onZoomOut: () {
                          setState(() {
                            _scale = (_scale - 0.1).clamp(0.5, 5.0);
                          });
                        },
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
