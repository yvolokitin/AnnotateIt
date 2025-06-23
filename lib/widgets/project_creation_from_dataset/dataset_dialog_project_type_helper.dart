import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

class DatasetImportProjectTypeHelper extends StatelessWidget {
  const DatasetImportProjectTypeHelper({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        l10n.projectTypeHelpTitle,
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.projectTypeWhyDisabledTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.projectTypeWhyDisabledBody,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.projectTypeAllowChangeTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.projectTypeAllowChangeBody,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.projectTypeWhenUseTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.projectTypeWhenUseBody,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(l10n.closeButton, style: const TextStyle(color: Colors.redAccent)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
