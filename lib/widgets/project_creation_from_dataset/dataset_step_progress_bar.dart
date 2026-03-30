import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';

class DatasetStepProgressBar extends StatelessWidget {
  // 1 = Select, 2 = Extract, 3 = Overview, 4 = Task Confirm, 5 = Create Project
  final int currentStep;

  const DatasetStepProgressBar({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 700;

    if (isCompact) {
      // Compact layout: avoid Expanded in unbounded width by removing connectors
      // and slightly reducing sizes.
      return Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildStep(l10n.datasetStepProgressSelection, 1, true),
            _buildStep(l10n.datasetStepProgressExtract, 2, true),
            _buildStep(l10n.datasetStepProgressOverview, 3, true),
            _buildStep(l10n.datasetStepProgressTaskConfirmation, 4, true),
            _buildStep(l10n.datasetStepProgressProjectCreation, 5, true),
          ],
        ),
      );
    }

    return Row(
      children: [
        _buildStep(l10n.datasetStepProgressSelection, 1, false),
        _buildLine(),
        _buildStep(l10n.datasetStepProgressExtract, 2, false),
        _buildLine(),
        _buildStep(l10n.datasetStepProgressOverview, 3, false),
        _buildLine(),
        _buildStep(l10n.datasetStepProgressTaskConfirmation, 4, false),
        _buildLine(),
        _buildStep(l10n.datasetStepProgressProjectCreation, 5, false),
      ],
    );
  }

  Widget _buildStep(String label, int stepIndex, bool compact) {
    final isActive = currentStep == stepIndex;
    final isCompleted = currentStep > stepIndex;
    final icon = _getStepIcon(stepIndex);

    final double circleSize = compact ? 36 : 48;
    final double iconSize = compact ? 16 : 18;
    final double fontSize = compact ? 12 : 14;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
              color: isCompleted
                  ? Colors.deepOrange[400]
                  : isActive
                      ? AppColors.accent
                      : Colors.grey[700],
            ),
            child: Center(
              child: Icon(
                isCompleted ? Icons.check : icon,
                color: Colors.white,
                size: iconSize,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive || isCompleted ? Colors.white : Colors.white54,
          ),
          child: Text(label, textAlign: TextAlign.center),
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
        return Icons.grid_view;
      case 4:
        return Icons.checklist;
      case 5:
        return Icons.build_circle;
      default:
        return Icons.circle;
    }
  }

  Widget _buildLine() => Expanded(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          height: 2,
          color: Colors.deepOrange[300],
        ),
      );
}
