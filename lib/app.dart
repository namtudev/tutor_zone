import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/flavors.dart';
import 'package:tutor_zone/router/app_router.dart';

/// Main application widget with Riverpod integration
class App extends ConsumerWidget {
  /// Creates the main [App] widget.
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider to enable Riverpod-based routing
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: F.title,
      debugShowCheckedModeBanner: false,
      // green jungle theme builtin by FlexColorScheme
      theme: FlexThemeData.light(scheme: FlexScheme.jungle),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.jungle),
      themeMode: ThemeMode.dark,
      routerConfig: router,
      // Show Talker logging UI in debug mode
      builder: (context, child) {
        return TalkerWrapper(
          talker: getTalkerInstance(),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
