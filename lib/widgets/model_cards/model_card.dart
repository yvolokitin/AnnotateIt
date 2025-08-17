import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../app_snackbar.dart';

class ModelCard extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String imageAsset;

  // Новые параметры
  final String urlEncoder;
  final String urlDecoder;
  final String urlConfig;
  final String modelSize;

  const ModelCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.urlEncoder,
    required this.urlDecoder,
    required this.urlConfig,
    required this.modelSize,
  });

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<ModelCard> {
  bool _downloading = false;
  bool _downloaded = false;
  double _progress = 0.0; // общий прогресс по трём файлам (0..1)
  String? _folderPath;

  http.Client? _client;
  StreamSubscription<List<int>>? _sub;
  IOSink? _sink;
  bool _canceled = false; // флаг для graceful cancel

  @override
  void initState() {
    super.initState();
    _checkAlreadyDownloaded();
  }

  @override
  void dispose() {
    _canceled = true;
    // Остановить поток/клиента, закрыть файл
    _sub?.cancel();
    _sink?.close();
    _client?.close();
    super.dispose();
  }

  Future<Directory> _modelsRoot() async {
    final dir = await getApplicationDocumentsDirectory();
    final base = Directory('${dir.path}/AnnotateIt/models/${widget.id}');
    if (!base.existsSync()) {
      base.createSync(recursive: true);
    }
    _folderPath = base.path;
    return base;
  }

  List<Uri> get _urls => [
        Uri.parse(widget.urlEncoder),
        Uri.parse(widget.urlDecoder),
        Uri.parse(widget.urlConfig),
      ];

  Future<List<File>> _targetFiles() async {
    final folder = await _modelsRoot();
    return _urls
        .map((u) => File('${folder.path}/${u.pathSegments.isNotEmpty ? u.pathSegments.last : 'file'}'))
        .toList();
  }

  Future<void> _checkAlreadyDownloaded() async {
    final files = await _targetFiles();
    final allExist = files.every((f) => f.existsSync() && f.lengthSync() > 0);
    if (!mounted) return;
    setState(() => _downloaded = allExist);
  }

  Future<void> _downloadModel() async {
    if (_downloading) return;

    if (mounted) {
      setState(() {
        _downloading = true;
        _progress = 0.0;
      });
    }

    final scaffold = ScaffoldMessenger.of(context);

    try {
      _client = http.Client();
      final client = _client!;
      final files = await _targetFiles();

      // Суммарная длина (если сервер отдаёт)
      int totalBytes = 0;
      final lengths = <int>[];
      for (final url in _urls) {
        if (_canceled) return;
        try {
          final head = await client.send(http.Request('HEAD', url));
          final len = head.contentLength ?? 0;
          lengths.add(len);
          totalBytes += len;
        } catch (_) {
          lengths.add(0);
        }
      }

      int downloadedSoFar = 0;

      for (int i = 0; i < _urls.length; i++) {
        if (_canceled) return;

        final url = _urls[i];
        final file = files[i];

        // Пропуск, если уже есть
        if (file.existsSync() && file.lengthSync() > 0) {
          downloadedSoFar += lengths[i];
          if (totalBytes > 0 && mounted) {
            setState(() => _progress = downloadedSoFar / totalBytes);
          }
          continue;
        }

        final req = http.Request('GET', url);
        final resp = await client.send(req);
        if (_canceled) return;

        _sink = file.openWrite();
        int received = 0;
        final thisLen = resp.contentLength ?? lengths[i];

        _sub = resp.stream.listen(
          (chunk) {
            if (_canceled) return;
            _sink?.add(chunk);
            received += chunk.length;
            if (!mounted) return;
            if (totalBytes > 0) {
              final currentTotal = downloadedSoFar + received;
              setState(() => _progress = currentTotal / totalBytes);
            } else if (thisLen > 0) {
              setState(() => _progress = (downloadedSoFar + (received / thisLen)) / _urls.length);
            } else {
              // Без длины — просто триггерим перестройку (не меняем прогресс)
              setState(() {});
            }
          },
          onDone: () async {
            await _sink?.flush();
            await _sink?.close();
            _sink = null;
            _sub = null;
            downloadedSoFar += (thisLen > 0 ? thisLen : received);
          },
          onError: (e) async {
            await _sink?.close();
            _sink = null;
            _sub = null;
            if (file.existsSync()) file.deleteSync();
            if (!_canceled && mounted) {
              setState(() {
                _downloading = false;
                _progress = 0.0;
              });
              AppSnackbar.show(
                context,
                'Download failed: $e',
                backgroundColor: Colors.red,
                textColor: Colors.white,
                saveToDb: false,
              );
            }
          },
          cancelOnError: true,
        );

        // Ждём завершения текущей подписки
        await _sub?.asFuture<void>();
        if (_canceled) return;
      }

      if (!mounted) return;
      setState(() {
        _downloading = false;
        _downloaded = true;
        _progress = 1.0;
      });
      AppSnackbar.show(
        context,
        '${widget.title} downloaded to ${_folderPath ?? ''}',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        saveToDb: false,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _downloading = false;
          _progress = 0.0;
          _downloaded = false;
        });
        AppSnackbar.show(
          context,
          'Download error: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          saveToDb: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);
    final darkGreen = Colors.lightGreen[900]!;

    // Бордер зелёный, если всё скачано
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
          final isNarrow = constraints.maxWidth < 900;
          final h = constraints.maxHeight;
          final compact = h <= 120;
          final leftWidth = constraints.maxWidth * (isNarrow ? 0.40 : 0.35);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Картинка слева
              SizedBox(
                width: leftWidth,
                child: Ink.image(
                  image: AssetImage(widget.imageAsset),
                  fit: BoxFit.cover,
                  child: const SizedBox.expand(),
                ),
              ),

              // Контент справа
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isNarrow ? 12 : 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max, // чтобы нижний блок был у низа
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок + чип размера
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Chip(
                            label: Text(widget.modelSize),
                            backgroundColor: theme.colorScheme.surfaceVariant,
                            labelStyle: (compact ? theme.textTheme.labelSmall : theme.textTheme.labelMedium),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Описание — заполняет пространство
                      Expanded(
                        child: Text(
                          widget.description,
                          style: theme.textTheme.bodyMedium,
                          maxLines: compact ? 1 : (isNarrow ? 2 : 3),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(height: compact ? 6 : 10),

                      // Нижний блок: Download / Downloading / Downloaded
                      if (_downloading) ...[
                        LinearProgressIndicator(value: _progress > 0 ? _progress : null),
                        const SizedBox(height: 6),
                        Text(
                          _progress > 0
                              ? 'Downloading ${(_progress * 100).clamp(0, 100).toStringAsFixed(0)}%'
                              : 'Starting download…',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else if (_downloaded) ...[
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
                                final p = _folderPath;
                                AppSnackbar.show(
                                  context,
                                  p == null ? 'Folder not found' : 'Saved in: $p',
                                  backgroundColor: Colors.orangeAccent,
                                  textColor: Colors.black,
                                  saveToDb: false,
                                );
                              },
                              icon: const Icon(Icons.folder_open),
                              label: const Text('Show path'),
                              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                            ),
                          ],
                        ),
                      ] else ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _downloadModel,
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // красная кнопка
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
