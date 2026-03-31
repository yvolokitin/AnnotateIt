import 'package:flutter/material.dart';

import '../models/ai_result_envelope.dart';
import '../services/inference_routing_policy.dart';

/// Compact UI widget for manually overriding the inference backend.
///
/// Displays the current routing decision with its reason, and lets
/// the user pick a specific backend or revert to automatic routing.
class InferenceBackendSelector extends StatelessWidget {
  /// Current override value (`null` = automatic).
  final AiBackendType? currentOverride;

  /// The most recent routing decision (for displaying reason text).
  final RoutingDecision? currentDecision;

  /// Called when the user selects a backend or reverts to auto.
  final ValueChanged<AiBackendType?> onChanged;

  /// Which backends are available (controls which chips are enabled).
  final BackendAvailability availability;

  const InferenceBackendSelector({
    super.key,
    required this.currentOverride,
    required this.onChanged,
    this.currentDecision,
    this.availability = const BackendAvailability(),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.route, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Inference Backend',
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildChip(
              context,
              label: 'Auto',
              icon: Icons.auto_awesome,
              isSelected: currentOverride == null,
              onSelected: (_) => onChanged(null),
            ),
            _buildChip(
              context,
              label: 'Local',
              icon: Icons.smartphone,
              isSelected: currentOverride == AiBackendType.local,
              enabled: availability.localAvailable,
              onSelected: (_) => onChanged(AiBackendType.local),
            ),
            _buildChip(
              context,
              label: 'On-Prem',
              icon: Icons.dns,
              isSelected: currentOverride == AiBackendType.onprem,
              enabled: availability.onpremAvailable,
              onSelected: (_) => onChanged(AiBackendType.onprem),
            ),
            _buildChip(
              context,
              label: 'Cloud',
              icon: Icons.cloud,
              isSelected: currentOverride == AiBackendType.external,
              enabled: availability.externalAvailable,
              onSelected: (_) => onChanged(AiBackendType.external),
            ),
          ],
        ),
        if (currentDecision != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                currentDecision!.isUserOverride
                    ? Icons.person
                    : Icons.auto_fix_high,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  currentDecision!.reason,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    bool enabled = true,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      selected: isSelected,
      onSelected: enabled ? onSelected : null,
      tooltip: enabled ? null : '$label backend is not available',
    );
  }
}
