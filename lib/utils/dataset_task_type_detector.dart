import 'dart:convert';
import 'dart:io';

/// Detects all possible dataset task types present in a dataset folder.
///
/// Scans all annotation files (`*.json`, `*.xml`, `*.txt`) recursively and applies dataset-specific
/// heuristics for COCO, YOLO, VOC, Datumaro, LabelMe, CVAT, and custom formats.
///
/// Returns a list of detected task types (zero, one or multiple):
///
/// Allowed types:
/// - "Detection bounding box"
/// - "Detection oriented"
/// - "Anomaly detection"
/// - "Binary Classification"
/// - "Multi-class Classification"
/// - "Multi-label Classification"
/// - "Hierarchical Classification"
/// - "Instance Segmentation"
/// - "Semantic Segmentation"
///
/// ## Detection rules:
///
/// ### JSON files:
/// - **Datumaro:** items > annotations > type = `bbox`, `oriented_bbox`, `polygon`, `mask`
/// - **COCO:** annotations > `bbox`, `oriented_bbox`, `segmentation`, `rle`, `mask`
/// - **LabelMe:** shapes > shape_type = `rectangle`, `polygon`
/// - **Datumaro Classification:** presence of categories / labels keys
///
/// ### XML files (VOC, CVAT, custom):
/// - `<bndbox>` → Detection bounding box
/// - `<oriented_bbox>` → Detection oriented
/// - `<polygon>` → Instance Segmentation
/// - `<segmentation>` or `<mask>` → Semantic Segmentation
///
/// ### TXT files (YOLO or custom):
/// - Single line + 5+ float/int values → Detection bounding box
/// - Single line + 1 value → Binary Classification
/// - Single line + multiple values → Multi-label Classification
///
/// ## Notes:
/// - Non-annotation txt files like `train.txt`, `val.txt`, `test.txt`, `classes.txt`, `obj.names` are ignored.
/// - Scans ALL annotation files (not just first match), resulting in extremely robust multi-task detection.
/// - You can use this in projects where datasets contain mixed annotations (e.g., Detection + Segmentation).
///
/// ## Example usage:
/// ```dart
/// final types = await detectAllDatasetTaskTypes(Directory('/my_dataset'));
/// print(types); // → e.g. ["Detection bounding box", "Instance Segmentation"]
/// ```
Future<List<String>> detectDatasetAllTaskTypes(Directory datasetDir) async {
  final Set<String> types = {};
  final annotationExtensions = ['.json', '.xml', '.txt'];
  final excludedTxtFiles = {'train.txt', 'val.txt', 'test.txt', 'classes.txt', 'obj.names'};

  final allFiles = datasetDir.listSync(recursive: true).whereType<File>().toList();

  final annotationFiles = allFiles.where((f) {
    final path = f.path.toLowerCase();
    final name = f.uri.pathSegments.last.toLowerCase();

    if (path.endsWith('.txt') && excludedTxtFiles.contains(name)) return false;

    return annotationExtensions.any((ext) => path.endsWith(ext));
  }).toList();

  if (annotationFiles.isEmpty) return [];

  try {
    for (final file in annotationFiles) {
      final name = file.path.toLowerCase();

      if (name.endsWith('.json')) {
        final text = await file.readAsString();
        final jsonMap = jsonDecode(text);

        if (jsonMap is Map) {
          // Datumaro
          if (jsonMap.containsKey('items') && jsonMap['items'] is List) {
            final items = jsonMap['items'] as List;
            for (final item in items) {
              if (item is Map && item.containsKey('annotations')) {
                final annotations = item['annotations'] as List;
                for (final annotation in annotations) {
                  if (annotation is Map && annotation.containsKey('type')) {
                    final type = annotation['type'];
                    if (type == 'mask' || type == 'segmentation') types.add("Instance Segmentation");
                    if (type == 'polygon') types.add("Instance Segmentation");
                    if (type == 'oriented_bbox') types.add("Detection oriented");
                    if (type == 'bbox') types.add("Detection bounding box");
                  }
                }
              }
            }
          }

          // COCO
          if (jsonMap.containsKey('annotations')) {
            final annotations = jsonMap['annotations'];
            if (annotations is List) {
              for (final ann in annotations) {
                if (ann is Map) {
                  if (ann.containsKey('segmentation') || ann.containsKey('rle') || ann.containsKey('mask')) {
                    types.add("Instance Segmentation");
                  } else if (ann.containsKey('oriented_bbox')) {
                    types.add("Detection oriented");
                  } else if (ann.containsKey('bbox')) {
                    types.add("Detection bounding box");
                  }
                }
              }
            }
          }

          // LabelMe
          if (jsonMap.containsKey('shapes')) {
            final shapes = jsonMap['shapes'];
            if (shapes is List) {
              for (final shape in shapes) {
                if (shape is Map && shape.containsKey('shape_type')) {
                  final shapeType = shape['shape_type'];
                  if (shapeType == 'polygon') types.add("Instance Segmentation");
                  else if (shapeType == 'rectangle') types.add("Detection bounding box");
                }
              }
            }
          }

          // Datumaro classification fallback
          if (jsonMap.containsKey('categories') || jsonMap.containsKey('labels')) {
            types.add("Multi-class Classification");
          }
        }
      }

      if (name.endsWith('.xml')) {
        final text = await file.readAsString();
        if (text.contains('<segmentation>') || text.contains('<mask>')) types.add("Semantic Segmentation");
        if (text.contains('<polygon>')) types.add("Instance Segmentation");
        if (text.contains('<oriented_bbox>')) types.add("Detection oriented");
        if (text.contains('<bndbox>')) types.add("Detection bounding box");
      }

      if (name.endsWith('.txt')) {
        final lines = await file.readAsLines();
        if (lines.isNotEmpty) {
          for (final line in lines) {
            final parts = line.trim().split(RegExp(r'\s+'));
            if (parts.length >= 5 && parts.every((p) => double.tryParse(p) != null || int.tryParse(p) != null)) {
              types.add("Detection bounding box");
              break;
            } else if (parts.length == 1) {
              types.add("Binary Classification");
              break;
            } else if (parts.length > 1) {
              types.add("Multi-label Classification");
              break;
            }
          }
        }
      }
    }
  } catch (_) {}

  return types.toList();
}
