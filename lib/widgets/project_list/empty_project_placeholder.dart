import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

import 'project_action_buttons.dart';

class EmptyProjectPlaceholder extends StatelessWidget {
  final VoidCallback onCreateNewProject;
  final VoidCallback onImportFromDataset;

  const EmptyProjectPlaceholder({
    super.key,
    required this.onCreateNewProject,
    required this.onImportFromDataset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    final double leftImageSize = screenWidth>1200 ? 350 : (screenWidth>920) ? 250 : 150;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (screenWidth<600)...[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child:Text(
              l10n.emptyProjectTitle,
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],

        Card(
          color: Colors.grey.shade800,
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth>1200 ? 24 : 12,
            vertical: 12,
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: leftImageSize,
            width: double.infinity,
            child: Row(
              children: [
                // Left: Image (only for larger screens)
                if (screenWidth>380)...[
                  Container(
                    width: leftImageSize,
                    height: leftImageSize,
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/start_first_project.png',
                        fit: BoxFit.cover,
                        height: leftImageSize,
                        width: leftImageSize,
                      ),
                    ),
                  ),
                ],
                // Right: Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth>1200 ? 24 : (screenWidth>920) ? 12 : 8,
                      vertical: screenWidth>1200 ? 24 : (screenWidth>920) ? 12 : 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (screenWidth>=600)...[
                          Text(
                            l10n.emptyProjectTitle,
                            style: TextStyle(
                              fontSize: screenWidth>1200 ? 26 : (screenWidth>920) ? 22 : 18,
                              fontFamily: 'CascadiaCode',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        Text(
                          l10n.emptyProjectDescription,
                          style: TextStyle(
                            fontSize: screenWidth>1200 ? 22 : (screenWidth>920) ? 18 : (screenWidth>500) ? 14 : 10,
                            fontFamily: 'CascadiaCode',
                            fontWeight: FontWeight.normal,
                            color: Colors.white70,
                          ),
                        ),

                        if (screenWidth>=920)...[
                          const Spacer(),
                          ProjectActionButtons(
                            onCreate: onCreateNewProject,
                            onImport: onImportFromDataset,
                            screenWidth: screenWidth,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (screenWidth<920)...[
          const SizedBox(height: 16),
          Container(
            margin: EdgeInsets.symmetric(
            horizontal: 12, vertical: 12,
            ),
            child: ProjectActionButtons(
              onCreate: onCreateNewProject,
              onImport: onImportFromDataset,
              screenWidth: screenWidth,
            ),
          ),
        ],
      ],
    );
  }
}
