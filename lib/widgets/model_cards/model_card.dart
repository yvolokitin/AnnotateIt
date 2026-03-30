import 'dart:io';
import 'dart:async';
import '../../utils/platform_utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:crypto/crypto.dart';

import '../app_snackbar.dart';
import '../../session/user_session.dart';
import '../../gen_l10n/app_localizations.dart';
import '../dialogs/alert_error_dialog.dart';

class ModelCard extends StatefulWidget {
  final String id;
  final String title;
  final String description;
  final String imageAsset;

  final String urlEncoder;
  final String urlDecoder;
  final String urlConfig;

  final String shaEncoder;
  final String shaDecoder;
  final String shaConfig;

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
    required this.shaEncoder,
    required this.shaDecoder,
    required this.shaConfig,
    required this.modelSize,
  });

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelArtifact {
  final Uri uri;
  final String fileName;
  final String expectedSha256;

  const _ModelArtifact({
    required this.uri,
    required this.fileName,
    required this.expectedSha256,
  });
}

class _ModelCardState extends State<ModelCard> {
  int _checkCounter = 0;
  bool _downloading = false;
  bool _downloaded = false;
  double _progress = 0.0;
  String? _folderPath;

  http.Client? _client;
  StreamSubscription<List<int>>? _sub;
  IOSink? _sink;
  bool _canceled = false;
  bool _postFrameCheckScheduled = false;

  // Prevent concurrent downloads across all ModelCard instances
  static bool _globalDownloading = false;
  bool _ownsGlobalLock = false;
  // Throttle UI updates to avoid spamming the Windows message queue
  DateTime _lastProgressUiUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  // Network robustness settings
  static const Duration _requestTimeout = Duration(
    seconds: 30,
  ); // connection and first-byte
  static const Duration _inactivityTimeout = Duration(
    seconds: 30,
  ); // between chunks
  static const Duration _progressUiInterval = Duration(
    milliseconds: 120,
  ); // throttle UI updates

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
          try {
            ent.deleteSync();
          } catch (_) {}
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

  Future<String> _sha256OfFile(File f) async {
    final digest = await sha256.bind(f.openRead()).first;
    return digest.toString();
  }

  bool _shaMatches(String expected, String actual) {
    if (expected.isEmpty) return true; // нет эталона — пропускаем проверку
    return expected.toLowerCase() == actual.toLowerCase();
  }

  @override
  void initState() {
    super.initState();
    _checkAlreadyDownloaded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Revalidate download status when dependencies change (e.g., on page return)
    _checkAlreadyDownloaded();
  }

  @override
  void didUpdateWidget(covariant ModelCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the model id or URLs change, re-check the files on disk
    if (oldWidget.id != widget.id ||
        oldWidget.urlEncoder != widget.urlEncoder ||
        oldWidget.urlDecoder != widget.urlDecoder ||
        oldWidget.urlConfig != widget.urlConfig) {
      _checkAlreadyDownloaded();
    }
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
    try {
      // Use user-configured models root folder
      final modelsRoot =
          await UserSession.instance.getCurrentUserModelsFolder();
      final base = Directory(p.join(modelsRoot, widget.id));
      if (!base.existsSync()) {
        base.createSync(recursive: true);
      }
      _folderPath = base.path;
      return base;
    } catch (_) {
      // Fallback to legacy default location if UserSession is not initialized
      final dir = await getApplicationDocumentsDirectory();
      final base = Directory(
        p.join(dir.path, 'AnnotateIt', 'models', widget.id),
      );
      if (!base.existsSync()) {
        base.createSync(recursive: true);
      }
      _folderPath = base.path;
      return base;
    }
  }

  bool get _hasDownloadSources {
    final hasEncoder = _parseArtifact(widget.urlEncoder, widget.shaEncoder);
    final hasConfig = _parseArtifact(widget.urlConfig, widget.shaConfig);
    return hasEncoder != null && hasConfig != null;
  }

  _ModelArtifact? _parseArtifact(String rawUrl, String expectedSha256) {
    final raw = rawUrl.trim();
    if (raw.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(raw);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return null;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return null;
    }
    final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    if (fileName.isEmpty) {
      return null;
    }
    return _ModelArtifact(
      uri: uri,
      fileName: fileName,
      expectedSha256: expectedSha256,
    );
  }

