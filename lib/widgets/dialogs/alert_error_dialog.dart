import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

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
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Colors.orangeAccent),
              Padding(
                padding: EdgeInsets.all(screenWidth > 1600 ? 40.0 : 20.0),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'CascadiaCode',
                    fontWeight: FontWeight.normal,
                    fontSize: 22,
                  ),
                ),
              ),
              if (showTips)
                Padding(
                  padding: EdgeInsets.all(screenWidth > 1600 ? 40.0 : 20.0),
                  child: Text(
                    tips!,
                    style: const TextStyle(
                      color: Colors.white60,
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
              fontSize: 22,
            ),
          ),
        ),
      ],
    );
  }
}
