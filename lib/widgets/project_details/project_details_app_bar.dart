import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../buttons/hover_icon_button.dart';
import '../dialogs/alert_error_dialog.dart';
import '../../utils/theme.dart';

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
        color: AppColors.darkSurface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.darkRail,
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
        ],
      ),
    );
  }
}