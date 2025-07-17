import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../gen_l10n/app_localizations.dart';
import '../../models/annotation.dart';

class DeleteAnnotationDialog extends StatelessWidget {
  final Annotation annotation;

  const DeleteAnnotationDialog({
    super.key,
    required this.annotation,
  });

  static Future<bool?> show({
    required BuildContext context,
    required Annotation annotation,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteAnnotationDialog(annotation: annotation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final FocusNode _focusNode = FocusNode();

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            Navigator.pop(context, true); // Confirm
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.pop(context, false); // Cancel
          }
        }
      },
      child: AlertDialog(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.orangeAccent, width: 1),
        ),
        titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 32,
                  color: Colors.orangeAccent,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.deleteAnnotationTitle,
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontFamily: 'CascadiaCode',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.orangeAccent),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Colors.orangeAccent),
                Padding(
                  padding: EdgeInsets.all(screenWidth > 1600 ? 40.0 : 20.0),
                  child: Text(
                    '${l10n.deleteAnnotationMessage} "${annotation.name ?? l10n.unnamedAnnotation}"?',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.normal,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Divider(color: Colors.orangeAccent),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            ),
            child: Text(
              l10n.buttonCancel,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[900],
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.redAccent, width: 2),
              ),
            ),
            child: Text(
              l10n.buttonDelete,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
