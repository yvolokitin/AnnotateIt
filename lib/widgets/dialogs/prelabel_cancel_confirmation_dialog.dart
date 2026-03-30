import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../shared/confirmation_dialog.dart';

class PreLabelCancelConfirmationDialog extends StatelessWidget {
  const PreLabelCancelConfirmationDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    return ConfirmationDialog.show(
      context,
      title: 'Cancel pre-labeling?',
      body: 'Scanning is in progress. Do you want to stop and close the dialog?',
      cancelLabel: 'Continue',
      confirmLabel: 'Stop and Close',
      accentColor: AppColors.accent,
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: 'Cancel pre-labeling?',
      body: 'Scanning is in progress. Do you want to stop and close the dialog?',
      cancelLabel: 'Continue',
      confirmLabel: 'Stop and Close',
      accentColor: AppColors.accent,
      barrierDismissible: false,
    );
  }
}