  List<_ModelArtifact> get _artifacts {
    final artifacts = <_ModelArtifact>[];

    final encoder = _parseArtifact(widget.urlEncoder, widget.shaEncoder);
    if (encoder != null) {
      artifacts.add(encoder);
    }

    final decoder = _parseArtifact(widget.urlDecoder, widget.shaDecoder);
    if (decoder != null) {
      artifacts.add(decoder);
    }

    final config = _parseArtifact(widget.urlConfig, widget.shaConfig);
    if (config != null) {
      artifacts.add(config);
    }

    return artifacts;
  }

  Future<List<File>> _targetFiles() async {
    final folder = await _modelsRoot();
    return _artifacts
        .map((artifact) => File(p.join(folder.path, artifact.fileName)))
        .toList();
  }

  // Common request headers to improve compatibility with hosting providers (e.g., GitHub Releases)
  static const Map<String, String> _commonHeaders = {
    'User-Agent': 'AnnotateIt/1.0 (+https://github.com/) ',
    'Accept': '*/*',
  };

  int _minValidBytes(String path) {
    final p = path.toLowerCase();
    if (p.endsWith('.onnx'))
      return 5 * 1024 * 1024; // ≥ 5 MB for model binaries
    if (p.endsWith('.yaml') || p.endsWith('.yml'))
      return 20; // small text file is fine
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
    await s.drain<void>().timeout(
      _requestTimeout,
      onTimeout: () {
        throw TimeoutException('Timed out while draining response');
      },
    );
  }

