import 'package:flutter/material.dart';

typedef ProgressCallback = void Function(int current, int total);

class StepDatasetProjectCreation extends StatefulWidget {
  final String? errorMessage;
  final int current;
  final int total;
  
  const StepDatasetProjectCreation({
    super.key,
    this.errorMessage,
    required this.current,
    required this.total,
  });

  @override
  State<StepDatasetProjectCreation> createState() => _StepDatasetProjectCreationState();
}

class _StepDatasetProjectCreationState extends State<StepDatasetProjectCreation> {
  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage == null) {
      final bool hasProgress = widget.total > 0;
      final double progress = hasProgress ? widget.current / widget.total : 0.0;

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          hasProgress
              ? CircularProgressIndicator(
                  color: Colors.redAccent,
                  strokeWidth: 5,
                  value: progress.clamp(0.0, 1.0),
                )
              : const CircularProgressIndicator(
                  color: Colors.redAccent,
                  strokeWidth: 5,
                ),
          const SizedBox(height: 24),
          Text(
            hasProgress
                ? 'Importing media (${widget.current} / ${widget.total})...'
                : 'Please wait...',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 12),
          const Text(
            'All media files are being added into the database\n'
            'and all annotations are being parsed.\n\n'
            'This may take a few moments depending on dataset size.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      );
    } else {
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
              'Reason:\n${widget.errorMessage}',
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
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }
}
