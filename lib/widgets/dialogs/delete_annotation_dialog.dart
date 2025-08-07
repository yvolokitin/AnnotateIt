import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../gen_l10n/app_localizations.dart';
import '../../models/annotation.dart';
import '../../session/user_session.dart';

class DeleteAnnotationResult {
  final bool shouldDelete;
  final bool dontAskAgain;

  DeleteAnnotationResult({
    required this.shouldDelete,
    required this.dontAskAgain,
  });
}

class DeleteAnnotationDialog extends StatefulWidget {
  final Annotation annotation;

  const DeleteAnnotationDialog({
    super.key,
    required this.annotation,
  });

  static Future<DeleteAnnotationResult?> show({
    required BuildContext context,
    required Annotation annotation,
  }) async {
    final result = await showDialog<DeleteAnnotationResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteAnnotationDialog(annotation: annotation),
    );
    
    // Return the result directly, which can be null if dialog was dismissed
    return result;
  }

  @override
  State<DeleteAnnotationDialog> createState() => _DeleteAnnotationDialogState();
}

class _DeleteAnnotationDialogState extends State<DeleteAnnotationDialog> {
  bool _dontAskAgain = false;
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            Navigator.pop(context, DeleteAnnotationResult(
              shouldDelete: true,
              dontAskAgain: _dontAskAgain,
            )); // Confirm
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.pop(context, DeleteAnnotationResult(
              shouldDelete: false,
              dontAskAgain: false,
            )); // Cancel
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
              onPressed: () => Navigator.pop(context, DeleteAnnotationResult(
                shouldDelete: false,
                dontAskAgain: false,
              )),
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
                    '${l10n.deleteAnnotationMessage} "${widget.annotation.name ?? l10n.unnamedAnnotation}"?',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.normal,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // Checkbox for "Don't ask again"
                Row(
                  children: [
                    Checkbox(
                      value: _dontAskAgain,
                      onChanged: (value) {
                        setState(() {
                          _dontAskAgain = value ?? false;
                        });
                      },
                      activeColor: Colors.orangeAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Remove annotations without confirmation in the future",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'CascadiaCode',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Divider(color: Colors.orangeAccent),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, DeleteAnnotationResult(
              shouldDelete: false,
              dontAskAgain: false,
            )),
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
            onPressed: () => Navigator.pop(context, DeleteAnnotationResult(
              shouldDelete: true,
              dontAskAgain: _dontAskAgain,
            )),
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