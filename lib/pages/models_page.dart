import 'package:flutter/material.dart';
import 'package:annotateit/widgets/model_cards/model_card.dart';

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
      imageAsset: 'assets/images/sam_example.jpg',
      downloadUrl: 'https://example.com/models/sam_mobile.onnx',
      defaultFileName: 'sam_mobile.onnx',
    ),
    ModelInfo(
      id: 'sam2_hiera_base',
      title: 'SAM2 Hiera Base+',
      description: 'Balanced accuracy/speed with Hiera base+ backbone.',
      imageAsset: 'assets/images/sam_example.jpg',
      downloadUrl: 'https://example.com/models/sam2_hiera_base_plus.onnx',
      defaultFileName: 'sam2_hiera_base_plus.onnx',
    ),
    ModelInfo(
      id: 'sam2_hiera_large',
      title: 'SAM2 Hiera Large',
      description: 'High-accuracy variant for best quality masks.',
      imageAsset: 'assets/images/sam_example.jpg',
      downloadUrl: 'https://example.com/models/sam2_hiera_large.onnx',
      defaultFileName: 'sam2_hiera_large.onnx',
    ),
    ModelInfo(
      id: 'ssd_mobilenet',
      title: 'SSD MobileNet',
      description: 'Fast single-shot detector for general objects.',
      imageAsset: 'assets/images/sam_example.jpg',
      downloadUrl: 'https://example.com/models/ssd_mobilenet.tflite',
      defaultFileName: 'ssd_mobilenet.tflite',
    ),
  ];



  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final crossAxisCount = isWide ? 2 : 1;

    // Return only the page content; parent provides Scaffold/AppBar
    return Padding(
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
          return ModelCard(
            id: m.id,
            title: m.title,
            description: m.description,
            imageAsset: m.imageAsset,
            downloadUrl: m.downloadUrl,
            defaultFileName: m.defaultFileName,
          );
        },
      ),
    );
  }
}

