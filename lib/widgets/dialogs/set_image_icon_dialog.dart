import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../models/media_item.dart';

class SetImageIconDialog extends StatelessWidget {
  final MediaItem media;
  final VoidCallback onConfirmed;

  const SetImageIconDialog({
    super.key,
    required this.media,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final borderColor = Colors.redAccent;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.setAsProjectIcon),
          const SizedBox(height: 8),
          const Divider(thickness: 1, color: Colors.white24),
        ],
      ),
      content: Text(
        l10n.setAsProjectIconConfirm(media.filePath),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: borderColor, width: 2),
            ),
          ),
          onPressed: () {
            onConfirmed();
            Navigator.pop(context);
          },
          child: Text(
            l10n.setAsProjectIcon,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              ),
          ),
        ),
      ],
    );
  }
}
