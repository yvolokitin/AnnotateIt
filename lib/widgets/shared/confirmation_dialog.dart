import 'package:flutter/material.dart';
import '../../utils/theme.dart';

/// Reusable confirmation dialog with warning icon, title, body, and two actions.
///
/// Replaces the near-duplicate `DatasetImportDiscardConfirmationDialog`
/// and `PreLabelCancelConfirmationDialog`.
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String body;
  final String cancelLabel;
  final String confirmLabel;
  final Color accentColor;
  final bool barrierDismissible;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.body,
    required this.cancelLabel,
    required this.confirmLabel,
    this.accentColor = Colors.redAccent,
    this.barrierDismissible = true,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String body,
    required String cancelLabel,
    required String confirmLabel,
    Color accentColor = Colors.redAccent,
    bool barrierDismissible = true,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ConfirmationDialog(
        title: title,
        body: body,
        cancelLabel: cancelLabel,
        confirmLabel: confirmLabel,
        accentColor: accentColor,
        barrierDismissible: barrierDismissible,
      ),
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
        side: BorderSide(color: accentColor, width: 1),
      ),
      titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.warning_outlined, size: 32, color: accentColor),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth > 700 ? 24 : 20,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: accentColor),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      content: Text(
        body,
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
            cancelLabel,
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
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            confirmLabel,
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
