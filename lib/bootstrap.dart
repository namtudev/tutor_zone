import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/flavors.dart';

/// Initializes the application.
/// Ensures that Flutter widgets are initialized, sets the flavor,
/// initializes logging, and creates a ProviderContainer for state management.
/// Returns a ProviderContainer which is used to manage the state of the application.
Future<ProviderContainer> bootstrap({
  required FlavorConfig flavorConfig,
  required Widget Function() appBuilder,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the current flavor
  F.setFlavor(flavorConfig.flavor);

  // Initialize logger
  initializeTalker();
  logInfo('🚀 Bootstrapping Tutor Zone - ${flavorConfig.appName}');

  // Initialize app-specific configurations
  await _initializeApp(flavorConfig);

  // Create a ProviderContainer with error logging
  final container = ProviderContainer(
    observers: <ProviderObserver>[const _ErrorLogger()],
  );

  // Initialize providers
  await _initProviders(container, flavorConfig);

  return container;
}

/// Initialize application configurations
Future<void> _initializeApp(FlavorConfig flavorConfig) async {
  try {
    logInfo('📝 Initializing app with flavor: ${flavorConfig.flavor.name}');

    // Log flavor configuration
    if (flavorConfig.enableLogging) {
      logInfo('✓ Debug logging enabled');
    }

    if (flavorConfig.enableAnalytics) {
      logInfo('✓ Analytics enabled');
    }

    logInfo('✓ API Base URL: ${flavorConfig.apiBaseUrl}');

    // Add more initialization logic here as needed
    // - Initialize databases
    // - Initialize services
    // - Load configuration
    // - etc.

    logInfo('✅ Application initialization complete');
  } catch (e, stackTrace) {
    logError('❌ Error during app initialization', e, stackTrace);
    rethrow;
  }
}

/// Initialize providers
Future<void> _initProviders(
  ProviderContainer container,
  FlavorConfig flavorConfig,
) async {
  try {
    // Initialize any required providers here
    // Example:
    // await container.read(authRepositoryProvider.notifier).fetchPreviousLogin();
    // container.read(someOtherProvider);

    logInfo('✓ Providers initialized successfully');
  } catch (e, stackTrace) {
    logError('❌ Error initializing providers', e, stackTrace);
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
    logError(
      '[${context.provider.name ?? context.provider.runtimeType}] Provider failed',
      error,
      stackTrace,
    );
  }
}
