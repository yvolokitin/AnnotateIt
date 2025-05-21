import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DatasetImportProjectTypeHelper extends StatelessWidget {
  const DatasetImportProjectTypeHelper({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        t.projectTypeHelpTitle,
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.projectTypeWhyDisabledTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              t.projectTypeWhyDisabledBody,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              t.projectTypeAllowChangeTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              t.projectTypeAllowChangeBody,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              t.projectTypeWhenUseTitle,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              t.projectTypeWhenUseBody,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(t.close, style: const TextStyle(color: Colors.redAccent)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
