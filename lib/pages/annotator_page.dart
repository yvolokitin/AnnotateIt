import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as ml_kit;

import '../data/labels_database.dart';
import '../data/dataset_database.dart';

import '../models/label.dart';
import '../models/project.dart';
import '../models/annotation.dart';
import '../models/annotated_labeled_media.dart';

import '../services/annotation_application_service.dart';
import '../services/ml_kit_image_labeling_service.dart';
import '../services/sam_segmentation_service.dart';
import '../session/user_session.dart';
import '../repositories/annotation_repository.dart';
import '../repositories/sqlite_annotation_repository.dart';

import '../widgets/dialogs/alert_error_dialog.dart';
import '../widgets/dialogs/delete_annotation_dialog.dart';

import '../widgets/imageannotator/annotator_left_toolbar.dart';
import '../widgets/imageannotator/annotator_right_sidebar.dart';
import '../widgets/imageannotator/annotator_bottom_toolbar.dart';
import '../widgets/imageannotator/annotator_top_toolbar.dart';
import '../widgets/imageannotator/annotator_canvas.dart';
import '../widgets/imageannotator/user_action.dart';

import '../widgets/app_snackbar.dart';
import '../utils/sam_model_utils.dart';
import 'image_editor.dart';

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

class _MediaOperationContext {
  final int index;
  final int mediaItemId;

  const _MediaOperationContext({
    required this.index,
    required this.mediaItemId,
  });
}

class _AnnotatorPageState extends State<AnnotatorPage> {
  static final _logger = Logger('AnnotatorPage');
  final AnnotationRepository _annotationRepository =
      const SqliteAnnotationRepository();
  late final AnnotationApplicationService _annotationService =
      AnnotationApplicationService(annotationRepository: _annotationRepository);
  late PageController _pageController;
  late double _currentZoom = 1.0;
  late int _resetZoomCount = 0;
  int _currentIndex = 0;
  Annotation? _selectedAnnotation;

  Label selectedLabel = Label(
    id: -1,
    projectId: -1,
    name: 'Unknown',
    color: '#808080',
    labelOrder: -1,
  );
  MouseCursor cursorIcon = SystemMouseCursors.basic;
  UserAction userAction = UserAction.navigation;

  // do not show right sidebar by default
  bool showRightSidebar = true; // false;
  bool showAnnotationNames = true;
  bool _mouseInsideImage = false;

  double currentOpacity = 0.35;
  double currentStrokeWidth = 4.0;
  double currentCornerSize = 8.0;

  final Map<int, AnnotatedLabeledMedia> _mediaCache = {};
  final Map<int, ui.Image> _imageCache = {};
  // Track invalid media items (like videos) that can't be loaded as images
  final Map<int, String> _invalidMediaCache = {};
  // Common video file extensions
  final List<String> _videoExtensions = [
    '.mp4',
    '.avi',
    '.mov',
    '.wmv',
    '.flv',
    '.mkv',
    '.webm',
    '.m4v',
    '.3gp',
    '.mpg',
    '.mpeg',
  ];

  // ML Kit image labeling service
  final MLKitImageLabelingService _mlKitService = MLKitImageLabelingService();
  bool _isProcessingMlKit = false;

  // SAM segmentation service
  final SamSegmentationService _samService = SamSegmentationService();
  bool _isProcessingSAM = false;
  bool _samBetaNotified = false;

  // Selected SAM model key: 'mobile' or 'sam2_hiera_base_plus'
  String _samModelKey = 'mobile';

  final FocusNode _focusNode = FocusNode();

  _MediaOperationContext? _captureCurrentMediaContext() {
    final media = _mediaCache[_currentIndex];
    final mediaId = media?.mediaItem.id;
    if (media == null || mediaId == null) return null;
    return _MediaOperationContext(index: _currentIndex, mediaItemId: mediaId);
  }

  bool _isLiveMediaContext(_MediaOperationContext ctx) {
    final media = _mediaCache[ctx.index];
    return media?.mediaItem.id == ctx.mediaItemId;
  }

  int _findLoadedIndexForMediaId(int mediaItemId) {
    for (final entry in _mediaCache.entries) {
      if (entry.value.mediaItem.id == mediaItemId) {
        return entry.key;
      }
    }
    return -1;
  }

