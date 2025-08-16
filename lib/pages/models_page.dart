import 'package:flutter/material.dart';
import 'package:annotateit/widgets/model_cards/model_card.dart';
import 'package:annotateit/widgets/model_cards/model_card_build_in.dart';
import 'package:annotateit/widgets/model_cards/model_card_comming_soon.dart';

import '../../gen_l10n/app_localizations.dart';

class ModelInfo {
  final String id;
  final String title;
  final String description;
  final String imageAsset;
  final String urlEncoder;
  final String urlDecoder;
  final String urlConfig;
  final String modelSize;

  const ModelInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.urlEncoder,
    required this.urlDecoder,
    required this.urlConfig,
    required this.modelSize,
  });
}

class ModelPage extends StatefulWidget {
  const ModelPage({super.key});

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<ModelInfo> models = [
      ModelInfo(
        id: 'sam_mobile',
        title: 'SAM Mobile',
        description: l10n.modelDescriptionSamMobile,
        imageAsset: 'assets/images/sam_mobile.jpeg',
        urlEncoder: '',
        urlDecoder: '',
        urlConfig: '',
        modelSize: '44Mb',
      ),
      ModelInfo(
        id: 'sam2_hiera_base',
        title: 'SAM2 Hiera Base+',
        description: l10n.modelDescriptionSAM2HieraBasePlus,
        imageAsset: 'assets/images/sam_example.jpg',
        // NOTE: Use your correct Base+ release paths; placeholders below if needed.
        urlEncoder: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Base_Plus/sam2_hiera_base_plus.encoder.onnx',
        urlDecoder: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Base_Plus/sam2_hiera_base_plus.decoder.onnx',
        urlConfig: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Base_Plus/config.yaml',
        modelSize: '352Mb',
      ),
      ModelInfo(
        id: 'sam2_hiera_large',
        title: 'SAM2 Hiera Large',
        description: l10n.modelDescriptionSAM2HieraLarge,
        imageAsset: 'assets/images/sam_example.jpg',
        urlEncoder: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/sam2_hiera_large.encoder.onnx',
        urlDecoder: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/sam2_hiera_large.decoder.onnx',
        urlConfig: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/config.yaml',
        modelSize: '860Mb',
      ),
      ModelInfo(
        id: 'ssd_mobilenet',
        title: 'SSD MobileNet',
        description: l10n.modelDescriptionSSDMobileNet,
        imageAsset: 'assets/images/ssd_mobilenet.jpg',
        urlEncoder: '',
        urlDecoder: '',
        urlConfig: '',
        modelSize: 'N/A',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final crossAxisCount = isWide ? 2 : 1;
        final double tileHeight = isWide ? 240 : 180;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: tileHeight,
            ),
            itemCount: models.length,
            itemBuilder: (context, index) {
              final m = models[index];
              if (m.id == 'sam_mobile') {
                return ModelCardBuiltIn(
                  id: m.id,
                  title: m.title,
                  description: m.description,
                  imageAsset: m.imageAsset,
                  modelSize: m.modelSize,
                );
              } else if (m.id == 'ssd_mobilenet') {
                return ModelCardCommingSoon(
                  id: m.id,
                  title: m.title,
                  description: m.description,
                  imageAsset: m.imageAsset,
                );
              } else {
                return ModelCard(
                  id: m.id,
                  title: m.title,
                  description: m.description,
                  imageAsset: m.imageAsset,
                  urlEncoder: m.urlEncoder,
                  urlDecoder: m.urlDecoder,
                  urlConfig: m.urlConfig,
                  modelSize: m.modelSize,
                );
              }
            },
          ),
        );
      },
    );
  }
}