  Future<http.StreamedResponse> _getWithRedirects(
    http.Client client,
    Uri uri, {
    int maxRedirects = 5,
  }) async {
    Uri current = uri;
    for (int i = 0; i < maxRedirects; i++) {
      final resp = await _sendWithRetry(
        client,
        'GET',
        current,
        headers: _commonHeaders,
      );
      // 3xx redirect handling
      if ((resp.statusCode >= 300 && resp.statusCode < 400) ||
          resp.isRedirect) {
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
    // Ticket-based guard to ensure only the latest check updates UI
    final int myTicket = ++_checkCounter;

    if (!_hasDownloadSources) {
      if (!mounted || myTicket != _checkCounter) return;
      setState(() => _downloaded = false);
      return;
    }

    try {
      final files = await _targetFiles();
      final allExist = files.every((f) {
        if (!f.existsSync()) return false;
        final minBytes = _minValidBytes(f.path);
        return f.lengthSync() >= minBytes;
      });

      if (!mounted || myTicket != _checkCounter) return;
      setState(() => _downloaded = allExist);
    } catch (_) {
      if (!mounted || myTicket != _checkCounter) return;
      setState(() => _downloaded = false);
    }
  }

  Future<void> _ensureFolderPath() async {
    if (_folderPath == null) {
      final d = await _modelsRoot();
      _folderPath = d.path;
    }
  }

  Future<void> _showSavedPath() async {
    await _ensureFolderPath();
    final p = _folderPath;
    AppSnackbar.show(
      context,
      p == null ? 'Folder not found' : 'Saved in: $p',
      backgroundColor: Colors.orangeAccent,
      textColor: Colors.black,
      saveToDb: false,
    );
  }

  Future<void> _openInFileExplorer() async {
    try {
      await _ensureFolderPath();
      final p = _folderPath;
      if (p == null) {
        throw Exception('Folder not found');
      }
      if (!Directory(p).existsSync()) {
        throw Exception('Folder not found');
      }
      if (PlatformUtils.isWindows) {
        await Process.run('explorer', [p]);
      } else if (PlatformUtils.isMacOS) {
        await Process.run('open', [p]);
      } else if (PlatformUtils.isLinux) {
        await Process.run('xdg-open', [p]);
      } else {
        throw Exception('Unsupported platform');
      }
    } catch (e) {
      AppSnackbar.show(
        context,
        'Cannot open folder: ${_friendlyError(e)}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        saveToDb: false,
      );
    }
  }

  Future<void> _downloadModel() async {
    if (_downloading) return;

    if (!_hasDownloadSources) {
      AppSnackbar.show(
        context,
        'Model download is unavailable in this deployment profile. Configure APP_MODEL_REGISTRY_BASE_URL or allow external model downloads.',
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.black,
        saveToDb: false,
      );
      return;
    }

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
      final artifacts = _artifacts;
      if (artifacts.isEmpty) {
        throw Exception('No valid model artifacts configured for download.');
      }
      final files = await _targetFiles();

      int totalBytes = 0;
      final lengths = <int>[];
      for (final artifact in artifacts) {
        if (_canceled) return;
        try {
          final head = await _sendWithRetry(
            client,
            'HEAD',
            artifact.uri,
            headers: _commonHeaders,
          );
          final len = head.contentLength ?? 0;
          lengths.add(len);
          totalBytes += len;
          await _drainWithTimeout(head.stream);
        } catch (_) {
          lengths.add(0);
        }
      }

      int downloadedSoFar = 0;
      for (int i = 0; i < artifacts.length; i++) {
        if (_canceled) return;

        final artifact = artifacts[i];
        final url = artifact.uri;
        final file = files[i];

        if (file.existsSync() &&
            file.lengthSync() >= _minValidBytes(file.path)) {
          downloadedSoFar += lengths[i];
          if (totalBytes > 0 && mounted) {
            setState(() => _progress = downloadedSoFar / totalBytes);
          }
          continue;
        }

        final resp = await _getWithRedirects(client, url);
        if (_canceled) return;

        if (resp.statusCode < 200 || resp.statusCode >= 300) {
          await _drainWithTimeout(resp.stream);
          if (mounted) {
            setState(() {
              _downloading = false;
              _progress = 0.0;
            });
            _showError(
              'Download failed (${resp.statusCode}) for ${url.toString()}',
            );
          }
          return;
        }

        final contentType = resp.headers['content-type'];
        final filePath = file.path;
        final isOnnx = filePath.toLowerCase().endsWith('.onnx');
        if (isOnnx && _looksLikeHtmlContentType(contentType)) {
          await _drainWithTimeout(resp.stream);
          if (mounted) {
            setState(() {
              _downloading = false;
              _progress = 0.0;
            });
            _showError(
              'Download failed: unexpected content for ${url.toString()}',
            );
          }
          return;
        }

        final tmp = File('$filePath.part');
        if (tmp.existsSync()) {
          try {
            tmp.deleteSync();
          } catch (_) {}
        }
        final sink = tmp.openWrite();

        int received = 0;
        final thisLen = resp.contentLength ?? lengths[i];

        try {
          await for (final chunk in resp.stream.timeout(_inactivityTimeout)) {
            sink.add(chunk);
            received += chunk.length;

            if (mounted) {
              final now = DateTime.now();
              if (now.difference(_lastProgressUiUpdate) >=
                  _progressUiInterval) {
                if (totalBytes > 0) {
                  final currentTotal = downloadedSoFar + received;
                  setState(() => _progress = currentTotal / totalBytes);
                } else if (thisLen > 0) {
                  setState(
                    () =>
                        _progress =
                            (downloadedSoFar + (received / thisLen)) /
                            artifacts.length,
                  );
                }
                _lastProgressUiUpdate = now;
              }
            }
          }
          await sink.flush();
          await sink.close();
        } catch (e) {
          try {
            await sink.flush();
            await sink.close();
          } catch (_) {}
          try {
            if (tmp.existsSync()) tmp.deleteSync();
          } catch (_) {}
          if (!_canceled && mounted) {
            setState(() {
              _downloading = false;
              _progress = 0.0;
            });
            _showError('Download failed: ${_friendlyError(e)}');
          }
          return;
        }

        try {
          final finalLen = tmp.lengthSync();
          final minBytes = _minValidBytes(filePath);
          if (finalLen < minBytes) {
            try {
              tmp.deleteSync();
            } catch (_) {}
            if (mounted && !_canceled) {
              setState(() {
                _downloading = false;
                _progress = 0.0;
              });
              _showError(
                'Download failed: file too small for ${url.toString()}',
              );
            }
            return;
          }

          final expectedSha = artifact.expectedSha256;

          if (expectedSha.isNotEmpty) {
            final actual = await _sha256OfFile(tmp);
            if (!_shaMatches(expectedSha, actual)) {
              try {
                tmp.deleteSync();
              } catch (_) {}
              if (mounted && !_canceled) {
                setState(() {
                  _downloading = false;
                  _progress = 0.0;
                });
                _showError(
                  'Checksum mismatch for ${url.pathSegments.isNotEmpty ? url.pathSegments.last : url.toString()}',
                );
              }
              return;
            }
          }

          if (file.existsSync()) {
            try {
              file.deleteSync();
            } catch (_) {}
          }
          tmp.renameSync(filePath);
          downloadedSoFar += (thisLen > 0 ? thisLen : received);
        } catch (e) {
          try {
            tmp.deleteSync();
          } catch (_) {}
          if (mounted && !_canceled) {
            setState(() {
              _downloading = false;
              _progress = 0.0;
            });
            _showError('Download failed: ${_friendlyError(e)}');
          }
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        _downloading = false;
        _progress = 1.0;
      });

      // Re-validate from disk after all files are finalized to avoid any transient UI mismatch
      await _checkAlreadyDownloaded();

      if (_downloaded) {
        AppSnackbar.show(
          context,
          '${widget.title} downloaded to ${_folderPath ?? ''}',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          saveToDb: false,
        );
      } else {
        _showError(
          'Downloaded files not found or incomplete. Please try again.',
        );
      }
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
      try {
        await _sub?.cancel();
      } catch (_) {}
      try {
        await _sink?.flush();
      } catch (_) {}
      try {
        await _sink?.close();
      } catch (_) {}
      _sink = null;
      _sub = null;
      try {
        _client?.close();
      } catch (_) {}
      if (_canceled) {
        _cleanupPartialFiles();
      }
      // Always release global download lock
      _releaseGlobalLock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);
    final darkGreen = Colors.lightGreen[900]!;

    // Ensure we re-check status after rebuilds (e.g., returning to page)
    if (!_postFrameCheckScheduled) {
      _postFrameCheckScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _postFrameCheckScheduled = false;
        _checkAlreadyDownloaded();
      });
    }

