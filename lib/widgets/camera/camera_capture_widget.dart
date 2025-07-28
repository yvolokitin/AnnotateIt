import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class CameraCaptureWidget extends StatefulWidget {
  final Function(File file, String fileType) onMediaCaptured;
  final VoidCallback onCancel;

  const CameraCaptureWidget({
    Key? key,
    required this.onMediaCaptured,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<CameraCaptureWidget> createState() => _CameraCaptureWidgetState();
}

class _CameraCaptureWidgetState extends State<CameraCaptureWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _capturedImage;
  bool _isPreviewMode = false;

  Future<void> _pickImage() async {
    try {
      String dialogTitle = 'Select Photo';
      String dialogContent = 'Please select a photo from your gallery.';
      
      if (Platform.isWindows) {
        dialogTitle = 'Windows Camera';
        dialogContent = 'We will help you take a photo using Windows Camera app.';
      }
      
      // Show appropriate dialog based on platform
      if (Platform.isWindows || Platform.isMacOS) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(dialogTitle),
            content: Text(dialogContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
      
      // Use gallery picker
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        
        // Generate a unique filename
        final String filename = '${const Uuid().v4()}.jpg';
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String filePath = path.join(appDir.path, filename);
        
        // Copy the file to the app directory
        final File savedFile = await imageFile.copy(filePath);
        
        setState(() {
          _capturedImage = savedFile;
          _isPreviewMode = true;
        });
      }
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to capture image: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCancel();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
  
  void _acceptImage() {
    if (_capturedImage != null) {
      widget.onMediaCaptured(_capturedImage!, 'jpg');
    }
  }
  
  void _rejectImage() {
    setState(() {
      _capturedImage = null;
      _isPreviewMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Preview mode UI
    if (_isPreviewMode && _capturedImage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _rejectImage,
          ),
          title: const Text(
            'Preview',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            // Image preview
            Expanded(
              child: Center(
                child: Image.file(
                  _capturedImage!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Accept/Reject buttons
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject button
                  ElevatedButton.icon(
                    onPressed: _rejectImage,
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text('Retake'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                  // Accept button
                  ElevatedButton.icon(
                    onPressed: _acceptImage,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Use Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // Camera selection UI for all platforms
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onCancel,
        ),
        title: const Text(
          'Camera Capture',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.white70,
            ),
            const SizedBox(height: 20),
            Text(
              Platform.isWindows 
                  ? 'Take a photo with Windows Camera'
                  : Platform.isMacOS
                      ? 'Select a photo from your gallery'
                      : 'Choose capture option',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // Capture button
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                child: const Icon(Icons.camera_alt, size: 40, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              Platform.isWindows
                  ? 'Click to launch Windows Camera'
                  : Platform.isMacOS
                      ? 'Click to select from gallery'
                      : 'Click to capture',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}