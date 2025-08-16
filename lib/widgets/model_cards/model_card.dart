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

  Future<Directory> _getSaveDir() async {
    return await getApplicationDocumentsDirectory();
  }

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
              setState(() {
                _progress = received / contentLen;
              });
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
            if (file.existsSync()) {
              file.deleteSync();
            }
            if (!mounted) return;
            setState(() {
              _downloading = false;
              _progress = 0.0;
            });

            scaffold.showSnackBar(
              SnackBar(content: Text('Download failed: $e')),
            );
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
    final isSamMobile = widget.id == 'sam_mobile';
    final isSsdComingSoon = widget.id == 'ssd_mobilenet';

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSamMobile
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: isSamMobile ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: isSsdComingSoon ? null : () {},
        child: Row(
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: Ink(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.imageAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSamMobile)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Chip(
                              label: const Text('Built-in'),
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                        else if (isSsdComingSoon)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Chip(
                              label: const Text('Coming soon'),
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Description
                    Text(
                      widget.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (isSamMobile) ...[
                      Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Built-in and ready to use',
                            ),
                          ),
                        ],
                      ),
                    ] else if (isSsdComingSoon) ...[
                      Row(
                        children: const [
                          Icon(Icons.hourglass_empty, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Coming soon — Not available yet',
                            ),
                          ),
                        ],
                      ),
                    ] else if (_downloading) ...[
                      LinearProgressIndicator(value: _progress > 0 ? _progress : null),
                      const SizedBox(height: 8),
                      Text(
                        _progress > 0 ? 'Downloading ${(_progress * 100).toStringAsFixed(0)}%' : 'Starting download…',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ] else if (_downloaded) ...[
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Downloaded',
                              style: Theme.of(context).textTheme.bodyMedium,
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
