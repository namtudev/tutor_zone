import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_zone/app.dart';
import 'package:tutor_zone/bootstrap.dart';
import 'package:tutor_zone/flavors.dart';

/// Development flavor entry point
Future<void> main() async {
  F.appFlavor = Flavor.dev;
  final container = await bootstrap(flavorConfig: FlavorConfig.dev);
  runApp(UncontrolledProviderScope(container: container, child: const App()));
}
