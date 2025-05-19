import 'package:flutter/material.dart';

class AlertErrorDialog extends StatelessWidget {
  final String title;
  final String message;

  // optional extra info
  final String? tips;

  const AlertErrorDialog({
    Key? key,
    required this.title,
    required this.message,
    this.tips,
  }) : super(key: key);

  static Future<void> show(BuildContext context, String title, String message, {String? tips}) {
    return showDialog(
      context: context,
      builder: (_) => AlertErrorDialog(title: title, message: message, tips: tips),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showTips = tips != null && tips!.trim().isNotEmpty;

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Color.fromARGB(167, 255, 255, 255)),
          const SizedBox(width: 40),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.normal,
              fontSize: 22,
            ),
          ),

          const SizedBox(width: 40),
          if (showTips) ...[
            const SizedBox(width: 40),
            const Divider(color: Color.fromARGB(167, 255, 255, 255)),
            const SizedBox(width: 40),

            Text(
              tips!,
              style: const TextStyle(
                color: Colors.white60,
                fontWeight: FontWeight.normal,
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 40),
            const Divider(color: Color.fromARGB(167, 255, 255, 255)),
            const SizedBox(width: 40),
          ]
        ],
      ),

      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'Close',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ],
    );
  }
}
