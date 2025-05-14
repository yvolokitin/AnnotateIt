import 'package:flutter/material.dart';

class StepDatasetProjectCreation extends StatelessWidget {
  final String? errorMessage;

  const StepDatasetProjectCreation({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) {
      // Normal progress screen
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            color: Colors.redAccent,
            strokeWidth: 5,
          ),
          SizedBox(height: 24),
          Text(
            'Please wait...',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 12),
          Text(
            'All media files are being added into the database\n'
            'and all annotations are being parsed.\n\n'
            'This may take a few moments depending on dataset size.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      );
    } else {
      // Error screen
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 24),
            const Text(
              'Project Creation Failed',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Reason:\n$errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text(
              'You can close this window and try the dataset import again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.close, color: Colors.black),
              label: const Text('Close', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        ),
      );
    }
  }
}
