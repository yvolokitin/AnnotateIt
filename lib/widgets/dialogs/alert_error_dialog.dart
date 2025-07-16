import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class AlertErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? tips;

  const AlertErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.tips,
  });

  static Future<void> show(
    BuildContext context,
    String title,
    String message, {
    String? tips,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AlertErrorDialog(
        title: title,
        message: message,
        tips: tips,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool showTips = tips != null && tips!.trim().isNotEmpty;

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
                  _buildTitleBar(context, l10n, title, titleFontSize),
                  const Divider(color: Colors.orangeAccent),
                  Expanded(child: _buildContent(bodyFontSize, showTips)),
                  const Divider(color: Colors.orangeAccent),
                  _buildBottomButton(context, l10n, bodyFontSize),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleBar(BuildContext context, AppLocalizations l10n, String title, double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, size: 32, color: Colors.orangeAccent),
            const SizedBox(width: 12),
            Text(
              title,
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
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildContent(double fontSize, bool showTips) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          if (showTips) ...[
            const SizedBox(height: 20),
            Text(
              tips!,
              style: TextStyle(
                color: Colors.white60,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.normal,
                fontSize: fontSize,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, AppLocalizations l10n, double fontSize) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
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
