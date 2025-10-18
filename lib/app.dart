import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/flavors.dart';
import 'package:tutor_zone/router/app_router.dart';

/// Main application widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: F.title,
      debugShowCheckedModeBanner: false,
      // green jungle theme builtin by FlexColorScheme
      theme: FlexThemeData.light(scheme: FlexScheme.jungle),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.jungle),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
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
