import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../main.dart';
import '../../services/file_logger.dart';

class ApplicationSettings extends StatelessWidget {
  final User user;
  final Function(User) onUserChange;

  const ApplicationSettings({
    super.key,
    required this.user,
    required this.onUserChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 800;
    final isTablet = MediaQuery.of(context).size.width > 500;

    return Container(
      color: Colors.grey[800],
      child: SingleChildScrollView(
        padding: isWide ? const EdgeInsets.all(24) : const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(l10n.settingsGeneralTitle, [
              _buildCountrySelection(context, isWide, isTablet),
              /// theme selection does not work yet
              /// _buildThemeSelection(context),
            ], isWide),

            _buildSection(l10n.settingsProjectCreationTitle, [
              _buildSwitchWithNote(
                title: l10n.settingsProjectCreationConfirmNoLabels,
                value: user.projectShowNoLabels,
                onChanged: (val) => onUserChange(user.copyWith(projectShowNoLabels: val)),
                note: l10n.settingsProjectCreationConfirmNoLabelsNote,
              ),
              _buildSwitchWithNote(
                title: "Show Import Warning Dialog",
                value: user.projectShowImportWarning,
                onChanged: (val) => onUserChange(user.copyWith(projectShowImportWarning: val)),
                note: "When enabled, shows a warning dialog when toggling 'Allow Project Type Change' during dataset import",
              ),
            ], isWide),

            _buildSection(l10n.settingsDatasetViewTitle, [
              _buildSwitchWithNote(
                title: l10n.settingsDatasetViewDuplicateWithAnnotations,
                value: user.datasetEnableDuplicate,
                onChanged: (val) => onUserChange(user.copyWith(datasetEnableDuplicate: val)),
                note: l10n.settingsDatasetViewDuplicateWithAnnotationsNote,
              ),
              _buildSwitchWithNote(
                title: l10n.settingsDatasetViewDeleteFromOS,
                value: user.datasetEnableDelete,
                onChanged: (val) => onUserChange(user.copyWith(datasetEnableDelete: val)),
                note: l10n.settingsDatasetViewDeleteFromOSNote,
              ),
            ], isWide),

            _buildSection(l10n.settingsLabelsCreationDeletionTitle, [
              _buildSwitchWithNote(
                title: l10n.settingsLabelsSetDefaultLabel,
                value: user.labelsSetFirstAsDefault,
                onChanged: (val) => onUserChange(user.copyWith(labelsSetFirstAsDefault: val)),
                note: l10n.settingsLabelsSetDefaultLabelNote,
              ),
              _buildSwitchWithNote(
                title: l10n.settingsLabelsDeletionWithAnnotations,
                value: user.labelsDeleteAnnotations,
                onChanged: (val) => onUserChange(user.copyWith(labelsDeleteAnnotations: val)),
                note: l10n.settingsLabelsDeletionWithAnnotationsNote,
              ),
            ], isWide),

            _buildSection(l10n.settingsAnnotationTitle, [
              _buildSliderWithButtons(
                context,
                l10n.settingsAnnotationOpacity,
                user.annotationOpacity,
                (val) => onUserChange(user.copyWith(annotationOpacity: val)),
              ),
              _buildSwitch(
                l10n.settingsAnnotationAutoSave,
                user.annotationAllowImageCopy,
                (val) => onUserChange(user.copyWith(annotationAllowImageCopy: val)),
              ),
            ], isWide),

            _buildSection("Storage", [
              _buildLogFileLink(context),
            ], isWide),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isWide) {
    final padding = isWide ? const EdgeInsets.all(18) : const EdgeInsets.all(8);
    final titlePadding = isWide ? const EdgeInsets.only(left: 18, top: 10) : const EdgeInsets.only(left: 8, top: 5);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: titlePadding,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontFamily: 'CascadiaCode',
                color: Colors.white,
              ),
            ),
          ),
          ...children.map((child) => Padding(padding: padding, child: child)).toList(),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    const redThumb = Colors.amber; // Color(0xFFFF0000);
    const redTrack = Color(0x33FFC107); // Color(0x3FFF0000);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.normal,
              color: Colors.white70,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return redThumb;
            return Colors.grey;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return redTrack;
            return Colors.grey.shade700;
          }),
        ),
      ],
    );
  }

  Widget _buildSwitchWithNote({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required String note,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSwitch(title, value, onChanged),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            note,
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'CascadiaCode',
              color: Colors.white60,
            ),
          ),
        ),
      ],
    );
  }

