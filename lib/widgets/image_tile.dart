import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

import '../models/media_item.dart';

class ImageTile extends StatefulWidget {
  final MediaItem media;

  const ImageTile({super.key, required this.media});

  @override
  State<ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<ImageTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final file = File(widget.media.filePath);

    if (!file.existsSync()) {
      return _errorContainer("File not found");
    }

    final Matrix4 transform = Matrix4.identity();
    if (_hovered) transform.scale(1.15);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        width: 140,
        height: 140,
        child: ClipRRect(
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                transform: transform,
                transformAlignment: Alignment.center,
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _hovered ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      color: Colors.grey[900],
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDelete(context, widget.media);
                        } else if (value == 'details') {
                          _showDetailsDialog(context, widget.media);
                        } else if (value == 'seticon') {
                          _confirmSetIcon(context, widget.media);
                        }
                      },
                      itemBuilder: (context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'details',
                          child: Text('Details'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'seticon',
                          child: Text('SetIcon'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorContainer(String message) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[850],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image, color: Colors.white24, size: 40),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  void _confirmSetIcon(BuildContext context, MediaItem media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set as Project Icon?"),
        content: Text(
          "Do you want to use '${media.filePath}' as the icon for this project? "
          "This will replace any previously set icon"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              print('To be implemented');
              Navigator.pop(context);
            },
            child: const Text("Set as Project Icon", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MediaItem media) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Do you want to remove that file from Dataset?"),
        content: Text("File '${media.filePath}' will be removed from Dataset"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              try {
                File(media.filePath).deleteSync();
                // TODO: Remove from DB
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("File removed from Dataset")),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Deletion error :-()")),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, MediaItem media) {
    final file = File(media.filePath);
    final stat = file.statSync();
    final created = DateFormat('dd.MM.yyyy HH:mm').format(stat.changed);
    final updated = DateFormat('dd.MM.yyyy HH:mm').format(media.uploadDate);
    final sizeKb = (stat.size / 1024).toStringAsFixed(1);
    final resolution = _getImageResolution(media.filePath);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
        title: const Text("File details", style: TextStyle(color: Colors.white)),
        content: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow("File path", media.filePath),
              _infoRow("Size", "$sizeKb KB"),
              _infoRow("Resolution", resolution),
              _infoRow("Creation date", created),
              _infoRow("Upload date", updated),          
              _infoRow("Owner", media.owner),
              _infoRow("Last annotater", "n/a"),
              _infoRow("Last annotation date", "n/a"),           
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.red, width: 2),
                ),
              ),
              child: Text(
                "Close",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SelectableText.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImageResolution(String path) {
    try {
      final bytes = File(path).readAsBytesSync();
      final image = img.decodeImage(bytes);
      if (image != null) {
        return "${image.width}×${image.height}";
      } else {
        return "unknown resolution";
      }
    } catch (e) {
      return "Could not read image resolution";
    }
  }
}