  void _handleSamModelChanged(String key) {
    // Only allow switching to models that are available locally (except mobile which is always available)
    if (key == 'mobile') {
      setState(() => _samModelKey = key);
      _samService.setModelVariant(SamModelVariant.mobile);
      return;
    }

    SamModelUtils.isDownloaded(key).then((available) {
      if (!mounted) return;
      if (available) {
        setState(() => _samModelKey = key);
        final variant =
            key == 'sam2_hiera_large'
                ? SamModelVariant.sam2HieraLarge
                : SamModelVariant.sam2HieraBasePlus;
        _samService.setModelVariant(variant);
      } else {
        // Fallback to mobile and inform the user
        AppSnackbar.show(
          context,
          'Selected SAM2 model is not available. Please download it first from the Model screen.',
          backgroundColor: Colors.orangeAccent,
          textColor: Colors.black,
          saveToDb: false,
        );
        setState(() => _samModelKey = 'mobile');
        _samService.setModelVariant(SamModelVariant.mobile);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.pageIndex * widget.pageSize) + widget.localIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _preloadInitialMedia();

    // Initialize ML Kit image labeler
    if (Platform.isAndroid || Platform.isIOS) {
      _mlKitService.initialize(confidenceThreshold: 0.6);
    }

    // Initialize SAM segmentation service (platform-agnostic; uses fallback if runtime unsupported)
    _samService.initialize();

    // Initialize default SAM model from user preference
    try {
      final preferredSam = UserSession.instance.getUser().preferredSamModelKey;
      if (preferredSam == 'mobile') {
        _handleSamModelChanged(preferredSam);
      } else {
        SamModelUtils.isDownloaded(preferredSam).then((available) {
          if (!mounted) return;
          if (available) {
            _handleSamModelChanged(preferredSam);
          } else {
            // Silently fallback to mobile on page open without notification
            setState(() => _samModelKey = 'mobile');
            _samService.setModelVariant(SamModelVariant.mobile);
          }
        });
      }
    } catch (_) {
      // UserSession may not be initialized in some contexts; ignore
    }

    if (widget.project.labels.isEmpty || widget.mediaItem.annotations.isEmpty) {
      showRightSidebar = false;
    }

    // Set the default label if one exists in the project
    if (widget.project.labels.isNotEmpty) {
      // Check if there's a label marked as default
      final hasDefaultLabel = widget.project.labels.any(
        (label) => label.isDefault,
      );

      // Get user preference for setting first label as default
      final setFirstLabelAsDefault =
          UserSession.instance.getUser().labelsSetFirstAsDefault;

      if (hasDefaultLabel) {
        // If there's a default label, use it regardless of user preference
        final defaultLabel = widget.project.labels.firstWhere(
          (label) => label.isDefault,
        );
        selectedLabel = defaultLabel;
      } else if (setFirstLabelAsDefault) {
        // If user has enabled "set first label as default" and no default label exists,
        // use the first label as default
        selectedLabel = widget.project.labels.first;
      }
      // If neither condition is met, keep the initial selectedLabel (Unknown)
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pageController.dispose();
    for (final image in _imageCache.values) {
      image.dispose();
    }

    if (Platform.isAndroid || Platform.isIOS) {
      _mlKitService.close();
    }

    _samService.close();

    super.dispose();
  }

  /// Handle a click (in image coordinates) when SAM tool is active
  Future<void> _handleSamTap(Offset imagePoint) async {
    if (_isProcessingSAM) return;

    final mediaCtx = _captureCurrentMediaContext();
    final currentMedia = mediaCtx == null ? null : _mediaCache[mediaCtx.index];
    final currentImage = mediaCtx == null ? null : _imageCache[mediaCtx.index];

    if (currentMedia == null || currentImage == null) {
      await AlertErrorDialog.show(
        context,
        'SAM',
        'No image available to process.',
      );
      return;
    }
    final activeCtx = mediaCtx!;

    if ((selectedLabel.id ?? -1) == -1) {
      await AlertErrorDialog.show(
        context,
        'No Label Selected',
        'Please select a label before creating an annotation.',
      );
      return;
    }

    setState(() => _isProcessingSAM = true);

    try {
      final polygon = await _samService.generateMaskPolygon(
        image: currentImage,
        tapPoint: imagePoint,
      );

      if (polygon.isEmpty) {
        await AlertErrorDialog.show(
          context,
          'SAM',
          'Could not generate a mask for the selected point.',
        );
        return;
      }

      final isDetectionProject = widget.project.type.toLowerCase().contains(
        'detect',
      );

      Annotation newAnnotation;
      if (isDetectionProject) {
        // Convert polygon to tight bounding box
        double minX = double.infinity,
            minY = double.infinity,
            maxX = -double.infinity,
            maxY = -double.infinity;
        for (final p in polygon) {
          if (p.dx < minX) minX = p.dx;
          if (p.dy < minY) minY = p.dy;
          if (p.dx > maxX) maxX = p.dx;
          if (p.dy > maxY) maxY = p.dy;
        }
        // Safety clamp to image bounds
        minX = minX.clamp(0.0, currentImage.width.toDouble());
        minY = minY.clamp(0.0, currentImage.height.toDouble());
        maxX = maxX.clamp(0.0, currentImage.width.toDouble());
        maxY = maxY.clamp(0.0, currentImage.height.toDouble());
        final rect = ui.Rect.fromLTRB(minX, minY, maxX, maxY);

        newAnnotation =
            Annotation(
                id: DateTime.now().millisecondsSinceEpoch,
                mediaItemId: currentMedia.mediaItem.id!,
                labelId: selectedLabel.id!,
                annotationType: 'bbox',
                data: {
                  'x': rect.left,
                  'y': rect.top,
                  'width': rect.width,
                  'height': rect.height,
                },
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
              ..name = selectedLabel.name
              ..color = selectedLabel.toColor();
      } else {
        // Segmentation project: save polygon mask
        newAnnotation =
            Annotation(
                id: DateTime.now().millisecondsSinceEpoch,
                mediaItemId: currentMedia.mediaItem.id!,
                labelId: selectedLabel.id!,
                annotationType: 'polygon',
                data: {
                  'points': polygon.map((p) => [p.dx, p.dy]).toList(),
                },
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
              ..name = selectedLabel.name
              ..color = selectedLabel.toColor();
      }

      final insertedId = await _annotationRepository.insertAnnotation(
        newAnnotation,
      );
      final savedAnnotation =
          Annotation(
              id: insertedId,
              mediaItemId: newAnnotation.mediaItemId,
              labelId: newAnnotation.labelId,
              annotationType: newAnnotation.annotationType,
              data: newAnnotation.data,
              confidence: newAnnotation.confidence,
              annotatorId: newAnnotation.annotatorId,
              comment: newAnnotation.comment,
              status: newAnnotation.status,
              version: newAnnotation.version,
              createdAt: newAnnotation.createdAt,
              updatedAt: newAnnotation.updatedAt,
            )
            ..name = newAnnotation.name
            ..color = newAnnotation.color;

      if (mounted) {
        setState(() {
          if (!_isLiveMediaContext(activeCtx)) {
            return;
          }
          final liveMedia = _mediaCache[activeCtx.index]!;
          final existingAnnotations = List<Annotation>.from(
            liveMedia.annotations ?? [],
          );
          existingAnnotations.add(savedAnnotation);
          _mediaCache[activeCtx.index] = liveMedia.copyWith(
            annotations: existingAnnotations,
          );
          if (_currentIndex == activeCtx.index) {
            _selectedAnnotation = savedAnnotation;
          }
        });
      }
    } catch (e) {
      await AlertErrorDialog.show(
        context,
        'SAM Failed',
        'An error occurred while generating the annotation: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessingSAM = false);
      }
    }
  }

  /// Process the current image with ML Kit and create annotations from the results
  Future<void> _processImageWithMlKit() async {
    if (_isProcessingMlKit) return;

    final mediaCtx = _captureCurrentMediaContext();
    final currentMedia = mediaCtx == null ? null : _mediaCache[mediaCtx.index];
    final currentImage = mediaCtx == null ? null : _imageCache[mediaCtx.index];

    if (currentMedia == null || currentImage == null) {
      await AlertErrorDialog.show(
        context,
        'ML Kit Processing Failed',
        'No image available to process.',
      );
      return;
    }
    final activeCtx = mediaCtx!;

    setState(() => _isProcessingMlKit = true);

    try {
      _logger.info(
        'Starting ML Kit image labeling for media ID: ${currentMedia.mediaItem.id}',
      );
      _logger.fine(
        'Image size: ${currentImage.width}x${currentImage.height}, projectType=${widget.project.type}',
      );

      // Process the image with ML Kit based on project type
      final labels = await _mlKitService.processImage(
        currentImage,
        projectType: widget.project.type,
      );

      if (labels.isEmpty) {
        _logger.info('No labels detected by ML Kit');
        if (mounted) {
          await AlertErrorDialog.show(
            context,
            'No Labels Detected',
            'ML Kit did not detect any labels in this image.',
            tips: 'Try a different image or adjust the confidence threshold.',
          );
        }
        return;
      }

      _logger.info('ML Kit detected ${labels.length} labels');

      // Convert ML Kit labels to annotations based on project type
      var annotations = _mlKitService.convertLabelsToAnnotations(
        labels: labels,
        mediaItemId: currentMedia.mediaItem.id!,
        projectLabels: widget.project.labels ?? [],
        annotatorId: 1, // Default annotator ID
        projectType: widget.project.type,
        imageWidth: currentImage.width,
        imageHeight: currentImage.height,
      );

      if (annotations.isEmpty) {
        _logger.info('No matching project labels found for ML Kit labels');

        // Get all detected labels from ML Kit
        final detectedLabels = _mlKitService.getDetectedLabels(labels);

        if (detectedLabels.isEmpty) {
          if (mounted) {
            await AlertErrorDialog.show(
              context,
              'No Labels Detected',
              'ML Kit did not detect any labels in this image.',
              tips: 'Try a different image or adjust the confidence threshold.',
            );
          }
          return;
        }

        // Automatically add new labels to the project
        final addedLabels = <Label>[];
        final existingLabelNames =
            widget.project.labels?.map((l) => l.name.toLowerCase()).toSet() ??
            {};

        for (final label in detectedLabels) {
          // Skip if label already exists in the project (case-insensitive comparison)
          if (existingLabelNames.contains(label.label.toLowerCase())) {
            continue;
          }

          try {
            // Add the label to the project
            final newLabel = await _addLabelToProjectInternal(label.label);
            if (newLabel != null) {
              addedLabels.add(newLabel);
              existingLabelNames.add(label.label.toLowerCase());
            }
          } catch (e) {
            _logger.warning(
              'Failed to add label ${label.label}: ${e.toString()}',
            );
          }
        }

        if (addedLabels.isEmpty) {
          _logger.info('No new labels were added to the project');
          return;
        }

        _logger.info('Added ${addedLabels.length} new labels to the project');

        // Process the image again with the updated project labels
        final updatedAnnotations = _mlKitService.convertLabelsToAnnotations(
          labels: labels,
          mediaItemId: currentMedia.mediaItem.id!,
          projectLabels: widget.project.labels ?? [],
          annotatorId: 1, // Default annotator ID
          projectType: widget.project.type,
          imageWidth: currentImage.width,
          imageHeight: currentImage.height,
        );

        if (updatedAnnotations.isEmpty) {
          _logger.warning(
            'Still no matching project labels after adding new labels',
          );
          return;
        }

        // Continue with the updated annotations
        annotations = updatedAnnotations;
      }

      _logger.info(
        'Created ${annotations.length} annotations from ML Kit labels',
      );

      // Save annotations to database
      final annotationDb = _annotationRepository;
      final savedAnnotations = <Annotation>[];

      for (final annotation in annotations) {
        _logger.fine(
          'Saving annotation type=${annotation.annotationType}, data=${annotation.data}',
        );
        final insertedId = await annotationDb.insertAnnotation(annotation);

        final savedAnnotation =
            Annotation(
                id: insertedId,
                mediaItemId: annotation.mediaItemId,
                labelId: annotation.labelId,
                annotationType: annotation.annotationType,
                data: annotation.data,
                confidence: annotation.confidence,
                annotatorId: annotation.annotatorId,
                comment: annotation.comment,
                status: annotation.status,
                version: annotation.version,
                createdAt: annotation.createdAt,
                updatedAt: annotation.updatedAt,
              )
              ..name = annotation.name
              ..color = annotation.color;

        savedAnnotations.add(savedAnnotation);
      }

      // Update UI
      if (mounted) {
        setState(() {
          if (!_isLiveMediaContext(activeCtx)) {
            return;
          }
          final liveMedia = _mediaCache[activeCtx.index]!;
          final existingAnnotations = List<Annotation>.from(
            liveMedia.annotations ?? [],
          );
          final newAnnotations = [...existingAnnotations, ...savedAnnotations];

          _mediaCache[activeCtx.index] = liveMedia.copyWith(
            annotations: newAnnotations,
          );

          // Switch back to navigation mode
          if (_currentIndex == activeCtx.index) {
            userAction = UserAction.navigation;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added ${savedAnnotations.length} labels from ML Kit',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _logger.severe('Error processing image with ML Kit', e);
      if (mounted) {
        await AlertErrorDialog.show(
          context,
          'ML Kit Processing Failed',
          'An error occurred while processing the image: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingMlKit = false);
      }
    }
  }

  /// Limits the image cache size by removing oldest entries when the cache exceeds maxSize.
  /// This helps prevent memory issues with large datasets.
  ///
  /// @param maxSize The maximum number of images to keep in the cache
  void _limitCacheSize(int maxSize) {
    if (_imageCache.length > maxSize) {
      final keysToRemove = _imageCache.keys.toList().sublist(
        0,
        _imageCache.length - maxSize,
      );
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
    final media = await DatasetDatabase.instance.loadMediaAtIndex(
      widget.datasetId,
      index,
    );
    if (media != null) {
      _mediaCache[index] = media;
      await _loadImage(index, media.mediaItem.filePath);
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadImage(int index, String filePath) async {
    if (_imageCache.containsKey(index) || _invalidMediaCache.containsKey(index))
      return;

    final file = File(filePath);
    if (!file.existsSync()) return;

    // Check if the file is a video based on its extension
    final fileExtension = filePath.toLowerCase().substring(
      filePath.lastIndexOf('.'),
    );
    if (_videoExtensions.contains(fileExtension)) {
      // Mark this as an invalid media item (video)
      final fileName = filePath.substring(filePath.lastIndexOf('\\') + 1);
      _invalidMediaCache[index] =
          'Video files are not supported for annotation: $fileName';
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
    if (event is KeyDownEvent) {
      final isDelete =
          event.logicalKey == LogicalKeyboardKey.delete ||
          event.logicalKey == LogicalKeyboardKey.backspace;
      if (isDelete && _selectedAnnotation != null) {
        await _handleAnnotationDelete(_selectedAnnotation!);
      }
    }
  }

  void _handlePageChange(int index) {
    setState(() {
      _currentIndex = index;
      // Clear selection when changing images
      _selectedAnnotation = null;
    });

    // Ensure the current page's media is loaded when navigating (e.g., wrap-around jumps)
    if (!_mediaCache.containsKey(index)) {
      _loadMedia(index);
    } else if (!_imageCache.containsKey(index) &&
        !_invalidMediaCache.containsKey(index)) {
      // In case media is cached but image wasn't decoded yet
      _loadImage(index, _mediaCache[index]!.mediaItem.filePath);
    }

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

  bool get _hasUnknownAnnotations {
    final currentMedia = _mediaCache[_currentIndex];
    if (currentMedia?.annotations == null) return false;
    return currentMedia!.annotations!.any((a) => a.labelId == -1);
  }

  void _handleAnnotationUpdated(Annotation updatedAnnotation) {
    setState(() {
      final currentMedia = _mediaCache[_currentIndex];
      if (currentMedia != null) {
        final annotations = List<Annotation>.from(
          currentMedia.annotations ?? [],
        );
        final existingIndex = annotations.indexWhere(
          (a) => a.id == updatedAnnotation.id,
        );

        if (existingIndex != -1) {
          annotations[existingIndex] = updatedAnnotation;
        } else {
          annotations.add(updatedAnnotation);
        }

        _mediaCache[_currentIndex] = currentMedia.copyWith(
          annotations: annotations,
        );
      }
    });
  }

  void _handleDefaultLabelSelected(Label? defaultLabel) async {
    final newDefaultLabel =
        defaultLabel ??
        Label(
          id: -1,
          projectId: -1,
          name: 'Unknown',
          color: '#808080',
          labelOrder: -1,
        );

    if (newDefaultLabel.id != -1) {
      // persist default label in DB
      await LabelsDatabase.instance.setLabelAsDefault(
        newDefaultLabel.id,
        widget.project.id!,
      );
    }

    // update in-memory project labels
    final updatedLabels =
        widget.project.labels?.map((label) {
          if (label.id == newDefaultLabel.id) {
            return label.copyWith(isDefault: true);
          } else {
            return label.copyWith(isDefault: false);
          }
        }).toList();

    // update the UI
    if (updatedLabels != null) {
      setState(() {
        selectedLabel = newDefaultLabel;
        widget.project.labels
          ?..clear()
          ..addAll(updatedLabels);
      });
    }
  }

  void _handleLabelSelected(Label label) async {
    setState(() => selectedLabel = label);

    final type = widget.project.type.toLowerCase();

    if (type.contains('classification')) {
      final mediaCtx = _captureCurrentMediaContext();
      final currentMedia =
          mediaCtx == null ? null : _mediaCache[mediaCtx.index];
      if (currentMedia == null) return;
      final activeCtx = mediaCtx!;
      final result = await _annotationService.assignClassificationLabel(
        mediaItemId: currentMedia.mediaItem.id!,
        label: label,
        isMultiLabel: type.contains('multi-label'),
        existingAnnotations: List<Annotation>.from(
          currentMedia.annotations ?? [],
        ),
      );
      if (!result.changed) return;

      setState(() {
        if (!_isLiveMediaContext(activeCtx)) {
          return;
        }
        final liveMedia = _mediaCache[activeCtx.index]!;
        _mediaCache[activeCtx.index] = liveMedia.copyWith(
          annotations: result.annotations,
        );
        if (_currentIndex == activeCtx.index) {
          _selectedAnnotation = result.addedAnnotation;
        }
      });
    } else {
      // For other project types, just update the selected label
      if (_selectedAnnotation != null) {
        _handleAnnotationLabelChanged(_selectedAnnotation!, label);
      }
    }
  }

  void _handleActionSelected(UserAction action) {
    if (action == UserAction.ml_kit_labeling) {
      // Check if ML Kit is supported on this platform
      if (!_mlKitService.isSupported) {
        // Show an error dialog if ML Kit is not supported
        AlertErrorDialog.show(
          context,
          'ML Kit Not Supported',
          'ML Kit image labeling is not supported on this platform.',
          tips: 'ML Kit is only available on Android and iOS devices.',
        );
        return;
      }

      // Set userAction to ML Kit labeling to show it as selected in the UI
      setState(() {
        userAction = action;
      });

      // Process the current image with ML Kit
      _processImageWithMlKit();
      return;
    }

    // Show SAM Beta quality notice when selecting SAM tool (do not save to DB)
    if (action == UserAction.sam_annotation) {
      if (!_samBetaNotified) {
        AppSnackbar.show(
          context,
          'SAM is integrated in Beta quality. Results may be inaccurate and performance may vary.',
          saveToDb: false,
        );
        _samBetaNotified = true;
      }
    }

    setState(() {
      userAction = action;
      cursorIcon =
          action == UserAction.navigation
              ? SystemMouseCursors.basic
              : SystemMouseCursors.precise;

      // Deselect annotation when leaving navigation/annotation mode
      _selectedAnnotation = null;
    });
  }

  void _handleAnnotationSelected(Annotation? annotation) {
    setState(() {
      _selectedAnnotation = annotation;
    });
  }

  Future<void> _handleAnnotationLabelChanged(
    Annotation annotation,
    Label newLabel,
  ) async {
    try {
      final mediaIndex = _findLoadedIndexForMediaId(annotation.mediaItemId);
      if (mediaIndex == -1) return;
      final mediaCtx = _MediaOperationContext(
        index: mediaIndex,
        mediaItemId: annotation.mediaItemId,
      );

      final result = await _annotationService.updateAnnotationLabel(
        annotation: annotation,
        newLabel: newLabel,
      );
      if (result.status == AnnotationLabelUpdateStatus.conflict) {
        if (mounted) {
          await AlertErrorDialog.show(
            context,
            'Update Conflict',
            'This annotation was changed by another operation. Reload the item and apply your change again.',
          );
        }
        return;
      }
      final persistedAnnotation = result.annotation!;

      // Update UI state
      if (mounted) {
        setState(() {
          if (!_isLiveMediaContext(mediaCtx)) {
            return;
          }
          final currentMedia = _mediaCache[mediaCtx.index];
          if (currentMedia != null) {
            final index =
                currentMedia.annotations?.indexWhere(
                  (a) => a.id == annotation.id,
                ) ??
                -1;

            if (index != -1) {
              // Create new list to trigger widget update
              final newAnnotations = List<Annotation>.from(
                currentMedia.annotations!,
              );
              newAnnotations[index] = persistedAnnotation;

              _mediaCache[mediaCtx.index] = currentMedia.copyWith(
                annotations: newAnnotations,
              );

              if (_selectedAnnotation?.id == annotation.id) {
                _selectedAnnotation = persistedAnnotation;
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
    // Check if we should show the confirmation dialog
    bool shouldShowDialog =
        UserSession.instance.askConfirmationOnAnnotationRemoval;
    bool shouldDelete = false;

    if (shouldShowDialog) {
      // Show the confirmation dialog
      final result = await DeleteAnnotationDialog.show(
        context: context,
        annotation: annotation,
      );

      if (result != null) {
        shouldDelete = result.shouldDelete;

        // If user checked "Don't ask again", save this preference
        if (result.dontAskAgain) {
          await UserSession.instance.setAskConfirmationOnAnnotationRemoval(
            false,
          );
        }
      }
    } else {
      // Skip confirmation and delete directly
      shouldDelete = true;
    }

    if (shouldDelete) {
      try {
        final mediaIndex = _findLoadedIndexForMediaId(annotation.mediaItemId);
        final mediaCtx =
            mediaIndex == -1
                ? null
                : _MediaOperationContext(
                  index: mediaIndex,
                  mediaItemId: annotation.mediaItemId,
                );

        // Delete from database
        final deletedCount = await _annotationRepository.deleteAnnotation(
          annotation.id!,
        );

        if (deletedCount > 0 && mounted) {
          setState(() {
            if (mediaCtx == null || !_isLiveMediaContext(mediaCtx)) {
              if (_selectedAnnotation?.id == annotation.id) {
                _selectedAnnotation = null;
              }
              return;
            }
            // Update local state
            final currentMedia = _mediaCache[mediaCtx.index];
            if (currentMedia != null) {
              final newAnnotations =
                  currentMedia.annotations
                      ?.where((a) => a.id != annotation.id)
                      .toList();

              _mediaCache[mediaCtx.index] = currentMedia.copyWith(
                annotations: newAnnotations,
              );

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
            tips:
                'Please try again or contact support if the problem persists.',
          );
        }
      }
    }
  }

  Future<void> _handleDeleteAllAnnotations() async {
    final mediaCtx = _captureCurrentMediaContext();
    final currentMedia = mediaCtx == null ? null : _mediaCache[mediaCtx.index];
    if (currentMedia == null) return;
    final activeCtx = mediaCtx!;
    try {
      final mediaId = currentMedia.mediaItem.id;
      if (mediaId == null) return;
      await _annotationRepository.deleteAnnotationsByMedia(mediaId);
      if (!mounted) return;
      setState(() {
        if (_isLiveMediaContext(activeCtx)) {
          final liveMedia = _mediaCache[activeCtx.index]!;
          _mediaCache[activeCtx.index] = liveMedia.copyWith(annotations: []);
        }
        _selectedAnnotation = null;
      });
    } catch (e) {
      if (mounted) {
        await AlertErrorDialog.show(
          context,
          'Deletion Error',
          'An error occurred while deleting all annotations: ${e.toString()}',
          tips: 'Please try again or contact support if the problem persists.',
        );
      }
    }
  }

  /// Show a dialog with detected labels and option to add them to the project
  Future<void> _showDetectedLabelsDialog(
    List<ml_kit.ImageLabel> detectedLabels,
  ) async {
    if (!mounted) return;

    // Sort labels by confidence (highest first)
    final sortedLabels = List<ml_kit.ImageLabel>.from(detectedLabels)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    // Show dialog with detected labels
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ML Kit Detected Objects'),
          content: SizedBox(
            width: 400,
            height: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ML Kit detected the following objects in this image:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'None of these match your project labels. You can add these labels to your project.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: sortedLabels.length,
                    itemBuilder: (context, index) {
                      final label = sortedLabels[index];
                      final confidence = (label.confidence * 100)
                          .toStringAsFixed(1);

                      return ListTile(
                        title: Text(label.label),
                        subtitle: Text('Confidence: $confidence%'),
                        trailing: ElevatedButton(
                          onPressed: () => _addLabelToProject(label.label),
                          child: const Text('Add to Project'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Add a new label to the project and return the created label
  Future<Label?> _addLabelToProjectInternal(String labelName) async {
    try {
      // Generate a random color for the new label
      final random = Random();
      final r = random.nextInt(200) + 55; // Avoid too dark colors
      final g = random.nextInt(200) + 55;
      final b = random.nextInt(200) + 55;
      final color =
          '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';

      // Create a new label
      final newLabel = Label(
        id: -1, // Will be assigned by the database
        projectId: widget.project.id!,
        name: labelName,
        color: color,
        labelOrder: (widget.project.labels?.length ?? 0) + 1,
      );

      // Save the label to the database
      final labelDb = LabelsDatabase.instance;
      final labelId = await labelDb.insertLabel(newLabel);

      if (labelId != -1) {
        // Create a complete label with the assigned ID
        final completeLabel = Label(
          id: labelId,
          projectId: newLabel.projectId,
          name: newLabel.name,
          color: newLabel.color,
          labelOrder: newLabel.labelOrder,
          isDefault: false,
          description: null,
          createdAt: DateTime.now(),
        );

        // Update the project's labels in memory
        setState(() {
          final updatedLabels = List<Label>.from(widget.project.labels ?? []);
          updatedLabels.add(completeLabel);
          widget.project.labels?.clear();
          widget.project.labels?.addAll(updatedLabels);
        });

        return completeLabel;
      }
      return null;
    } catch (e) {
      _logger.severe('Error adding label to project', e);
      return null;
    }
  }

  /// Add a new label to the project
  Future<void> _addLabelToProject(String labelName) async {
    try {
      // Generate a random color for the new label
      final random = Random();
      final r = random.nextInt(200) + 55; // Avoid too dark colors
      final g = random.nextInt(200) + 55;
      final b = random.nextInt(200) + 55;
      final color =
          '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';

      // Create a new label
      final newLabel = Label(
        id: -1, // Will be assigned by the database
        projectId: widget.project.id!,
        name: labelName,
        color: color,
        labelOrder: (widget.project.labels?.length ?? 0) + 1,
      );

      // Save the label to the database
      final labelDb = LabelsDatabase.instance;
      final labelId = await labelDb.insertLabel(newLabel);

      if (labelId != -1) {
        // Create a complete label with the assigned ID
        final completeLabel = Label(
          id: labelId,
          projectId: newLabel.projectId,
          name: newLabel.name,
          color: newLabel.color,
          labelOrder: newLabel.labelOrder,
          isDefault: false,
          description: null,
          createdAt: DateTime.now(),
        );

        // Update the project's labels in memory
        setState(() {
          final updatedLabels = List<Label>.from(widget.project.labels ?? []);
          updatedLabels.add(completeLabel);
          widget.project.labels?.clear();
          widget.project.labels?.addAll(updatedLabels);
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added label "$labelName" to project'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      _logger.severe('Error adding label to project', e);
      if (mounted) {
        await AlertErrorDialog.show(
          context,
          'Failed to Add Label',
          'An error occurred while adding the label: ${e.toString()}',
        );
      }
    }
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
          child: Stack(
            children: [
              Column(
                children: [
                  AnnotatorTopToolbar(
                    project: widget.project,
                    onBack: () => Navigator.pop(context, 'refresh'),
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
                        final errorMessage = _invalidMediaCache[index];

                        // Show loading indicator if media is not loaded yet
                        if (media == null) {
                          // Ensure media starts loading for this page (handles wrap-around jumps)
                          _loadMedia(index);
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // Show error message for invalid media (like videos)
                        if (errorMessage != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  errorMessage,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(
                                          (0.3 * 255).toInt(),
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      final newPage = _currentIndex + 1;
                                      _pageController.jumpToPage(
                                        newPage < widget.totalMediaCount
                                            ? newPage
                                            : 0,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(30),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 5,
                                      ),
                                      child: Text(
                                        'Next Media Item',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontFamily: 'CascadiaCode',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        // Show loading indicator if image is not loaded yet
                        if (image == null) {
                          // Decode/load image for already-loaded media
                          _loadImage(index, media.mediaItem.filePath);
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return Row(
                          children: [
                            AnnotatorLeftToolbar(
                              type: widget.project.type,
                              opacity: currentOpacity,
                              strokeWidth: currentStrokeWidth,
                              cornerSize: currentCornerSize,
                              selectedAction: userAction,
                              showAnnotationNames: showAnnotationNames,
                              isProcessingMlKit: _isProcessingMlKit,
                              isProcessingSAM: _isProcessingSAM,
                              selectedSamModelKey: _samModelKey,
                              onSamModelChanged: _handleSamModelChanged,
                              onOpacityChanged:
                                  (v) => setState(() => currentOpacity = v),
                              onStrokeWidthChanged:
                                  (v) => setState(() => currentStrokeWidth = v),
                              onCornerSizeChanged:
                                  (v) => setState(() => currentCornerSize = v),
                              onResetZoomPressed:
                                  () => setState(() => _resetZoomCount++),
                              onShowDatasetGridChanged:
                                  (v) => setState(() => showRightSidebar = v),
                              onActionSelected: _handleActionSelected,
                              onShowAnnotationNames:
                                  (v) =>
                                      setState(() => showAnnotationNames = v),
                              onSwitchToEditor: () {
                                final newPageIndex =
                                    _currentIndex ~/ widget.pageSize;
                                final newLocalIndex =
                                    _currentIndex % widget.pageSize;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ImageEditorPage(
                                          project: widget.project,
                                          mediaItem: media!,
                                          datasetId: widget.datasetId,
                                          pageIndex: newPageIndex,
                                          pageSize: widget.pageSize,
                                          localIndex: newLocalIndex,
                                          totalMediaCount:
                                              widget.totalMediaCount,
                                        ),
                                  ),
                                );
                              },
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: MouseRegion(
                                      onEnter:
                                          (_) => setState(
                                            () => _mouseInsideImage = true,
                                          ),
                                      onExit:
                                          (_) => setState(
                                            () => _mouseInsideImage = false,
                                          ),
                                      cursor:
                                          _mouseInsideImage
                                              ? cursorIcon
                                              : SystemMouseCursors.basic,
                                      child: AnnotatorCanvas(
                                        image: image,
                                        mediaItemId: media.mediaItem.id!,
                                        labels: widget.project.labels ?? [],
                                        annotations: media.annotations,
                                        resetZoomCount: _resetZoomCount,
                                        showAnnotationNames:
                                            showAnnotationNames,
                                        opacity: currentOpacity,
                                        strokeWidth: currentStrokeWidth,
                                        cornerSize: currentCornerSize,
                                        userAction: userAction,
                                        selectedLabel: selectedLabel,
                                        selectedAnnotation: _selectedAnnotation,
                                        requestedZoom: _currentZoom,
                                        onZoomChanged: (zoom) {
                                          if (!mounted) return;
                                          if ((_currentZoom - zoom).abs() <
                                              0.0005)
                                            return;
                                          setState(() => _currentZoom = zoom);
                                        },
                                        onAnnotationUpdated:
                                            _handleAnnotationUpdated,
                                        onAnnotationSelected:
                                            _handleAnnotationSelected,
                                        onSamTap: _handleSamTap,
                                        onAnnotationLabelChanged:
                                            _handleAnnotationLabelChanged,
                                        onAnnotationDelete:
                                            _handleAnnotationDelete,
                                      ),
                                    ),
                                  ),
                                  AnnotatorBottomToolbar(
                                    currentZoom: _currentZoom,
                                    currentMedia: media.mediaItem,
                                    showUnknownWarning: _hasUnknownAnnotations,
                                    onZoomIn: () {
                                      setState(() {
                                        _currentZoom = (_currentZoom + 0.01)
                                            .clamp(0.01, 20.0);
                                      });
                                    },
                                    onZoomOut: () {
                                      setState(() {
                                        _currentZoom = (_currentZoom - 0.01)
                                            .clamp(0.01, 20.0);
                                      });
                                    },
                                    onPrevImg: () {
                                      final newPage = _currentIndex - 1;
                                      _pageController.jumpToPage(
                                        newPage >= 0
                                            ? newPage
                                            : widget.totalMediaCount - 1,
                                      );
                                    },
                                    onNextImg: () {
                                      final newPage = _currentIndex + 1;
                                      _pageController.jumpToPage(
                                        newPage < widget.totalMediaCount
                                            ? newPage
                                            : 0,
                                      );
                                    },
                                    onWarning: () {
                                      AlertErrorDialog.show(
                                        context,
                                        'Unknown Annotations',
                                        'This image contains annotations with unknown labels. Please assign a label to continue.',
                                        tips:
                                            'You can select a default label or choose from the available labels.',
                                      );
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
                              onAnnotationLabelChanged:
                                  _handleAnnotationLabelChanged,
                              onAnnotationDelete: _handleAnnotationDelete,
                              onDeleteAll: _handleDeleteAllAnnotations,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              // Global processing overlay
              if (_isProcessingSAM || _isProcessingMlKit)
                Positioned.fill(
                  child: AbsorbPointer(
                    absorbing: true,
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: CircularProgressIndicator(
                            strokeWidth: 6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
