import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';

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
      spacing: 14,
      runSpacing: 8,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.accentOrange],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: onCreate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: screenWidth < 500 ? 12 : 14,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              screenWidth > 500
                  ? l10n.emptyProjectCreateNew
                  : l10n.emptyProjectCreateNewShort,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth > 1200 ? 17 : 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onImport,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: screenWidth < 500 ? 12 : 14,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            side: BorderSide(color: Colors.white.withOpacity(0.15)),
          ),
          icon: Icon(Icons.upload_file_rounded, color: Colors.white.withOpacity(0.7)),
          label: Text(
            screenWidth > 500
                ? l10n.emptyProjectImportDataset
                : l10n.emptyProjectImportDatasetShort,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: screenWidth > 1200 ? 17 : 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
