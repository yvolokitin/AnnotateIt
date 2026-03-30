import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class PreLabelCancelConfirmationDialog extends StatelessWidget {
  const PreLabelCancelConfirmationDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PreLabelCancelConfirmationDialog(),
    );
    return result ?? false;
    }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.accent, width: 1),
      ),
      titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_outlined, size: 32, color: AppColors.accent),
              const SizedBox(width: 12),
              Text(
                'Cancel pre-labeling?',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth > 700 ? 24 : 20,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.accent),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      content: Text(
        'Scanning is in progress. Do you want to stop and close the dialog?',
        style: TextStyle(
          color: Colors.white70,
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
            'Continue',
            style: TextStyle(
              color: Colors.white54,
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
            'Stop and Close',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: screenWidth > 700 ? 16 : 14,
            ),
          ),
        ),
      ],
    );
  }
}
