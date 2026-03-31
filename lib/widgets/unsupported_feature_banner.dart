import 'package:flutter/material.dart';

import '../services/feature_gate.dart';

/// A banner / placeholder widget shown when a feature is not available
/// on the current platform.
///
/// Use this as a drop-in replacement wherever a feature-gated widget
/// would normally appear:
///
/// ```dart
/// if (FeatureGate.instance.isEnabled(AppFeature.videoTimeline))
///   VideoTimeline(...)
/// else
///   UnsupportedFeatureBanner(feature: AppFeature.videoTimeline)
/// ```
class UnsupportedFeatureBanner extends StatelessWidget {
  final AppFeature feature;
  final Widget? alternativeAction;

  const UnsupportedFeatureBanner({
    super.key,
    required this.feature,
    this.alternativeAction,
  });

  @override
  Widget build(BuildContext context) {
    final reason = FeatureGate.instance.disabledReason(feature);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.orange.shade300,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _featureLabel(feature),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade200,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (alternativeAction != null) ...[
            const SizedBox(width: 12),
            alternativeAction!,
          ],
        ],
      ),
    );
  }

  static String _featureLabel(AppFeature feature) {
    switch (feature) {
      case AppFeature.videoTimeline:
        return 'Video Timeline';
      case AppFeature.samSegmentation:
        return 'SAM Segmentation';
      case AppFeature.tfliteInference:
        return 'TFLite Inference';
      case AppFeature.mlKitLabeling:
        return 'ML Kit Labeling';
      case AppFeature.dragAndDrop:
        return 'Drag & Drop Import';
      case AppFeature.videoFrameExtraction:
        return 'Video Frame Extraction';
      case AppFeature.exportZip:
        return 'ZIP Export';
      case AppFeature.externalStreamInference:
        return 'External Stream Inference';
    }
  }
}

/// A convenience wrapper that conditionally shows [child] or an
/// [UnsupportedFeatureBanner] based on the current [FeatureGate] state.
class FeatureGuard extends StatelessWidget {
  final AppFeature feature;
  final Widget child;
  final Widget? fallback;

  const FeatureGuard({
    super.key,
    required this.feature,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (FeatureGate.instance.isEnabled(feature)) {
      return child;
    }
    return fallback ?? UnsupportedFeatureBanner(feature: feature);
  }
}
