import 'package:flutter/material.dart';

class TopToolbar extends StatelessWidget {
  final String projectName;
  final String projectType;
  final VoidCallback onBack;
  final VoidCallback onHelp;

  const TopToolbar({
    super.key,
    required this.projectName,
    required this.projectType,
    required this.onBack,
    required this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.grey[900],
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
            tooltip: 'Back to Project',
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(projectName + ' @ ' + projectType, style: const TextStyle(color: Colors.white, fontSize: 22)),
              // Text(projectType, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: onHelp,
            tooltip: 'Help',
          ),
        ],
      ),
    );
  }
}