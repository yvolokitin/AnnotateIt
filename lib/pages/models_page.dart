import 'package:flutter/material.dart';

import '../widgets/model_cards/model_card.dart';
import '../widgets/model_cards/model_card_build_in.dart';
import '../widgets/model_cards/model_card_comming_soon.dart';
import '../widgets/model_cards/models_top_bar.dart';
import '../config/model_registry_urls.dart';

import '../gen_l10n/app_localizations.dart';

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
        urlEncoder: ModelRegistryUrls.sam2HieraBasePlusEncoder,
        urlDecoder: ModelRegistryUrls.sam2HieraBasePlusDecoder,
        urlConfig: ModelRegistryUrls.sam2HieraBasePlusConfig,
        shaEncoder:
            '53b79cec15f2078b3c7410f00f00950a09ef02007dccf238859fec156e42cc8d',
        shaDecoder:
            '666f00ce2664de31211a71068b6b74c3fc5aeee089ebeb2fc9c37834b9ce03b4',
        shaConfig:
            '9a1b2e1976daf9d802aba4b330d9bfb1438948aff8328716b80884b1124d4428',
        modelSize: '352Mb',
      ),
      ModelInfo(
        id: 'sam2_hiera_large',
        title: 'SAM2 Hiera Large',
        description: l10n.modelDescriptionSAM2HieraLarge,
        imageAsset: 'assets/images/sam_example.jpg',
        urlEncoder: ModelRegistryUrls.sam2HieraLargeEncoder,
        urlDecoder: ModelRegistryUrls.sam2HieraLargeDecoder,
        urlConfig: ModelRegistryUrls.sam2HieraLargeConfig,
        shaEncoder:
            'cb252d7b59fdeb2567f7134ed9f23d712e4f24584628913bbcb0ea72ba72b617',
        shaDecoder:
            '2b5a3d40a017e61d2cb4fac7147ebf899d24b082753fb5049be3810d2318ca07',
        shaConfig:
            'bce77bef82f523bec8daedfbaeac252d43075534574cc4579876d78678f4fab5',
        modelSize: '860Mb',
      ),
      ModelInfo(
        id: 'classification_efficientnet-tflite-lite4-fp32-v2',
        title: 'EfficientNet-Lite4',
        description:
            "EfficientNet-Lite4 FP32v2 is a convolutional neural network (CNN) from the EfficientNet-Lite family, designed for image classification on mobile and edge devices. EfficientNet-Lite models provide a strong balance of accuracy and efficiency, using fewer parameters and computations than many traditional CNNs. The FP32v2 variant is distributed in TensorFlow Lite format, making it directly usable in mobile and embedded applications for real-time image classification. While FP32 ensures maximum accuracy, smaller quantized versions (e.g., INT8) offer lower latency and power consumption on constrained hardware.",
        imageAsset:
            'assets/images/efficientnet-tflite-lite4-classification.jpg',
        urlEncoder: ModelRegistryUrls.efficientNetLite4Classifier,
        urlDecoder: '',
        urlConfig: ModelRegistryUrls.efficientNetLite4ClassifierLabels,
        shaEncoder:
            'f0d69132ee9759f2d98e817f7a96a28e40384d3c1894f222c4e6653d9e285586',
        shaDecoder: '',
        shaConfig:
            'ff830819b4418bc52ce12b81398e2d7f6fbf09f98584cd83f3f92629a3074eb7',
        modelSize: '50Mb',
      ),
      ModelInfo(
        id: 'efficientdet-tflite-lite4-detection-metadata-v2',
        title: 'EfficientDet-Lite4',
        description:
            "EfficientDet-Lite4 is an object detection model optimized for mobile and edge devices. It uses an EfficientNet-Lite4 backbone with a BiFPN feature network to achieve strong accuracy while keeping the model size small and inference fast.     Task: Object detection (bounding boxes + labels) Dataset: Trained on COCO (90 common object classes). Format: TensorFlow Lite with metadata (easy integration and standardized input/output). Input: 320×320 RGB image (normalized to 0–1). Output: Bounding boxes, class IDs (0–89), and confidence scores",
        imageAsset: 'assets/images/efficientnet-tflite-lite4-detection.jpg',
        urlEncoder: ModelRegistryUrls.efficientDetLite4Detector,
        urlDecoder: '',
        urlConfig: ModelRegistryUrls.cocoLabels,
        shaEncoder:
            '0d9b3ffe97d6d9e78ac1632f4b63630f35e39c87d20349b648268d671c7730c5',
        shaDecoder: '',
        shaConfig:
            '4d4aaea7bee6be2f675d9b53a9195ca36dfe6429f7479f29155da522a6c85930',
        modelSize: '20Mb',
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
