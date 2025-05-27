import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/label.dart';

class AllLabelsDialog extends StatelessWidget {
  final List<Label> labels;
  final String? projectTitle;
  final String? iconPath;

  const AllLabelsDialog({
    super.key,
    required this.labels,
    this.projectTitle,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return AlertDialog(
      backgroundColor: Colors.grey[850],
      titlePadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.all(16),
      title: const Text('All Labels', style: TextStyle(color: Colors.white)),
      content: isMobile
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (projectTitle != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        projectTitle!,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (iconPath != null)
                    Container(
                      width: double.infinity,
                      height: 140,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: _resolveImage(iconPath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  const Text("Labels:", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: labels.map(_buildChip).toList(),
                  ),
                ],
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (projectTitle != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          projectTitle!,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (iconPath != null)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: _resolveImage(iconPath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 32),

                // Right column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Labels:", style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: labels.map(_buildChip).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildChip(Label label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: _fromHex(label.color),
            shape: BoxShape.circle,
          ),
        ),
        Text(label.name, style: const TextStyle(color: Colors.white)),
        const SizedBox(width: 8),
      ],
    );
  }

  static ImageProvider _resolveImage(String path) {
    if (path.toLowerCase().endsWith('.svg')) {
      // This won't be used directly; SVG needs a widget (handled above)
      return const AssetImage('assets/images/fallback.png');
    } else {
      return FileImage(File(path));
    }
  }

  static Color _fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('FF');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
