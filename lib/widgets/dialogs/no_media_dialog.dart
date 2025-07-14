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
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (screenWidth >= 800)...[
                    const SizedBox(height: 40),
                  ],

                  Text(
                    l10n.noMediaDialogUploadPrompt,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CascadiaCode',
                      fontSize: 24),
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
                      fontSize: 20,
                      fontFamily: 'CascadiaCode',
                    ),
                  ),
                  Text(
                    l10n.noMediaDialogSupportedImageTypesList,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontFamily: 'CascadiaCode',
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
                        fontSize: 20,
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
