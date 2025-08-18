import 'package:flutter/material.dart';

import '../widgets/model_cards/model_card.dart';
import '../widgets/model_cards/model_card_build_in.dart';
import '../widgets/model_cards/model_card_comming_soon.dart';
import '../widgets/model_cards/models_top_bar.dart';

import '../../gen_l10n/app_localizations.dart';

class ModelInfo {
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

  const ModelInfo({
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
        shaEncoder: '',
        shaDecoder: '',
        shaConfig: '',
        modelSize: '44Mb',
      ),
      ModelInfo(
        id: 'sam2_hiera_base',
        title: 'SAM2 Hiera Base+',
        description: l10n.modelDescriptionSAM2HieraBasePlus,
        imageAsset: 'assets/images/sam_example.jpg',
        urlEncoder: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/sam2_hiera_base_plus.encoder.onnx',
        urlDecoder: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/sam2_hiera_base_plus.decoder.onnx',
        urlConfig: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/sam2_hiera_base_plus_config.yaml',
        shaEncoder: '53b79cec15f2078b3c7410f00f00950a09ef02007dccf238859fec156e42cc8d',
        shaDecoder: '666f00ce2664de31211a71068b6b74c3fc5aeee089ebeb2fc9c37834b9ce03b4',
        shaConfig: '9a1b2e1976daf9d802aba4b330d9bfb1438948aff8328716b80884b1124d4428',
        modelSize: '352Mb',
      ),
      ModelInfo(
        id: 'sam2_hiera_large',
        title: 'SAM2 Hiera Large',
        description: l10n.modelDescriptionSAM2HieraLarge,
        imageAsset: 'assets/images/sam_example.jpg',
        urlEncoder: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/sam2_hiera_large.encoder.onnx',
        urlDecoder: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/sam2_hiera_large.decoder.onnx',
        urlConfig: 'https://github.com/yvolokitin/segment-anything-onnx-models/releases/download/SAM2_Hiera_Large/sam2_hiera_large_config.yaml',
        shaEncoder: 'cb252d7b59fdeb2567f7134ed9f23d712e4f24584628913bbcb0ea72ba72b617',
        shaDecoder: '2b5a3d40a017e61d2cb4fac7147ebf899d24b082753fb5049be3810d2318ca07',
        shaConfig: 'bce77bef82f523bec8daedfbaeac252d43075534574cc4579876d78678f4fab5',
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
        shaEncoder: '',
        shaDecoder: '',
        shaConfig: '',
        modelSize: 'N/A',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final crossAxisCount = isWide ? 2 : 1;
        final double tileHeight = isWide ? 240 : 180;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModelsTopBar(),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        shaEncoder: m.shaEncoder,
                        shaDecoder: m.shaDecoder,
                        shaConfig: m.shaConfig,
                        modelSize: m.modelSize,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
