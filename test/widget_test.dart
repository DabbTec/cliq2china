// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:cliq2china/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Cliq2ChinaApp());

    // Verify that login screen is shown (welcome text)
    expect(find.text('Welcome back to'), findsOneWidget);
    expect(find.text('Cliq2China'), findsNWidgets(2)); // One in text, one in app title/GetMaterialApp
  });
}
