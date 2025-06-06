import 'package:flutter/material.dart';
import '../../models/label.dart';
import '../../models/project.dart';

class AnnotatorTopToolbar extends StatefulWidget {
  final Project project;

  final VoidCallback onBack;
  final VoidCallback onHelp;

  const AnnotatorTopToolbar({
    super.key,
    required this.project,
    required this.onBack,
    required this.onHelp,
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
    print('labels.length: ${labels.length}');
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompact = MediaQuery.of(context).size.width < 1200;

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
                // bottom: BorderSide(color: Colors.black, width: 2),
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
                          style: const TextStyle(color: Colors.white),
                          icon: const SizedBox.shrink(),
                          borderRadius: BorderRadius.circular(6),
                          isExpanded: true, // ensures full width is used inside dropdown
                          items: [
                            DropdownMenuItem<Label>(
                              value: null,
                              child: const Text("Select default label", style: TextStyle(fontSize: 20)),
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
                                        style: const TextStyle(fontSize: 22),
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

          if (!isCompact) ...[
            const SizedBox(width: 60),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.project.name} @ ${widget.project.type}',
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),
          IconButton(
            icon: const Icon(Icons.pending_sharp, color: Colors.white),
            onPressed: widget.onHelp,
            tooltip: 'Help',
          ),
        ],
      ),
    );
  }
}