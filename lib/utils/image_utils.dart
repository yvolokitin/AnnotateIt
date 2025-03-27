import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<File?> generateThumbnailFromImage(File imageFile, String projectId) async {
  try {
    // read original image and decode
    final originalBytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(originalBytes);
    if (originalImage == null) return null;

    // resize for thumbnail to use less space from original image
    final thumbnailImage = img.copyResize(originalImage, width: 460);
    final thumbnailBytes = img.encodeJpg(thumbnailImage);

    final directory = await getApplicationDocumentsDirectory();
    final thumbnailsDir = Directory(path.join(directory.path, 'thumbnails'));
    if (!thumbnailsDir.existsSync()) {
      thumbnailsDir.createSync(recursive: true);
    }

    // save thumbnail in the file system
    final thumbnailPath = path.join(thumbnailsDir.path, '$projectId.jpg');
    final thumbnailFile = File(thumbnailPath);
    await thumbnailFile.writeAsBytes(thumbnailBytes);

    print('Thumbnail created at: $thumbnailPath');
    return thumbnailFile;

  } catch (e) {
    print('Error when tried to create thumbnail: $e');
    return null;
  }
}
