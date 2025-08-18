import 'package:flutter/material.dart';
import '../dialogs/alert_error_dialog.dart';
import '../../gen_l10n/app_localizations.dart';

class ModelsTopBar extends StatelessWidget {
  const ModelsTopBar({super.key});

  void _showLabelsHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    AlertErrorDialog.show(
      context,
      l10n.modelsAnnotation,
      l10n.modelsHelpBody,
      tips: l10n.modelsHelpTips,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 10,
      ),
      child: Row(
        children: [
          Text(
            l10n.modelsAnnotation,
            style: TextStyle(
              fontSize: screenWidth > 1600 ? 26 : (screenWidth > 1200) ? 22 : 18,
              color: Colors.white,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              size: 28,
              color: Colors.white70,
            ),
            onPressed: () => _showLabelsHelpDialog(context),
          ),
        ],
      ),
    );
  }
}
