import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_annotator/widgets/imageannotator/left_toolbar.dart';

void main() {
  group('LeftToolbar Widget Tests', () {
    testWidgets('displays bounding box icon and calls callback on tap', (WidgetTester tester) async {
      String? selectedTool;
      double currentOpacity = 0.5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeftToolbar(
              opacity: currentOpacity,
              onOpacityChanged: (newOpacity) {
                currentOpacity = newOpacity;
              },
              onToolSelected: (tool) {
                selectedTool = tool;
              },
            ),
          ),
        ),
      );

      // Verify the bounding box icon is present
      final boundingBoxIconFinder = find.byIcon(Icons.crop_square);
      expect(boundingBoxIconFinder, findsOneWidget);

      // Tap the bounding box icon
      await tester.tap(boundingBoxIconFinder);
      await tester.pump(); // Rebuild the widget after the tap

      // Verify the callback was called with the correct tool name
      expect(selectedTool, 'bounding_box');
    });

    testWidgets('displays other icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LeftToolbar(
              opacity: 0.5,
              onOpacityChanged: (_) {},
              onToolSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.polyline), findsOneWidget);
      expect(find.byIcon(Icons.select_all), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
