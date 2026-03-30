import 'dart:io';
import 'dart:async';
import '../../utils/platform_utils.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../gen_l10n/app_localizations.dart';
import '../../utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';

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
      if (PlatformUtils.isAndroid) {
        _requestCameraPermission().then((granted) {
          if (granted) {
            _initializeCamera();
          } else {
            _showErrorDialog("Camera permission is required to take pictures.");
          }
        });
      } else if (PlatformUtils.isIOS) {
        // On iOS, rely on the camera plugin to request and manage permissions.
        // Avoid using permission_handler to prevent false negatives and duplicate prompts.
        _initializeCamera();
      } else {
        // Other native platforms fall back to existing handling in _initializeCamera
        _initializeCamera();
      }
    } else {
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      // Check if running on unsupported platforms
      if (PlatformUtils.isLinux) {
        _showErrorDialog('Camera functionality is not supported on Linux');
        return;
      }
      
      // For Windows, use image_picker instead of direct camera access
      if (PlatformUtils.isWindows) {
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
      if (PlatformUtils.isWindows) {
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
  // On Windows, we use a special approach:
  // 1. Launch the built-in Windows Camera app using Process.run
  // 2. Guide the user to take a photo and save it
  // 3. Use the gallery picker to select the saved photo
  // This approach is necessary because the image_picker_windows plugin
  // doesn't support direct camera access without a camera delegate
  Future<void> _captureImageWithPicker(ImageSource source) async {
    try {
      if (PlatformUtils.isWindows) {
        // For Windows, launch the built-in Windows Camera app
        try {
          // Show a dialog explaining the process to the user
          final l10n = AppLocalizations.of(context)!;
          final screenWidth = MediaQuery.of(context).size.width;
          final bool? proceed = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: (screenWidth > 1200) ? 34 : 26,
                    color: Theme.of(context).colorScheme.info,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Windows Camera',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.info,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.bold,
                      fontSize: (screenWidth > 1200) ? 26 : 20,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Theme.of(context).colorScheme.info),
                  Padding(
                    padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
                    child: Text(
                      'We will open the native Windows Camera app. After taking a photo, save it and return here to select it.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.muted,
                        fontFamily: 'CascadiaCode',
                        fontWeight: FontWeight.normal,
                        fontSize: (screenWidth > 1200) ? 24 : 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth > 1200 ? 25.0 : 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('1. Take a photo in Camera app', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 6),
                        Text('2. Save the photo to a known location', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 6),
                        Text('3. Return here and press Continue', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.buttonCancel,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.muted,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'CascadiaCode',
                          fontSize: (screenWidth > 1200) ? 22 : 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Theme.of(context).colorScheme.info, width: 2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.buttonContinue,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'CascadiaCode',
                              fontWeight: FontWeight.bold,
                              fontSize: (screenWidth > 1200) ? 22 : 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
          if (proceed != true) {
            widget.onCancel();
            return;
          }
          
          // Launch the Windows Camera app using url_launcher for reliability
          final uri = Uri.parse('microsoft.windows.camera:');
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!launched) {
            throw Exception('Windows Camera app failed to launch');
          }
          
          // Wait a moment to ensure the Camera app has time to launch
          await Future.delayed(const Duration(seconds: 1));
          
          // Show a dialog to guide the user to select the captured image
          final bool proceedToPick = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              final screenWidth = MediaQuery.of(context).size.width;
              final l10n = AppLocalizations.of(context)!;
              return AlertDialog(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: (screenWidth > 1200) ? 34 : 26,
                      color: Theme.of(context).colorScheme.info,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Select Your Photo',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.info,
                        fontFamily: 'CascadiaCode',
                        fontWeight: FontWeight.bold,
                        fontSize: (screenWidth > 1200) ? 26 : 20,
                      ),
                    ),
                  ],
                ),
                content: Padding(
                  padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
                  child: Text(
                    'After taking and saving your photo with the Windows Camera app, click Continue to select the saved photo.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.muted,
                      fontFamily: 'CascadiaCode',
                      fontWeight: FontWeight.normal,
                      fontSize: (screenWidth > 1200) ? 24 : 20,
                    ),
                  ),
                ),
                actions: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.buttonCancel,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.muted,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'CascadiaCode',
                            fontSize: (screenWidth > 1200) ? 22 : 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Theme.of(context).colorScheme.info, width: 2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.buttonContinue,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'CascadiaCode',
                                fontWeight: FontWeight.bold,
                                fontSize: (screenWidth > 1200) ? 22 : 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ) ?? false;
          if (!proceedToPick) {
            widget.onCancel();
            return;
          }
        } catch (e) {
          if (kDebugMode) print('Failed to launch Windows Camera app: $e');
          
          // Show an error dialog and offer to use gallery picker instead
          final bool proceedWithGallery = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              final screenWidth = MediaQuery.of(context).size.width;
              return AlertDialog(
                backgroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: (screenWidth > 1200) ? 34 : 26,
                      color: Theme.of(context).colorScheme.info,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Camera Error',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.info,
                        fontFamily: 'CascadiaCode',
                        fontWeight: FontWeight.bold,
                        fontSize: (screenWidth > 1200) ? 26 : 20,
                      ),
                    ),
                  ],
                ),
                content: Padding(
                  padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Could not launch Windows Camera app: ${e.toString().split('\n')[0]}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.muted,
                          fontFamily: 'CascadiaCode',
                          fontWeight: FontWeight.normal,
                          fontSize: (screenWidth > 1200) ? 24 : 20,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'You can still select a photo from your gallery instead.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.buttonCancel,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.muted,
                            fontWeight: FontWeight.normal,
                            fontFamily: 'CascadiaCode',
                            fontSize: (screenWidth > 1200) ? 22 : 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Theme.of(context).colorScheme.info, width: 2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue with Gallery',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'CascadiaCode',
                                fontWeight: FontWeight.bold,
                                fontSize: (screenWidth > 1200) ? 22 : 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ) ?? false;
          if (!proceedWithGallery) {
            widget.onCancel();
            return;
          }
          
          // Continue with gallery picker
        }
        
        // Use gallery picker to select the captured image
        final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
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
      } else {
        // For web and other platforms, use the standard image picker
        final XFile? pickedFile = await _imagePicker.pickImage(source: source);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.info, width: 1),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              size: (screenWidth > 1200) ? 34 : 26,
              color: Theme.of(context).colorScheme.info,
            ),
            const SizedBox(width: 12),
            Text(
              'Camera Error',
              style: TextStyle(
                color: Theme.of(context).colorScheme.info,
                fontFamily: 'CascadiaCode',
                fontWeight: FontWeight.bold,
                fontSize: (screenWidth > 1200) ? 26 : 20,
              ),
            ),
          ],
        ),
        content: Padding(
          padding: EdgeInsets.all(screenWidth > 1200 ? 25.0 : 12.0),
          child: Text(
            message,
            style: TextStyle(
              color: Theme.of(context).colorScheme.muted,
              fontFamily: 'CascadiaCode',
              fontWeight: FontWeight.normal,
              fontSize: (screenWidth > 1200) ? 24 : 20,
            ),
          ),
        ),
        actions: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onCancel();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.buttonClose,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.muted,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'CascadiaCode',
                    fontSize: (screenWidth > 1200) ? 22 : 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    // For web or Windows, use image_picker with special handling
    // On Windows, this will launch the Windows Camera app via _captureImageWithPicker
    if (kIsWeb || PlatformUtils.isWindows) {
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
    if (kIsWeb || PlatformUtils.isWindows) {
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
      
      // Camera mode UI for Windows
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
              if (PlatformUtils.isWindows) ...[
                const Text(
                  'Take a photo with Windows Camera',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 400,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1. Click the camera button below',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '2. Take a photo using Windows Camera app',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '3. Save the photo to a location you can find',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '4. Return here to select the saved photo',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Choose capture option',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: 40),
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
              if (PlatformUtils.isWindows) ...[
                const SizedBox(height: 20),
                const Text(
                  'Click to launch Windows Camera',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
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
