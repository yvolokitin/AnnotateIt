import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class AnnotationsSettingsDialog extends StatefulWidget {
  final double initialOpacity;
  final double initialStrokeWidth;
  final double initialCornerSize;
  final void Function(double opacity, double strokeWidth, double cornerSize) onSettingsChanged;

  const AnnotationsSettingsDialog({
    super.key,
    required this.initialOpacity,
    required this.initialStrokeWidth,
    required this.initialCornerSize,
    required this.onSettingsChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required double initialOpacity,
    required double initialStrokeWidth,
    required double initialCornerSize,
    required void Function(double, double, double) onSettingsChanged,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AnnotationsSettingsDialog(
        initialOpacity: initialOpacity,
        initialStrokeWidth: initialStrokeWidth,
        initialCornerSize: initialCornerSize,
        onSettingsChanged: onSettingsChanged,
      ),
    );
  }

  @override
  State<AnnotationsSettingsDialog> createState() => _AnnotationsSettingsDialogState();
}

class _AnnotationsSettingsDialogState extends State<AnnotationsSettingsDialog> {
  late double _opacity;
  late double _strokeWidth;
  late double _cornerSize;

  @override
  void initState() {
    super.initState();
    _opacity = widget.initialOpacity;
    _strokeWidth = widget.initialStrokeWidth;
    _cornerSize = widget.initialCornerSize;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final isLargeScreen = screenWidth >= 1200;

        final dialogWidth = screenWidth * (isLargeScreen ? 0.9 : 1.0);
        final dialogHeight = screenHeight * (isLargeScreen ? 0.9 : 1.0);
        final padding = EdgeInsets.all(isLargeScreen ? 40.0 : 20.0);

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
                  _buildTitleBar(l10n),
                  const Divider(color: Colors.orangeAccent),
                  Expanded(child: _buildSliders()),
                  _buildBottomButtons(l10n),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleBar(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.settings, size: 32, color: Colors.orangeAccent),
            SizedBox(width: 12),
            Text(
              'Annotation Settings',
              style: TextStyle(
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
    );
  }

  Widget _buildSliders() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSlider(
            label: 'Opacity',
            value: _opacity,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            labelFormatter: (v) => '${(v * 100).round()}%',
            onChanged: (v) => setState(() => _opacity = v),
          ),
          const SizedBox(height: 24),
          _buildSlider(
            label: 'Border Width',
            value: _strokeWidth,
            min: 1.0,
            max: 40.0,
            divisions: 10,
            onChanged: (v) => setState(() => _strokeWidth = v),
          ),
          const SizedBox(height: 24),
          _buildSlider(
            label: 'Corner Size',
            value: _cornerSize,
            min: 2.0,
            max: 40.0,
            divisions: 12,
            onChanged: (v) => setState(() => _cornerSize = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    String Function(double)? labelFormatter,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${labelFormatter != null ? labelFormatter(value) : value.toStringAsFixed(1)}',
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'CascadiaCode',
            fontSize: 20,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Colors.orangeAccent,
          inactiveColor: Colors.grey[600],
          label: labelFormatter?.call(value),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildBottomButtons(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
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
            widget.onSettingsChanged(_opacity, _strokeWidth, _cornerSize);
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
