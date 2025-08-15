import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ModelInfo {
  final String id;
  final String title;
  final String description;
  final String imageAsset;
  final String downloadUrl;
  final String defaultFileName;

  const ModelInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.downloadUrl,
    required this.defaultFileName,
  });
}

class ModelPage extends StatefulWidget {
  const ModelPage({super.key});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  // Define your 4 models here. Replace URLs with the actual locations.
  final List<ModelInfo> _models = const [
    ModelInfo(
      id: 'sam_mobile',
      title: 'SAM Mobile',
      description: 'Lightweight SAM variant for on-device segmentation.',
      imageAsset: 'assets/images/sam_example.png',
      downloadUrl: 'https://example.com/models/sam_mobile.onnx',
      defaultFileName: 'sam_mobile.onnx',
    ),
    ModelInfo(
      id: 'sam2_hiera_base',
      title: 'SAM2 Hiera Base+',
      description: 'Balanced accuracy/speed with Hiera base+ backbone.',
      imageAsset: 'assets/images/sam_example.png',
      downloadUrl: 'https://example.com/models/sam2_hiera_base_plus.onnx',
      defaultFileName: 'sam2_hiera_base_plus.onnx',
    ),
    ModelInfo(
      id: 'sam2_hiera_large',
      title: 'SAM2 Hiera Large',
      description: 'High-accuracy variant for best quality masks.',
      imageAsset: 'assets/images/sam_example.png',
      downloadUrl: 'https://example.com/models/sam2_hiera_large.onnx',
      defaultFileName: 'sam2_hiera_large.onnx',
    ),
    ModelInfo(
      id: 'ssd_mobilenet',
      title: 'SSD MobileNet',
      description: 'Fast single-shot detector for general objects.',
      imageAsset: 'assets/images/sam_example.png',
      downloadUrl: 'https://example.com/models/ssd_mobilenet.tflite',
      defaultFileName: 'ssd_mobilenet.tflite',
    ),
  ];

  // Per-card state
  final Map<String, double> _progress = {}; // 0.0..1.0
  final Map<String, bool> _downloading = {};
  final Map<String, bool> _downloaded = {};
  final Map<String, String?> _savedPaths = {};

  @override
  void initState() {
    super.initState();
    for (final m in _models) {
      _progress[m.id] = 0;
      _downloading[m.id] = false;
      _downloaded[m.id] = false;
      _savedPaths[m.id] = null;
    }
  }

  Future<Directory> _getSaveDir() async {
    // Cross-platform safe location
    return await getApplicationDocumentsDirectory();
  }

  Future<void> _downloadModel(ModelInfo model) async {
    if (_downloading[model.id] == true) return;

    setState(() {
      _downloading[model.id] = true;
      _progress[model.id] = 0.0;
    });

    final scaffold = ScaffoldMessenger.of(context);

    try {
      final dir = await _getSaveDir();
      final filePath = '${dir.path}/${model.defaultFileName}';
      final file = File(filePath);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }

      final request = http.Request('GET', Uri.parse(model.downloadUrl));
      final streamed = await http.Client().send(request);

      final contentLen = streamed.contentLength ?? 0;
      int received = 0;
      final sink = file.openWrite();

      await streamed.stream.listen(
        (chunk) {
          sink.add(chunk);
          received += chunk.length;
          if (contentLen > 0) {
            setState(() {
              _progress[model.id] = received / contentLen;
            });
          }
        },
        onDone: () async {
          await sink.flush();
          await sink.close();

          setState(() {
            _downloading[model.id] = false;
            _downloaded[model.id] = true;
            _progress[model.id] = 1.0;
            _savedPaths[model.id] = filePath;
          });

          scaffold.showSnackBar(
            SnackBar(content: Text('${model.title} downloaded to $filePath')),
          );
        },
        onError: (e) async {
          await sink.close();
          file.existsSync() ? file.deleteSync() : null;

          setState(() {
            _downloading[model.id] = false;
            _progress[model.id] = 0.0;
          });

          scaffold.showSnackBar(
            SnackBar(content: Text('Download failed: $e')),
          );
        },
        cancelOnError: true,
      ).asFuture();
    } catch (e) {
      setState(() {
        _downloading[model.id] = false;
        _progress[model.id] = 0.0;
      });
      scaffold.showSnackBar(
        SnackBar(content: Text('Download error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final crossAxisCount = isWide ? 2 : 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Models'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            // Taller to accommodate description + button + progress
            childAspectRatio: isWide ? 2.6 : 1.8,
          ),
          itemCount: _models.length,
          itemBuilder: (context, index) {
            final m = _models[index];
            final downloading = _downloading[m.id] ?? false;
            final downloaded = _downloaded[m.id] ?? false;
            final progress = _progress[m.id] ?? 0.0;

            return Card(
              elevation: 3,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () {}, // optional: open details
                child: Row(
                  children: [
                    // Image
                    AspectRatio(
                      aspectRatio: 1,
                      child: Ink(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(m.imageAsset),
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
                            // Title
                            Text(
                              m.title,
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            // Description
                            Text(
                              m.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            if (downloading) ...[
                              LinearProgressIndicator(value: progress > 0 ? progress : null),
                              const SizedBox(height: 8),
                              Text(
                                progress > 0 ? 'Downloading ${(progress * 100).toStringAsFixed(0)}%' : 'Starting download…',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ] else if (downloaded) ...[
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
                                      final p = _savedPaths[m.id];
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
                                  onPressed: () => _downloadModel(m),
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
          },
        ),
      ),
    );
  }
}
