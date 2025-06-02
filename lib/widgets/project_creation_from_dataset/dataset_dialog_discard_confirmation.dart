import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

class DatasetImportDiscardConfirmationDialog extends StatelessWidget {
  const DatasetImportDiscardConfirmationDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const DatasetImportDiscardConfirmationDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[800],
      title: Text(
        AppLocalizations.of(context)!.discardDatasetImportTitle,
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        AppLocalizations.of(context)!.discardDatasetImportMessage,
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            AppLocalizations.of(context)!.keep,
            style: TextStyle(color: Colors.white54)
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            AppLocalizations.of(context)!.discard,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
