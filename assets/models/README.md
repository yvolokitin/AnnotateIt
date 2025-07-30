# TensorFlow Lite Models for AnnotateIt

This directory is where you should place TensorFlow Lite model files that are used by the application for object detection.

## Required Model Files

The application is looking for the following files:

1. `ssd_mobilenet.tflite` - The SSD MobileNet model file for object detection
2. `ssd_mobilenet_labels.txt` - The labels file containing class names for the model

## How to Obtain the Model Files

### Option 1: Download Pre-trained Models

You can download pre-trained SSD MobileNet models from the TensorFlow Model Zoo:

1. Visit [TensorFlow Lite Model Zoo](https://www.tensorflow.org/lite/examples/object_detection/overview)
2. Download the SSD MobileNet model (either v1 or v2)
3. Rename the downloaded .tflite file to `ssd_mobilenet.tflite`
4. Create a text file named `ssd_mobilenet_labels.txt` with the COCO dataset labels (or use the labels file that came with the model)

### Option 2: Convert Your Own Model

If you have your own trained TensorFlow model, you can convert it to TensorFlow Lite format:

1. Use the [TensorFlow Lite Converter](https://www.tensorflow.org/lite/convert) to convert your model
2. Save the converted model as `ssd_mobilenet.tflite` in this directory
3. Create a text file named `ssd_mobilenet_labels.txt` with your model's class labels (one label per line)

## Example Labels File Format

The `ssd_mobilenet_labels.txt` file should contain one class label per line, for example:

```
person
bicycle
car
motorcycle
airplane
bus
train
truck
...
```

## Placement

After obtaining the model files, place them in this directory (`assets/models/`). The application will automatically load them when needed.

## Note

If you don't place the model files in this directory, the application will look for them in the application's documents directory. You can manually copy the files there if you prefer not to bundle them with the application.