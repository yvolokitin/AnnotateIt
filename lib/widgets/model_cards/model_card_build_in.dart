import 'package:flutter/material.dart';
import '../../gen_l10n/app_localizations.dart';

class ModelCardBuiltIn extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String imageAsset;
  final String modelSize;

  const ModelCardBuiltIn({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.modelSize,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);
    final darkGreen = Colors.lightGreen[900]!;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: darkGreen, width: 2),
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
                child: Ink.image(
                  image: AssetImage(imageAsset),
                  fit: BoxFit.cover,
                  child: const SizedBox.expand(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isNarrow ? 12 : 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: (compact
                                      ? theme.textTheme.titleSmall
                                      : (isNarrow
                                          ? theme.textTheme.titleMedium
                                          : theme.textTheme.titleLarge)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text('${l10n.modelBuildIn}, $modelSize'),
                            backgroundColor: darkGreen,
                            labelStyle: (compact
                                    ? theme.textTheme.labelSmall
                                    : theme.textTheme.labelMedium)
                                ?.copyWith(color: Colors.white),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          description,
                          style: theme.textTheme.bodyMedium,
                          maxLines: compact ? 1 : (isNarrow ? 2 : 3),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(height: compact ? 6 : 10),

                      // Статус всегда внизу
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: darkGreen,
                              size: compact ? 16 : (isNarrow ? 18 : 20)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.modelBuildInAndReady,
                              style: compact
                                  ? theme.textTheme.bodySmall
                                  : theme.textTheme.bodyMedium,
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
