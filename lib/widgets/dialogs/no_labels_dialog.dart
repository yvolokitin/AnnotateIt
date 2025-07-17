import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class NoLabelsDialog extends StatelessWidget {
  const NoLabelsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: Container(
            padding: EdgeInsets.all(screenWidth > 1150 ? 24 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Text(
                  l10n.noLabelsTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'CascadiaCode',
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth > 1450 ? 24 : 20,
                  ),
                ),
                SizedBox(height: screenWidth > 1450 ? 40 : 10),
                Text(
                  l10n.noLabelsExplain1,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth > 640 ? 18 : 14,
                    fontFamily: 'CascadiaCode',
                  ),
                ),
                Text(
                  l10n.noLabelsExplain2,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth > 640 ? 18 : 14,
                    fontFamily: 'CascadiaCode',
                  ),
                ),
                Text(
                  l10n.noLabelsExplain3,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: screenWidth > 640 ? 18 : 14,
                    fontFamily: 'CascadiaCode',
                  ),
                ),
                SizedBox(
                  height: screenWidth > 1450 ? 300 : (screenWidth > 640) ? 200 : 140,
                  child: Padding(
                    padding: EdgeInsets.all(screenWidth > 1450
                        ? 45
                        : (screenWidth > 640)
                            ? 20
                            : 6),
                    child: Image.asset(
                      'assets/images/no_labels.png',
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ),
                if (screenWidth > 640) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.noLabelsExplain4,
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'CascadiaCode',
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    l10n.noLabelsExplain5,
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'CascadiaCode',
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    l10n.noLabelsExplain6,
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'CascadiaCode',
                      fontSize: 18,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
