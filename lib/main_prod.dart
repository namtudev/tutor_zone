import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_zone/app.dart';
import 'package:tutor_zone/bootstrap.dart';
import 'package:tutor_zone/flavors.dart';

/// Production flavor entry point
Future<void> main() async {
  F.appFlavor = Flavor.prod;
  final container = await bootstrap(flavorConfig: FlavorConfig.prod, appBuilder: () => const App());
  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
