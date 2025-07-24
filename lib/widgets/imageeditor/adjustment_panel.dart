import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class AdjustmentPanel extends StatefulWidget {
  final double initialBrightness;
  final double initialContrast;
  final Function(double brightness, double contrast) onApply;
  final VoidCallback onCancel;
  final bool isBrightnessMode; // true for brightness, false for contrast

  const AdjustmentPanel({
    Key? key,
    required this.initialBrightness,
    required this.initialContrast,
    required this.onApply,
    required this.onCancel,
    required this.isBrightnessMode,
  }) : super(key: key);

  @override
  State<AdjustmentPanel> createState() => _AdjustmentPanelState();
}

class _AdjustmentPanelState extends State<AdjustmentPanel> {
  late double _brightness;
  late double _contrast;

  @override
  void initState() {
    super.initState();
    _brightness = widget.initialBrightness;
    _contrast = widget.initialContrast;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      width: 300, // Fixed width to prevent layout issues
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isBrightnessMode ? 'Adjust Brightness' : 'Adjust Contrast',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.isBrightnessMode) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.brightness_low, color: Colors.white70),
                SizedBox(
                  width: 200, // Fixed width for the slider
                  child: Slider(
                    value: _brightness,
                    min: -1.0,
                    max: 1.0,
                    divisions: 100,
                    label: _brightness.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        _brightness = value;
                      });
                    },
                  ),
                ),
                const Icon(Icons.brightness_high, color: Colors.white70),
              ],
            ),
          ] else ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.contrast, color: Colors.white70),
                SizedBox(
                  width: 200, // Fixed width for the slider
                  child: Slider(
                    value: _contrast,
                    min: 0.0,
                    max: 2.0,
                    divisions: 100,
                    label: _contrast.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        _contrast = value;
                      });
                    },
                  ),
                ),
                const Icon(Icons.contrast_outlined, color: Colors.white70),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: widget.onCancel,
                child: Text(l10n.buttonCancel),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => widget.onApply(_brightness, _contrast),
                child: Text(l10n.buttonApply),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}