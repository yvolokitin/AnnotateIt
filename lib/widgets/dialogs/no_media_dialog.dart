import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../gen_l10n/app_localizations.dart';

import 'alert_error_dialog.dart';

class NoMediaDialog extends StatefulWidget {
  final int projectId;
  final String datasetId;

  const NoMediaDialog({
    required this.projectId,
    required this.datasetId,
    super.key,
  });

  @override
  NoMediaDialogState createState() => NoMediaDialogState();
}

class NoMediaDialogState extends State<NoMediaDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final smallScreen = (screenWidth < 700) || (screenHeight < 750);

    return Container(
      padding: EdgeInsets.all(smallScreen ? 5 : 24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: smallScreen ? 5 : 40),

                  Text(
                    screenWidth>600 ? l10n.noMediaDialogUploadPrompt : l10n.noMediaDialogUploadPromptShort,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CascadiaCode',
                      fontSize: smallScreen ? 20 : 24,
                    ),
                  ),

                  if (screenWidth >= 800)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: SvgPicture.asset(
                          'assets/images/media_upload.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                  Text(
                    l10n.noMediaDialogSupportedImageTypesTitle,
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'CascadiaCode',
                      fontSize: smallScreen ? 16 : 20,
                    ),
                  ),
                  Text(
                    l10n.noMediaDialogSupportedImageTypesList,
                    style: TextStyle(
                      color: Colors.grey,
                      fontFamily: 'CascadiaCode',
                      fontSize: smallScreen ? 16 : 20,
                    ),
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: _showSupportedVideoDialog,
                    child: Text(
                      l10n.noMediaDialogSupportedVideoFormatsLink,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        decoration: TextDecoration.underline,
                        fontFamily: 'CascadiaCode',
                        fontSize: smallScreen ? 16 : 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportedVideoDialog() {
    final l10n = AppLocalizations.of(context)!;
    AlertErrorDialog.show(
      context,
      l10n.noMediaDialogSupportedVideoFormatsTitle,
      l10n.noMediaDialogSupportedVideoFormatsList,
      tips: l10n.noMediaDialogSupportedVideoFormatsWarning,
    );
  }
}
