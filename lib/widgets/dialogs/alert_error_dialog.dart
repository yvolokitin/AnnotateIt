import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class AlertErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? tips;

  const AlertErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.tips,
  });

  static Future<void> show(
    BuildContext context,
    String title,
    String message, {
    String? tips,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AlertErrorDialog(
        title: title,
        message: message,
        tips: tips,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showTips = tips != null && tips!.trim().isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      // insetPadding: screenWidth > 700 ? const EdgeInsets.symmetric(horizontal: 40, vertical: 24) : EdgeInsets.zero,
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
                Icons.info_outline,
                size: 32,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth > 700 ? 24 : 20,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.orangeAccent),
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Colors.orangeAccent),
              Padding(
                padding: EdgeInsets.all(screenWidth > 1600 ? 40.0 : 20.0),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'CascadiaCode',
                    fontWeight: FontWeight.normal,
                    fontSize: screenWidth > 700 ? 22 : 18,
                  ),
                ),
              ),
              if (showTips)
                Padding(
                  padding: EdgeInsets.all(screenWidth > 1600 ? 40.0 : 20.0),
                  child: Text(
                    tips!,
                    style: TextStyle(
                      color: Colors.white60,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.normal,
                      fontSize: screenWidth > 700 ? 22 : 18,
                    ),
                  ),
                ),
              SizedBox(height: screenWidth > 700 ? 25 : 15),
              const Divider(color: Colors.orangeAccent),
            ],
          ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.orangeAccent, width: 2),
            ),
          ),
          child: Text(
            AppLocalizations.of(context)!.buttonClose,
            style: TextStyle(
              color: Colors.orangeAccent,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
              fontSize: screenWidth > 700 ? 22 : 18,
            ),
          ),
        ),
      ],
    );
  }
}
