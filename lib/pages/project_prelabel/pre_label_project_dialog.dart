import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../../data/dataset_database.dart';
import '../../data/labels_database.dart';
import '../../models/dataset.dart';
import '../../models/label.dart';
import '../../models/media_item.dart';
import '../../models/project.dart';
import '../../services/ml_kit_image_labeling_service.dart';
import '../../services/tflite_classification_service.dart';
import '../../utils/color_utils.dart';
import '../../widgets/dialogs/edit_labels_list_dialog.dart';

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

  int _totalImages = 0;
  int _processed = 0;

  // Suggested labels as plain strings
  final Set<String> _suggested = <String>{};

  // Reviewed labels (as objects) after scan completes
  List<Label> _reviewLabels = [];

  // Backend services (nullable, set during scanning)
  MLKitImageLabelingService? _mlService;
  TFLiteClassificationService? _tflService;

  // For EditLabelsListDialog
  final ScrollController _scrollController = ScrollController();

  // Inline status/error message to display inside the dialog instead of SnackBars
  String? _inlineMessage;
  Color _inlineMessageColor = Colors.white70;

  @override
  void initState() {
    super.initState();
    // kick off scanning on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScan());
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
      for (final ds in datasets) {
        final media = await DatasetDatabase.instance.fetchMediaForDataset(ds.id);
        _totalImages += media.where((m) => m.isImage).length;
      }
      if (!mounted) return;
      setState(() {});

      if (_totalImages == 0) {
        setState(() {
          _isScanning = false;
          _inlineMessage = 'No images found in project datasets. Please upload media first.';
          _inlineMessageColor = Colors.orangeAccent;
        });
        return;
      }
    } catch (e, st) {
      _log.severe('Failed to scan datasets', e, st);
      if (mounted) {
        setState(() {
          _isScanning = false;
          _inlineMessage = 'Failed to read datasets.';
          _inlineMessageColor = Colors.redAccent;
        });
      }
      return;
    }

    // Initialize labeling backend: ML Kit (mobile) or TFLite (cross-platform)
    try {
      if (widget.useTFLite) {
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
              if (widget.useTFLite) {
                final result = await _tflService!.classifyImage(file);
                if (result != null) {
                  final name = result.label.trim();
                  if (name.isNotEmpty) {
                    _suggested.add(name);
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
            if (mounted) {
              setState(() {
                _processed += 1;
              });
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
        if (widget.useTFLite) {
          await _tflService?.dispose();
          _tflService = null;
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
      await LabelsDatabase.instance.updateProjectLabels(widget.project.id!, _reviewLabels);
      if (!mounted) return;
      Navigator.of(context).pop('refresh');
    } catch (e, st) {
      _log.severe('Failed to save labels', e, st);
      if (!mounted) return;
      setState(() {
        _inlineMessage = 'Failed to save labels';
        _inlineMessageColor = Colors.redAccent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalImages == 0 ? 0.0 : _processed / (_totalImages.toDouble());

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.grey[800],
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pre-label Project',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'CascadiaCode',
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (_isScanning && !_cancelRequested) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cancel pre-labeling?'),
                            content: const Text('Scanning is in progress. Do you want to stop and close the dialog?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Continue'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Stop and Close'),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return;
                        setState(() => _cancelRequested = true);
                      }
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close, color: Colors.white70),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                widget.useTFLite
                  ? 'Automatically scan project images using a TensorFlow Lite model and propose label names. You can review and edit before saving.'
                  : 'Automatically scan project images using Google ML Kit and propose label names. You can review and edit before saving.',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),

              if (_isScanning) ...[
                // Centered progress section
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            backgroundColor: Colors.grey[700],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _totalImages > 0
                                ? 'Progress: ${(progress * 100).toStringAsFixed(0)}%'
                                : 'Scanning images...'
                            ,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _totalImages > 0 ? progress : null,
                            backgroundColor: Colors.grey[700],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            minHeight: 6,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Processed $_processed of $_totalImages images',
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_cancelRequested) return;
                        final confirm = await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cancel pre-labeling?'),
                            content: const Text('Do you want to stop scanning and review collected labels, or continue?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Continue'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text('Stop'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          setState(() {
                            _cancelRequested = true;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.white70, width: 1),
                        ),
                      ),
                      child: const Text(
                        'Cancel Pre-labeling',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Note: Cancelling will stop scanning. You can review labels collected so far.',
                        style: TextStyle(color: Colors.orangeAccent),
                      ),
                    )
                  ],
                ),
              ] else ...[
                // After scanning completes or is cancelled, show the review UI
                Expanded(
                  child: (_inlineMessage != null)
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
                                    ? 'No images found in project datasets. Please upload media first.'
                                    : 'No labels were suggested. You can close this dialog.',
                                style: TextStyle(color: Colors.white70),
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
                            )),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 12),
                    if (_reviewLabels.isNotEmpty)
                      ElevatedButton(
                        onPressed: _saveLabels,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: const BorderSide(color: Colors.redAccent, width: 2),
                          ),
                        ),
                        child: const Text(
                          'Save Labels',
                          style: TextStyle(color: Colors.white),
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
