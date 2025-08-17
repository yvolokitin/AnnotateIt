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
  double _progress = 0.0;
  String? _folderPath;

  http.Client? _client;
  StreamSubscription<List<int>>? _sub;
  IOSink? _sink;
  bool _canceled = false;

  // Prevent concurrent downloads across all ModelCard instances
  static bool _globalDownloading = false;
  bool _ownsGlobalLock = false;
  // Throttle UI updates to avoid spamming the Windows message queue
  DateTime _lastProgressUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  // Network robustness settings
  static const Duration _requestTimeout = Duration(seconds: 30); // connection and first-byte
  static const Duration _inactivityTimeout = Duration(seconds: 30); // between chunks
  static const Duration _progressUiInterval = Duration(milliseconds: 120); // throttle UI updates

  void _showError(String message) {
    if (!mounted) return;
    AppSnackbar.show(
      context,
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      saveToDb: false,
    );
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    if (e is TimeoutException) {
      return 'Network timeout. Please check your internet connection and try again.';
    }
    if (e is SocketException) {
      return 'Network error: ${e.message}. Please check your internet connection.';
    }
    if (e is HandshakeException) {
      return 'Secure connection failed. Please try again later or check your network.';
    }
    if (e is HttpException) {
      return 'HTTP error: ${e.message}';
    }
    // Fallback to the object's string
    return s;
  }

  void _cleanupPartialFiles() {
    try {
      final folder = _folderPath;
      if (folder == null) return;
      final dir = Directory(folder);
      if (!dir.existsSync()) return;
      for (final ent in dir.listSync()) {
        if (ent is File && ent.path.toLowerCase().endsWith('.part')) {
          try { ent.deleteSync(); } catch (_) {}
        }
      }
    } catch (_) {
      // ignore cleanup errors
    }
  }

  void _releaseGlobalLock() {
    if (_ownsGlobalLock) {
      _ownsGlobalLock = false;
      _globalDownloading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAlreadyDownloaded();
  }

  @override
  void dispose() {
    _canceled = true;

    _sub?.cancel();
    _sink?.close();
    _client?.close();
    // Ensure any partial .part files are cleaned up on cancellation/dispose
    _cleanupPartialFiles();
    // Release global lock if this widget owned it
    _releaseGlobalLock();
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

  // Common request headers to improve compatibility with hosting providers (e.g., GitHub Releases)
  static const Map<String, String> _commonHeaders = {
    'User-Agent': 'AnnotateIt/1.0 (+https://github.com/) ',
    'Accept': '*/*',
  };

  int _minValidBytes(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.onnx')) return 5 * 1024 * 1024; // ≥ 5 MB for model binaries
    if (p.endsWith('.yaml') || p.endsWith('.yml')) return 20; // small text file is fine
    return 100; // default small threshold
    }

  bool _looksLikeHtmlContentType(String? ct) {
    if (ct == null) return false;
    final l = ct.toLowerCase();
    return l.contains('text/html') || l.contains('text/plain');
  }

  Future<http.StreamedResponse> _sendWithRetry(
    http.Client client,
    String method,
    Uri uri, {
    Map<String, String>? headers,
    int maxAttempts = 3,
  }) async {
    Object? lastError;
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final req = http.Request(method, uri);
        if (headers != null) req.headers.addAll(headers);
        return await client.send(req).timeout(_requestTimeout);
      } catch (e) {
        lastError = e;
        if (attempt >= maxAttempts) rethrow;
        // Exponential backoff: 0.5s, 2s, 4.5s ...
        final delayMs = 500 * attempt * attempt;
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    // Should not reach here; throw the last error if any
    throw lastError ?? Exception('Unknown error sending request');
  }

  Future<void> _drainWithTimeout(Stream<List<int>> s) async {
    await s.drain<void>().timeout(_requestTimeout, onTimeout: () {
      throw TimeoutException('Timed out while draining response');
    });
  }

  Future<http.StreamedResponse> _getWithRedirects(http.Client client, Uri uri, {int maxRedirects = 5}) async {
    Uri current = uri;
    for (int i = 0; i < maxRedirects; i++) {
      final resp = await _sendWithRetry(client, 'GET', current, headers: _commonHeaders);
      // 3xx redirect handling
      if ((resp.statusCode >= 300 && resp.statusCode < 400) || resp.isRedirect) {
        final location = resp.headers['location'];
        await _drainWithTimeout(resp.stream);
        if (location == null) return resp;
        current = current.resolve(location);
        continue;
      }
      return resp;
    }
    throw Exception('Too many redirects when downloading: ' + uri.toString());
  }

  Future<void> _checkAlreadyDownloaded() async {
    final files = await _targetFiles();
    final allExist = files.every((f) {
      if (!f.existsSync()) return false;
      final minBytes = _minValidBytes(f.path);
      return f.lengthSync() >= minBytes;
    });
    if (!mounted) return;
    setState(() => _downloaded = allExist);
  }

  Future<void> _downloadModel() async {
    if (_downloading) return;

    if (_globalDownloading) {
      // Inform user and avoid starting another download simultaneously
      AppSnackbar.show(
        context,
        'Another model download is already in progress. Please wait until it finishes.',
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.black,
        saveToDb: false,
      );
      return;
    }
    _globalDownloading = true;
    _ownsGlobalLock = true;

    if (mounted) {
      setState(() {
        _downloading = true;
        _progress = 0.0;
      });
    }

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
          final head = await _sendWithRetry(client, 'HEAD', url, headers: _commonHeaders);
          final len = head.contentLength ?? 0;
          lengths.add(len);
          totalBytes += len;
          await _drainWithTimeout(head.stream);
        } catch (_) {
          lengths.add(0);
        }
      }

      int downloadedSoFar = 0;

      for (int i = 0; i < _urls.length; i++) {
        if (_canceled) return;

        final url = _urls[i];
        final file = files[i];

        // Skip if a valid file already exists (meets min size)
        if (file.existsSync() && file.lengthSync() >= _minValidBytes(file.path)) {
          downloadedSoFar += lengths[i];
          if (totalBytes > 0 && mounted) {
            setState(() => _progress = downloadedSoFar / totalBytes);
          }
          continue;
        }

        // Perform GET with manual redirect handling and common headers
        final resp = await _getWithRedirects(client, url);
        if (_canceled) return;

        // Validate status code
        if (resp.statusCode < 200 || resp.statusCode >= 300) {
          await _drainWithTimeout(resp.stream);
          if (mounted) {
            setState(() {
              _downloading = false;
              _progress = 0.0;
            });
            AppSnackbar.show(
              context,
              'Download failed (${resp.statusCode}) for ${url.toString()}',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              saveToDb: false,
            );
          }
          return;
        }

        final contentType = resp.headers['content-type'];
        final filePath = file.path;
        final isOnnx = filePath.toLowerCase().endsWith('.onnx');
        // Fail fast if server returns HTML/text for supposed binary
        if (isOnnx && _looksLikeHtmlContentType(contentType)) {
          await _drainWithTimeout(resp.stream);
          if (mounted) {
            setState(() {
              _downloading = false;
              _progress = 0.0;
            });
            AppSnackbar.show(
              context,
              'Download failed: unexpected content for ${url.toString()}',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              saveToDb: false,
            );
          }
          return;
        }

        // Write into temporary .part file
        final tmp = File(filePath + '.part');
        if (tmp.existsSync()) {
          try { tmp.deleteSync(); } catch (_) {}
        }
        _sink = tmp.openWrite();
        int received = 0;
        final thisLen = resp.contentLength ?? lengths[i];

        _sub = resp.stream.timeout(_inactivityTimeout).listen(
          (chunk) {
            if (_canceled) return;
            _sink?.add(chunk);
            received += chunk.length;
            if (!mounted) return;
            final now = DateTime.now();
            if (now.difference(_lastProgressUiUpdate) >= _progressUiInterval) {
              if (totalBytes > 0) {
                final currentTotal = downloadedSoFar + received;
                setState(() => _progress = currentTotal / totalBytes);
              } else if (thisLen > 0) {
                setState(() => _progress = (downloadedSoFar + (received / thisLen)) / _urls.length);
              } else {
                setState(() {});
              }
              _lastProgressUiUpdate = now;
            }
          },
          onDone: () async {
            await _sink?.flush();
            await _sink?.close();
            _sink = null;
            _sub = null;
            try {
              final finalLen = tmp.lengthSync();
              final minBytes = _minValidBytes(filePath);
              if (finalLen < minBytes) {
                try { tmp.deleteSync(); } catch (_) {}
                if (mounted && !_canceled) {
                  setState(() {
                    _downloading = false;
                    _progress = 0.0;
                  });
                  AppSnackbar.show(
                    context,
                    'Download failed: file too small for ${url.toString()}',
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    saveToDb: false,
                  );
                }
                return;
              }
              // Move into place
              if (file.existsSync()) {
                try { file.deleteSync(); } catch (_) {}
              }
              tmp.renameSync(filePath);
              downloadedSoFar += (thisLen > 0 ? thisLen : received);
            } catch (e) {
              try { tmp.deleteSync(); } catch (_) {}
              if (mounted && !_canceled) {
                setState(() {
                  _downloading = false;
                  _progress = 0.0;
                });
                AppSnackbar.show(
                  context,
                  'Download failed: ${_friendlyError(e)}',
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  saveToDb: false,
                );
              }
            }
          },
          onError: (e) async {
            await _sink?.close();
            _sink = null;
            _sub = null;
            try { File(filePath + '.part').deleteSync(); } catch (_) {}
            if (!_canceled && mounted) {
              setState(() {
                _downloading = false;
                _progress = 0.0;
              });
              AppSnackbar.show(
                context,
                'Download failed: ${_friendlyError(e)}',
                backgroundColor: Colors.red,
                textColor: Colors.white,
                saveToDb: false,
              );
            }
          },
          cancelOnError: true,
        );

        // Wait for current subscription
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
          'Download error: ${_friendlyError(e)}',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          saveToDb: false,
        );
      }
    } finally {
      try { await _sub?.cancel(); } catch (_) {}
      try { await _sink?.flush(); } catch (_) {}
      try { await _sink?.close(); } catch (_) {}
      _sink = null;
      _sub = null;
      try { _client?.close(); } catch (_) {}
      if (_canceled) {
        _cleanupPartialFiles();
      }
      // Always release global download lock
      _releaseGlobalLock();
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
