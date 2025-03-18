// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vap/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnnotateItApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AnnotateItApp());

    // Verify that the default page is Projects.
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Account'), findsNothing);
    expect(find.text('Learn'), findsNothing);
    expect(find.text('About'), findsNothing);

    // Tap the Account icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle();

    // Verify that the Account page is displayed.
    expect(find.text('Projects'), findsNothing);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Learn'), findsNothing);
    expect(find.text('About'), findsNothing);

    // Tap the Learn icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.school));
    await tester.pumpAndSettle();

    // Verify that the Learn page is displayed.
    expect(find.text('Projects'), findsNothing);
    expect(find.text('Account'), findsNothing);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('About'), findsNothing);

    // Tap the About icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.info));
    await tester.pumpAndSettle();

    // Verify that the About page is displayed.
    expect(find.text('Projects'), findsNothing);
    expect(find.text('Account'), findsNothing);
    expect(find.text('Learn'), findsNothing);
    expect(find.text('About'), findsOneWidget);
  });
}
