import 'package:flutter/material.dart';
import '../gen_l10n/app_localizations.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.grey[800],
      width: double.infinity,
      height: double.infinity, // Fill vertical space
      alignment: Alignment.topLeft,
      child: Padding(
        padding: (width > 1200) ? const EdgeInsets.all(24) : const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Text(
                l10n.aboutTitle,
                style: TextStyle(
                  fontSize: width>1200 ? 26 : 16,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: width>1200 ? 24 : 12),

              Text(
                l10n.aboutDescription,
                style: TextStyle(
                  fontSize: width>1200 ? 22 : 16,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 30),

              Text(
                l10n.aboutFeaturesTitle,
                style: TextStyle(
                  fontSize: width>1200 ? 22 : 16,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: width>1200 ? 24 : 12),
              Text(
                l10n.aboutFeatures,
                style: TextStyle(
                  fontSize: width>1200 ? 22 : 16,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 35),
              Text(
                l10n.aboutCallToAction,
                style: TextStyle(
                  fontSize: width>1200 ? 24 : 16,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
