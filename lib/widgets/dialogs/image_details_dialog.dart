import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;

import '../../data/user_database.dart';
import '../../models/annotated_labeled_media.dart';

class ImageDetailsDialog extends StatefulWidget {
  final AnnotatedLabeledMedia media;

  const ImageDetailsDialog({super.key, required this.media});

  @override
  State<ImageDetailsDialog> createState() => _ImageDetailsDialogState();
}

class _ImageDetailsDialogState extends State<ImageDetailsDialog> {
  String resolution = "-";
  String sizeKb = "-";
  String ownerName = "Unknown";
  String created = "-";
  String uploaded = "-";

  @override
  void initState() {
    super.initState();
    _loadFileDetails();
  }

  Future<void> _loadFileDetails() async {
    final file = File(widget.media.mediaItem.filePath);
    if (file.existsSync()) {
      final stat = await file.stat();
      setState(() {
        sizeKb = (stat.size / 1024).toStringAsFixed(1);
        created = DateFormat('dd.MM.yyyy HH:mm').format(stat.changed);
        uploaded = DateFormat('dd.MM.yyyy HH:mm').format(widget.media.mediaItem.uploadDate);
      });

      final image = img.decodeImage(await file.readAsBytes());
      if (image != null) {
        setState(() {
          resolution = "${image.width}×${image.height}";
        });
      }
    }

    final owner = await UserDatabase.instance.getById(widget.media.mediaItem.ownerId);
    setState(() {
      ownerName = owner != null ? "${owner.firstName} ${owner.lastName}" : "Unknown";
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media.mediaItem;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;
    final isFullscreen = isMobile || isTablet;

    final dialogContent = SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "File Details",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  SelectableText(media.filePath, style: const TextStyle(color: Colors.white70, fontFamily: 'monospace')),
                  const SizedBox(height: 24),
                  isFullscreen
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 200,
                              child: Image.file(File(media.filePath), fit: BoxFit.contain),
                            ),
                            const SizedBox(height: 24),
                            _buildDetailsList(media),
                            const SizedBox(height: 24),
                            _buildAnnotationsList(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.2,
                              child: Image.file(File(media.filePath), fit: BoxFit.contain),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                width: screenWidth * 0.4,
                                child: _buildDetailsList(media),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                width: screenWidth * 0.4 - 64,
                                child: _buildAnnotationsList(),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[850],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.red, width: 2),
                        ),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );

    return isFullscreen
        ? Dialog.fullscreen(
            backgroundColor: Colors.grey[850],
            child: dialogContent,
          )
        : Dialog(
            backgroundColor: Colors.grey[850],
            child: dialogContent,
          );
  }

  Widget _buildDetailsList(media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow("UUID", media.uuid),
        _infoRow("Dataset ID", media.datasetId.toString()),
        _infoRow("Extension", media.extension),
        _infoRow("Media Type", media.type.toString().split('.').last),
        _infoRow("Width", media.width?.toString() ?? "-"),
        _infoRow("Height", media.height?.toString() ?? "-"),
        _infoRow("Source", media.source ?? "-"),
        _infoRow("Upload Date", uploaded),
        _infoRow("Created At", created),
        _infoRow("Resolution", resolution),
        _infoRow("File Size", "$sizeKb KB"),
        _infoRow("Owner", ownerName),
        _infoRow("Last Annotator", media.lastAnnotator ?? "-"),
        _infoRow("Last Annotation Date", media.lastAnnotatedDate?.toString() ?? "-"),
        _infoRow("Annotation Count", widget.media.annotations.length.toString()),
        _infoRow("Labels", widget.media.labels.map((l) => l.name).join(", ")),
      ],
    );
  }

  Widget _buildAnnotationsList() {
    if (widget.media.annotations.isEmpty) {
      return const Text("No annotations", style: TextStyle(color: Colors.white70));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Annotations:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...widget.media.annotations.map((a) {
          final type = a.annotationType;
          final createdAt = DateFormat('dd.MM.yyyy HH:mm').format(a.createdAt);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("$type / $createdAt",
                style: const TextStyle(color: Colors.white, fontFamily: 'monospace')),
          );
        }).toList(),
      ],
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
}
