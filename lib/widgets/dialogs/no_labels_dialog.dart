import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';

import 'alert_error_dialog.dart';
import '../../models/label.dart';
import '../../data/labels_database.dart';
import '../../gen_l10n/app_localizations.dart';

class NoLabelsDialog extends StatelessWidget {
  final int projectId;
  final String projectType;
  final void Function(List<Label>) onLabelsImported;

  const NoLabelsDialog({
    required this.projectId,
    required this.projectType,
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
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final isBinary = projectType.toLowerCase().contains('binary');
    final showWarning = isBinary && labels.length > 2;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.lightGreenAccent, width: 1),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.importLabelsPreviewTitle,
              style: const TextStyle(
                color: Colors.lightGreenAccent,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.bold,
              ),
            ),
            if (showWarning) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent, width: 1),
                ),
                child: const Text(
                  'Only the first 2 labels will be imported for binary classification.',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'CascadiaCode',
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
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
            onPressed: () async {
              try {
                final labelsToImport = showWarning ? labels.take(2).toList() : labels;

                // when projectId > 0: project already exists in the DB, and labels should be saved
                if (projectId > 0) {
                  await LabelsDatabase.instance.updateProjectLabels(projectId, labelsToImport);
                }

                // always notify parent, regardless of projectId
                onLabelsImported(labelsToImport);
                
                // close ONLY import labels preview dialog
                Navigator.pop(context);

              } catch (e) {
                Navigator.pop(context);
                AlertErrorDialog.show(
                  context,
                  l10n.importLabelsFailedTitle,
                  '${l10n.importLabelsDatabaseError} ${e.toString()}',
                  tips: l10n.importLabelsDatabaseErrorTips,
                );
              }
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
      int fallbackOrder = 0;

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
          final map = Map<String, dynamic>.from(item);

          // Validate name
          final name = map['name'];
          if (name == null || name is! String || name.trim().isEmpty) {
            return AlertErrorDialog.show(
              context,
              l10n.importLabelsFailedTitle,
              l10n.importLabelsNameMissingOrEmpty,
              tips: l10n.importLabelsNameMissingOrEmptyTips,
            );
          }

          final int labelOrder = map.containsKey('label_order') && map['label_order'] is int
            ? map['label_order']
            : fallbackOrder++;

          final parsed = Label.fromJsonForImport(map, projectId, labelOrder);
          labels.add(parsed);

        } catch (e) {
          return AlertErrorDialog.show(
            context,
            l10n.importLabelsFailedTitle,
            '${l10n.importLabelsJsonLabelParseError} ${e.toString()}',
            tips: l10n.importLabelsJsonLabelParseTips,
          );
        }
      }

      await _showLabelImportPreviewDialog(context, labels, decoded);
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
