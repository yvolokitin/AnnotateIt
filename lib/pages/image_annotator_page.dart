import 'dart:io';
import 'package:flutter/material.dart';

import '../models/annotated_labeled_media.dart';
import '../models/annotation.dart';
import '../models/project.dart';

import '../session/user_session.dart';
import '../widgets/imageannotator/annotation_canvas_from_file.dart';
import '../widgets/imageannotator/annotation_rect.dart';
import '../widgets/imageannotator/left_toolbar.dart';
import '../widgets/imageannotator/right_sidebar.dart';
import '../widgets/imageannotator/bottom_toolbar.dart';
import '../widgets/imageannotator/top_toolbar.dart';

class ImageAnnotatorPage extends StatefulWidget {
  final List<AnnotatedLabeledMedia> annotatedItems;
  final int initialIndex;
  final Project project;
  final bool preloaded;

  const ImageAnnotatorPage({
    super.key,
    required this.annotatedItems,
    required this.initialIndex,
    required this.project,
    this.preloaded = false,
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
  double _fillOpacity = 0.1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadAnnotationsFromAnnotated(widget.annotatedItems[_currentIndex]);
  }

  void _loadAnnotationsFromAnnotated(AnnotatedLabeledMedia annotated) {
    setState(() {
      _annotations = annotated.annotations.map((a) {
        final data = a.data;
        final label = annotated.findLabelById(a.labelId);

        if (label == null) {
          throw Exception("Label with ID '${a.labelId}' not found for annotation.");
        }          

        return AnnotationRect(
          rect: Rect.fromLTWH(
            (data['x'] as num?)?.toDouble() ?? 0.0,
            (data['y'] as num?)?.toDouble() ?? 0.0,
            (data['width'] as num?)?.toDouble() ?? 0.0,
            (data['height'] as num?)?.toDouble() ?? 0.0,
          ),
          label: label,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = widget.annotatedItems[_currentIndex];
    final file = File(current.mediaItem.filePath);

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
                          itemCount: widget.annotatedItems.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                            _loadAnnotationsFromAnnotated(widget.annotatedItems[index]);
                          },
                          itemBuilder: (context, index) {
                            final annotated = widget.annotatedItems[index];
                            final file = File(annotated.mediaItem.filePath);

                            return MouseRegion(
                              cursor: SystemMouseCursors.precise,
                              child: AnnotationCanvasFromFile(
                                file: file,
                                annotations: _annotations,
                                labelDefinitions: annotated.labels,
                              ),
                            );
                          },
                        ),
                      ),
                      BottomToolbar(
                        scale: _scale,
                        onZoomIn: () => setState(() => _scale = (_scale + 0.1).clamp(0.5, 5.0)),
                        onZoomOut: () => setState(() => _scale = (_scale - 0.1).clamp(0.5, 5.0)),
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

  Future<void> _saveAnnotations() async {
    final mediaId = widget.annotatedItems[_currentIndex].mediaItem.id!;
    final currentUser = UserSession.instance.getUser();

    for (final ann in _annotations) {
      final annotation = Annotation(
        mediaItemId: mediaId,
        labelId: null,
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
        updatedAt: DateTime.now(),
      );

      // await AnnotationDatabase.instance.insertAnnotation(annotation);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Annotations saved (not yet persisted)')),
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
