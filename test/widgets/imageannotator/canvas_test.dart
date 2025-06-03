import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_annotator/widgets/imageannotator/canvas.dart' as annotator_canvas;
import 'package:image_annotator/widgets/imageannotator/canvas_painter.dart';
import 'package:image_annotator/models/annotation.dart';
import 'package:image_annotator/models/label.dart';
import 'package:image_annotator/models/shape/rect_shape.dart';

// Helper function to create a dummy ui.Image for testing
Future<ui.Image> createTestImage(int width, int height) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder); // Use Flutter's Canvas, not our custom one
  final paint = Paint()..color = Colors.white;
  canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);
  return recorder.endRecording().toImage(width, height);
}

void main() {
  late ui.Image testImage;

  setUpAll(() async {
    // Create the test image once for all tests
    testImage = await createTestImage(100, 100);
  });

  group('Canvas Widget Tests', () {
    testWidgets('displays image using CustomPaint', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: annotator_canvas.Canvas(
              image: testImage,
              annotations: [],
              labelDefinitions: [],
              onAnnotationCreated: (annotation) {},
              activeTool: null,
            ),
          ),
        ),
      );

      // Verify that CustomPaint is used (which implies the image is being drawn)
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('bounding box drawing interaction creates annotation', (WidgetTester tester) async {
      Annotation? createdAnnotation;
      final List<Annotation> annotations = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: annotator_canvas.Canvas(
              image: testImage,
              annotations: annotations,
              labelDefinitions: [],
              onAnnotationCreated: (annotation) {
                createdAnnotation = annotation;
                annotations.add(annotation); // Add to list to simulate update
              },
              activeTool: "bounding_box", // Set bounding_box tool active
            ),
          ),
        ),
      );

      // Ensure the widget is fully built and matrix is set
      await tester.pumpAndSettle();

      // Simulate a pan gesture
      final Offset startPoint = Offset(10, 10);
      final Offset endPoint = Offset(60, 60); // Results in a 50x50 rect

      // Start the gesture
      final TestGesture gesture = await tester.startGesture(startPoint);
      await tester.pump(); // Let widget rebuild for gesture start

      // Verify temporary points are passed to CustomPaint's painter
      CustomPaint customPaint = tester.widget(find.byType(CustomPaint));
      CanvasPainter painter = customPaint.painter as CanvasPainter;
      // At start, points are usually [start, start]. Let's check after an update.

      // Update the gesture
      await gesture.moveTo(endPoint);
      await tester.pump(); // Let widget rebuild for gesture update

      // Verify painter has current points (transformed to image space)
      // This requires knowing the transformation, which is tricky here.
      // A simpler check is that onAnnotationCreated will eventually be called.
      // For a more robust test of currentPoints in painter, one might need to
      // expose painter state or use a captor if painter itself was mockable.

      customPaint = tester.widget(find.byType(CustomPaint));
      painter = customPaint.painter as CanvasPainter;
      expect(painter.currentPoints.length, 2, reason: "Painter should have 2 current points during drag");
      // Note: painter.currentPoints are in image space.
      // The exact values depend on the initial matrix transform of the canvas.
      // For simplicity here, we'll focus on the final annotation.

      // End the gesture
      await gesture.up();
      await tester.pumpAndSettle(); // Let widget rebuild and process gesture end

      // Verify an annotation was created
      expect(createdAnnotation, isNotNull, reason: "onAnnotationCreated should be called");
      expect(createdAnnotation, isA<Annotation>());

      // Verify the shape of the annotation
      expect(createdAnnotation!.shape, isA<RectShape>(), reason: "Shape should be RectShape");
      final RectShape createdRectShape = createdAnnotation!.shape as RectShape;

      // Due to the default matrix scaling (0.9) and potential translation,
      // the coordinates won't be exactly 10,10 to 60,60.
      // They are transformed. For this test, let's check for positive width/height.
      // A more precise test would calculate the expected transformed coordinates.
      expect(createdRectShape.width, greaterThan(0));
      expect(createdRectShape.height, greaterThan(0));

      // Example of how one might check points if the transformation was identity or known:
      // Assuming _screenToImageSpace was accessible or matrix was identity for testing:
      // expect(createdRectShape.x, closeTo(10.0 / scale, 0.1));
      // expect(createdRectShape.y, closeTo(10.0 / scale, 0.1));
      // expect(createdRectShape.width, closeTo(50.0 / scale, 0.1));
      // expect(createdRectShape.height, closeTo(50.0 / scale, 0.1));

      // Verify that _currentPoints is cleared in CanvasState after pan end
      // This is internal state, but its effect is that painter.currentPoints should be empty.
      customPaint = tester.widget(find.byType(CustomPaint));
      painter = customPaint.painter as CanvasPainter;
      expect(painter.currentPoints.isEmpty, isTrue, reason: "Painter currentPoints should be empty after gesture.");
    });
  });
}
