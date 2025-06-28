import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
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
                AppLocalizations.of(context)!.deleteAnnotationTitle,
                style: const TextStyle(
                  color: Colors.orangeAccent,
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
                  '${AppLocalizations.of(context)!.deleteAnnotationMessage} "${annotation.name ?? AppLocalizations.of(context)!.unnamedAnnotation}"?',
                  style: const TextStyle(
                    color: Colors.white70,
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
            AppLocalizations.of(context)!.cancelButton,
            style: const TextStyle(
              color: Colors.white70,
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
            AppLocalizations.of(context)!.deleteButton,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ],
    );
  }
}
