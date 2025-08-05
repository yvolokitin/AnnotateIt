import 'package:flutter/material.dart';
import '../gen_l10n/app_localizations.dart';
import '../widgets/responsive/responsive_layout.dart';
import '../widgets/responsive/responsive_text.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});
  
  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return 'v${info.version} (Build ${info.buildNumber})';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ResponsiveLayout.builder(
      builder: (context, constraints, screenSize) {
        return Container(
          color: Colors.grey[800],
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.topLeft,
          child: Padding(
            padding: ResponsiveLayout.getPadding(context),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  ResponsiveText(
                    l10n.aboutTitle,
                    maxSize: 26,
                    minSize: 16,
                    fontWeight: FontWeight.bold,
                    themeStyle: 'titleLarge',
                  ),
                  SizedBox(
                    height: ResponsiveLayout.value<double>(
                      context: context,
                      mobile: 12,
                      desktop: 24,
                    ),
                  ),
                  ResponsiveText(
                    l10n.aboutDescription,
                    maxSize: 22,
                    minSize: 16,
                    themeStyle: 'bodyLarge',
                  ),
                  const SizedBox(height: 30),
                  ResponsiveText(
                    l10n.aboutFeaturesTitle,
                    maxSize: 22,
                    minSize: 16,
                    fontWeight: FontWeight.bold,
                    themeStyle: 'titleMedium',
                  ),
                  SizedBox(
                    height: ResponsiveLayout.value<double>(
                      context: context,
                      mobile: 12,
                      desktop: 24,
                    ),
                  ),
                  ResponsiveText(
                    l10n.aboutFeatures,
                    maxSize: 22,
                    minSize: 16,
                    themeStyle: 'bodyLarge',
                  ),
                  const SizedBox(height: 35),
                  ResponsiveText(
                    l10n.aboutCallToAction,
                    maxSize: 24,
                    minSize: 16,
                    fontWeight: FontWeight.bold,
                    style: TextStyle(
                      fontFamily: 'CascadiaCode',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 40),

                  FutureBuilder<String>(
                    future: getAppVersion(),
                    builder: (context, snapshot) {
                      final versionText = snapshot.hasData
                          ? 'Version: ${snapshot.data}'
                          : 'Loading version...';

                      return ResponsiveText(
                        versionText,
                        maxSize: 16,
                        minSize: 12,
                        style: TextStyle(
                          fontFamily: 'CascadiaCode',
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
/*
                  ResponsiveText(
                    'Version: $appVersion',
                    maxSize: 16,
                    minSize: 12,
                    style: TextStyle(
                      fontFamily: 'CascadiaCode',
                      color: Colors.grey[400],
                    ),
                  ),
*/                  
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
