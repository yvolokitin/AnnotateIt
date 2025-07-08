import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

class StepProjectTypeSelectionConfirmation extends StatelessWidget {
  final String currentProjectType;
  final String newProjectType;

  const StepProjectTypeSelectionConfirmation({
    super.key,
    required this.currentProjectType,
    required this.newProjectType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ScrollController scrollController = ScrollController();

    return Scrollbar(
      thumbVisibility: true,
      thickness: 8,
      radius: const Radius.circular(8),
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.changeProjectTypeWarningTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$currentProjectType -> $newProjectType',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.changeProjectTypeConversionIntro,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.changeProjectTypeConversionDetails,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
