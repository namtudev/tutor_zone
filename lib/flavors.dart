/// Flavor enumeration for development, staging, and production environments
enum Flavor {
  /// Development environment
  dev,

  /// Staging environment
  staging,

  /// Production environment
  prod,
}

/// Flavor configuration class
/// Stores environment-specific settings for API endpoints, logging, analytics, and app name.
class FlavorConfig {
  /// Creates a new [FlavorConfig] with the given settings
  const FlavorConfig({required this.flavor, required this.apiBaseUrl, required this.enableLogging, required this.enableAnalytics, required this.appName});

  /// Development flavor configuration
  static const FlavorConfig dev = FlavorConfig(
    flavor: Flavor.dev,
    apiBaseUrl: 'https://dev-api.example.com',
    enableLogging: true,
    enableAnalytics: false,
    appName: 'Tutor Zone (Dev)',
  );

  /// Staging flavor configuration
  static const FlavorConfig staging = FlavorConfig(
    flavor: Flavor.staging,
    apiBaseUrl: 'https://staging-api.example.com',
    enableLogging: true,
    enableAnalytics: true,
    appName: 'Tutor Zone (Staging)',
  );

  /// Production flavor configuration
  static const FlavorConfig prod = FlavorConfig(
    flavor: Flavor.prod,
    apiBaseUrl: 'https://api.example.com',
    enableLogging: false,
    enableAnalytics: true,
    appName: 'Tutor Zone',
  );

  /// The current flavor
  final Flavor flavor;

  /// API base URL for this environment
  final String apiBaseUrl;

  /// Whether debug logging is enabled
  final bool enableLogging;

  /// Whether analytics is enabled
  final bool enableAnalytics;

  /// Application display name
  final String appName;

  /// Get flavor config by name
  static FlavorConfig getConfig(String flavorName) {
    switch (flavorName.toLowerCase()) {
      case 'dev':
        return dev;
      case 'staging':
        return staging;
      case 'prod':
        return prod;
      default:
        return dev;
    }
  }

  /// Check if current flavor is development
  bool get isDev => flavor == Flavor.dev;

  /// Check if current flavor is staging
  bool get isStaging => flavor == Flavor.staging;

  /// Check if current flavor is production
  bool get isProd => flavor == Flavor.prod;
}

/// Convenience class for accessing the current flavor configuration
/// This mirrors the atlas pattern for easy access throughout the app
class F {
  /// Current app flavor
  static Flavor? appFlavor;
  static FlavorConfig? _config;

  /// Set the flavor and its configuration
  static void setFlavor(Flavor flavor) {
    appFlavor = flavor;
    _config = FlavorConfig.getConfig(flavor.name);
  }

  /// Get the current flavor name
  static String get name => appFlavor?.name ?? '';

  /// Get the app title based on current flavor
  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Tutor Zone (Dev)';
      case Flavor.staging:
        return 'Tutor Zone (Staging)';
      case Flavor.prod:
        return 'Tutor Zone';
      default:
        return 'Tutor Zone';
    }
  }

  /// Get the current flavor configuration
  static FlavorConfig get config => _config ?? FlavorConfig.dev;
}
