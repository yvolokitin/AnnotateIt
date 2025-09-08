import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import '../../session/user_session.dart';

class ExportedDatasetsDialog extends StatefulWidget {
  const ExportedDatasetsDialog({super.key});

  @override
  State<ExportedDatasetsDialog> createState() => _ExportedDatasetsDialogState();
}

class _ExportedDatasetsDialogState extends State<ExportedDatasetsDialog> {
  bool _loading = true;
  List<File> _zipFiles = [];
  String? _folderPath;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _loading = true;
    });
    try {
      final folder =
          await UserSession.instance.getCurrentUserDatasetExportFolder();
      final dir = Directory(folder);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final entries = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.toLowerCase().endsWith('.zip'))
          .toList()
        ..sort((a, b) {
          final sa = a.statSync();
          final sb = b.statSync();
          return sb.modified.compareTo(sa.modified);
        });

      if (mounted) {
        setState(() {
          _folderPath = folder;
          _zipFiles = entries;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _zipFiles = [];
          _loading = false;
        });
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var size = bytes.toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    final str = unitIndex == 0 ? size.toStringAsFixed(0) : size.toStringAsFixed(2);
    return '$str ${units[unitIndex]}';
  }

  Future<void> _saveFile(File file) async {
    try {
      if (!(Platform.isAndroid || Platform.isIOS)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Save is available on Android/iOS only')),
          );
        }
        return;
      }
      final params = SaveFileDialogParams(
        sourceFilePath: file.path,
        fileName: p.basename(file.path),
      );
      final savedPath = await FlutterFileDialog.saveFile(params: params);
      if (mounted) {
        if (savedPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to $savedPath')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Save cancelled')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  Future<void> _shareFile(BuildContext originContext, File file) async {
    try {
      final box = originContext.findRenderObject() as RenderBox?;
      final rect = box != null
          ? (box.localToGlobal(Offset.zero) & box.size)
          : const Rect.fromLTWH(0, 0, 0, 0);

      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'application/zip',
            name: p.basename(file.path),
          )
        ],
        text: p.basename(file.path),
        subject: p.basename(file.path),
        sharePositionOrigin: rect,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isWideLarge = w > 1600;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    final dialogWidth = isWideLarge ? w * 0.9 : w;
    final dialogHeight = isWideLarge ? h * 0.9 : h;

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isWideLarge ? 12 : 0),
      ),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          border: isWideLarge ? Border.all(color: Colors.grey, width: 1) : null,
          borderRadius: BorderRadius.circular(isWideLarge ? 12 : 0),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isWideLarge ? 12 : 0),
                  topRight: Radius.circular(isWideLarge ? 12 : 0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_zip_outlined, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Exported Datasets',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'CascadiaCode',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadFiles,
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_folderPath != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[800]!, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.folder_outlined, size: 18, color: Colors.white70),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                _folderPath!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'CascadiaCode',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : _zipFiles.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.archive_outlined, size: 56, color: Colors.grey[600]),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No exported datasets found',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontFamily: 'CascadiaCode',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(12),
                                itemCount: _zipFiles.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final file = _zipFiles[index];
                                  final stat = file.statSync();
                                  final name = p.basename(file.path);
                                  final sizeStr = _formatBytes(stat.size);
                                  final dateStr = dateFormat.format(stat.modified);
                                  return Material(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      leading: const Icon(Icons.archive, color: Colors.white),
                                      title: Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'CascadiaCode',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '$sizeStr   •   $dateStr',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontFamily: 'CascadiaCode',
                                        ),
                                      ),
                                      trailing: Wrap(
                                        spacing: 4,
                                        children: [
                                          IconButton(
                                            tooltip: 'Save to Files/Drive',
                                            icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
                                            onPressed: () => _saveFile(file),
                                          ),
                                          IconButton(
                                            tooltip: 'Share',
                                            icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
                                            onPressed: () => _shareFile(context, file),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
