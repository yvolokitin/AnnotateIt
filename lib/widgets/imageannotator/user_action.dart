enum UserAction {
  navigation,
  bbox_annotation,
  samPoint,
  samBox,  

  classification, // not implemented yet
  polygon_annotation, // not implemented yet
  ml_kit_labeling, // Google ML Kit image labeling
  tflite_detection, // TFLite Flutter object detection
}
