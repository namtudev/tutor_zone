// This is a basic Flutter widget test for Tutor Zone app.

import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_zone/app.dart';

void main() {
  testWidgets('App initializes and displays home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that app renders without crashing
    expect(find.byType(App), findsOneWidget);
  });
}
