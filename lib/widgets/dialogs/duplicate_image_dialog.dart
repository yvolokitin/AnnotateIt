import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';
import '../../models/annotated_labeled_media.dart';

class DuplicateImageDialog extends StatefulWidget {
  final AnnotatedLabeledMedia media;
  final void Function(bool withAnnotations, bool saveAsDefault) onConfirmed;

  const DuplicateImageDialog({
    super.key,
    required this.media,
    required this.onConfirmed,
  });

  @override
  State<DuplicateImageDialog> createState() => _DuplicateImageDialogState();
}

class _DuplicateImageDialogState extends State<DuplicateImageDialog> {
  bool _withAnnotations = true;
  bool _saveAsDefault = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 8, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.duplicateImage,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            tooltip: l10n.buttonCancel,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(thickness: 1, color: Colors.white70),
          const SizedBox(height: 25),

          RadioListTile<bool>(
            value: true,
            groupValue: _withAnnotations,
            activeColor: Colors.amber,
            onChanged: (val) => setState(() => _withAnnotations = val!),
            title: Text(
              l10n.duplicateWithAnnotations,
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.normal,
                color: Colors.white
              ),
            ),
            subtitle: Text(
              l10n.duplicateWithAnnotationsHint,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.normal,
                color: Colors.white70
              ),
            ),
          ),
          RadioListTile<bool>(
            value: false,
            groupValue: _withAnnotations,
            activeColor: Colors.amber,
            onChanged: (val) => setState(() => _withAnnotations = val!),
            title: Text(
              l10n.duplicateImageOnly,
              style: const TextStyle(
                fontSize: 22,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.normal,
                color: Colors.white
              ),
            ),
            subtitle: Text(
              l10n.duplicateImageOnlyHint,
              style: const TextStyle(
                fontSize: 20,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.normal,
                color: Colors.white70
              ),
            ),
          ),
          const SizedBox(height: 25), 
          CheckboxListTile(
            value: _saveAsDefault,
            onChanged: (val) => setState(() => _saveAsDefault = val!),
            activeColor: Colors.amber,
            checkColor: Colors.black,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              l10n.saveDuplicateChoiceAsDefault,
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.normal,
                color: Colors.white70,
              ),
            ),
          ),

          const SizedBox(height: 25),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.white70, width: 2),
            ),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.buttonCancel,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 22,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
          onPressed: () {
            widget.onConfirmed(_withAnnotations, _saveAsDefault);
            Navigator.pop(context);
          },
          child: Text(
            l10n.duplicateImage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
