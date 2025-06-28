import 'package:flutter/material.dart';
import 'package:vap/gen_l10n/app_localizations.dart';

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

    return AlertDialog(
      title: Text(l10n.dialog_opacity_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _opacity,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(_opacity * 100).round()}%',
            onChanged: (value) => setState(() => _opacity = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelButton),
        ),
        TextButton(
          onPressed: () {
            widget.onOpacityChanged(_opacity);
            Navigator.pop(context);
          },
          child: Text(l10n.applyButton),
        ),
      ],
    );
  }
}
