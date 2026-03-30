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

  void _showBetaDetailsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    AlertErrorDialog.show(
      context,
      l10n.betaDialogTitle,
      l10n.betaDialogMessage,
      tips: l10n.betaDialogTips,
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
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showBetaDetailsDialog(context),
            child: Chip(
              label: Text(
                'Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.orange,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              visualDensity: VisualDensity.compact,
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
