import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';

class ModelCardCommingSoon extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String imageAsset;

  const ModelCardCommingSoon({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final radius = BorderRadius.circular(16);
    const disabledTextColor = Colors.white70;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: Colors.grey[700]!,
          width: 2,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 900;
          final h = constraints.maxHeight;
          final compact = h <= 120;
          final leftWidth = constraints.maxWidth * (isNarrow ? 0.40 : 0.35);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: leftWidth,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Ink.image(
                      image: AssetImage(imageAsset),
                      fit: BoxFit.cover,
                      child: const SizedBox.expand(),
                    ),
                    const ColoredBox(color: Color(0x80000000)),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isNarrow ? 12 : 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: (compact
                                ? Theme.of(context).textTheme.titleSmall
                                : (isNarrow
                                    ? Theme.of(context).textTheme.titleMedium
                                    : Theme.of(context).textTheme.titleLarge))
                            ?.copyWith(color: disabledTextColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: disabledTextColor),
                          maxLines: compact ? 1 : (isNarrow ? 2 : 3),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: compact ? 6 : 10),
                      Row(
                        children: [
                          const Icon(Icons.hourglass_empty, color: disabledTextColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.modelComingSoon,
                              style: (compact
                                      ? Theme.of(context).textTheme.bodySmall
                                      : Theme.of(context).textTheme.bodyMedium)
                                  ?.copyWith(color: disabledTextColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