    final borderColor =
        _downloaded ? darkGreen : theme.colorScheme.outlineVariant;
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
              SizedBox(
                width: leftWidth,
                child: Ink.image(
                  image: AssetImage(widget.imageAsset),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.title,
                              style:
                                  compact
                                      ? theme.textTheme.titleSmall
                                      : (isNarrow
                                          ? theme.textTheme.titleMedium
                                          : theme.textTheme.titleLarge),
                              softWrap: true,
                              maxLines: compact ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const SizedBox(width: 4),
                          Chip(
                            label: Text(widget.modelSize),
                            backgroundColor:
                                _downloaded
                                    ? Colors.green
                                    : theme.colorScheme.surfaceVariant,
                            labelStyle: (compact
                                    ? theme.textTheme.labelSmall
                                    : theme.textTheme.labelMedium)
                                ?.copyWith(
                                  color: _downloaded ? Colors.white : null,
                                ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Expanded(
                        child: Text(
                          widget.description,
                          style: theme.textTheme.bodyMedium,
                          softWrap: true,
                          maxLines: compact ? 1 : null,
                          overflow:
                              compact
                                  ? TextOverflow.ellipsis
                                  : TextOverflow.fade,
                        ),
                      ),

                      SizedBox(height: compact ? 6 : 10),

                      if (_downloading) ...[
                        LinearProgressIndicator(
                          value: _progress > 0 ? _progress : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _progress > 0
                              ? '${l10n.modelDownloading} ${(_progress * 100).clamp(0, 100).toStringAsFixed(0)}%'
                              : '${l10n.modelStartingDownload}…',
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
                                l10n.modelDownloaded,
                                style:
                                    compact
                                        ? theme.textTheme.bodySmall
                                        : theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: l10n.menuAbout,
                                  icon: const Icon(Icons.info_outline),
                                  onPressed: () {
                                    AlertErrorDialog.show(
                                      context,
                                      widget.title,
                                      widget.description,
                                    );
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  tooltip: l10n.modelShowPath,
                                  icon: const Icon(Icons.folder),
                                  onPressed: () {
                                    _showSavedPath();
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                                IconButton(
                                  tooltip: l10n.modelOpenPath,
                                  icon: const Icon(Icons.folder_open),
                                  onPressed: () {
                                    _openInFileExplorer();
                                  },
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ] else ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!_hasDownloadSources)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  'Download source is not configured for this environment.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.orangeAccent,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: l10n.menuAbout,
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () {
                                      AlertErrorDialog.show(
                                        context,
                                        widget.title,
                                        widget.description,
                                      );
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const SizedBox(width: 6),
                                  ElevatedButton.icon(
                                    onPressed:
                                        _hasDownloadSources
                                            ? _downloadModel
                                            : null,
                                    icon: const Icon(Icons.download),
                                    label: Text(l10n.modelDownload),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _hasDownloadSources
                                              ? Colors.red
                                              : Colors.grey,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: compact ? 10 : 14,
                                        vertical: compact ? 8 : 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      visualDensity:
                                          compact
                                              ? VisualDensity.compact
                                              : VisualDensity.standard,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
