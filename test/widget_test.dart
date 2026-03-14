// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('App boots smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AnnotateItApp());
    await tester.pump();

    expect(find.byType(AnnotateItApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);

    // Drain delayed startup overlay timer/animation to avoid pending-timer failure.
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Navigation controls render and respond', (WidgetTester tester) async {
    await tester.pumpWidget(const AnnotateItApp());
    await tester.pump();

    final accountNav = find.byIcon(Icons.account_circle_outlined);
    final aboutNav = find.byIcon(Icons.error_outline_rounded);

    expect(accountNav, findsWidgets);
    expect(aboutNav, findsWidgets);

    await tester.tap(accountNav.first);
    await tester.pumpAndSettle();
    await tester.tap(aboutNav.first);
    await tester.pumpAndSettle();

    expect(find.byType(AnnotateItApp), findsOneWidget);
  });
}
