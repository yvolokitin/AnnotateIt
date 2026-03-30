import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../shared/confirmation_dialog.dart';

class DatasetImportDiscardConfirmationDialog extends StatelessWidget {
  const DatasetImportDiscardConfirmationDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    return ConfirmationDialog.show(
      context,
      title: l10n.discardDatasetImportTitle,
      body: l10n.discardDatasetImportMessage,
      cancelLabel: l10n.buttonKeep,
      confirmLabel: l10n.buttonDiscard,
      accentColor: Colors.redAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ConfirmationDialog(
      title: l10n.discardDatasetImportTitle,
      body: l10n.discardDatasetImportMessage,
      cancelLabel: l10n.buttonKeep,
      confirmLabel: l10n.buttonDiscard,
      accentColor: Colors.redAccent,
    );
  }
}
