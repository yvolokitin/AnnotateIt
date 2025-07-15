import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../data/dataset_database.dart';
import '../data/annotation_database.dart';

import '../models/label.dart';
import '../models/project.dart';
import '../models/annotation.dart';
import '../models/annotated_labeled_media.dart';

import '../widgets/dialogs/alert_error_dialog.dart';
import '../widgets/dialogs/delete_annotation_dialog.dart';

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
  Annotation? _selectedAnnotation;

  Label selectedLabel = Label(id: -1, projectId: -1, name: 'Default', color: '#000000', labelOrder: -1);
  MouseCursor cursorIcon = SystemMouseCursors.basic;
  UserAction userAction = UserAction.navigation;

  bool showAnnotationNames = true;
  bool showRightSidebar = true;
  bool _mouseInsideImage = false;
  double labelOpacity = 0.35;

  final Map<int, AnnotatedLabeledMedia> _mediaCache = {};
  final Map<int, ui.Image> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.pageIndex * widget.pageSize) + widget.localIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _preloadInitialMedia();
  }

  void _preloadInitialMedia() {
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
      if (mounted) setState(() {});
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
    if (mounted) setState(() {});
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentIndex = index;
      // Clear selection when changing images
      _selectedAnnotation = null;
    });
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
  }

  void _handleDefaultLabelSelected(Label? label) {
    print('!!!!!!!!!!!!!!!!! $label');
  }

  void _handleLabelSelected(Label label) {
    setState(() => selectedLabel = label);
  
    // Only automatically create classification annotations if this is a classification project
    if (!widget.project.type.toLowerCase().contains('classification')) {
      return;
    }

    final currentMedia = _mediaCache[_currentIndex];
    if (currentMedia == null) return;

    // Check if this label already exists as a classification
    final existingIndex = currentMedia.annotations?.indexWhere(
      (a) => a.annotationType == 'classification' && a.labelId == label.id
    ) ?? -1;

    if (existingIndex != -1) return;

    // Create new classification annotation
    final newAnnotations = currentMedia.annotations != null 
      ? List<Annotation>.from(currentMedia.annotations!)
      : <Annotation>[];

    newAnnotations.add(Annotation(
      id: null,
      mediaItemId: currentMedia.mediaItem.id!,
      labelId: label.id,
      annotationType: 'classification',
      data: {},
      confidence: 1.0,
      annotatorId: null,
      comment: null,
      status: 'pending',
      version: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )..name = label.name
     ..color = label.toColor());

    _mediaCache[_currentIndex] = currentMedia.copyWith(annotations: newAnnotations);
  }

  void _handleActionSelected(UserAction action) {
    setState(() {
      userAction = action;
      cursorIcon = action == UserAction.navigation
          ? SystemMouseCursors.basic
          : SystemMouseCursors.precise;
    });
  }

  void _handleAnnotationSelected(Annotation? annotation) {
    setState(() {
      _selectedAnnotation = annotation;
    });
  }

  Future<void> _handleAnnotationLabelChanged(Annotation annotation, Label newLabel) async {
    try {
      // Create updated annotation
      final updatedAnnotation = annotation.copyWith(
        labelId: newLabel.id,
        name: newLabel.name,
        color: newLabel.toColor(),
        updatedAt: DateTime.now(),
      );

      // Update in database
      await AnnotationDatabase.instance.updateAnnotation(updatedAnnotation);

      // Update UI state
      if (mounted) {
        setState(() {
          final currentMedia = _mediaCache[_currentIndex];
          if (currentMedia != null) {
            final index = currentMedia.annotations?.indexWhere(
              (a) => a.id == annotation.id
            ) ?? -1;

            if (index != -1) {
              // Create new list to trigger widget update
              final newAnnotations = List<Annotation>.from(currentMedia.annotations!);
              newAnnotations[index] = updatedAnnotation;

              _mediaCache[_currentIndex] = currentMedia.copyWith(annotations: newAnnotations);
            
              if (_selectedAnnotation?.id == annotation.id) {
                _selectedAnnotation = updatedAnnotation;
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        await AlertErrorDialog.show(
          context,
          'Update Failed',
          'Failed to update annotation label: ${e.toString()}',
        );  
      }
    }
  }

  Future<void> _handleAnnotationDelete(Annotation annotation) async {
    final shouldDelete = await DeleteAnnotationDialog.show(
      context: context,
      annotation: annotation,
    );
  
    if (shouldDelete ?? false) {
      try {
        // Delete from database
        final deletedCount = await AnnotationDatabase.instance.deleteAnnotation(annotation.id!);
      
        if (deletedCount > 0 && mounted) {
          setState(() {
            // Update local state
            final currentMedia = _mediaCache[_currentIndex];
            if (currentMedia != null) {
              final newAnnotations = currentMedia.annotations?.where(
                (a) => a.id != annotation.id
              ).toList();
            
              _mediaCache[_currentIndex] = currentMedia.copyWith(annotations: newAnnotations);
            
              if (_selectedAnnotation?.id == annotation.id) {
                _selectedAnnotation = null;
              }
            }
          });
        } else {
          if (mounted) {
            await AlertErrorDialog.show(
              context,
              'Deletion Failed',
              'The annotation could not be deleted from the database.',
              tips: 'Please try again or check your database connection.',
            );
          }
        }
      } catch (e) {
        if (mounted) {
          await AlertErrorDialog.show(
            context,
            'Deletion Error',
            'An error occurred while deleting the annotation: ${e.toString()}',
            tips: 'Please try again or contact support if the problem persists.',
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final image in _imageCache.values) {
      image.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            AnnotatorTopToolbar(
              project: widget.project,
              onBack: () => Navigator.pop(context),
              onHelp: () {},
              onAssignedLabel: _handleLabelSelected,
              onDefaultLabelSelected: _handleDefaultLabelSelected,
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.totalMediaCount,
                onPageChanged: _handlePageChange,
                // disables swipe navigation
                physics: const NeverScrollableScrollPhysics(),
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
                                  mediaItemId: widget.mediaItem.mediaItem.id!,
                                  labels: widget.project.labels ?? [],
                                  annotations: media.annotations,
                                  resetZoomCount: _resetZoomCount,
                                  showAnnotationNames: showAnnotationNames,
                                  opacity: labelOpacity,
                                  userAction: userAction,
                                  selectedLabel: selectedLabel,
                                  selectedAnnotation: _selectedAnnotation,
                                  onZoomChanged: (zoom) {
                                    if (mounted) {
                                      setState(() => _currentZoom = zoom);
                                    }
                                  },
                                  onAnnotationUpdated: _handleAnnotationUpdated,
                                  onAnnotationSelected: _handleAnnotationSelected,
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
                        collapsed: !showRightSidebar,
                        labels: widget.project.labels ?? [],
                        annotations: media.annotations ?? [],
                        selectedAnnotation: _selectedAnnotation,
                        onAnnotationSelected: _handleAnnotationSelected,
                        onAnnotationLabelChanged: _handleAnnotationLabelChanged,
                        onAnnotationDelete: _handleAnnotationDelete,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}