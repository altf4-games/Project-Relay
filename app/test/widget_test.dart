// This is a basic Flutter widget test for Relay app.

import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('Relay app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RelayApp());

    // Verify that the login screen loads
    expect(find.text('RELAY'), findsOneWidget);
    expect(find.text('HOST IP'), findsOneWidget);
    expect(find.text('CONNECT'), findsOneWidget);
  });
}
