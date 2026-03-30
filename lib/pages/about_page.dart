import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../gen_l10n/app_localizations.dart';
import '../widgets/responsive/responsive_layout.dart';
import '../widgets/responsive/responsive_text.dart';
import '../widgets/animated/responsive_flying_words_text.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutWidget extends StatelessWidget {
  const AboutWidget({super.key});

  static const String _privacyPolicyUrl = 'https://annotateit.ai/privacy';

  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return 'v${info.version} (Build ${info.buildNumber})';
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(_privacyPolicyUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                  ResponsiveFlyingWordsText(
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
                  ResponsiveFlyingWordsText(
                    l10n.aboutDescription,
                    maxSize: 22,
                    minSize: 16,
                    themeStyle: 'bodyLarge',
                  ),
                  const SizedBox(height: 30),
                  ResponsiveFlyingWordsText(
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
                  ResponsiveFlyingWordsText(
                    l10n.aboutFeatures,
                    maxSize: 22,
                    minSize: 16,
                    themeStyle: 'bodyLarge',
                  ),
                  const SizedBox(height: 35),
                  ResponsiveFlyingWordsText(
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
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _openPrivacyPolicy,
                    child: ResponsiveText(
                      'Privacy Policy',
                      maxSize: 16,
                      minSize: 12,
                      style: TextStyle(
                        fontFamily: 'CascadiaCode',
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
