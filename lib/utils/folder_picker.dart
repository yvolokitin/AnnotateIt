import 'package:file_selector/file_selector.dart';

Future<String?> pickFolderPath() async {
  final directory = await getDirectoryPath();
  return directory;
}
