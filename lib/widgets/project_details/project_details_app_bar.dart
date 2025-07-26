import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: screenWidth >= 1800 ? 80 : screenWidth > 550 ? 60 : 50,
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
            margin: EdgeInsets.only(left: screenWidth > 550 ? 16 : 10),
            onPressed: onBackPressed,
          ),
          /// disabled help button for now
/*
          HoverIconButton(
            icon: Icons.help_outline,
            margin: EdgeInsets.only(right: screenWidth > 550 ? 16 : 10),
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
*/          
        ],
      ),
    );
  }
}