import 'package:flutter/material.dart';

class DatasetStepProgressBar extends StatelessWidget {
  final int currentStep; // 1 = Select, 2 = Extract, 3 = Detect, 4 = Labels, 5 = Create

  const DatasetStepProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStep("1", "Dataset Selection", 1),
        _buildLine(),
        _buildStep("2", "Extract ZIP", 2),
        _buildLine(),
        _buildStep("3", "Detect Type", 3),
        _buildLine(),
        _buildStep("4", "Labels", 4),
        _buildLine(),
        _buildStep("5", "Create Project", 5),
      ],
    );
  }

  Widget _buildStep(String number, String label, int stepIndex) {
    final isActive = currentStep == stepIndex;
    final isCompleted = currentStep > stepIndex;
    final icon = _getStepIcon(stepIndex);

    return Column(
      children: [
        Tooltip(
          message: label,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.redAccent.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
              color: isCompleted
                  ? Colors.deepOrange[400]
                  : isActive
                      ? Colors.redAccent
                      : Colors.grey[700],
            ),
            child: Center(
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive || isCompleted ? Colors.white : Colors.white54,
          ),
          child: Text('$number. $label'),
        ),
      ],
    );
  }

  IconData _getStepIcon(int stepIndex) {
    switch (stepIndex) {
      case 1:
        return Icons.folder_open;
      case 2:
        return Icons.unarchive;
      case 3:
        return Icons.search;
      case 4:
        return Icons.label_outline;
      case 5:
        return Icons.check_circle_outline;
      default:
        return Icons.circle;
    }
  }

  Widget _buildLine() => Expanded(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          height: 2,
          color: Colors.deepOrange[300],
        ),
      );
} 
