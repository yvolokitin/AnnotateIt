import 'package:flutter/material.dart';

class AlertErrorDialog extends StatelessWidget {
  final String title;
  final String message;

  // optional extra info
  final String? tips;

  const AlertErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.tips,
  });

  static Future<void> show(BuildContext context, String title, String message, {String? tips}) {
    return showDialog(
      context: context,
      builder: (_) => AlertErrorDialog(title: title, message: message, tips: tips),
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
        side: BorderSide(color: Colors.orangeAccent, width: 1),
      ),
      title: Row(
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
              fontWeight: FontWeight.bold,
              fontSize: 24
            ),
          ),
        ],
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.orangeAccent),
          Padding(
            padding: EdgeInsets.all(screenWidth > 1600 ? 40.0 : 20.0),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white70,
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
                  fontWeight: FontWeight.normal,
                  fontSize: 22,
                ),
              ),
            ),


          const SizedBox(height: 25),
          const Divider(color: Colors.orangeAccent),
        ],
      ),

      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.orangeAccent, width: 2),
            ),
          ),
          child: const Text(
            'Close',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ],
    );
  }
}
