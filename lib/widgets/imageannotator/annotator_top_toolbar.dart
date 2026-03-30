import 'package:flutter/material.dart';
import '../../models/label.dart';
import '../../models/project.dart';
import '../../gen_l10n/app_localizations.dart';
import '../labels/create_label_dialog.dart';

import 'annotator_labels.dart';

class AnnotatorTopToolbar extends StatefulWidget {
  final Project project;

  final VoidCallback onBack;
  final VoidCallback onHelp;

  final ValueChanged<Label>? onAssignedLabel;
  final ValueChanged<Label?>? onDefaultLabelSelected;
  final Future<Label?> Function(String name, String color)? onCreateLabel;

  const AnnotatorTopToolbar({
    super.key,
    required this.project,
    required this.onBack,
    required this.onHelp,
    required this.onAssignedLabel,
    required this.onDefaultLabelSelected,
    this.onCreateLabel,
  });

  @override
  State<AnnotatorTopToolbar> createState() => _AnnotatorTopToolbarState();
}

class _AnnotatorTopToolbarState extends State<AnnotatorTopToolbar> {
  Label? selectedDefaultLabel;

  @override
  void initState() {
    super.initState();
    for (final label in widget.project.labels!) {
      if (label.isDefault) {
        selectedDefaultLabel = label;
        widget.onDefaultLabelSelected?.call(label);
        break;
      }
    }
  }

  Future<void> _showCreateLabelDialog() async {
    if (widget.onCreateLabel == null) return;

    final created = await CreateLabelDialog.show(
      context: context,
      existingLabels: widget.project.labels ?? [],
      onCreateLabel: widget.onCreateLabel!,
    );

    if (created != null && mounted) {
      setState(() => selectedDefaultLabel = created);
      widget.onDefaultLabelSelected?.call(created);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    final detection = widget.project.type.toLowerCase().contains('detection');
    final segmentation = widget.project.type.toLowerCase().contains('segmentation');
    final hasLabels = (widget.project.labels ?? []).isNotEmpty;

    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.black, width: 2)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBack,
              tooltip: l10n.annotatorTopToolbarBackTooltip,
              iconSize: 32,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),

          if (detection || segmentation) ...[
            SizedBox(width: screenWidth > 700 ? 25 : 5),
            Expanded(
              child: Row(
                children: [
                  if (hasLabels)
                    SizedBox(
                      width: 220,
                      height: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey[850],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Label?>(
                            value: selectedDefaultLabel,
                            dropdownColor: Colors.grey[850],
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white, fontFamily: 'CascadiaCode'),
                            icon: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(6),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<Label?>(
                                value: null,
                                child: Text(
                                  l10n.annotatorTopToolbarSelectDefaultLabel,
                                  style: const TextStyle(fontSize: 16, fontFamily: 'CascadiaCode'),
                                ),
                              ),
                              ...(widget.project.labels ?? []).map((label) {
                                return DropdownMenuItem<Label>(
                                  value: label,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(color: label.toColor(), shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          label.name,
                                          style: const TextStyle(fontSize: 16, fontFamily: 'CascadiaCode'),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (newValue) {
                              setState(() => selectedDefaultLabel = newValue);
                              widget.onDefaultLabelSelected?.call(newValue);
                            },
                          ),
                        ),
                      ),
                    ),

                  if (!hasLabels)
                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: _showCreateLabelDialog,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text(
                          'Create Label',
                          style: TextStyle(fontFamily: 'CascadiaCode', fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),

                  const SizedBox(width: 8),

                  if (hasLabels && selectedDefaultLabel != null)
                    GestureDetector(
                      onTap: () {
                        setState(() => selectedDefaultLabel = null);
                        widget.onDefaultLabelSelected?.call(null);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey[700]),
                        child: const Icon(Icons.clear, size: 18, color: Colors.white),
                      ),
                    ),

                  if (hasLabels) ...[
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        onPressed: _showCreateLabelDialog,
                        icon: const Icon(Icons.add_circle_outline, size: 22, color: Colors.white70),
                        tooltip: 'Add new label',
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          SizedBox(width: screenWidth > 1280 ? 30 : 10),

          SizedBox(
            width: (screenWidth - 400),
            child: AnnotatorLabels(
              labels: widget.project.labels ?? [],
              width: (screenWidth - 400),
              onLabelSelected: (label) => widget.onAssignedLabel?.call(label),
            ),
          ),

          SizedBox(width: screenWidth > 1280 ? 20 : 5),
        ],
      ),
    );
  }
}
