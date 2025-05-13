import 'package:flutter/material.dart';

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
      title: const Text(
        "Discard Dataset Import?",
        style: TextStyle(color: Colors.white),
      ),
      content: const Text(
        "You have already extracted a dataset. Cancelling now will delete the extracted files and detected dataset details. Are you sure you want to proceed?",
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Keep", style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("Discard", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
