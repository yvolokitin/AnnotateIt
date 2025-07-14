import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class OpacityDialog extends StatefulWidget {
  final double initialOpacity;
  final ValueChanged<double> onOpacityChanged;

  const OpacityDialog({
    super.key,
    required this.initialOpacity,
    required this.onOpacityChanged,
  });

  @override
  State<OpacityDialog> createState() => _OpacityDialogState();

  static Future<void> show(BuildContext context, {
    required double initialOpacity,
    required ValueChanged<double> onOpacityChanged,
  }) {
    return showDialog(
      context: context,
      builder: (context) => OpacityDialog(
        initialOpacity: initialOpacity,
        onOpacityChanged: onOpacityChanged,
      ),
    );
  }
}

class _OpacityDialogState extends State<OpacityDialog> {
  late double _opacity;

  @override
  void initState() {
    super.initState();
    _opacity = widget.initialOpacity;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return AlertDialog(
      backgroundColor: Colors.grey[800],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.orangeAccent, width: 1),
      ),
      titlePadding: const EdgeInsets.only(left: 16, top: 16, right: 8),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.opacity,
                size: 32,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.dialogOpacityTitle,
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 24,
                  fontFamily: 'CascadiaCode',
                  fontWeight: FontWeight.bold,
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
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Colors.orangeAccent),
              Padding(
                padding: EdgeInsets.all(screenWidth > 1600 ? 40.0 : 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dialogOpacityExplanation,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'CascadiaCode',
                        fontWeight: FontWeight.normal,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      value: _opacity,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      activeColor: Colors.orangeAccent,
                      inactiveColor: Colors.grey[600],
                      label: '${(_opacity * 100).round()}%',
                      onChanged: (value) => setState(() => _opacity = value),
                    ),
                    Center(
                      child: Text(
                        '${(_opacity * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 22,
                          fontFamily: 'CascadiaCode',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          ),
          child: Text(
            l10n.buttonCancel,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 22,
              fontFamily: 'CascadiaCode',
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onOpacityChanged(_opacity);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.orangeAccent, width: 2),
            ),
          ),
          child: Text(
            l10n.buttonApply,
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'CascadiaCode',
              fontSize: 22,
            ),
          ),
        ),
      ],
    );
  }
}