import 'package:flutter/material.dart';

class DatasetStepProgressBar extends StatelessWidget {
  final int currentStep; // 1-based: 1 = Upload, 2 = Confirm

  const DatasetStepProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStepIndicator(step: 1, label: "Upload", isActive: currentStep == 1),
        _buildConnector(),
        _buildStepIndicator(step: 2, label: "Confirm", isActive: currentStep == 2),
      ],
    );
  }

  Widget _buildStepIndicator({required int step, required String label, required bool isActive}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isActive ? Colors.redAccent : Colors.grey[700],
          child: Text(
            step.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        height: 2,
        color: Colors.white24,
      ),
    );
  }
}
