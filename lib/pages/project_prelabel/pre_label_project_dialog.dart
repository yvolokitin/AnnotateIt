import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../data/dataset_database.dart';
import '../../data/labels_database.dart';
import '../../data/annotation_database.dart';
import '../../models/dataset.dart';
import '../../models/label.dart';
import '../../models/annotation.dart';
import '../../models/project.dart';
import '../../services/ml_kit_image_labeling_service.dart';
import '../../services/tflite_classification_service.dart';
import '../../services/tflite_detection_service.dart';
import '../../utils/color_utils.dart';
import '../../widgets/dialogs/edit_labels_list_dialog.dart';
import '../../utils/theme.dart';
import '../../widgets/dialogs/prelabel_cancel_confirmation_dialog.dart';
import '../models_page.dart';
import '../../widgets/model_cards/model_card.dart';
import '../../gen_l10n/app_localizations.dart';

class PreLabelProjectDialog extends StatefulWidget {
  final Project project;
  final bool useTFLite;

  const PreLabelProjectDialog({super.key, required this.project, this.useTFLite = false});

  @override
  State<PreLabelProjectDialog> createState() => _PreLabelProjectDialogState();
}

class _PreLabelProjectDialogState extends State<PreLabelProjectDialog> {
  final _log = Logger('PreLabelProjectDialog');

  bool _isScanning = false;
  bool _cancelRequested = false;

  // Selected backend: true = TFLite, false = ML Kit
  bool _useTFLite = false;

  int _totalImages = 0;
  int _processed = 0;

  // Suggested labels as plain strings
  final Set<String> _suggested = <String>{};

  // Reviewed labels (as objects) after scan completes
  List<Label> _reviewLabels = [];

  // Backend services (nullable, set during scanning)
  MLKitImageLabelingService? _mlService;
  TFLiteClassificationService? _tflService;
  TFLiteDetectionService? _tflDetService;

  // For EditLabelsListDialog
  final ScrollController _scrollController = ScrollController();
  
  // Throttle UI progress updates to avoid UI hang on large scans
  DateTime _lastUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  // Inline status/error message to display inside the dialog instead of SnackBars
  String? _inlineMessage;
  Color _inlineMessageColor = Colors.white70;

  // Status flags for UI (avoid relying on localized strings)
  bool _isSaving = false;
  bool _isAnnotating = false;

  // UI step: 0 = intro, 1 = preflight checks, 2 = scanning/review
  int _uiStep = 1;

  // Summary counters after pre-annotation completes
  int _summaryLabelsAdded = 0;
  int _summaryImagesAnnotated = 0;
  int _summaryAnnotationsAdded = 0;

  bool _preflightLoading = false;
  bool _preflightChecked = false;
  bool _hasImages = false;
  bool? _modelAvailable; // null = not applicable or not checked yet

  // Thumbnails to orbit during scanning
  List<ImageProvider> _orbitImages = [];

  bool get _isDetection => widget.project.type.toLowerCase().contains('detection');

  @override
  void initState() {
    super.initState();
    // Determine default backend based on platform
    // On iOS/Android, allow user to choose (start with provided initial value)
    // On other platforms, default to TFLite
    _useTFLite = (Platform.isAndroid || Platform.isIOS) ? widget.useTFLite : true;
    // Start at Step 1 (preflight checks)
    // Trigger preflight checks as soon as dialog opens
    scheduleMicrotask(() {
      if (mounted) {
        _runPreflightChecks();
      }
    });
  }

  Future<void> _runPreflightChecks() async {
    setState(() {
      _preflightLoading = true;
      _preflightChecked = false;
      _hasImages = false;
      _modelAvailable = _useTFLite ? null : true; // MLKit path doesn't need model
      _inlineMessage = null;
      _totalImages = 0;
    });

    try {
      final datasets = await DatasetDatabase.instance.fetchDatasetsForProject(widget.project.id!);
      int count = 0;
      for (final ds in datasets) {
        final media = await DatasetDatabase.instance.fetchMediaForDataset(ds.id);
        count += media.where((m) => m.isImage).length;
      }
      if (!mounted) return;
      setState(() {
        _totalImages = count;
        _hasImages = count > 0;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _inlineMessage = l10n.preLabelErrorReadDatasetsTryAgain;
        _inlineMessageColor = Colors.redAccent;
      });
    }

    if (_useTFLite) {
      try {
        if (_isDetection) {
          final det = TFLiteDetectionService();
          final ok = await det.isModelAvailableInUserFolder();
          if (mounted) setState(() { _modelAvailable = ok; });
        } else {
          final cls = TFLiteClassificationService();
          final ok = await cls.isModelAvailableInUserFolder();
          if (mounted) setState(() { _modelAvailable = ok; });
        }
      } catch (e) {
        if (mounted) setState(() {
          _modelAvailable = false;
          _inlineMessage = AppLocalizations.of(context)!.preLabelErrorCheckModelAvailability;
          _inlineMessageColor = Colors.orangeAccent;
        });
      }
    }

    if (mounted) {
      setState(() {
        _preflightLoading = false;
        _preflightChecked = true;
      });
    }
  }