Widget _buildSliderWithButtons(BuildContext context, String label, double value, ValueChanged<double> onChanged) {
  const redColor = Colors.amber; // Color(0xFFFF0000); // solid red
  const redColor30 = Color(0x4DFFC107); // Color(0x4DFF0000); // 30% opacity
  const redColor20 = Color(0x33FFC107); // Color(0x33FF0000); // 20% opacity

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'CascadiaCode',
        ),
      ),
      Row(
        children: [
          IconButton(
            onPressed: () {
              if (value > 0.01) onChanged((value - 0.01).clamp(0.0, 1.0));
            },
            icon: const Icon(Icons.remove, color: Colors.white70),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: redColor,
                inactiveTrackColor: redColor30,
                thumbColor: redColor,
                overlayColor: redColor20,
                valueIndicatorColor: redColor,
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                label: '${(value * 100).toStringAsFixed(0)}%',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (value < 0.99) onChanged((value + 0.01).clamp(0.0, 1.0));
            },
            icon: const Icon(Icons.add, color: Colors.white70),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildThemeSelection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsThemeTitle,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'CascadiaCode',
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['light', 'dark', 'system'].map((mode) {
            /// only Dark mode is implemented across whole application
            final isDisabled = mode != 'dark';
            final isSelected = user.themeMode == mode;

            return Expanded(
              child: GestureDetector(
                //onTap: () => onUserChange(user.copyWith(themeMode: mode)),
                onTap: isDisabled
                  ? null // Prevent tap
                  : () => onUserChange(user.copyWith(themeMode: mode)),
                child: Card(
                  color: user.themeMode == mode ? Colors.amber : Colors.grey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        mode.toUpperCase(),
                        style: TextStyle(
                          color: user.themeMode == mode ? Colors.black : Colors.white70,
                          fontWeight: user.themeMode == mode ? FontWeight.bold : FontWeight.normal,
                          fontFamily: 'CascadiaCode',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCountrySelection(BuildContext context, bool isWide, bool isTablet) {
    final countryNames = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'nl': 'Dutch',
      'ru': 'Russian',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.settingsLanguageTitle,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'CascadiaCode',
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: countryNames.entries.map((entry) {
            final code = entry.key;
            final fullName = entry.value;
            final label = isWide
                ? fullName
                : (isTablet ? code.toUpperCase() : fullName);
            final isSelected = user.language == code;

            return SizedBox(
              width: isWide ? 160 : (isTablet ? 130 : double.infinity),
              child: GestureDetector(
                onTap: () {
                  // Update the user's language preference
                  onUserChange(user.copyWith(language: code));
                  
                  // Update the app's locale to reflect the language change
                  // This will trigger a rebuild of the MaterialApp with the new locale
                  if (AnnotateItApp.instance != null) {
                    AnnotateItApp.instance!.updateLocale();
                  }
                },
                child: Card(
                  color: isSelected ? Colors.amber : Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    child: Center(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'CascadiaCode',
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLogFileLink(BuildContext context) {
    final logFilePath = FileLogger.instance.logFilePath;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Application Log File',
          style: const TextStyle(
            fontSize: 20,
            fontFamily: 'CascadiaCode',
            fontWeight: FontWeight.normal,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        if (logFilePath != null) ...[
          GestureDetector(
            onTap: () async {
              try {
                await FileLogger.instance.openLogFileLocation();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to open log file location: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.folder_open,
                    color: Colors.amber,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      logFilePath,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'CascadiaCode',
                        color: Colors.amber,
                        decoration: TextDecoration.underline,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new,
                    color: Colors.amber,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Click to open the folder containing the application log file. This file contains all app logs including potential crashes.',
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'CascadiaCode',
              color: Colors.white60,
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Log file not available',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'CascadiaCode',
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The application log file could not be initialized. Check file permissions.',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'CascadiaCode',
              color: Colors.white60,
            ),
          ),
        ],
      ],
    );
  }
}
