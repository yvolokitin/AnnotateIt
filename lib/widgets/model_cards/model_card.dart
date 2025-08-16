import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ModelCard extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String imageAsset;
  final String downloadUrl;
  final String defaultFileName;

  const ModelCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.downloadUrl,
    required this.defaultFileName,
  });

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<ModelCard> {
  bool _downloading = false;
  bool _downloaded = false;
  double _progress = 0.0;
  String? _savedPath;

  Future<Directory> _getSaveDir() => getApplicationDocumentsDirectory();

  Future<void> _downloadModel() async {
    if (_downloading) return;

    setState(() {
      _downloading = true;
      _progress = 0.0;
    });

    final scaffold = ScaffoldMessenger.of(context);

    try {
      final dir = await _getSaveDir();
      final filePath = '${dir.path}/${widget.defaultFileName}';
      final file = File(filePath);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(widget.downloadUrl));
        final streamed = await client.send(request);

        final contentLen = streamed.contentLength ?? 0;
        int received = 0;
        final sink = file.openWrite();

        await streamed.stream.listen(
          (chunk) {
            sink.add(chunk);
            received += chunk.length;
            if (contentLen > 0) {
              setState(() => _progress = received / contentLen);
            }
          },
          onDone: () async {
            await sink.flush();
            await sink.close();
            if (!mounted) return;
            setState(() {
              _downloading = false;
              _downloaded = true;
              _progress = 1.0;
              _savedPath = filePath;
            });
            scaffold.showSnackBar(
              SnackBar(content: Text('${widget.title} downloaded to $filePath')),
            );
          },
          onError: (e) async {
            await sink.close();
            if (file.existsSync()) file.deleteSync();
            if (!mounted) return;
            setState(() {
              _downloading = false;
              _progress = 0.0;
            });
            scaffold.showSnackBar(SnackBar(content: Text('Download failed: $e')));
          },
          cancelOnError: true,
        ).asFuture();
      } finally {
        client.close();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _progress = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);
    final darkGreen = Colors.lightGreen[900]!;

    final isComingSoon = widget.id == 'ssd_mobilenet'; // твоя логика "coming soon"

    // Рамка: если скачано — темно-зелёная, иначе нейтральная
    final borderColor = _downloaded ? darkGreen : theme.colorScheme.outlineVariant;
    final borderWidth = _downloaded ? 2.0 : 1.5;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Размеры ячейки диктует Grid (см. ModelPage с mainAxisExtent)
          final isNarrow = constraints.maxWidth < 900;
          final h = constraints.maxHeight;
          final compact = h <= 120;

          final leftWidth = constraints.maxWidth * (isNarrow ? 0.40 : 0.35);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch, // картинка тянется по высоте карточки
            children: [
              // ЛЕВАЯ ЧАСТЬ: картинка (40% / 35% ширины)
              SizedBox(
                width: leftWidth,
                child: Ink.image(
                  image: AssetImage(widget.imageAsset),
                  fit: BoxFit.cover,
                  child: const SizedBox.expand(),
                ),
              ),

              // ПРАВАЯ ЧАСТЬ: контент
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isNarrow ? 12 : 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max, // растягиваем колонку на всю высоту карточки
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок + бейдж статуса
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style: compact
                                  ? theme.textTheme.titleSmall
                                  : (isNarrow ? theme.textTheme.titleMedium : theme.textTheme.titleLarge),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (_downloaded)
                            Chip(
                              label: const Text('Downloaded'),
                              backgroundColor: theme.colorScheme.primaryContainer,
                              labelStyle: (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium)
                                  ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )
                          else if (_downloading)
                            Chip(
                              label: Text('${(_progress * 100).clamp(0, 100).toStringAsFixed(0)}%'),
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              labelStyle: (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            )
                          else if (isComingSoon)
                            Chip(
                              label: const Text('Coming soon'),
                              backgroundColor: theme.colorScheme.secondaryContainer,
                              labelStyle: (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium)
                                  ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Описание — заполняет всё доступное пространство и толкает статус/кнопку вниз
                      Expanded(
                        child: Text(
                          widget.description,
                          style: theme.textTheme.bodyMedium,
                          maxLines: compact ? 1 : (isNarrow ? 2 : 3),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(height: compact ? 6 : 10),

                      // НИЖНИЙ БЛОК: всегда прижат к низу
                      if (isComingSoon)
                        Row(
                          children: [
                            Icon(Icons.hourglass_empty, color: theme.colorScheme.outline),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Coming soon — Not available yet',
                                style: compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        )
                      else if (_downloading) ...[
                        LinearProgressIndicator(value: _progress > 0 ? _progress : null),
                        const SizedBox(height: 6),
                        Text(
                          _progress > 0
                              ? 'Downloading ${(_progress * 100).toStringAsFixed(0)}%'
                              : 'Starting download…',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ]
                      else if (_downloaded)
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: darkGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Downloaded',
                                style: compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                final p = _savedPath;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(p == null ? 'File not found' : 'Saved at: $p')),
                                );
                              },
                              icon: const Icon(Icons.folder_open),
                              label: const Text('Show path'),
                              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            ),
                          ],
                        )
                      else
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _downloadModel,
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 10 : 14,
                                vertical: compact ? 8 : 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
                            ),
                          ),
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
