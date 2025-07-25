import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../gen_l10n/app_localizations.dart';

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
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFrontCamera = false;
  bool _isPreviewMode = false;
  File? _capturedImage;
  final ImagePicker _imagePicker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeCamera();
    } else {
      // For web, we don't need to initialize the camera in advance
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Check if running on unsupported platforms
      if (Platform.isLinux) {
        _showErrorDialog('Camera functionality is not supported on Linux');
        return;
      }
      
      // For Windows, use image_picker instead of direct camera access
      if (Platform.isWindows) {
        // Don't show error dialog immediately, just set initialized to true
        // so we can use image_picker when the user tries to take a photo
        setState(() {
          _isInitialized = true;
        });
        return;
      }
      
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        _showErrorDialog('No cameras found');
        return;
      }

      // Start with the back camera
      await _initializeCameraController(_cameras![0]);
    } catch (e) {
      // For Windows, the availableCameras() call might fail with MissingPluginException
      // In that case, we'll use image_picker instead
      if (Platform.isWindows) {
        setState(() {
          _isInitialized = true;
        });
      } else {
        _showErrorDialog('Failed to initialize camera: $e');
      }
    }
  }

  Future<void> _initializeCameraController(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      _showErrorDialog('Failed to initialize camera controller: $e');
    }
  }
  
  // Method to handle image capture on web or Windows platform
  Future<void> _captureImageWithPicker(ImageSource source) async {
    try {
      // For Windows, use gallery picker instead of camera to avoid cameraDelegate error
      final ImageSource actualSource = Platform.isWindows ? ImageSource.gallery : source;
      
      final XFile? pickedFile = await _imagePicker.pickImage(source: actualSource);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        
        // Generate a unique filename
        final String filename = '${const Uuid().v4()}.jpg';
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String filePath = path.join(appDir.path, filename);
        
        // Copy the file to the app directory
        final File savedFile = await imageFile.copy(filePath);
        
        // Store the captured image and switch to preview mode
        setState(() {
          _capturedImage = savedFile;
          _isPreviewMode = true;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to capture image: $e');
    }
  }
  
  // This method is no longer used as we're disabling video capture functionality
  // per user's request to only allow photo capture
  Future<void> _captureVideoWithPicker(ImageSource source) async {
    _showErrorDialog('Video capture is disabled. Please use photo capture instead.');
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Error'),
        content: Text(message),
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

  Future<void> _takePicture() async {
    // For web or Windows, use image_picker
    if (kIsWeb || Platform.isWindows) {
      await _captureImageWithPicker(ImageSource.camera);
      return;
    }
    
    if (!_isInitialized || _controller == null) {
      return;
    }

    try {
      final XFile photo = await _controller!.takePicture();
      final File photoFile = File(photo.path);
      
      // Generate a unique filename
      final String filename = '${const Uuid().v4()}.jpg';
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = path.join(appDir.path, filename);
      
      // Copy the file to the app directory
      final File savedFile = await photoFile.copy(filePath);
      
      // Store the captured image and switch to preview mode
      setState(() {
        _capturedImage = savedFile;
        _isPreviewMode = true;
      });
    } catch (e) {
      _showErrorDialog('Failed to take picture: $e');
    }
  }

  // This method is no longer used as we're disabling video capture functionality
  // per user's request to only allow photo capture
  Future<void> _toggleRecording() async {
    _showErrorDialog('Video capture is disabled. Please use photo capture instead.');
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      return;
    }

    setState(() {
      _isInitialized = false;
      _isFrontCamera = !_isFrontCamera;
    });

    final int cameraIndex = _isFrontCamera ? 1 : 0;
    await _initializeCameraController(_cameras![cameraIndex]);
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
    final l10n = AppLocalizations.of(context)!;
    
    // Web or Windows platform UI
    if (kIsWeb || Platform.isWindows) {
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
            title: Text(
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
      
      // Camera mode UI
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onCancel,
          ),
          title: Text(
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
              const SizedBox(height: 30),
              Text(
                'Choose capture option',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              // Circular capture button to match native UI
              GestureDetector(
                onTap: () => _captureImageWithPicker(ImageSource.camera),
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
            ],
          ),
        ),
      );
    }
    
    // Native platform UI
    if (!_isInitialized || _controller == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Preview mode UI for native platforms
    if (_isPreviewMode && _capturedImage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Image preview
            Positioned.fill(
              child: Image.file(
                _capturedImage!,
                fit: BoxFit.contain,
              ),
            ),
            
            // Top bar with back button
            Positioned(
              top: 40,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                onPressed: _rejectImage,
              ),
            ),
            
            // Bottom controls - Accept/Reject buttons
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject button
                  GestureDetector(
                    onTap: _rejectImage,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 40),
                    ),
                  ),
                  
                  // Accept button
                  GestureDetector(
                    onTap: _acceptImage,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 40),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Camera mode UI for native platforms
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          
          // Top bar with close button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: widget.onCancel,
            ),
          ),
          
          // Switch camera button
          if (_cameras != null && _cameras!.length > 1)
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 30),
                onPressed: _switchCamera,
              ),
            ),
          
          // Recording timer removed as we've disabled video recording functionality
          
          // Bottom controls - Only photo capture button as per user's request
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(Icons.camera_alt, size: 40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}