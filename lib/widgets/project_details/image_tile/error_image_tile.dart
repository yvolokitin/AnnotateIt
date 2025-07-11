import 'package:flutter/material.dart';

class ErrorImageTile extends StatelessWidget {
  final String message;

  const ErrorImageTile({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[850],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image, color: Colors.white24, size: 40),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white38,
              fontFamily: 'CascadiaCode',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
