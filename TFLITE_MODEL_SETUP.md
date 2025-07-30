# TensorFlow Lite Model Setup for AnnotateIt

## Issue Resolution

This document addresses the following error messages:

```
WARNING: TFLiteDetectionService: Model file not found: ssd_mobilenet.tflite
WARNING: TFLiteDetectionService: Model file not found: ssd_mobilenet_labels.txt
SEVERE: TFLiteDetectionService: Model or labels file not found
```

## Changes Made

The following changes have been implemented to resolve this issue:

1. Created a dedicated `assets/models/` directory for TensorFlow Lite model files
2. Updated `pubspec.yaml` to include this directory in the app's assets
3. Modified `TFLiteDetectionService` to:
   - First check for model files in the application's documents directory
   - If not found there, try to load them from assets
   - Copy asset files to a local directory for use by the TFLite interpreter
4. Added a sample labels file (`assets/models/ssd_mobilenet_labels.txt`)
5. Created documentation on how to obtain and use the model files

## How to Resolve the Error

To resolve the "Model file not found" errors, you need to obtain the SSD MobileNet model file and place it in the correct location. You have two options:

### Option 1: Bundle the Model with the App (Recommended)

1. Download a pre-trained SSD MobileNet model from the [TensorFlow Lite Model Zoo](https://www.tensorflow.org/lite/examples/object_detection/overview)
2. Rename the downloaded .tflite file to `ssd_mobilenet.tflite`
3. Place this file in the `assets/models/` directory
4. The labels file is already provided at `assets/models/ssd_mobilenet_labels.txt`
5. Rebuild and run the app

### Option 2: Load the Model at Runtime

If you prefer not to bundle the model with the app (e.g., to reduce app size):

1. Download a pre-trained SSD MobileNet model as described above
2. Rename it to `ssd_mobilenet.tflite`
3. Copy both the model file and the labels file to the application's documents directory on the user's device
   - On Windows: `C:\Users\<username>\AppData\Roaming\<app_name>\`
   - On macOS: `/Users/<username>/Library/Application Support/<app_name>/`

## Model File Sources

You can obtain SSD MobileNet models from:

1. [TensorFlow Lite Model Zoo](https://www.tensorflow.org/lite/examples/object_detection/overview)
2. [TensorFlow Hub](https://tfhub.dev/s?deployment-format=lite&q=ssd%20mobilenet)
3. [TensorFlow Object Detection API](https://github.com/tensorflow/models/blob/master/research/object_detection/g3doc/tf1_detection_zoo.md)

The SSD MobileNet V1 or V2 models are recommended for their balance of speed and accuracy.

## Customizing the Labels

If you want to use a different set of labels:

1. Edit the `assets/models/ssd_mobilenet_labels.txt` file
2. Ensure each label is on a separate line
3. Make sure the labels match the classes your model was trained on

## Troubleshooting

If you continue to experience issues:

1. Check the application logs for specific error messages
2. Verify that the model file is compatible with TensorFlow Lite
3. Ensure the labels file format is correct (one label per line)
4. Check that the model and labels file are correctly named (`ssd_mobilenet.tflite` and `ssd_mobilenet_labels.txt`)

For more detailed information, refer to the README file in the `assets/models/` directory.