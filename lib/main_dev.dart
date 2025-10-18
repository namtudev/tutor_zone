import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tutor_zone/app.dart';
import 'package:tutor_zone/bootstrap.dart';
import 'package:tutor_zone/flavors.dart';

/// Development flavor entry point
Future<void> main() async {
  F.appFlavor = Flavor.dev;
  final container = await bootstrap(
    flavorConfig: FlavorConfig.dev,
    appBuilder: () => const App(),
  );
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}
