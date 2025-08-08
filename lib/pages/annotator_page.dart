import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as ml_kit;

import 'package:sam_onnx/sam_onnx.dart';
import 'dart:typed_data';

import '../data/labels_database.dart';
import '../data/dataset_database.dart';
import '../data/annotation_database.dart';

import '../models/label.dart';
import '../models/project.dart';
import '../models/annotation.dart';
import '../models/annotated_labeled_media.dart';

import '../services/ml_kit_image_labeling_service.dart';
import '../services/tflite_detection_service.dart';
import '../session/user_session.dart';

import '../widgets/dialogs/alert_error_dialog.dart';
import '../widgets/dialogs/delete_annotation_dialog.dart';

import '../widgets/imageannotator/annotator_left_toolbar.dart';
import '../widgets/imageannotator/annotator_right_sidebar.dart';
import '../widgets/imageannotator/annotator_bottom_toolbar.dart';
import '../widgets/imageannotator/annotator_top_toolbar.dart';
import '../widgets/imageannotator/annotator_canvas.dart';
import '../widgets/imageannotator/user_action.dart';

// SAM helpers in your repo
import '../sam/sam_service.dart';
import '../sam/image_preprocess.dart';
import '../sam/mask_post.dart';
import '../sam/asset_io.dart';

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
  static final _logger = Logger('AnnotatorPage');
  late PageController _pageController;
  late double _currentZoom = 1.0;
  late int _resetZoomCount = 0;
  int _currentIndex = 0;
  Annotation? _selectedAnnotation;

  Label selectedLabel = Label(id: -1, projectId: -1, name: 'Unknown', color: '#808080', labelOrder: -1);
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
    '.mp4', '.avi', '.mov', '.wmv', '.flv', '.mkv', '.webm', '.m4v', '.3gp', '.mpg', '.mpeg'
  ];

  // ML Kit image labeling service
  final MLKitImageLabelingService _mlKitService = MLKitImageLabelingService();
  bool _isProcessingMlKit = false;
  
  // TFLite detection service
  final TFLiteDetectionService _tfliteService = TFLiteDetectionService();
  bool _isProcessingTFLite = false;

  final FocusNode _focusNode = FocusNode();

  // SAM state: service, busy flag, provider, and optional embedding cache
  late final SamService _sam;
  bool _samBusy = false;

  // SamProvider _provider = SamProvider.auto;
  SamProvider _provider = Platform.isWindows
    ? SamProvider.directml
    : (Platform.isAndroid ? SamProvider.nnapi : SamProvider.auto);

  final _embeddings = <int, Float32List>{};

  @override
  void initState() {
    super.initState();
    _currentIndex = (widget.pageIndex * widget.pageSize) + widget.localIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _preloadInitialMedia();

    // Initialize SAM
    _initSam();
    
    // Initialize ML Kit image labeler
    if (Platform.isAndroid || Platform.isIOS) {
      _mlKitService.initialize(confidenceThreshold: 0.6);
    }
    
    // Initialize TFLite detection service
    if (Platform.isWindows || Platform.isMacOS) {
      print('WINDOWS:: Initializing TFLite detection service');
      _tfliteService.initialize(confidenceThreshold: 0.5);
    }

    if (widget.project.labels.isEmpty || widget.mediaItem.annotations.isEmpty) {
      showRightSidebar = false;
    }
    
    // Set the default label if one exists in the project
    if (widget.project.labels.isNotEmpty) {
      // Check if there's a label marked as default
      final hasDefaultLabel = widget.project.labels.any((label) => label.isDefault);
      
      // Get user preference for setting first label as default
      final setFirstLabelAsDefault = UserSession.instance.getUser().labelsSetFirstAsDefault;
      
      if (hasDefaultLabel) {
        // If there's a default label, use it regardless of user preference
        final defaultLabel = widget.project.labels.firstWhere((label) => label.isDefault);
        selectedLabel = defaultLabel;
      } else if (setFirstLabelAsDefault) {
        // If user has enabled "set first label as default" and no default label exists,
        // use the first label as default
        selectedLabel = widget.project.labels.first;
      }
      // If neither condition is met, keep the initial selectedLabel (Unknown)
    }
  }

  /// Initialize the SAM service by copying models from assets to temp and creating ORT sessions.
  Future<void> _initSam() async {
    try {
      final encPath = await ensureAssetFile('assets/models_sam/mobile_sam.encoder.onnx');
      final decPath = await ensureAssetFile('assets/models_sam/mobile_sam.decoder.onnx');
      final svc = SamService(encoderPath: encPath, decoderPath: decPath, provider: _provider);
      await svc.load();
      setState(() => _sam = svc);
    } catch (e, st) {
      _logger.severe('Failed to initialize SAM', e, st);
      if (mounted) {
        await AlertErrorDialog.show(
          context,
          'SAM Initialization Failed',
          'Could not initialize the SAM models.\n${e.toString()}',
        );
      }
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
    
    if (Platform.isWindows || Platform.isMacOS) {
      _tfliteService.close();
    }

    super.dispose();
  }
  
// Находим bbox в маске (mask = 256x256, 0/1, но может быть 0/255)
Rect _bboxFromMask(Uint8List mask, int origW, int origH) {
  const int M = 256;
  int minX = M, minY = M, maxX = -1, maxY = -1;
  for (int y = 0; y < M; y++) {
    final rowOff = y * M;
    for (int x = 0; x < M; x++) {
      final v = mask[rowOff + x];
      if (v > 127) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }
  if (maxX < 0 || maxY < 0) return Rect.zero;

  // Маппим из 256x256 в оригинальные координаты
  final sx = origW / 256.0;
  final sy = origH / 256.0;
  return Rect.fromLTRB(minX * sx, minY * sy, (maxX + 1) * sx, (maxY + 1) * sy);
}

// Грубый полигонизатор: собираем граничные точки и строим выпуклую оболочку (convex hull).
List<Offset> _polygonFromMaskConvex(Uint8List mask, int origW, int origH) {
  const int M = 256;
  final points = <Offset>[];

  // берём границу с шагом (для скорости)
  const step = 2;
  for (int y = step; y < M - step; y += step) {
    for (int x = step; x < M - step; x += step) {
      final v = mask[y * M + x] > 127;
      if (!v) continue;
      // Элементарный признак границы — есть сосед с нулём
      bool border = false;
      for (int dy = -1; dy <= 1 && !border; dy++) {
        for (int dx = -1; dx <= 1 && !border; dx++) {
          if (dx == 0 && dy == 0) continue;
          final nv = mask[(y + dy) * M + (x + dx)] > 127;
          if (!nv) border = true;
        }
      }
      if (border) {
        points.add(Offset(x * (origW / 256.0), y * (origH / 256.0)));
      }
    }
  }

  if (points.isEmpty) return const [];

  // Andrew's monotone chain
  points.sort((a, b) => (a.dx == b.dx) ? a.dy.compareTo(b.dy) : a.dx.compareTo(b.dx));
  double cross(Offset o, Offset a, Offset b) =>
    (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);

  final lower = <Offset>[];
  for (final p in points) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (int i = points.length - 1; i >= 0; i--) {
    final p = points[i];
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  lower.removeLast();
  upper.removeLast();
  final hull = <Offset>[...lower, ...upper];

  // Упростим до разумного числа вершин (чтобы не перегружать UI/БД)
  const maxVerts = 64;
  if (hull.length <= maxVerts) return hull;
  final stepPick = hull.length / maxVerts;
  final simplified = <Offset>[];
  for (double i = 0; i < hull.length; i += stepPick) {
    simplified.add(hull[i.toInt()]);
  }
  return simplified;
}

Future<void> _handleSamTap(Offset imagePoint) async {
  if (_samBusy) return;
  final currentMedia = _mediaCache[_currentIndex];
  final uiImg = _imageCache[_currentIndex];
  if (currentMedia == null || uiImg == null) return;

  final mediaId = currentMedia.mediaItem.id!;
  final origW = uiImg.width;
  final origH = uiImg.height;

  setState(() => _samBusy = true);
  try {
    // 1) Возьмём/посчитаем embedding (кэш по mediaId)
    Float32List embedding;
    if (_embeddings.containsKey(mediaId)) {
      embedding = _embeddings[mediaId]!;
    } else {
      final img = await _currentImageData(); // твоя функция: width/height/rgb
      // Препроцесс в CHW float32 для encoder (1024x1024, нормализация)
      final chw = preprocessToSamInput(img).tensor;
      embedding = SamOnnx.instance.runEncoder(chw);
      _embeddings[mediaId] = embedding;
    }

    // 2) Подготовим входы для decoder
    // points: [x,y] в координатах исходного изображения
    final points = Float32List.fromList([imagePoint.dx, imagePoint.dy]);
    final labels = Int32List.fromList([1]); // foreground point

    // 3) Запустим decoder -> получим маску 256x256 и IoU
    final (mask, iou) = SamOnnx.instance.runDecoder(
      embedding: embedding,
      points: points,
      labels: labels,
      origH: origH,
      origW: origW,
    );

    if (mask.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SAM: empty mask')),
      );
      return;
    }

    // 4) Конвертируем в аннотацию по типу проекта
    final isDetect = widget.project.type.toLowerCase().contains('detect');
    final isSegment = widget.project.type.toLowerCase().contains('segment');

    Annotation newAnn;

    if (isDetect) {
      final rect = _bboxFromMask(mask, origW, origH);
      if (rect == Rect.zero) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SAM: no foreground found')),
        );
        return;
      }
      newAnn = Annotation(
        id: null,
        mediaItemId: mediaId,
        labelId: selectedLabel.id!,
        annotationType: 'bbox',
        data: {
          'x': rect.left,
          'y': rect.top,
          'width': rect.width,
          'height': rect.height,
        },
        confidence: iou,
        annotatorId: 1,
        status: 'pending',
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
      ..name = selectedLabel.name
      ..color = selectedLabel.toColor();
    } else if (isSegment) {
      final poly = _polygonFromMaskConvex(mask, origW, origH);
      if (poly.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SAM: mask too small for polygon')),
        );
        return;
      }
      newAnn = Annotation(
        id: null,
        mediaItemId: mediaId,
        labelId: selectedLabel.id!,
        annotationType: 'polygon',
        data: {
          'points': poly.map((p) => [p.dx, p.dy]).toList(),
        },
        confidence: iou,
        annotatorId: 1,
        status: 'pending',
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
      ..name = selectedLabel.name
      ..color = selectedLabel.toColor();
    } else {
      // fallback: как bbox
      final rect = _bboxFromMask(mask, origW, origH);
      newAnn = Annotation(
        id: null,
        mediaItemId: mediaId,
        labelId: selectedLabel.id!,
        annotationType: 'bbox',
        data: {
          'x': rect.left,
          'y': rect.top,
          'width': rect.width,
          'height': rect.height,
        },
        confidence: iou,
        annotatorId: 1,
        status: 'pending',
        version: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )
      ..name = selectedLabel.name
      ..color = selectedLabel.toColor();
    }

    // 5) Сохраняем в БД и обновляем UI
    final insertedId = await AnnotationDatabase.instance.insertAnnotation(newAnn);
    final saved = newAnn.copyWithId(insertedId);

    final existing = List<Annotation>.from(currentMedia.annotations ?? []);
    existing.add(saved);
    setState(() {
      _mediaCache[_currentIndex] = currentMedia.copyWith(annotations: existing);
      _selectedAnnotation = saved;
      userAction = UserAction.navigation; // вернёмся в навигацию, можно убрать если не нужно
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('SAM ${isSegment ? 'polygon' : 'bbox'} added (IoU ${iou.toStringAsFixed(2)})')),
    );
  } catch (e, st) {
    _logger.severe('SAM tap failed', e, st);
    if (mounted) {
      AlertErrorDialog.show(context, 'SAM failed', e.toString());
    }
  } finally {
    if (mounted) setState(() => _samBusy = false);
  }
}


  /// Process the current image with ML Kit and create annotations from the results
  Future<void> _processImageWithMlKit() async {
    if (_isProcessingMlKit) return;
    
    final currentMedia = _mediaCache[_currentIndex];
    final currentImage = _imageCache[_currentIndex];
    
    if (currentMedia == null || currentImage == null) {
      await AlertErrorDialog.show(
        context,
        'ML Kit Processing Failed',
        'No image available to process.',
      );
      return;
    }
    
    setState(() => _isProcessingMlKit = true);
    
    try {
      _logger.info('Starting ML Kit image labeling for media ID: ${currentMedia.mediaItem.id}');
      
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
        final existingLabelNames = widget.project.labels?.map((l) => l.name.toLowerCase()).toSet() ?? {};
        
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
            _logger.warning('Failed to add label ${label.label}: ${e.toString()}');
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
        );
        
        if (updatedAnnotations.isEmpty) {
          _logger.warning('Still no matching project labels after adding new labels');
          return;
        }
        
        // Continue with the updated annotations
        annotations = updatedAnnotations;
      }
      
      _logger.info('Created ${annotations.length} annotations from ML Kit labels');
      
      // Save annotations to database
      final annotationDb = AnnotationDatabase.instance;
      final savedAnnotations = <Annotation>[];
      
      for (final annotation in annotations) {
        final insertedId = await annotationDb.insertAnnotation(annotation);
        
        final savedAnnotation = Annotation(
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
          final currentMedia = _mediaCache[_currentIndex];
          final existingAnnotations = List<Annotation>.from(currentMedia?.annotations ?? []);
          final newAnnotations = [...existingAnnotations, ...savedAnnotations];
          
          if (currentMedia != null) {
            _mediaCache[_currentIndex] = currentMedia.copyWith(annotations: newAnnotations);
          }
          
          // Switch back to navigation mode
          userAction = UserAction.navigation;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${savedAnnotations.length} labels from ML Kit'),
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
  
  /// Process the current image with TFLite and create bounding box annotations from the results
  Future<void> _processImageWithTFLite() async {
    if (_isProcessingTFLite) return;
    
    final currentMedia = _mediaCache[_currentIndex];
    final currentImage = _imageCache[_currentIndex];
    
    if (currentMedia == null || currentImage == null) {
      await AlertErrorDialog.show(
        context,
        'TFLite Processing Failed',
        'No image available to process.',
      );
      return;
    }
    
    // Check if the project type is compatible with object detection
    if (!widget.project.type.toLowerCase().contains('detect')) {
      await AlertErrorDialog.show(
        context,
        'TFLite Detection Not Compatible',
        'TFLite object detection is only compatible with detection project types.',
        tips: 'This feature is designed for bounding box annotation projects.',
      );
      return;
    }
    
    setState(() => _isProcessingTFLite = true);
    
    try {
      _logger.info('Starting TFLite object detection for media ID: ${currentMedia.mediaItem.id}');
      
      // Process the image with TFLite
      final detections = await _tfliteService.processImage(currentImage);
      
      if (detections.isEmpty) {
        _logger.info('No objects detected by TFLite');
        if (mounted) {
          await AlertErrorDialog.show(
            context,
            'No Objects Detected',
            'TFLite did not detect any objects in this image.',
            tips: 'Try a different image or adjust the confidence threshold.',
          );
        }
        return;
      }
      
      _logger.info('TFLite detected ${detections.length} objects');
      
      // Convert TFLite detections to annotations
      var annotations = _tfliteService.convertDetectionsToAnnotations(
        detections: detections,
        mediaItemId: currentMedia.mediaItem.id!,
        projectLabels: widget.project.labels ?? [],
        annotatorId: 1, // Default annotator ID
      );
      
      if (annotations.isEmpty) {
        _logger.info('No matching project labels found for TFLite detections');
        
        // Get all detected objects from TFLite
        final detectedObjects = _tfliteService.getDetectedObjects(detections);
        
        if (detectedObjects.isEmpty) {
          if (mounted) {
            await AlertErrorDialog.show(
              context,
              'No Objects Detected',
              'TFLite did not detect any objects in this image.',
              tips: 'Try a different image or adjust the confidence threshold.',
            );
          }
          return;
        }
        
        // Automatically add new labels to the project
        final addedLabels = <Label>[];
        final existingLabelNames = widget.project.labels?.map((l) => l.name.toLowerCase()).toSet() ?? {};
        
        for (final detection in detectedObjects) {
          // Skip if label already exists in the project (case-insensitive comparison)
          if (existingLabelNames.contains(detection.label.toLowerCase())) {
            continue;
          }
          
          try {
            // Add the label to the project
            final newLabel = await _addLabelToProjectInternal(detection.label);
            if (newLabel != null) {
              addedLabels.add(newLabel);
              existingLabelNames.add(detection.label.toLowerCase());
            }
          } catch (e) {
            _logger.warning('Failed to add label ${detection.label}: ${e.toString()}');
          }
        }
        
        if (addedLabels.isEmpty) {
          _logger.info('No new labels were added to the project');
          return;
        }
        
        _logger.info('Added ${addedLabels.length} new labels to the project');
        
        // Process the image again with the updated project labels
        annotations = _tfliteService.convertDetectionsToAnnotations(
          detections: detections,
          mediaItemId: currentMedia.mediaItem.id!,
          projectLabels: widget.project.labels ?? [],
          annotatorId: 1, // Default annotator ID
        );
        
        if (annotations.isEmpty) {
          _logger.warning('Still no matching project labels after adding new labels');
          return;
        }
      }
      
      _logger.info('Created ${annotations.length} annotations from TFLite detections');
      
      // Save annotations to database
      final annotationDb = AnnotationDatabase.instance;
      final savedAnnotations = <Annotation>[];
      
      for (final annotation in annotations) {
        final insertedId = await annotationDb.insertAnnotation(annotation);
        
        final savedAnnotation = Annotation(
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
          final existingAnnotations = List<Annotation>.from(currentMedia.annotations ?? []);
          final newAnnotations = [...existingAnnotations, ...savedAnnotations];
          
          _mediaCache[_currentIndex] = currentMedia.copyWith(annotations: newAnnotations);
          
          // Switch back to navigation mode
          userAction = UserAction.navigation;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${savedAnnotations.length} bounding boxes from TFLite'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _logger.severe('Error processing image with TFLite', e);
      if (mounted) {
        await AlertErrorDialog.show(
          context,
          'TFLite Processing Failed',
          'An error occurred while processing the image: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingTFLite = false);
      }
    }
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
      final fileName = filePath.substring(filePath.lastIndexOf('\\') + 1);
      _invalidMediaCache[index] = 'Video files are not supported for annotation: $fileName';
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
      final isDelete = event.logicalKey == LogicalKeyboardKey.delete || event.logicalKey == LogicalKeyboardKey.backspace;
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
        final annotations = List<Annotation>.from(currentMedia.annotations ?? []);
        final existingIndex = annotations.indexWhere((a) => a.id == updatedAnnotation.id);
      
        if (existingIndex != -1) {
          annotations[existingIndex] = updatedAnnotation;
        } else {
          annotations.add(updatedAnnotation);
        }

        _mediaCache[_currentIndex] = currentMedia.copyWith(annotations: annotations);
      }
    });
  }

  void _handleDefaultLabelSelected(Label? defaultLabel) async {
    final newDefaultLabel = defaultLabel ?? Label(
      id: -1,
      projectId: -1,
      name: 'Unknown',
      color: '#808080',
      labelOrder: -1,
    );

    if (newDefaultLabel.id != -1) {
      // persist default label in DB
      await LabelsDatabase.instance.setLabelAsDefault(newDefaultLabel.id, widget.project.id!);
    }

    // update in-memory project labels
    final updatedLabels = widget.project.labels?.map((label) {
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
      final currentMedia = _mediaCache[_currentIndex];
      if (currentMedia == null) return;

      // Multi-label: allow multiple classification annotations
      if (type.contains('multi-label')) {
        final exists = currentMedia.annotations?.any(
          (a) => a.annotationType == 'classification' && a.labelId == label.id
        ) ?? false;

        if (exists) return;

        final newAnnotation = Annotation(
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
        )
        ..name = label.name
        ..color = label.toColor();

        final insertedId = await AnnotationDatabase.instance.insertAnnotation(newAnnotation);

        final savedAnnotation = Annotation(
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

        final newAnnotations = List<Annotation>.from(currentMedia.annotations ?? []);
        newAnnotations.add(savedAnnotation);

        setState(() {
          _mediaCache[_currentIndex] = currentMedia.copyWith(annotations: newAnnotations);
        });

      } else {
        // Binary or multi-class: only one label allowed
        // Remove any existing classification annotation for this media
        // Remove any existing classification annotation for this media in DB
        final db = AnnotationDatabase.instance;
        final mediaId = currentMedia.mediaItem.id!;

        // Delete all classification annotations for this media item
        await db.deleteAnnotationsByMedia(mediaId);

        final newAnnotation = Annotation(
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
        )
        ..name = label.name
        ..color = label.toColor();

        final insertedId = await db.insertAnnotation(newAnnotation);

        final savedAnnotation = Annotation(
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

        setState(() {
          _mediaCache[_currentIndex] = currentMedia.copyWith(annotations: [savedAnnotation]);
        });
      }
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
    
    if (action == UserAction.tflite_detection) {
      // Check if TFLite is supported on this platform
      if (!_tfliteService.isSupported) {
        // Show an error dialog if TFLite is not supported
        AlertErrorDialog.show(
          context,
          'TFLite Not Supported',
          'TFLite object detection is not supported on this platform.',
          tips: 'TFLite is not supported on web platforms.',
        );
        return;
      }
      
      // Set userAction to TFLite detection to show it as selected in the UI
      setState(() {
        userAction = action;
      });
      
      // Process the current image with TFLite
      _processImageWithTFLite();
      return;
    }
    
    setState(() {
      userAction = action;
      cursorIcon = action == UserAction.navigation
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
    // Check if we should show the confirmation dialog
    bool shouldShowDialog = UserSession.instance.askConfirmationOnAnnotationRemoval;
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
          await UserSession.instance.setAskConfirmationOnAnnotationRemoval(false);
        }
      }
    } else {
      // Skip confirmation and delete directly
      shouldDelete = true;
    }
  
    if (shouldDelete) {
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

  /// Show a dialog with detected labels and option to add them to the project
  Future<void> _showDetectedLabelsDialog(List<ml_kit.ImageLabel> detectedLabels) async {
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
                      final confidence = (label.confidence * 100).toStringAsFixed(1);
                      
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
      final color = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
      
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
      final color = '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
      
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

  /// Helper: return RGB bytes for the currently shown image.
  /// SAM expects RGB, row-major, no alpha.
  Future<ImageData> _currentImageData() async {
    final ui.Image? uiImg = _imageCache[_currentIndex];
    if (uiImg == null) {
      throw StateError('No image loaded for index $_currentIndex');
    }
    final bd = await uiImg.toByteData(format: ui.ImageByteFormat.rawRgba);
    final rgba = bd!.buffer.asUint8List();
    final rgb = Uint8List(uiImg.width * uiImg.height * 3);
    int di = 0;
    for (int i = 0; i < rgba.length; i += 4) {
      rgb[di++] = rgba[i];       // R
      rgb[di++] = rgba[i + 1];   // G
      rgb[di++] = rgba[i + 2];   // B
    }
    return ImageData(uiImg.width, uiImg.height, rgb);
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
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha((0.3 * 255).toInt()),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  final newPage = _currentIndex + 1;
                                  _pageController.jumpToPage(newPage < widget.totalMediaCount ? newPage : 0);
                                },
                                borderRadius: BorderRadius.circular(30),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                  child: Text(
                                    'Next Media Item',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontFamily: 'CascadiaCode',
                                      fontWeight: FontWeight.bold
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
                      return const Center(child: CircularProgressIndicator());
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
                          isProcessingTFLite: _isProcessingTFLite,
                          onOpacityChanged: (v) => setState(() => currentOpacity = v),
                          onStrokeWidthChanged: (v) => setState(() => currentStrokeWidth = v),
                          onCornerSizeChanged: (v) => setState(() => currentCornerSize = v),                        
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
                                    mediaItemId: media.mediaItem.id!,
                                    labels: widget.project.labels ?? [],
                                    annotations: media.annotations,
                                    resetZoomCount: _resetZoomCount,
                                    showAnnotationNames: showAnnotationNames,
                                    opacity: currentOpacity,
                                    strokeWidth: currentStrokeWidth,
                                    cornerSize: currentCornerSize,
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

                                    onSamTap: _handleSamTap,
                                  ),
                                ),
                              ),
                              AnnotatorBottomToolbar(
                                currentZoom: _currentZoom,
                                currentMedia: media.mediaItem,
                                showUnknownWarning: _hasUnknownAnnotations,
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
      ),
    );
  }
}
