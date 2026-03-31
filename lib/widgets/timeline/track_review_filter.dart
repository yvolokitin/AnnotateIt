import 'package:flutter/material.dart';
import '../../models/annotation_track.dart';

/// Chip-based filter bar for selecting a review status to filter video
/// annotation tracks. Selecting a chip calls [onChanged] with the status
/// string; selecting the already-active chip deselects it (passes `null`).
class TrackReviewFilter extends StatelessWidget {
  final String? selectedStatus;
  final Map<String, int> statusCounts;
  final ValueChanged<String?> onChanged;

  const TrackReviewFilter({
    super.key,
    this.selectedStatus,
    this.statusCounts = const {},
    required this.onChanged,
  });

  static const _statusMeta = <String, _StatusMeta>{
    TrackReviewStatus.draft: _StatusMeta(
      label: 'Draft',
      icon: Icons.edit_outlined,
      color: Color(0xFF90A4AE),
    ),
    TrackReviewStatus.proposed: _StatusMeta(
      label: 'Proposed',
      icon: Icons.rate_review_outlined,
      color: Color(0xFF42A5F5),
    ),
    TrackReviewStatus.accepted: _StatusMeta(
      label: 'Accepted',
      icon: Icons.check_circle_outline,
      color: Color(0xFF66BB6A),
    ),
    TrackReviewStatus.rejected: _StatusMeta(
      label: 'Rejected',
      icon: Icons.cancel_outlined,
      color: Color(0xFFEF5350),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _statusMeta.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final entry = _statusMeta.entries.elementAt(index);
          final status = entry.key;
          final meta = entry.value;
          final count = statusCounts[status] ?? 0;
          final selected = selectedStatus == status;

          return FilterChip(
            avatar: Icon(meta.icon, size: 16, color: meta.color),
            label: Text(
              count > 0 ? '${meta.label} ($count)' : meta.label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : Colors.white70,
              ),
            ),
            selected: selected,
            selectedColor: meta.color.withValues(alpha: 0.3),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            checkmarkColor: meta.color,
            side: BorderSide(
              color: selected
                  ? meta.color.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
            ),
            onSelected: (_) => onChanged(selected ? null : status),
          );
        },
      ),
    );
  }
}

class _StatusMeta {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusMeta({
    required this.label,
    required this.icon,
    required this.color,
  });
}
