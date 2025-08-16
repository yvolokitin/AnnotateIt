import 'package:flutter/material.dart';

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
    final radius = BorderRadius.circular(16);
    const disabledTextColor = Colors.white70;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      color: Colors.grey[850],
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
          final h = constraints.maxHeight;         // высоту задаёт Grid (mainAxisExtent)
          final compact = h <= 120;                // компактный режим для низких плиток
          final leftWidth = constraints.maxWidth * (isNarrow ? 0.40 : 0.35);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ЛЕВАЯ часть: затемнённое изображение
              SizedBox(
                width: leftWidth,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5), // затемнение
                    BlendMode.darken,
                  ),
                  child: Ink.image(
                    image: AssetImage(imageAsset),
                    fit: BoxFit.cover,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),

              // ПРАВАЯ часть: контент
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isNarrow ? 12 : 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max, // растягиваем колонку на всю высоту карточки
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок
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

                      // Описание — заполняет всё доступное пространство и толкает статус вниз
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

                      // Статус — всегда в самом низу карточки
                      Row(
                        children: [
                          const Icon(Icons.hourglass_empty, color: disabledTextColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Coming soon — Not available yet',
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
