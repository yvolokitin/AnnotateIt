import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../gen_l10n/app_localizations.dart';

class StepDescriptionWidget extends StatelessWidget {
  final int currentStep;
  final String? extractedPath;
  final String? datasetFormat;

  const StepDescriptionWidget({
    super.key,
    required this.currentStep,
    this.extractedPath,
    this.datasetFormat,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (currentStep == 1) {
      return Text(
        l10n.datasetStepUploadZip,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white70,
          fontFamily: 'CascadiaCode',
        ),
      );
    } else if (currentStep == 2) {
      return Text(
        l10n.datasetStepExtractingZip,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white70,
          fontFamily: 'CascadiaCode',
        ),
      );
    } else if (currentStep == 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              if (extractedPath != null) {
                await launchUrl(Uri.file(extractedPath!), mode: LaunchMode.platformDefault);
              }
            },
            child: Text(
              l10n.datasetStepExtractedPath(extractedPath ?? ''),
              style: const TextStyle(
                color: Colors.blueAccent,
                fontSize: 18,
                fontFamily: 'CascadiaCode',
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.datasetStepDetectedTaskType(datasetFormat ?? ''),
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white70,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ],
      );
    } else {
      return Text(
        l10n.datasetStepSelectProjectType,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.white70,
          fontFamily: 'CascadiaCode',
        ),
      );
    }
  }
}
