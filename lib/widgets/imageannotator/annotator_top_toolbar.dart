import 'package:flutter/material.dart';
import '../../models/label.dart';
import '../../models/project.dart';

import 'annotator_labels.dart';

class AnnotatorTopToolbar extends StatefulWidget {
  final Project project;

  final VoidCallback onBack;
  final VoidCallback onHelp;

  final ValueChanged<Label>? onAssignedLabel;
  final ValueChanged<Label?>? onDefaultLabelSelected;

  const AnnotatorTopToolbar({
    super.key,
    required this.project,
    required this.onBack,
    required this.onHelp,
    required this.onAssignedLabel,
    required this.onDefaultLabelSelected,
  });

  @override
  State<AnnotatorTopToolbar> createState() => _AnnotatorTopToolbarState();
}

class _AnnotatorTopToolbarState extends State<AnnotatorTopToolbar> {
  List<Label> labels = [];
  Label? selectedLabel;

  @override
  void initState() {
    super.initState();
    labels = List<Label>.from(widget.project.labels ?? []);
    print('AnnotatorTopToolbar labels.length: ${labels.length}');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    bool detection = widget.project.type.toLowerCase().contains('detection');
    bool segmentation = widget.project.type.toLowerCase().contains('segmentation');
    // bool classification = widget.project.type.toLowerCase().contains('classification');

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
              tooltip: 'Back to Project',
              iconSize: 32,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ),

          if (detection || segmentation)...[
            const SizedBox(width: 25),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: SizedBox(
                      width: 200,
                      height: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey[850],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Label>(
                            value: selectedLabel,
                            dropdownColor: Colors.grey[850],
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white, fontFamily: 'CascadiaCode',),
                            icon: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(6),
                            isExpanded: true, // ensures full width is used inside dropdown
                            items: [
                              DropdownMenuItem<Label>(
                                value: null,
                                child: Text(
                                  "Select default label",
                                  style: TextStyle(
                                    fontSize: (screenWidth > 1280) ? 18 : 14,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: 'CascadiaCode',
                                  ),
                                ),
                              ),
                              ...labels.map((Label label) {
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
                                            fontSize: (screenWidth > 1280) ? 20 : 16,
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
                                selectedLabel = newValue;
                              });

                              if (widget.onDefaultLabelSelected != null) {
                                widget.onDefaultLabelSelected!(newValue);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (selectedLabel != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedLabel = null;
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
              ),
            ),
          ],

          SizedBox(width: screenWidth > 1280 ? 40 : 20), // 62 + 20 + 20

          SizedBox(
            width: screenWidth>1400 ? screenWidth * 0.8 : screenWidth * 0.5,
            child: AnnotatorLabels(
              labels: labels,
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