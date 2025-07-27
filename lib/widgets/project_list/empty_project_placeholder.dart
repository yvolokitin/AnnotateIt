import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            final l10n = AppLocalizations.of(context)!;
            final screenSize = MediaQuery.of(context).size;
            final screenWidth = screenSize.width;
            final screenHeight = screenSize.height;
            final isPortrait = orientation == Orientation.portrait;
            
            // Determine if we're on a small device
            final isSmallDevice = screenWidth < 360;
            // Determine if we're on a medium device
            final isMediumDevice = screenWidth >= 360 && screenWidth < 600;
            // Determine if we're on a tablet
            final isTablet = screenWidth >= 600 && screenWidth < 900;
            // Determine if we're on a desktop
            final isDesktop = screenWidth >= 900;
            
            // Calculate image size based on available space and device type
            final double leftImageSize = isDesktop 
                ? (screenWidth > 1200 ? 350 : 250)
                : isTablet 
                    ? 200
                    : isMediumDevice 
                        ? 150
                        : 120;
            
            // Calculate font sizes that are readable on all devices
            final titleFontSize = isDesktop 
                ? 26.0
                : isTablet 
                    ? 22.0
                    : 18.0;
            
            final descriptionFontSize = isDesktop 
                ? 18.0
                : isTablet 
                    ? 16.0
                    : 14.0;
            
            // Determine if we should show the image based on available space
            final shouldShowImage = !isSmallDevice || !isPortrait;
            
            // Determine if we should show buttons inside the card
            final showButtonsInCard = isDesktop || (!isPortrait && isTablet);
            
            // Determine if we should use a column layout instead of row for very small screens
            final useColumnLayout = isSmallDevice && isPortrait;
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title for smaller screens (outside the card)
                  if (!isDesktop && !isTablet)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Text(
                        l10n.emptyProjectTitle,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontFamily: 'CascadiaCode',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            
                  // Main card
                  Card(
                    color: Colors.grey.shade800,
                    margin: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: 16,
                    ),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: useColumnLayout
                        ? _buildColumnLayout(
                            context,
                            l10n,
                            leftImageSize,
                            shouldShowImage,
                            titleFontSize,
                            descriptionFontSize,
                            showButtonsInCard,
                            screenWidth,
                          )
                        : _buildRowLayout(
                            context,
                            l10n,
                            leftImageSize,
                            shouldShowImage,
                            titleFontSize,
                            descriptionFontSize,
                            showButtonsInCard,
                            isDesktop,
                            isTablet,
                            screenWidth,
                          ),
                  ),
            
                  // Buttons for smaller screens (outside the card)
                  if (!showButtonsInCard)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: ProjectActionButtons(
                        onCreate: onCreateNewProject,
                        onImport: onImportFromDataset,
                        screenWidth: screenWidth,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildRowLayout(
    BuildContext context,
    AppLocalizations l10n,
    double leftImageSize,
    bool shouldShowImage,
    double titleFontSize,
    double descriptionFontSize,
    bool showButtonsInCard,
    bool isDesktop,
    bool isTablet,
    double screenWidth,
  ) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: Image (only if we should show it)
          if (shouldShowImage)
            Container(
              width: leftImageSize,
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
                ),
              ),
            ),
          
          // Right: Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 24 : isTablet ? 16 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (only for larger screens)
                  if (isDesktop || isTablet)
                    Text(
                      l10n.emptyProjectTitle,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontFamily: 'CascadiaCode',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  
                  if (isDesktop || isTablet) 
                    const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    l10n.emptyProjectDescription,
                    style: TextStyle(
                      fontSize: descriptionFontSize,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.normal,
                      color: Colors.white70,
                    ),
                  ),
                  
                  // Buttons (only for larger screens)
                  if (showButtonsInCard) ...[
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
    );
  }
  
  Widget _buildColumnLayout(
    BuildContext context,
    AppLocalizations l10n,
    double imageSize,
    bool shouldShowImage,
    double titleFontSize,
    double descriptionFontSize,
    bool showButtonsInCard,
    double screenWidth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image at the top (if we should show it)
        if (shouldShowImage)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              'assets/images/start_first_project.png',
              height: imageSize,
              fit: BoxFit.cover,
            ),
          ),
        
        // Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              Text(
                l10n.emptyProjectDescription,
                style: TextStyle(
                  fontSize: descriptionFontSize,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.normal,
                  color: Colors.white70,
                ),
              ),
              
              // Buttons (if they should be inside the card)
              if (showButtonsInCard) ...[
                const SizedBox(height: 16),
                ProjectActionButtons(
                  onCreate: onCreateNewProject,
                  onImport: onImportFromDataset,
                  screenWidth: screenWidth,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
