import 'package:flutter/material.dart';
import '../../models/label.dart';
import '../../models/project.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/color_utils.dart';
import '../dialogs/color_picker_dialog.dart';

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
        if (widget.onDefaultLabelSelected != null) {
          widget.onDefaultLabelSelected!(label);
        }
        break;
      }
    }
  }

  void _showCreateLabelDialog() {
    final nameController = TextEditingController();
    String selectedColor = generateColorByIndex(widget.project.labels?.length ?? 0);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Color displayColor = _fromHex(selectedColor);
            return AlertDialog(
              backgroundColor: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.white24, width: 1),
              ),
              title: Row(
                children: [
                  const Icon(Icons.label_outline, color: Colors.white, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    'Create Label',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: ctx,
                              builder: (_) => ColorPickerDialog(
                                initialColor: selectedColor,
                                onColorSelected: (newColor) {
                                  setDialogState(() {
                                    selectedColor = newColor;
                                  });
                                },
                              ),
                            );
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: displayColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white38, width: 1.5),
                            ),
                            child: const Icon(Icons.palette, color: Colors.white70, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            autofocus: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'CascadiaCode',
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Label name',
                              hintStyle: TextStyle(color: Colors.grey[500], fontFamily: 'CascadiaCode'),
                              filled: true,
                              fillColor: Colors.grey[800],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                              ),
                            ),
                            onSubmitted: (_) => _submitLabel(ctx, nameController, selectedColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: List.generate(
                        basicColors.length,
                        (i) {
                          final c = basicColors[i];
                          final hex = '#${c.value.toRadixString(16).substring(2).toUpperCase()}';
                          final isSelected = selectedColor.toUpperCase().replaceAll('#', '') == hex.toUpperCase().replaceAll('#', '');
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedColor = hex),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: c,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontFamily: 'CascadiaCode')),
                ),
                ElevatedButton(
                  onPressed: () => _submitLabel(ctx, nameController, selectedColor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(color: Colors.white, fontFamily: 'CascadiaCode', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitLabel(BuildContext dialogContext, TextEditingController controller, String color) async {
    final name = controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(dialogContext);
    if (widget.onCreateLabel != null) {
      final created = await widget.onCreateLabel!(name, color);
      if (created != null) {
        setState(() {
          selectedDefaultLabel = created;
        });
        widget.onDefaultLabelSelected?.call(created);
      }
    }
  }

  Color _fromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;

    bool detection = widget.project.type.toLowerCase().contains('detection');
    bool segmentation = widget.project.type.toLowerCase().contains('segmentation');

    final hasLabels = (widget.project.labels ?? []).isNotEmpty;

    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: const Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBack,
              tooltip: l10n.annotatorTopToolbarBackTooltip,
              iconSize: 32,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ),

          if (detection || segmentation)...[
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
                            style: const TextStyle(color: Colors.white, fontFamily: 'CascadiaCode',),
                            icon: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(6),
                            isExpanded: true,
                            items: [
                              DropdownMenuItem<Label?>(
                                value: null,
                                child: Text(
                                  l10n.annotatorTopToolbarSelectDefaultLabel,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'CascadiaCode',
                                    ),
                                ),
                              ),
                              ...(List<Label>.from(widget.project.labels?? [])).map((Label label) {
                                return DropdownMenuItem<Label>(
                                  value: label,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: label.toColor(),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          label.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            fontFamily: 'CascadiaCode',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                            onChanged: (Label? newValue) {
                              setState(() {
                                selectedDefaultLabel = newValue;
                              });

                              if (widget.onDefaultLabelSelected != null) {
                                widget.onDefaultLabelSelected!(newValue);
                              }
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
                          style: TextStyle(
                            fontFamily: 'CascadiaCode',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
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
                  if (hasLabels && selectedDefaultLabel != null)...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDefaultLabel = null;
                        });

                        if (widget.onDefaultLabelSelected != null) {
                          widget.onDefaultLabelSelected!(null);
                        }                        
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[700],
                        ),
                        child: const Icon(Icons.clear, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
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
            width: (screenWidth-400),
            child: AnnotatorLabels(
              labels: widget.project.labels ?? [],
              width: (screenWidth-400),
              onLabelSelected: (label) {
                widget.onAssignedLabel?.call(label);
              }
            ),
          ),

          SizedBox(width: screenWidth > 1280 ? 20 : 5),
        ],
      ),
    );
  }
}
