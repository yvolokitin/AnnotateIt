import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

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

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.setAsProjectIcon),
          const SizedBox(height: 8),
          const Divider(thickness: 1, color: Colors.white),
        ],
      ),
      content: Text(
        l10n.setAsProjectIconConfirm(media.filePath),
        style: const TextStyle(
          color: Colors.white70,
          fontFamily: 'CascadiaCode',
          fontWeight: FontWeight.normal,
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Colors.white70, width: 2),
            ),
          ),
          child: Text(
            l10n.buttonCancel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 22,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
              ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
          onPressed: () {
            onConfirmed();
            Navigator.pop(context);
          },
          child: Text(
            l10n.setAsProjectIcon,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'CascadiaCode',
              ),
          ),
        ),
      ],
    );
  }
}
