import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class ProjectActionButtons extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onImport;
  final double screenWidth;

  const ProjectActionButtons({
    super.key,
    required this.onCreate,
    required this.onImport,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: onCreate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add_circle_outline, color: Colors.white),
          label: Text(
            screenWidth > 500 ? l10n.emptyProjectCreateNew : l10n.emptyProjectCreateNewShort,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth > 1200 ? 22 : 18,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onImport,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            side: const BorderSide(color: Colors.white54),
          ),
          icon: const Icon(Icons.upload_file, color: Colors.white),
          label: Text(
            screenWidth > 500 ? l10n.emptyProjectImportDataset : l10n.emptyProjectImportDatasetShort,
            style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth > 1200 ? 22 : 18,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
