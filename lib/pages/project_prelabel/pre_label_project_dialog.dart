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
import '../../utils/color_utils.dart';
import '../../widgets/dialogs/edit_labels_list_dialog.dart';

class PreLabelProjectDialog extends StatefulWidget {
  final Project project;

  const PreLabelProjectDialog({super.key, required this.project});

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

  // For EditLabelsListDialog
  final ScrollController _scrollController = ScrollController();

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
    });

    // Initialize ML Kit service
    final ml = MLKitImageLabelingService();
    ml.initialize(confidenceThreshold: 0.6);

    try {
      // Fetch datasets for the project
      final List<Dataset> datasets = await DatasetDatabase.instance.fetchDatasetsForProject(widget.project.id!);

      // Count total images first
      for (final ds in datasets) {
        final media = await DatasetDatabase.instance.fetchMediaForDataset(ds.id);
        _totalImages += media.where((m) => m.isImage).length;
      }
      if (!mounted) return;
      setState(() {});

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
              final labels = await ml.processImageFile(file, projectType: widget.project.type);
              for (final l in labels) {
                final name = l.label.trim();
                if (name.isNotEmpty) {
                  _suggested.add(name);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save labels')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalImages == 0 ? 0.0 : _processed / (_totalImages.toDouble());

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.grey[900],
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close, color: Colors.white70),
                  )
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Automatically scan project images using Google ML Kit and propose label names. You can review and edit before saving.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),

              if (_isScanning) ...[
                Row(
                  children: [
                    const SizedBox(width: 8),
                    const CircularProgressIndicator(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LinearProgressIndicator(value: _totalImages > 0 ? progress : null),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Processed $_processed of $_totalImages images',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _cancelRequested = true;
                        });
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
                  child: _reviewLabels.isEmpty
                      ? const Center(
                          child: Text(
                            'No labels were suggested. You can close this dialog.',
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
                        ),
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
