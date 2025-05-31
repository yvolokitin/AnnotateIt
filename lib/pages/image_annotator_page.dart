import 'dart:io';
import 'package:flutter/material.dart';

import '../models/media_item.dart';
import '../models/annotation.dart';
import '../models/project.dart';
import '../data/annotation_database.dart';
import '../session/user_session.dart';

import '../widgets/imageannotator/annotation_canvas_from_file.dart';
// import '../widgets/imageannotator/annotation_rect.dart'; // No longer needed
import '../widgets/imageannotator/annotation_tool.dart';
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
  // List<AnnotationRect> _annotations = []; // Old
  List<Annotation> _annotations = [];    // New
  Offset? _startPoint;
  Offset? _currentPoint;
  bool _isDrawing = false;
  final String _currentLabel = "Label";
  int? _selectedLabelId;
  bool _mouseInsideImage = false;
  AnnotationTool _currentTool = AnnotationTool.none;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _loadBoundingBoxAnnotations();
  }

  void _loadBoundingBoxAnnotations() async {
    if (widget.mediaItems.isEmpty || _currentIndex >= widget.mediaItems.length) return;
    final mediaId = widget.mediaItems[_currentIndex].id;
    if (mediaId == null) return; // Cannot load annotations without media ID

    final loadedAnnotations = await AnnotationDatabase.instance.fetchAnnotations(mediaId, type: 'bbox');
    if (!mounted) return; // Check if the widget is still in the tree
    setState(() {
      _annotations = loadedAnnotations.where((a) => a.annotationType.toLowerCase() == 'bbox').toList();
    });
  }

  Future<void> _saveAnnotations() async {
    if (widget.mediaItems.isEmpty || _currentIndex >= widget.mediaItems.length) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No media item selected.')),
        );
      }
      return;
    }
    final mediaId = widget.mediaItems[_currentIndex].id;
    if (mediaId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot save annotations without a media ID.')),
        );
      }
      return;
    }

    final currentUser = UserSession.instance.getUser();
    if (currentUser.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in.')),
        );
      }
      return;
    }

    // Filter for new annotations (those without an ID)
    final List<Annotation> newAnnotationsToSave = [];
    for (final ann in _annotations) {
      if (ann.id == null) { // This is a new annotation
        // Ensure labelId is set for new annotations.
        // The drawing logic in canvas.dart assigns widget.selectedLabelId (which is _selectedLabelId from this page).
        // So, ann.labelId should be populated if _selectedLabelId was set at the time of drawing.
        if (ann.labelId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('A new annotation is missing a label. Please select a label. Annotation data: ${ann.data}')),
            );
          }
          return; // Stop saving if a new annotation is missing a label
        }
        newAnnotationsToSave.add(
          Annotation(
            // id is null for new annotations
            mediaItemId: mediaId,
            labelId: ann.labelId, // Should be set during creation
            annotationType: ann.annotationType, // Should be 'bbox'
            data: ann.data,
            confidence: ann.confidence ?? 1.0,
            annotatorId: currentUser.id, // Set current user as annotator
            createdAt: DateTime.now(),   // Set creation timestamp
            updatedAt: DateTime.now(),   // Set update timestamp
            // version, comment, status can be defaulted or set if UI supports it
          )
        );
      }
      // Existing annotations (ann.id != null) are not saved again by this logic.
      // If updating existing annotations becomes a requirement, this method needs expansion.
    }

    if (newAnnotationsToSave.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No new annotations to save.')),
        );
      }
      return;
    }

    try {
      // Use batch insert for efficiency
      await AnnotationDatabase.instance.insertAnnotationsBatch(newAnnotationsToSave);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New annotations saved successfully.')),
        );
        // Reload annotations to get DB-assigned IDs and ensure consistency
        _loadBoundingBoxAnnotations();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving annotations: $e')),
        );
      }
      print('Error saving annotations: $e');
    }
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

  void _handleAnnotationCreated(Annotation annotation) {
    // This is where the new annotation would be added to a list
    // that's passed to the canvas and eventually saved.
    if (!mounted) return;
    setState(() {
      _annotations.add(annotation);
    });
    // For debugging:
    // print('New annotation added to ImageAnnotatorPage._annotations. Total: ${_annotations.length}');
  }

  @override
  Widget build(BuildContext context) {
    final currentMedia = widget.mediaItems[_currentIndex];
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
                  opacity: fillOpacity, // Ensure fillOpacity is defined in this scope
                  onOpacityChanged: (value) => setState(() => fillOpacity = value), // Ensure fillOpacity is defined
                  onToolSelected: (tool) {
                    setState(() {
                      _currentTool = tool;
                      // Optional: Reset drawing state if necessary
                      // _isDrawing = false;
                      // _startPoint = null;
                      // _currentPoint = null;
                      print('Tool selected: $_currentTool');
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
                                // child: AnnotationCanvasDemo(imageFile: file, annotations: _annotations,),
                                child: AnnotationCanvasFromFile(
                                  file: file,
                                  annotations: _annotations, // Now List<Annotation>
                                  labelDefinitions: widget.project.labels ?? [], // Pass project labels
                                  currentTool: _currentTool,
                                  currentMediaItemId: widget.mediaItems[_currentIndex].id ?? 0,
                                  selectedLabelId: _selectedLabelId,
                                  onAnnotationCreated: _handleAnnotationCreated,
                                ),
                                /*child: AnnotationCanvas(
                                  imageFile: file,
                                  annotations: _annotations,
                                  label: _currentLabel,
                                  fillOpacity: fillOpacity,
                                  labels: widget.project.labels ?? [],
                                  scale: _scale,
                                  onScaleChanged: (newScale) => setState(() => _scale = newScale),
                                  onLabelSelected: (ann, newLabel) => setState(() => ann.label = newLabel),
                                  onNewAnnotation: (ann) => setState(() => _annotations.add(ann)),
                                ),*/
                              //),
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
                  annotations: _annotations, // Already List<Annotation>
                  labelDefinitions: widget.project.labels ?? [], // Add this
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
