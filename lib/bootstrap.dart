import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_zone/config/firebase_options_dev.dart' as firebase_dev;
import 'package:tutor_zone/config/firebase_options_prod.dart' as firebase_prod;
import 'package:tutor_zone/config/firebase_options_staging.dart' as firebase_staging;
import 'package:tutor_zone/core/access_mode/app_access_mode.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/flavors.dart';

/// Initializes the application.
/// Ensures that Flutter widgets are initialized, sets the flavor,
/// initializes logging, and creates a ProviderContainer for state management.
/// Returns a ProviderContainer which is used to manage the state of the application.
Future<ProviderContainer> bootstrap({
  required FlavorConfig flavorConfig,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the current flavor
  F.setFlavor(flavorConfig.flavor);

  // Initialize logger
  initializeTalker();
  logInfo('Bootstrapping Tutor Zone - ${flavorConfig.appName}');

  // Determine persisted access mode before bootstrapping services
  final accessMode = await loadInitialAccessMode();
  logInfo('App starting in ${accessMode.name} mode');

  // Initialize app-specific configurations
  await _initializeApp(flavorConfig, accessMode);

  // Create a ProviderContainer with error logging
  final container = ProviderContainer(
    observers: <ProviderObserver>[const _ErrorLogger()],
  );

  // Initialize providers
  await _initProviders(container, flavorConfig, accessMode);

  return container;
}

/// Initialize application configurations
Future<void> _initializeApp(
  FlavorConfig flavorConfig,
  AppAccessMode accessMode,
) async {
  try {
    logInfo('Initializing app with flavor: ${flavorConfig.flavor.name}');

    // Initialize Firebase with flavor-specific configuration
    await _initializeFirebase(flavorConfig.flavor);

    // Log flavor configuration
    if (flavorConfig.enableLogging) {
      logInfo('Debug logging enabled');
    }

    if (flavorConfig.enableAnalytics) {
      logInfo('Analytics enabled');
    }

    logInfo('API Base URL: ${flavorConfig.apiBaseUrl}');

    // Add more initialization logic here as needed
    // - Initialize databases
    // - Initialize services
    // - Load configuration
    // - etc.

    logInfo('Application initialization complete');
  } catch (e, stackTrace) {
    logError('Error during app initialization', e, stackTrace);
    rethrow;
  }
}

/// Initialize Firebase with the correct configuration based on flavor
Future<void> _initializeFirebase(Flavor flavor) async {
  try {
    logInfo('Initializing Firebase for ${flavor.name} environment...');

    // Select the appropriate Firebase options based on flavor
    final FirebaseOptions firebaseOptions;
    switch (flavor) {
      case Flavor.dev:
        firebaseOptions = firebase_dev.DefaultFirebaseOptions.currentPlatform;
      case Flavor.staging:
        firebaseOptions = firebase_staging.DefaultFirebaseOptions.currentPlatform;
      case Flavor.prod:
        firebaseOptions = firebase_prod.DefaultFirebaseOptions.currentPlatform;
    }

    // Initialize Firebase
    await Firebase.initializeApp(options: firebaseOptions);

    logInfo('Firebase initialized successfully (${firebaseOptions.projectId})');
  } catch (e, stackTrace) {
    logError('Error initializing Firebase', e, stackTrace);
    rethrow;
  }
}

/// Initialize providers
Future<void> _initProviders(
  ProviderContainer container,
  FlavorConfig flavorConfig,
  AppAccessMode accessMode,
) async {
  try {
    logInfo('Access mode passed to provider init: ${accessMode.name}');
    final mode = await container.read(appAccessModeProvider.future);
    logInfo('Initial access mode provider value: ${mode.name}');

    // Initialize any required providers here
    // Example:
    // await container.read(authRepositoryProvider.notifier).fetchPreviousLogin();
    // container.read(someOtherProvider);

    logInfo('Providers initialized successfully');
  } catch (e, stackTrace) {
    logError('Error initializing providers', e, stackTrace);
    rethrow;
  }
}

/// Logs errors that occur in providers.
base class _ErrorLogger extends ProviderObserver {
  /// Creates an instance of `_ErrorLogger`.
  const _ErrorLogger();

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (newValue.runtimeType.toString().startsWith('AsyncError')) {
      logError(
        '[${context.provider.name}] Provider error',
        newValue,
        StackTrace.current,
      );
    }
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    logError('[${context.provider.name ?? context.provider.runtimeType}] Provider failed', error, stackTrace);
  }
}
