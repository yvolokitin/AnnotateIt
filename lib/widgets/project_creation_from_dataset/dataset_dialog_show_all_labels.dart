import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class ShowAllLabelsDialog extends StatelessWidget {
  final List<String> labels;

  const ShowAllLabelsDialog({super.key, required this.labels});

  @override
  Widget build(BuildContext context) {
    final sortedLabels = List<String>.from(labels)..sort();
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        l10n.allLabels,
        style: const TextStyle(color: Colors.white),
      ),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: sortedLabels
                .map((label) => Chip(
                      label: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'CascadiaCode',
                        ),
                      ),
                      backgroundColor: Colors.redAccent,
                    ))
                .toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.buttonClose,
            style: const TextStyle(
              color: Colors.redAccent,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ),
      ],
    );
  }
}
