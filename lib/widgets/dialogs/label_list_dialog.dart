import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import '../../models/label.dart';
import '../dialogs/alert_error_dialog.dart';

class LabelListDialog extends StatelessWidget {
  final List<Label> labels;
  final ScrollController scrollController;

  final void Function(int index) onColorTap;
  final void Function(Label label) onDelete;
  final void Function(int index, String newName) onNameChanged;
  final void Function(int index, String newColor) onColorChanged;
  
  const LabelListDialog({
    super.key,
    required this.labels,
    required this.scrollController,
    required this.onColorTap,
    required this.onNameChanged,
    required this.onDelete,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.width;
    if (labels.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Container(
              padding: EdgeInsets.all(screenHeight > 1150 ? 24 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    "You have no Labels in the Project",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: screenHeight > 1450 ? 24 : 20,
                    ),
                  ),
                  SizedBox(height: screenHeight > 1450 ? 40 : 10),
                  Text(
                    "You can't annotate without labels because labels give meaning to what you're marking",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  Text(
                    " — without them, the model would not know what the annotation represents.",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  Text(
                    "An annotation without a label is just an empty box.",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  SizedBox(
                    height: screenHeight > 1450 ? 300 : 200,
                    child: Padding(
                      padding: EdgeInsets.all(screenHeight > 1450 ? 45 : 20),
                      child: Image.asset(
                        'assets/images/no_labels.png',
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    "Labels define the categories or classes you're annotating in your dataset.",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  Text(
                    "Whether you're tagging objects in images, classifying, or segmenting regions,",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  Text(
                    "labels are essential for organizing your annotations clearly and consistently.",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          thickness: 8,
          trackVisibility: true,
          child: Padding(
            padding: const EdgeInsets.only(right: 26, left: 18),
            child: ListView.builder(
              controller: scrollController,
              itemCount: labels.length,
              itemBuilder: (context, index) {
                final label = labels[index];
                final TextEditingController controller =
                    TextEditingController(text: label.name);
                bool isEditing = false;

                return StatefulBuilder(
                  builder: (context, setLocalState) {
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                          ),
                          child: SizedBox(
                            height: 60,
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  onColorTap(index);
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: label.toColor(),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),
                              Flexible(
                                child: SizedBox(
                                height: 46,
                                child: TextField(
                                  controller: controller,
                                  enabled: isEditing,
                                  onSubmitted: (value) {
                                    final newName = value.trim();
                                    final isDuplicate = labels.any((l) =>
                                        l.name.toLowerCase() == newName.toLowerCase() &&
                                        l != label);
                                    if (isDuplicate) {
                                      final l10n = AppLocalizations.of(context)!;
                                      AlertErrorDialog.show(
                                        context,
                                        l10n.labelDuplicateTitle,
                                        l10n.labelDuplicateMessage(newName),
                                        tips: l10n.labelDuplicateTips,
                                      );
                                      return;
                                    }
                                    onNameChanged(index, newName);
                                    setLocalState(() => isEditing = false);
                                  },
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isEditing ? Colors.white10 : Colors.transparent,
                                    contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                    ),
                                  ),
                                ),
                              ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  isEditing ? Icons.save : Icons.edit,
                                  color: Colors.white,
                                ),
                                iconSize: 30,
                                onPressed: () {
                                  if (isEditing) {
                                    final newName = controller.text.trim();
                                    final isDuplicate = labels.any((l) =>
                                        l.name.toLowerCase() == newName.toLowerCase() &&
                                        l != label);
                                    if (isDuplicate) {
                                      final l10n = AppLocalizations.of(context)!;
                                      AlertErrorDialog.show(
                                        context,
                                        l10n.labelDuplicateTitle,
                                        l10n.labelDuplicateMessage(newName),
                                        tips: l10n.labelDuplicateTips,
                                      );
                                      return;
                                    }
                                    onNameChanged(index, newName);
                                  }
                                  setLocalState(() => isEditing = !isEditing);
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white),
                                iconSize: 30,
                                onPressed: () => onDelete(label),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
    }
  }
}
