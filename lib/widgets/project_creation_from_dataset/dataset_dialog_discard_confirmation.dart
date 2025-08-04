import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_outlined, size: 32, color: Colors.redAccent),
              const SizedBox(width: 12),
              Text(
                l10n.discardDatasetImportTitle,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth > 700 ? 24 : 20,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            tooltip: l10n.buttonClose,
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      content: Text(
        l10n.discardDatasetImportMessage,
        style: TextStyle(
          color: Colors.white70,
          fontFamily: 'CascadiaCode',
          fontSize: screenWidth > 700 ? 16 : 14,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            l10n.buttonKeep,
            style: TextStyle(
              color: Colors.white54,
              fontFamily: 'CascadiaCode',
              fontSize: screenWidth > 700 ? 16 : 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            l10n.buttonDiscard,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
              fontSize: screenWidth > 700 ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }
}
