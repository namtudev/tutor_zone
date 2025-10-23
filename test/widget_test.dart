// This is a basic Flutter widget test for Tutor Zone app.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_zone/app.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';

void main() {
  setUpAll(() {
    // Initialize Talker for logging in tests
    initializeTalker();
  });

  testWidgets('App initializes and displays home screen', (WidgetTester tester) async {
    // Build our app with ProviderScope (required for Riverpod)
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    // Verify that app renders without crashing
    expect(find.byType(App), findsOneWidget);
  });
}