  Future<void> _openModelsPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: SafeArea(child: const ModelPage()),
        ),
      ),
    );
    if (!mounted) return;
    await _runPreflightChecks();
  }

  // Build an inline model card for downloading the required TFLite model
  Widget _buildInlineModelCard() {
    if (_isDetection) {
      // EfficientDet-Lite4 (Detection)
      return ModelCard(
        id: 'efficientdet-tflite-lite4-detection-metadata-v2',
        title: 'EfficientDet-Lite4',
        description: "EfficientDet-Lite4 is an object detection model optimized for mobile and edge devices. It uses an EfficientNet-Lite4 backbone with a BiFPN feature network to achieve strong accuracy while keeping the model size small and inference fast.     Task: Object detection (bounding boxes + labels) Dataset: Trained on COCO (90 common object classes). Format: TensorFlow Lite with metadata (easy integration and standardized input/output). Input: 320×320 RGB image (normalized to 0–1). Output: Bounding boxes, class IDs (0–89), and confidence scores",
        imageAsset: 'assets/images/efficientnet-tflite-lite4-detection.jpg',
        urlEncoder: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/efficientdet-tflite-lite4-detection-metadata-v2.tflite',
        urlDecoder: '',
        urlConfig: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/coco_labels.txt',
        shaEncoder: '0d9b3ffe97d6d9e78ac1632f4b63630f35e39c87d20349b648268d671c7730c5',
        shaDecoder: '',
        shaConfig: '4d4aaea7bee6be2f675d9b53a9195ca36dfe6429f7479f29155da522a6c85930',
        modelSize: '20Mb',
      );
    } else {
      // EfficientNet-Lite4 FP32v2 (Classification)
      return ModelCard(
        id: 'classification_efficientnet-tflite-lite4-fp32-v2',
        title: 'EfficientNet-Lite4',
        description: "EfficientNet-Lite4 FP32v2 is a convolutional neural network (CNN) from the EfficientNet-Lite family, designed for image classification on mobile and edge devices. EfficientNet-Lite models provide a strong balance of accuracy and efficiency, using fewer parameters and computations than many traditional CNNs. The FP32v2 variant is distributed in TensorFlow Lite format, making it directly usable in mobile and embedded applications for real-time image classification. While FP32 ensures maximum accuracy, smaller quantized versions (e.g., INT8) offer lower latency and power consumption on constrained hardware.",
        imageAsset: 'assets/images/efficientnet-tflite-lite4-classification.jpg',
        urlEncoder: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/efficientnet-tflite-lite4-fp32-v2.tflite',
        urlDecoder: '',
        urlConfig: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/classification_efficientnet-tflite-lite0-int8-v2_labels.txt',
        shaEncoder: 'f0d69132ee9759f2d98e817f7a96a28e40384d3c1894f222c4e6653d9e285586',
        shaDecoder: '',
        shaConfig: 'ff830819b4418bc52ce12b81398e2d7f6fbf09f98584cd83f3f92629a3074eb7',
        modelSize: '50Mb',
      );
    }
  }

  // Small helper to render a summary stat line
  Widget _buildSummaryStat(String title, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.purple.withOpacity(0.6), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _cancelRequested = false;
      _totalImages = 0;
      _processed = 0;
      _suggested.clear();
      _inlineMessage = null;
      _inlineMessageColor = Colors.white70;
    });

    // First, check that project has at least one image across datasets
    List<Dataset> datasets = const [];
    try {
      datasets = await DatasetDatabase.instance.fetchDatasetsForProject(widget.project.id!);
      final List<ImageProvider> orbit = [];
      for (final ds in datasets) {
        final media = await DatasetDatabase.instance.fetchMediaForDataset(ds.id);
        _totalImages += media.where((m) => m.isImage).length;
        // Collect up to 8 thumbnails for orbit animation
        if (orbit.length < 8) {
          for (final item in media) {
            if (!item.isImage) continue;
            try {
              final f = File(item.filePath);
              if (f.existsSync()) {
                orbit.add(FileImage(f));
                if (orbit.length >= 8) break;
              }
            } catch (_) {}
          }
        }
      }
      if (!mounted) return;
      setState(() { _orbitImages = orbit; });

      if (_totalImages == 0) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _isScanning = false;
          _inlineMessage = l10n.preLabelNoImagesUploadFirst;
          _inlineMessageColor = Colors.orangeAccent;
        });
        return;
      }
    } catch (e, st) {
      _log.severe('Failed to scan datasets', e, st);
      if (mounted) {
        setState(() {
          _isScanning = false;
          _inlineMessage = AppLocalizations.of(context)!.preLabelErrorReadDatasets;
          _inlineMessageColor = Colors.redAccent;
        });
      }
      return;
    }

    // Initialize labeling backend: ML Kit (mobile) or TFLite (cross-platform)
    try {
      final isDetection = widget.project.type.toLowerCase().contains('detection');
      if (_useTFLite) {
        if (isDetection) {
          _tflDetService = TFLiteDetectionService();
          final available = await _tflDetService!.isModelAvailableInUserFolder();
          if (!available) {
            setState(() {
              _isScanning = false;
              _inlineMessage = 'Detection model not found in your Models folder. Please download it from the Model screen.';
              _inlineMessageColor = Colors.orangeAccent;
            });
            return;
          }
          await _tflDetService!.initializeFromUserFolder();
        } else {
          _tflService = TFLiteClassificationService();
          final available = await _tflService!.isModelAvailableInUserFolder();
          if (!available) {
            setState(() {
              _isScanning = false;
              _inlineMessage = 'Classification model not found in your Models folder. Please download it from the Model screen.';
              _inlineMessageColor = Colors.orangeAccent;
            });
            return;
          }
          await _tflService!.initializeFromUserFolder();
        }
      } else {
        _mlService = MLKitImageLabelingService();
        _mlService!.initialize(confidenceThreshold: 0.6);
      }
    } catch (e, st) {
      _log.severe('Failed to initialize labeling backend', e, st);
      if (mounted) {
        setState(() {
          _isScanning = false;
          final details = e.toString();
          _inlineMessage = 'Failed to initialize labeling backend. Check model files or permissions.' + (details.isNotEmpty ? '\n\nDetails: ' + details : '');
          _inlineMessageColor = Colors.redAccent;
        });
      }
      return;
    }

    try {
      // Process images dataset-by-dataset
      for (final ds in datasets) {
        if (_cancelRequested) break;

        final media = await DatasetDatabase.instance.fetchMediaForDataset(ds.id);
        for (final item in media) {
          if (_cancelRequested) break;
          if (!item.isImage) {
            continue;
          }
          try {
            final file = File(item.filePath);
            if (!await file.exists()) {
              _log.warning('File not found: ${item.filePath}');
            } else {
              if (_useTFLite) {
                final isDetection = widget.project.type.toLowerCase().contains('detection');
                if (isDetection) {
                  final dets = await _tflDetService!.detectImage(file);
                  for (final d in dets) {
                    final name = d.label.trim();
                    if (name.isNotEmpty) {
                      _suggested.add(name);
                    }
                  }
                } else {
                  final isMultiLabel = widget.project.type.toLowerCase().contains('multi-label');
                  if (isMultiLabel) {
                    final results = await _tflService!.classifyImageMulti(
                      file,
                      confidenceThreshold: 0.6,
                      maxResults: 10,
                    );
                    for (final r in results) {
                      final name = r.label.trim();
                      if (name.isNotEmpty) {
                        _suggested.add(name);
                      }
                    }
                  } else {
                    final result = await _tflService!.classifyImage(file);
                    if (result != null) {
                      final name = result.label.trim();
                      if (name.isNotEmpty) {
                        _suggested.add(name);
                      }
                    }
                  }
                }
              } else {
                final labels = await _mlService!.processImageFile(file, projectType: widget.project.type);
                for (final l in labels) {
                  final name = l.label.trim();
                  if (name.isNotEmpty) {
                    _suggested.add(name);
                  }
                }
              }
            }
          } catch (e, st) {
            _log.warning('Failed to process image: ${item.filePath}', e, st);
          } finally {
            _processed += 1;
            if (mounted) {
              final now = DateTime.now();
              final shouldRefresh = now.difference(_lastUiUpdate) > const Duration(milliseconds: 120)
                  || (_processed % 10 == 0)
                  || (_processed >= _totalImages);
              if (shouldRefresh) {
                setState(() {});
                _lastUiUpdate = now;
              }
            }
            // Yield to UI periodically to avoid long blocking loops
            if ((_processed % 5) == 0) {
              await Future<void>.delayed(const Duration(milliseconds: 1));
            }
          }
        }
      }

      // Build review labels list from suggestions (unique), with generated colors
      if (mounted) {
        final List<String> sorted = _suggested.toList()..sort();
        _reviewLabels = [
          for (int i = 0; i < sorted.length; i++)
            Label(
              id: -1,
              labelOrder: i,
              projectId: widget.project.id!,
              name: sorted[i],
              color: generateColorByIndex(i),
              createdAt: DateTime.now(),
            )
        ];
      }
    } catch (e, st) {
      _log.severe('Pre-label scan failed', e, st);
    } finally {
      try {
        if (_useTFLite) {
          await _tflService?.dispose();
          _tflService = null;
          await _tflDetService?.dispose();
          _tflDetService = null;
        }
      } catch (_) {}
      if (!mounted) return;
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _saveLabels() async {
    try {
      // 1) Save labels and keep annotations consistent for removed/renamed labels
      setState(() {
        _inlineMessage = 'Saving labels...';
        _inlineMessageColor = Colors.white70;
      });
      await LabelsDatabase.instance.updateProjectLabels(widget.project.id!, _reviewLabels);

      // 2) Fetch final labels with real IDs and update summary counts
      final projectLabels = await LabelsDatabase.instance.fetchLabelsByProject(widget.project.id!);
      if (mounted) {
        setState(() {
          _summaryLabelsAdded = projectLabels.length;
          _isAnnotating = true;
          _inlineMessage = 'Annotating images...';
          _inlineMessageColor = Colors.white70;
        });
      }

      // 3) Annotate all images in project with detected labels and collect stats
      await _annotateAllImages(projectLabels);

      if (!mounted) return;
      setState(() {
        _isAnnotating = false;
        _inlineMessage = null;
        _uiStep = 3; // Show summary step
      });
    } catch (e, st) {
      _log.severe('Failed to save labels / annotate', e, st);
      if (!mounted) return;
      setState(() {
        _inlineMessage = 'Failed to save labels or annotate images';
        _inlineMessageColor = Colors.redAccent;
      });
    }
  }

  Future<void> _annotateAllImages(List<Label> projectLabels) async {
    // Build quick lookup map for labels by lowercased name
    final Map<String, Label> labelByName = {
      for (final l in projectLabels) l.name.toLowerCase(): l
    };

    // Reset summary counters
    _summaryImagesAnnotated = 0;
    _summaryAnnotationsAdded = 0;

    setState(() {
      _inlineMessage = 'Annotating images...';
      _inlineMessageColor = Colors.white70;
      _processed = 0;
      _totalImages = 0;
    });

    // Prepare datasets and count images
    final datasets = await DatasetDatabase.instance.fetchDatasetsForProject(widget.project.id!);
    for (final ds in datasets) {
      final media = await DatasetDatabase.instance.fetchMediaForDataset(ds.id);
      _totalImages += media.where((m) => m.isImage).length;
    }
    if (mounted) setState(() {});

    // Initialize backend if needed
    final isDetection = widget.project.type.toLowerCase().contains('detection');
    if (_useTFLite) {
      if (isDetection) {
        _tflDetService ??= TFLiteDetectionService();
        final available = await _tflDetService!.isModelAvailableInUserFolder();
        if (!available) {
          setState(() {
            _inlineMessage = 'Detection model not found in your Models folder. Please download it from the Model screen.';
            _inlineMessageColor = Colors.orangeAccent;
          });
          return;
        }
        await _tflDetService!.initializeFromUserFolder();
      } else {
        _tflService ??= TFLiteClassificationService();
        final available = await _tflService!.isModelAvailableInUserFolder();
        if (!available) {
          setState(() {
            _inlineMessage = 'Classification model not found in your Models folder. Please download it from the Model screen.';
            _inlineMessageColor = Colors.orangeAccent;
          });
          return;
        }
        await _tflService!.initializeFromUserFolder();
      }
    } else {
      _mlService ??= MLKitImageLabelingService();
      _mlService!.initialize(confidenceThreshold: 0.6);
    }

    try {
      for (final ds in datasets) {
        final media = await DatasetDatabase.instance.fetchMediaForDataset(ds.id);
        for (final item in media) {
          if (!item.isImage) continue;
          final file = File(item.filePath);
          if (!await file.exists()) {
            _log.warning('File not found during annotation: ${item.filePath}');
            if (mounted) setState(() { _processed += 1; });
            continue;
          }

          try {
            // Fetch existing annotations to avoid duplicates (by labelId + type)
            final existing = await AnnotationDatabase.instance.fetchAnnotations(item.id!);
            final Set<String> existingKeys = existing
              .map((a) => '${a.labelId ?? -1}|${a.annotationType}')
              .toSet();

            final now = DateTime.now();
            final List<Annotation> toInsert = [];

            if (_useTFLite) {
              if (isDetection) {
                final dets = await _tflDetService!.detectImage(file);
                for (final d in dets) {
                  final label = labelByName[d.label.toLowerCase()];
                  if (label == null) continue;

                  Map<String, dynamic> data;
                  if (d.box != null && item.width != null && item.height != null) {
                    final ymin = d.box![0];
                    final xmin = d.box![1];
                    final ymax = d.box![2];
                    final xmax = d.box![3];
                    final iw = item.width!.toDouble();
                    final ih = item.height!.toDouble();
                    data = {
                      'x': (xmin * iw),
                      'y': (ymin * ih),
                      'width': ((xmax - xmin) * iw),
                      'height': ((ymax - ymin) * ih),
                    };
                  } else {
                    data = {
                      'x': 50.0,
                      'y': 50.0,
                      'width': 100.0,
                      'height': 100.0,
                    };
                  }

                  final key = '${label.id}|bbox';
                  if (existingKeys.contains(key)) continue;

                  toInsert.add(Annotation(
                    mediaItemId: item.id!,
                    labelId: label.id,
                    annotationType: 'bbox',
                    data: data,
                    confidence: d.score,
                    annotatorId: 1,
                    comment: 'Generated by TFLite',
                    status: 'auto_generated',
                    createdAt: now,
                    updatedAt: now,
                  )..name = 'AI: ${label.name}');
                }
              } else {
                final isMultiLabel = widget.project.type.toLowerCase().contains('multi-label');
                if (isMultiLabel) {
                  final results = await _tflService!.classifyImageMulti(
                    file,
                    confidenceThreshold: 0.6,
                    maxResults: 10,
                  );
                  for (final r in results) {
                    final label = labelByName[r.label.toLowerCase()];
                    if (label == null) continue;
                    final key = '${label.id}|classification';
                    if (!existingKeys.contains(key)) {
                      toInsert.add(Annotation(
                        mediaItemId: item.id!,
                        labelId: label.id,
                        annotationType: 'classification',
                        data: {'label': label.name},
                        confidence: r.score,
                        annotatorId: 1,
                        comment: 'Generated by TFLite',
                        status: 'auto_generated',
                        createdAt: now,
                        updatedAt: now,
                      )..name = 'AI: ${label.name}');
                    }
                  }
                } else {
                  final result = await _tflService!.classifyImage(file);
                  if (result != null) {
                    final label = labelByName[result.label.toLowerCase()];
                    if (label != null) {
                      final key = '${label.id}|classification';
                      if (!existingKeys.contains(key)) {
                        toInsert.add(Annotation(
                          mediaItemId: item.id!,
                          labelId: label.id,
                          annotationType: 'classification',
                          data: {'label': label.name},
                          confidence: result.score,
                          annotatorId: 1,
                          comment: 'Generated by TFLite',
                          status: 'auto_generated',
                          createdAt: now,
                          updatedAt: now,
                        )..name = 'AI: ${label.name}');
                      }
                    }
                  }
                }
              }
            } else {
              final labels = await _mlService!.processImageFile(file, projectType: widget.project.type);
              final anns = _mlService!.convertLabelsToAnnotations(
                labels: labels,
                mediaItemId: item.id!,
                projectLabels: projectLabels,
                annotatorId: 1,
                projectType: widget.project.type,
                imageWidth: item.width,
                imageHeight: item.height,
              );
              for (final a in anns) {
                final key = '${a.labelId ?? -1}|${a.annotationType}';
                if (!existingKeys.contains(key)) {
                  toInsert.add(a);
                }
              }
            }

            if (toInsert.isNotEmpty) {
              // Update summary statistics
              _summaryAnnotationsAdded += toInsert.length;
              _summaryImagesAnnotated += 1;
              await AnnotationDatabase.instance.insertAnnotationsBatch(toInsert);
            }
          } catch (e, st) {
            _log.warning('Failed to annotate image ${item.filePath}', e, st);
          } finally {
            if (mounted) {
              setState(() { _processed += 1; });
            }
          }
        }
      }
    } finally {
      // Dispose TFLite services if used
      if (_useTFLite) {
        try { await _tflService?.dispose(); } catch (_) {}
        try { await _tflDetService?.dispose(); } catch (_) {}
        _tflService = null;
        _tflDetService = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalImages == 0 ? 0.0 : _processed / (_totalImages.toDouble());
    final screenSize = MediaQuery.of(context).size;
    final bool isWide = screenSize.width > 1600;
    final bool isCompact = screenSize.width < 650;
    final double targetWidth = isWide ? screenSize.width * 0.9 : screenSize.width;
    final double targetHeight = isWide ? screenSize.height * 0.9 : screenSize.height;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.grey[800],
      shape: isWide
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).colorScheme.purple, width: 1),
            )
          : null,
      child: SizedBox(
        width: targetWidth,
        height: targetHeight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: isWide ? 34 : 26,
                        color: Theme.of(context).colorScheme.purple,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.preLabelProject,
                        style: TextStyle(
                          fontSize: isWide ? 26 : 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.purple,
                          fontFamily: 'CascadiaCode',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () async {
                      if (_isScanning && !_cancelRequested) {
                        final confirm = await PreLabelCancelConfirmationDialog.show(context);
                        if (confirm != true) return;
                        setState(() => _cancelRequested = true);
                      }
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close, color: Colors.white70),
                  )
                ],
              ),
              Divider(color: Theme.of(context).colorScheme.purple),
              const SizedBox(height: 12),
              Text(
                _useTFLite
                  ? l10n.preLabelIntroTflite
                  : l10n.preLabelIntroMlkit,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),

              if (_uiStep == 1) ...[
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(
                              l10n.preLabelStep1Title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.purple,
                                fontFamily: 'CascadiaCode',
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (Platform.isAndroid || Platform.isIOS) ...[
                              const Text(
                                'Choose the pre-labeling backend to use:',
                                style: TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 8),
                              RadioListTile<bool>(
                                value: false,
                                groupValue: _useTFLite,
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() { _useTFLite = v; });
                                  _runPreflightChecks();
                                },
                                dense: true,
                                title: const Text('ML Kit', style: TextStyle(color: Colors.white70)),
                                activeColor: Colors.lightGreenAccent,
                                tileColor: Colors.white12,
                              ),
                              RadioListTile<bool>(
                                value: true,
                                groupValue: _useTFLite,
                                onChanged: (v) {
                                  if (v == null) return;
                                  setState(() { _useTFLite = v; });
                                  _runPreflightChecks();
                                },
                                dense: true,
                                title: const Text('TFLite', style: TextStyle(color: Colors.white70)),
                                activeColor: Colors.lightGreenAccent,
                                tileColor: Colors.white12,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_preflightLoading) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white70)),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(l10n.preLabelCheckingProjectAndModels, style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ] else ...[
                              Row(
                                children: [
                                  Icon(_hasImages ? Icons.check_circle : Icons.error, color: _hasImages ? Colors.lightGreenAccent : Colors.orangeAccent),
                                  const SizedBox(width: 8),
                                  Text(l10n.preLabelImagesInProjectDatasets(_totalImages), style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_useTFLite) ...[
                                Row(
                                  children: [
                                    Icon((_modelAvailable ?? false) ? Icons.check_circle : Icons.download, color: (_modelAvailable ?? false) ? Colors.lightGreenAccent : Colors.orangeAccent),
                                    const SizedBox(width: 8),
                                    Text(
                                      (_modelAvailable ?? false) ? l10n.preLabelModelAvailableInFolder : l10n.preLabelModelMissingPleaseDownload,
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (!(_modelAvailable ?? false))
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(minHeight: 160, maxHeight: 260),
                                        child: _buildInlineModelCard(),
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton(
                                          onPressed: _runPreflightChecks,
                                          style: TextButton.styleFrom(foregroundColor: Colors.grey),
                                          child: Text(l10n.preLabelRecheck),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                              if (_hasImages && (!_useTFLite || (_modelAvailable ?? false))) ...[
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.10),
                                    border: Border.all(color: Colors.lightGreenAccent.withOpacity(0.8)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.verified, color: Colors.lightGreenAccent, size: 28),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              l10n.preLabelAllPrerequisitesMet,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                Chip(
                                                  label: Text(l10n.preLabelChipImages(_totalImages)),
                                                  backgroundColor: Colors.green,
                                                  labelStyle: const TextStyle(color: Colors.white),
                                                  visualDensity: VisualDensity.compact,
                                                ),
                                                if (_useTFLite)
                                                  Chip(
                                                    label: Text(_isDetection ? l10n.preLabelBackendTfliteDetection : l10n.preLabelBackendTfliteClassification),
                                                    backgroundColor: Colors.green,
                                                    labelStyle: const TextStyle(color: Colors.white),
                                                    visualDensity: VisualDensity.compact,
                                                  )
                                                else
                                                  Chip(
                                                    label: Text(l10n.preLabelBackendMlkit),
                                                    backgroundColor: Colors.green,
                                                    labelStyle: const TextStyle(color: Colors.white),
                                                    visualDensity: VisualDensity.compact,
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              l10n.preLabelYouCanProceed,
                                              style: const TextStyle(color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (_inlineMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(_inlineMessage!, style: TextStyle(color: _inlineMessageColor)),
                              ],
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      child: Text(l10n.buttonCancel),
                    ),
                    Row(
                      children: [
                        if (!_preflightLoading)
                          TextButton(
                            onPressed: _runPreflightChecks,
                            style: TextButton.styleFrom(foregroundColor: Colors.grey),
                            child: Text(l10n.ffmpegRecheckButton),
                          ),
                        const SizedBox(width: 8),
                        Builder(builder: (context) {
                          final canStart = _hasImages && (!_useTFLite || (_modelAvailable ?? false));
                          return ElevatedButton(
                            onPressed: (!_preflightLoading && canStart) ? () {
                              setState(() { _uiStep = 2; });
                              _startScan();
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.purple,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text(isCompact ? l10n.preLabelStartPreLabeling.split(RegExp(r'\s+')).first : l10n.preLabelStartPreLabeling, style: TextStyle(color: Colors.white)),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ] else if (_uiStep == 0) ...[
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step 0: What will happen next',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.purple,
                                fontFamily: 'CascadiaCode',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _useTFLite
                                  ? '• The project images will be scanned using your TensorFlow Lite model.'
                                  : '• The project images will be scanned using Google ML Kit on this device.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '• We will propose label names found across images. You can review and edit them.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '• When you click "Start pre-annotation", labels will be saved to the project.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.project.type.toLowerCase().contains('detection')
                                  ? '• Images will then be auto-annotated with bounding boxes for the detected labels.'
                                  : '• Images will then be auto-annotated with classification labels.',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '• Existing annotations are respected and duplicates are avoided.',
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '• You can cancel at any time. Progress may take a while on large projects.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey),
                      child: Text(l10n.buttonCancel),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() { _uiStep = 1; });
                        _startScan();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Text(l10n.buttonNext, style: const TextStyle(color: Colors.white)), 
                    ),
                  ],
                ),
              ] else if (_isScanning) ...[
                // Centered progress section
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          SizedBox(
                            width: 240,
                            height: 240,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: OrbitingThumbnails(
                                    images: _orbitImages,
                                    itemSize: 28,
                                    minRadius: 56,
                                    maxRadius: 104,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.purple),
                                      backgroundColor: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _totalImages > 0
                                ? l10n.preLabelProgressPercent((progress * 100).toStringAsFixed(0))
                                : l10n.preLabelScanningImages,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _totalImages > 0 ? progress : null,
                            backgroundColor: Colors.grey[700],
                            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.purple),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.preLabelProcessedOfTotalImages(_processed, _totalImages),
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (_uiStep == 3) ...[
                // Summary step after pre-annotation completes
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.preLabelSummaryTitle,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.purple,
                              fontFamily: 'CascadiaCode',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryStat(l10n.preLabelSummaryLabelsAdded, _summaryLabelsAdded),
                          const SizedBox(height: 8),
                          _buildSummaryStat(l10n.preLabelSummaryImagesAnnotated, _summaryImagesAnnotated),
                          const SizedBox(height: 8),
                          _buildSummaryStat(l10n.preLabelSummaryAnnotationsAdded, _summaryAnnotationsAdded),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop('refresh'),
                                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                                child: const Text('Close'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop('open_project'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.purple,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text('Open project', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // After scanning completes or is cancelled, show the review UI
                Expanded(
                  child: (_isAnnotating)
                      ? Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 240,
                                  height: 240,
                                  child: OrbitingBoundingBoxes(
                                    color: Theme.of(context).colorScheme.purple,
                                    secondaryColor: Theme.of(context).colorScheme.purple.withOpacity(0.7),
                                    boxCount: 5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_inlineMessage != null)
                                  Text(
                                    _inlineMessage!,
                                    style: TextStyle(color: _inlineMessageColor, fontSize: 16, fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: _totalImages > 0 ? (_processed / (_totalImages.toDouble())) : null,
                                  backgroundColor: Colors.grey[700],
                                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.purple),
                                  minHeight: 6,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${AppLocalizations.of(context)!.preLabelProcessedOfTotalImages(_processed, _totalImages)}',
                                  style: const TextStyle(color: Colors.white70),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : (_inlineMessage != null
                          ? Center(
                              child: Text(
                                _inlineMessage!,
                                style: TextStyle(color: _inlineMessageColor),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : (_reviewLabels.isEmpty
                              ? Center(
                                  child: Text(
                                    _totalImages == 0
                                        ? AppLocalizations.of(context)!.preLabelNoImagesUploadFirst
                                        : AppLocalizations.of(context)!.preLabelNoLabelsSuggested,
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                )
                              : EditLabelsListDialog(
                                  projectId: widget.project.id!,
                                  projectType: widget.project.type,
                                  labels: _reviewLabels,
                                  scrollController: _scrollController,
                                  onColorTap: (index) {},
                                  onLabelsChanged: (updated) {
                                    setState(() {
                                      _reviewLabels = updated;
                                    });
                                  },
                                )))
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_reviewLabels.isNotEmpty && !(_inlineMessage?.toLowerCase().startsWith('annotating images') ?? false) && !(_inlineMessage?.toLowerCase().startsWith('saving labels') ?? false))
                      ElevatedButton(
                        onPressed: _saveLabels,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.purple,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          isCompact
                              ? AppLocalizations.of(context)!.preLabelStartPreAnnotation.split(RegExp(r'\s+')).first
                              : AppLocalizations.of(context)!.preLabelStartPreAnnotation,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Animated orbiting bounding boxes used during the "Annotating images..." phase
class OrbitingBoundingBoxes extends StatefulWidget {
  final Color color;
  final Color secondaryColor;
  final int boxCount;
  final double strokeWidth;
  final double minRadius;
  final double maxRadius;

  const OrbitingBoundingBoxes({
    super.key,
    this.color = Colors.blueAccent,
    this.secondaryColor = Colors.lightBlueAccent,
    this.boxCount = 6,
    this.strokeWidth = 2.0,
    this.minRadius = 48,
    this.maxRadius = 96,
  });

  @override
  State<OrbitingBoundingBoxes> createState() => _OrbitingBoundingBoxesState();
}

class _OrbitingBoundingBoxesState extends State<OrbitingBoundingBoxes> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _OrbitingBoxPainter(
            progress: _controller.value,
            color: widget.color,
            secondaryColor: widget.secondaryColor,
            boxCount: widget.boxCount,
            strokeWidth: widget.strokeWidth,
            minRadius: widget.minRadius,
            maxRadius: widget.maxRadius,
          ),
        ),
      ),
    );
  }
}

class _OrbitingBoxPainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  final Color secondaryColor;
  final int boxCount;
  final double strokeWidth;
  final double minRadius;
  final double maxRadius;

  _OrbitingBoxPainter({
    required this.progress,
    required this.color,
    required this.secondaryColor,
    required this.boxCount,
    required this.strokeWidth,
    required this.minRadius,
    required this.maxRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Subtle central sun-like circle
    final sunPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color.withOpacity(0.35)
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, 14, sunPaint);

    // Orbits background rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = secondaryColor.withOpacity(0.20)
      ..strokeWidth = 1.0;

    for (int r = 0; r < 3; r++) {
      final radius = minRadius + (maxRadius - minRadius) * (r + 1) / 3.5;
      canvas.drawCircle(center, radius, ringPaint);
    }

    for (int i = 0; i < boxCount; i++) {
      final angleBase = 2 * math.pi * (i / boxCount);
      // Rotate all boxes around center
      final orbitAngle = angleBase + 2 * math.pi * progress;

      // Slight radial oscillation per box to feel "flying"
      final oscillation = math.sin((angleBase + 4 * math.pi * progress) * 2.0) * 4.0;
      final radius = ((i % 2 == 0) ? maxRadius : minRadius) - 6 + oscillation;

      final dx = center.dx + radius * math.cos(orbitAngle);
      final dy = center.dy + radius * math.sin(orbitAngle);
      final position = Offset(dx, dy);

      // Box size varies slightly
      final baseW = 34.0 - (i % 3) * 4.0;
      final baseH = 24.0 - (i % 2) * 3.0;

      // Draw the box, rotated tangentially to the orbit
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(orbitAngle + math.pi / 2);

      final rect = Rect.fromCenter(center: Offset.zero, width: baseW, height: baseH);
      final strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = (i % 2 == 0) ? color : secondaryColor;

      // Outer glow effect by drawing a faint stroke first
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 2
        ..color = strokePaint.color.withOpacity(0.28);

      canvas.drawRect(rect, glowPaint);
      canvas.drawRect(rect, strokePaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitingBoxPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.boxCount != boxCount ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.minRadius != minRadius ||
        oldDelegate.maxRadius != maxRadius;
  }
}


// Animated orbiting thumbnails used during the pre-labeling scan phase
class OrbitingThumbnails extends StatefulWidget {
  final List<ImageProvider> images;
  final double itemSize;
  final double minRadius;
  final double maxRadius;
  final Duration duration;
  final Color color; // used for placeholders & accents

  const OrbitingThumbnails({
    super.key,
    required this.images,
    this.itemSize = 28,
    this.minRadius = 56,
    this.maxRadius = 104,
    this.duration = const Duration(seconds: 8),
    this.color = Colors.purpleAccent,
  });

  @override
  State<OrbitingThumbnails> createState() => _OrbitingThumbnailsState();
}

class _OrbitingThumbnailsState extends State<OrbitingThumbnails> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..repeat();
  }

  @override
  void didUpdateWidget(covariant OrbitingThumbnails oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      if (!_controller.isAnimating) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
          final images = widget.images;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value; // 0..1
              final List<Widget> stackChildren = [];

              void addOrbitItems({required int count, required double radius, required double speed, required double sizeFactor, required int offsetIndex, required bool useImages}) {
                for (int i = 0; i < count; i++) {
                  final angleBase = 2 * math.pi * (i / count);
                  final angle = angleBase + 2 * math.pi * t * speed + (offsetIndex * 0.37);
                  final dx = center.dx + radius * math.cos(angle);
                  final dy = center.dy + radius * math.sin(angle);
                  final pos = Offset(dx, dy);
                  final w = widget.itemSize * sizeFactor;
                  final h = w;

                  Widget child;
                  if (useImages && images.isNotEmpty) {
                    final imgIdx = (i + offsetIndex) % images.length;
                    child = ClipOval(
                      child: Image(
                        image: images[imgIdx],
                        width: w,
                        height: h,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                      ),
                    );
                    child = Container(
                      width: w,
                      height: h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.purple.withOpacity(0.9), width: 1.2),
                        boxShadow: [
                          BoxShadow(color: theme.colorScheme.purple.withOpacity(0.25), blurRadius: 4, spreadRadius: 0.5),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: child,
                    );
                  } else {
                    // Placeholder: glowing dot
                    child = Container(
                      width: w * 0.6,
                      height: h * 0.6,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.85),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: widget.color.withOpacity(0.35), blurRadius: 6, spreadRadius: 1),
                        ],
                      ),
                    );
                  }

                  stackChildren.add(Positioned(
                    left: pos.dx - w / 2,
                    top: pos.dy - h / 2,
                    child: child,
                  ));
                }
              }

              if (images.length <= 4) {
                // Single ring
                final r = (widget.minRadius + widget.maxRadius) / 2;
                final count = images.isNotEmpty ? images.length : 6;
                addOrbitItems(count: count, radius: r, speed: 1.0, sizeFactor: 1.0, offsetIndex: 0, useImages: images.isNotEmpty);
              } else {
                // Two rings: inner and outer
                final half = (images.length / 2).ceil();
                final inner = images.isNotEmpty ? half : 6;
                final outer = images.isNotEmpty ? (images.length - half) : 6;
                addOrbitItems(count: inner, radius: widget.minRadius, speed: 1.2, sizeFactor: 0.95, offsetIndex: 0, useImages: images.isNotEmpty);
                addOrbitItems(count: outer, radius: widget.maxRadius, speed: 0.8, sizeFactor: 1.1, offsetIndex: half, useImages: images.isNotEmpty);
              }

              // Optional faint orbit rings
              stackChildren.add(Positioned.fill(
                child: CustomPaint(
                  painter: _OrbitRingPainter(
                    color: theme.colorScheme.purple.withOpacity(0.18),
                    minRadius: widget.minRadius,
                    maxRadius: widget.maxRadius,
                  ),
                ),
              ));

              return Stack(children: stackChildren);
            },
          );
        },
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  final Color color;
  final double minRadius;
  final double maxRadius;

  _OrbitRingPainter({required this.color, required this.minRadius, required this.maxRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    canvas.drawCircle(center, minRadius, paint);
    canvas.drawCircle(center, (minRadius + maxRadius) / 2, paint);
    canvas.drawCircle(center, maxRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.minRadius != minRadius || oldDelegate.maxRadius != maxRadius;
  }
}
