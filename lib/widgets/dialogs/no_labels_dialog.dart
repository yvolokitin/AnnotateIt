import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

import '../../gen_l10n/app_localizations.dart';
import '../dialogs/alert_error_dialog.dart';
import '../../models/label.dart';

class NoLabelsDialog extends StatelessWidget {
  final int projectId;
  final void Function(List<Label>) onLabelsImported;

  const NoLabelsDialog({
    required this.projectId,
    required this.onLabelsImported,
    super.key,
  });

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
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () => _importLabelsFromFile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.lightGreenAccent, width: 1),
                    ),
                  ),
                  child: Text(
                    l10n.buttonImportLabels,
                    style: TextStyle(
                      color: Colors.lightGreenAccent,
                      fontSize: screenWidth > 1200 ? 22 : 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'CascadiaCode',
                    ),
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

  Future<void> _showLabelImportPreviewDialog(
    BuildContext context,
    List<Label> labels,
    dynamic rawJson,
    void Function(List<Label>) onConfirmed,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.lightGreenAccent, width: 1),
        ),
        title: Text(
          l10n.importLabelsPreviewTitle,
          style: const TextStyle(
            color: Colors.lightGreenAccent,
            fontFamily: 'CascadiaCode',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: SelectableText(
              const JsonEncoder.withIndent('  ').convert(rawJson),
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'CascadiaCode',
                fontSize: 14,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.buttonCancel,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'CascadiaCode',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirmed(labels);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.lightGreenAccent, width: 1),
              ),
            ),
            child: Text(
              l10n.buttonImport,
              style: const TextStyle(
                color: Colors.lightGreenAccent,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importLabelsFromFile(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return;
    try {
      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      dynamic decoded;
      try {
        decoded = jsonDecode(jsonString);
      } catch (e) {
        return AlertErrorDialog.show(
          context,
          l10n.importLabelsFailedTitle,
          '${l10n.importLabelsJsonParseError} ${e.toString()}',
          tips: l10n.importLabelsJsonParseTips,
        );
      }

      if (decoded is! List) {
        return AlertErrorDialog.show(
          context,
          l10n.importLabelsFailedTitle,
          l10n.importLabelsJsonNotList(decoded.runtimeType),
          tips: l10n.importLabelsJsonNotListTips,
        );
      }

      final List<Label> labels = [];
      for (final item in decoded) {
        if (item is! Map) {
          return AlertErrorDialog.show(
            context,
            l10n.importLabelsFailedTitle,
            l10n.importLabelsJsonItemNotMap(item.runtimeType),
            tips: l10n.importLabelsJsonItemNotMapTips,
          );
        }
        try {
          final label = Label.fromMap(Map<String, dynamic>.from(item));
          labels.add(label);
        } catch (e) {
          return AlertErrorDialog.show(
            context,
            l10n.importLabelsFailedTitle,
            '${l10n.importLabelsJsonLabelParseError} ${e.toString()}',
            tips: l10n.importLabelsJsonLabelParseTips,
          );
        }
      }

      await _showLabelImportPreviewDialog(
        context, labels,
        decoded,
        onLabelsImported,
      );

    } catch (e) {
      await AlertErrorDialog.show(
        context,
        l10n.importLabelsFailedTitle,
        '${l10n.importLabelsUnexpectedError} ${e.toString()}',
        tips: l10n.importLabelsUnexpectedErrorTip,
      );
    }
  }
}
