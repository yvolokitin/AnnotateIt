import 'package:flutter/material.dart';

import '../../gen_l10n/app_localizations.dart';
import '../../utils/sam_model_utils.dart';

class SamModelSelectionResult {
  final String modelKey;
  final bool remember;
  SamModelSelectionResult({required this.modelKey, required this.remember});
}

class SamModelSelectorDialog extends StatefulWidget {
  final String initialSelectedKey; // 'mobile' or 'sam2_hiera_base_plus'
  final bool initialRemember;

  const SamModelSelectorDialog({super.key, required this.initialSelectedKey, required this.initialRemember});

  static Future<SamModelSelectionResult?> show(BuildContext context, {
    required String initialSelectedKey,
    required bool initialRemember,
  }) {
    return showDialog<SamModelSelectionResult>(
      context: context,
      builder: (_) => SamModelSelectorDialog(
        initialSelectedKey: initialSelectedKey,
        initialRemember: initialRemember,
      ),
    );
  }

  @override
  State<SamModelSelectorDialog> createState() => _SamModelSelectorDialogState();
}

class _SamModelSelectorDialogState extends State<SamModelSelectorDialog> {
  late String _selectedKey;
  late bool _remember;

  @override
  void initState() {
    super.initState();
    _selectedKey = widget.initialSelectedKey;
    _remember = widget.initialRemember;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.orangeAccent, width: 1),
      ),
      title: Row(
        children: [
          Icon(
            Icons.memory,
            size: (screenWidth > 1200) ? 34 : 26,
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 12),
          Text(
            '${l10n.toolbarSAM} Model',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
              fontSize: (screenWidth > 1200) ? 26 : 20,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.orangeAccent),
          Padding(
            padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<List<String>>(
                  future: SamModelUtils.availableKeysWithMobile(),
                  builder: (context, snapshot) {
                    final keys = snapshot.data ?? const ['mobile'];
                    final tiles = <Widget>[];
                    if (keys.contains('sam2_hiera_large')) {
                      tiles.add(_buildRadioTile(title: 'Segment Anything 2 (Hiera-Large)', value: 'sam2_hiera_large'));
                    }
                    if (keys.contains('sam2_hiera_base_plus')) {
                      tiles.add(_buildRadioTile(title: 'Segment Anything 2 (Hiera-Base+)', value: 'sam2_hiera_base_plus'));
                    }
                    tiles.add(_buildRadioTile(title: 'SAM Mobile', value: 'mobile'));
                    return Column(mainAxisSize: MainAxisSize.min, children: tiles);
                  },
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.orangeAccent,
                  checkColor: Colors.black,
                  title: Text(
                    'Remember my choice and do not ask anymore',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.normal,
                      fontSize: (screenWidth > 1200) ? 20 : 18,
                    ),
                  ),
                  subtitle: Text(
                    'You can change this later in User settings',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.normal,
                      fontSize: (screenWidth > 1200) ? 18 : 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(null),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.buttonCancel,
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'CascadiaCode',
                  fontSize: (screenWidth > 1200) ? 22 : 20,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(
                  SamModelSelectionResult(modelKey: _selectedKey, remember: _remember),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.orangeAccent, width: 2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.buttonConfirm,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                      fontSize: (screenWidth > 1200) ? 22 : 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioTile({required String title, required String value}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSelected = _selectedKey == value;
    return RadioListTile<String>(
      activeColor: Colors.orangeAccent,
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth > 1200 ? 12 : 6,
        vertical: 6,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.normal,
                fontSize: (screenWidth > 1200) ? 20 : 18,
              ),
            ),
          ),
          if (isSelected) const Icon(Icons.check, color: Colors.orangeAccent),
        ],
      ),
      value: value,
      groupValue: _selectedKey,
      onChanged: (v) => setState(() => _selectedKey = v ?? _selectedKey),
    );
  }
}
