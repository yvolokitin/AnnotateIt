// File: lib/pages/project_creation/create_dataset_logic.dart
import 'dart:io';
import 'dart:isolate';
import '../../../utils/dataset_import_utils.dart';

Future<void> extractInIsolate(List<dynamic> args) async {
  final zipPath = args[0] as String;
  final storagePath = args[1] as String; // Already resolved before isolate was spawned
  final sendPort = args[2] as SendPort;

  final zipFile = File(zipPath);

  try {
    final extractedDir = await extractZipToAppFolder(
      zipFile,
      storagePath,
      onProgress: (progress) {
        sendPort.send({"type": "extract_progress", "progress": progress});
      },
    );

    sendPort.send({"type": "extract_done", "path": extractedDir.path});
  } catch (e, stack) {
    sendPort.send({
      "type": "extract_error",
      "error": e.toString(),
      "stack": stack.toString(),
    });
  }
}

Future<void> detectInIsolate(List<dynamic> args) async {
  final path = args[0] as String;
  final sendPort = args[1] as SendPort;
  final dir = Directory(path);

  final taskType = await detectDatasetType(dir, onProgress: (progress) {
    sendPort.send({"type": "detect_progress", "progress": progress});
  });

  sendPort.send({"type": "detect_done", "taskType": taskType});
}

Future<String> getDefaultStoragePath(Future<String> Function() getBasePath) async {
  final basePath = await getBasePath();
  final uniqueFolder = 'dataset_${DateTime.now().millisecondsSinceEpoch}';
  final fullPath = Directory("$basePath/$uniqueFolder");
  await fullPath.create(recursive: true);
  return fullPath.path;
}
