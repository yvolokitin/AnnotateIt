import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../session/user_session.dart';

class DatasetImportProjectTypeHelper extends StatefulWidget {
  const DatasetImportProjectTypeHelper({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const DatasetImportProjectTypeHelper(),
    );
  }

  @override
  State<DatasetImportProjectTypeHelper> createState() => _DatasetImportProjectTypeHelperState();
}

class _DatasetImportProjectTypeHelperState extends State<DatasetImportProjectTypeHelper> {
  bool _dontAskAgain = false;

  Future<void> _handleClose() async {
    if (_dontAskAgain) {
      await UserSession.instance.setProjectShowImportWarning(false);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Build the content message with all sections
    final message = '''${l10n.projectTypeWhyDisabledTitle}

${l10n.projectTypeWhyDisabledBody}

${l10n.projectTypeAllowChangeTitle}

${l10n.projectTypeAllowChangeBody}

${l10n.projectTypeWhenUseTitle}

${l10n.projectTypeWhenUseBody}''';

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final isLargeScreen = screenWidth >= 1200;

        final dialogWidth = screenWidth * (isLargeScreen ? 0.9 : 1.0);
        final dialogHeight = screenHeight * (isLargeScreen ? 0.9 : 1.0);
        final padding = EdgeInsets.all(isLargeScreen ? 40.0 : 20.0);
        final titleFontSize = screenWidth > 700 ? 24.0 : 20.0;
        final bodyFontSize = screenWidth > 700 ? 22.0 : 18.0;

        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.orangeAccent, width: 1),
          ),
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleBar(context, l10n, titleFontSize),
                  const Divider(color: Colors.orangeAccent),
                  Expanded(child: _buildContent(message, bodyFontSize)),
                  const Divider(color: Colors.orangeAccent),
                  _buildCheckboxSection(l10n, bodyFontSize),
                  _buildBottomButton(context, l10n, bodyFontSize),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleBar(BuildContext context, AppLocalizations l10n, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, size: 32, color: Colors.orangeAccent),
            const SizedBox(width: 12),
            Text(
              l10n.projectTypeHelpTitle,
              style: TextStyle(
                color: Colors.orangeAccent,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.orangeAccent),
          tooltip: l10n.buttonClose,
          onPressed: _handleClose,
        ),
      ],
    );
  }

  Widget _buildContent(String message, double fontSize) {
    return SingleChildScrollView(
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white70,
          fontFamily: 'CascadiaCode',
          fontWeight: FontWeight.normal,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildCheckboxSection(AppLocalizations l10n, double fontSize) {
    return CheckboxListTile(
      value: _dontAskAgain,
      onChanged: (val) => setState(() => _dontAskAgain = val ?? false),
      title: Text(
        l10n.deleteProjectOptionDontAskAgain,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'CascadiaCode',
          fontWeight: FontWeight.normal,
          fontSize: fontSize,
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: Colors.orangeAccent,
    );
  }

  Widget _buildBottomButton(BuildContext context, AppLocalizations l10n, double fontSize) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: _handleClose,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.orangeAccent, width: 2),
          ),
        ),
        child: Text(
          l10n.buttonClose,
          style: TextStyle(
            color: Colors.orangeAccent,
            fontFamily: 'CascadiaCode',
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
