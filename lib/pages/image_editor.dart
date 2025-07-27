import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/dataset_database.dart';
import '../models/annotated_labeled_media.dart';
import '../models/project.dart';

import '../widgets/dialogs/alert_error_dialog.dart';
import '../widgets/dialogs/delete_annotation_dialog.dart';

import '../widgets/imageeditor/editor_left_toolbar.dart';
import '../widgets/imageeditor/editor_bottom_toolbar.dart';
import '../widgets/imageeditor/editor_top_toolbar.dart';
import '../widgets/imageeditor/editor_canvas.dart';
import '../widgets/imageeditor/editor_action.dart';

class ImageEditorPage extends StatefulWidget {
  final Project project;
  final AnnotatedLabeledMedia mediaItem;
  final String datasetId;
  final int pageIndex, pageSize, localIndex;
  final int totalMediaCount;

  const ImageEditorPage({
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
  State<ImageEditorPage> createState() => _ImageEditorPageState();
}

class _ImageEditorPageState extends State<ImageEditorPage> {
  late PageController _pageController;
  late double _currentZoom = 1.0;
  late int _resetZoomCount = 0;
  int _currentIndex = 0;

  MouseCursor cursorIcon = SystemMouseCursors.basic;
  EditorAction userAction = EditorAction.navigation;

  // do not show right sidebar by default
  bool showRightSidebar = true; // false;
  bool showAnnotationNames = true;
  bool _mouseInsideImage = false;
  bool _isImageModified = false;

  double currentOpacity = 0.35;
  double currentStrokeWidth = 4.0;
  double currentCornerSize = 8.0;

  final Map<int, AnnotatedLabeledMedia> _mediaCache = {};
  final Map<int, ui.Image> _imageCache = {};
  // Track invalid media items (like videos) that can't be loaded as images
  final Map<int, String> _invalidMediaCache = {};
  // Common video file extensions
  final List<String> _videoExtensions = [
    '.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv', '.webm', '.m4v', '.3gp', '.mpg', '.mpeg'
  ];

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.pageIndex * widget.pageSize) + widget.localIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _preloadInitialMedia();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    for (final image in _imageCache.values) {
      image.dispose();
    }
    super.dispose();
  }
  
  /// Limits the image cache size by removing oldest entries when the cache exceeds maxSize.
  /// This helps prevent memory issues with large datasets.
  /// 
  /// @param maxSize The maximum number of images to keep in the cache
  void _limitCacheSize(int maxSize) {
    if (_imageCache.length > maxSize) {
      final keysToRemove = _imageCache.keys.toList().sublist(0, _imageCache.length - maxSize);
      for (final key in keysToRemove) {
        _imageCache[key]?.dispose();
        _imageCache.remove(key);
      }
    }
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
    if (_imageCache.containsKey(index) || _invalidMediaCache.containsKey(index)) return;
    
    final file = File(filePath);
    if (!file.existsSync()) return;
    
    // Check if the file is a video based on its extension
    final fileExtension = filePath.toLowerCase().substring(filePath.lastIndexOf('.'));
    if (_videoExtensions.contains(fileExtension)) {
      // Mark this as an invalid media item (video)
      _invalidMediaCache[index] = 'Video files are not supported for editing';
      if (mounted) setState(() {});
      return;
    }

    try {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _imageCache[index] = frame.image;
      
      // Limit cache size to prevent memory issues with large datasets
      _limitCacheSize(5);
    } catch (e) {
      // Handle other invalid image formats or corrupted files
      _invalidMediaCache[index] = 'Invalid image data: ${e.toString()}';
    }
    
    if (mounted) setState(() {});
  }

  void _handleKeyPress(KeyEvent event) async {
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentIndex = index;
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

  void _handleActionSelected(EditorAction action) {
    setState(() {
      userAction = action;
      cursorIcon = action == EditorAction.navigation
          ? SystemMouseCursors.basic
          : SystemMouseCursors.precise;
    });
  }
  
  // Save the modified image to the original file
  void _saveModifiedImage() async {
    try {
      final currentMedia = _mediaCache[_currentIndex];
      if (currentMedia == null) return;
      
      final filePath = currentMedia.mediaItem.filePath;
      final file = File(filePath);
      
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      // Get the cropped image from the EditorCanvas using the static method directly
      // Use the instance method through the key to avoid Type issues
      final editorCanvasState = EditorCanvas.editorCanvasKey.currentState;
      final croppedImage = editorCanvasState != null 
          ? await (editorCanvasState as dynamic).getCroppedImage() 
          : null;
      
      if (croppedImage != null) {
        // Convert the image to bytes
        final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final pngBytes = byteData.buffer.asUint8List();
          
          // Write the bytes to the file
          await file.writeAsBytes(pngBytes);
          
          // Properly dispose of the old image before removing it from the cache
          final oldImage = _imageCache[_currentIndex];
          if (oldImage != null) {
            oldImage.dispose();
          }
          _imageCache.remove(_currentIndex);
          
          // Reload the image in the cache
          await _loadImage(_currentIndex, filePath);
          
          // Reset the modified state
          setState(() {
            _isImageModified = false;
          });
          
          // Close the loading indicator
          Navigator.of(context).pop();
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
          return;
        }
      }
      
      // If we get here, something went wrong with the cropping
      // Close the loading indicator
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save image: Could not crop the image'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Close the loading indicator if it's showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Handle image modification state changes
  void _handleImageModified(bool isModified) {
    setState(() {
      _isImageModified = isModified;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyPress,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              EditorTopToolbar(
                project: widget.project,
                isModified: _isImageModified,
                onBack: () => Navigator.pop(context, 'refresh'),
                onHelp: () {},
                onSave: _isImageModified ? () {
                  _saveModifiedImage();
                } : null,
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
                    final errorMessage = _invalidMediaCache[index];
                    
                    // Show loading indicator if media is not loaded yet
                    if (media == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    // Show error message for invalid media (like videos)
                    if (errorMessage != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                final newPage = _currentIndex + 1;
                                _pageController.jumpToPage(newPage < widget.totalMediaCount ? newPage : 0);
                              },
                              child: const Text('Next Media Item'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    // Show loading indicator if image is not loaded yet
                    if (image == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    return Row(
                      children: [
                        EditorLeftToolbar(
                          type: widget.project.type,
                          selectedAction: userAction,
                          onResetZoomPressed: () => setState(() => _resetZoomCount++),
                          onActionSelected: _handleActionSelected,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: MouseRegion(
                                  onEnter: (_) => setState(() => _mouseInsideImage = true),
                                  onExit: (_) => setState(() => _mouseInsideImage = false),
                                  cursor: _mouseInsideImage ? cursorIcon : SystemMouseCursors.basic,
                                  child: EditorCanvas(
                                    key: EditorCanvas.editorCanvasKey,
                                    image: image,
                                    mediaItemId: media.mediaItem.id!,
                                    resetZoomCount: _resetZoomCount,
                                    editorAction: userAction,
                                    onZoomChanged: (zoom) {
                                      if (mounted) {
                                        setState(() => _currentZoom = zoom);
                                      }
                                    },
                                    onModifiedChanged: (isModified) {
                                      setState(() {
                                        _isImageModified = isModified;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              EditorBottomToolbar(
                                currentZoom: _currentZoom,
                                currentMedia: media.mediaItem,
                                showUnknownWarning: false,
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
                                onWarning: () {
                                  AlertErrorDialog.show(
                                    context,
                                    'Unknown Annotations',
                                    'This image contains annotations with unknown labels. Please assign a label to continue.',
                                    tips: 'You can select a default label or choose from the available labels.',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}