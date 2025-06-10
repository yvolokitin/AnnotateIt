import 'package:flutter/material.dart';
import '../../models/user.dart';

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
    final isWide = MediaQuery.of(context).size.width > 800;
    final isTablet = MediaQuery.of(context).size.width > 500;

    return Container(
      color: Colors.grey[800],
      child: SingleChildScrollView(
        padding: isWide ? const EdgeInsets.all(24) : const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('General Settings', [
              _buildCountrySelection(context, isWide, isTablet),
              _buildThemeSelection(),
            ], isWide),

            _buildSection('Project Creation', [
              _buildSwitchWithNote(
                title: 'Always ask to confirm when create a project with no labels',
                value: user.projectShowNoLabels ?? true,
                onChanged: (val) => onUserChange(user.copyWith(projectShowNoLabels: val)),
                note: 'You’ll be warned if you try to create a project without any labels defined.',
              ),
            ], isWide),

            _buildSection('Dataset View', [
              _buildSwitchWithNote(
                title: 'Duplicate (make a copy) image always with annotations',
                value: user.datasetEnableDuplicate ?? true,
                onChanged: (val) => onUserChange(user.copyWith(datasetEnableDuplicate: val)),
                note: 'When duplicating, annotations will be included unless you change settings.',
              ),
              _buildSwitchWithNote(
                title: 'When delete image from Dataset, always delete it from OS / file system',
                value: user.datasetEnableDelete ?? true,
                onChanged: (val) => onUserChange(user.copyWith(datasetEnableDelete: val)),
                note: 'Deletes the file from disk too, not just from the dataset.',
              ),
            ], isWide),

            _buildSection('Annotation Settings', [
              _buildSliderWithButtons(
                'Annotation opacity',
                user.annotationOpacity ?? 0.35,
                (val) => onUserChange(user.copyWith(annotationOpacity: val)),
              ),
              _buildSwitch(
                'Always Save or Submit annotation when move to the next image',
                user.annotationAllowImageCopy ?? true,
                (val) => onUserChange(user.copyWith(annotationAllowImageCopy: val)),
              ),
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
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          ...children.map((child) => Padding(padding: padding, child: child)).toList(),
        ],
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 20, color: Colors.white70)),
      value: value,
      onChanged: onChanged,
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
          padding: const EdgeInsets.only(left: 16, bottom: 12),
          child: Text(note, style: const TextStyle(fontSize: 16, color: Colors.white60)),
        ),
      ],
    );
  }

  Widget _buildSliderWithButtons(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (value > 0.01) onChanged((value - 0.01).clamp(0.0, 1.0));
              },
              icon: const Icon(Icons.remove, color: Colors.white70),
            ),
            Expanded(
              child: Slider(
                value: value,
                onChanged: onChanged,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                label: '${(value * 100).toStringAsFixed(0)}%',
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

  Widget _buildThemeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Theme selection',
          style: TextStyle(fontSize: 20, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Row(
          children: ['light', 'dark', 'system'].map((mode) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onUserChange(user.copyWith(themeMode: mode)),
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
      'en': 'English 🇬🇧',
      'es': 'Spanish 🇪🇸',
      'fr': 'French 🇫🇷',
      'de': 'German 🇩🇪',
      'it': 'Italian 🇮🇹',
      'pt': 'Portuguese 🇵🇹',
      'nl': 'Dutch 🇳🇱',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Country / Language',
          style: TextStyle(fontSize: 20, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: countryNames.entries.map((entry) {
            final code = entry.key;
            final label = entry.value;
            final isSelected = user.language == code;

            return SizedBox(
              width: isWide ? 160 : (isTablet ? 130 : double.infinity),
              child: GestureDetector(
                onTap: () => onUserChange(user.copyWith(language: code)),
                child: Card(
                  color: isSelected ? Colors.amber : Colors.grey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                    child: Center(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
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
}
