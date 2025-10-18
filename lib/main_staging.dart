import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tutor_zone/app.dart';
import 'package:tutor_zone/bootstrap.dart';
import 'package:tutor_zone/flavors.dart';

/// Staging flavor entry point
Future<void> main() async {
  F.appFlavor = Flavor.staging;
  final container = await bootstrap(
    flavorConfig: FlavorConfig.staging,
    appBuilder: () => const App(),
  );
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const App(),
    ),
  );
}
