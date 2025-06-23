import 'package:flutter/material.dart';

import '../buttons/hover_icon_button.dart';

class ProjectDetailsAppBar extends StatelessWidget {
  final VoidCallback onBackPressed;
  
  const ProjectDetailsAppBar({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width >= 1600 ? 80 : 60,
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
            onPressed: () => print("Help is not implemented yet"),
          ),
        ],
      ),
    );
  }
}