import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import '../buttons/hover_icon_button.dart';
import '../dialogs/alert_error_dialog.dart';

class ProjectDetailsAppBar extends StatelessWidget {
  final VoidCallback onBackPressed;
  
  const ProjectDetailsAppBar({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width >= 1800 ? 80 : 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[900]!,
            width: 2,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          HoverIconButton(
            icon: Icons.arrow_back,
            margin: const EdgeInsets.only(left: 20.0),
            onPressed: onBackPressed,
          ),
          HoverIconButton(
            icon: Icons.help_outline,
            margin: const EdgeInsets.only(right: 20.0),
            onPressed: () {
              final l10n = AppLocalizations.of(context)!;

              AlertErrorDialog.show(
                context,
                l10n.projectHelpTitle,
                l10n.projectHelpMessage,
                tips: l10n.projectHelpTips,
              );
            }
          ),
        ],
      ),
    );
  }
}