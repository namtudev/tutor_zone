import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';

part 'router_listenable.g.dart';

/// Router notifier that implements Listenable for GoRouter's refreshListenable
///
/// This notifier is used to trigger router refreshes when app state changes,
/// such as authentication state or other global state that affects routing.
///
/// The notifier is kept alive throughout the app lifecycle to maintain
/// consistent router state.
@Riverpod(keepAlive: true)
class RouterListenable extends _$RouterListenable implements Listenable {
  VoidCallback? _routeListener;

  @override
  void build() {
    logInfo('RouterNotifier initialized');

    // Listen to self to trigger route updates when state changes
    listenSelf((_, _) {
      logDebug('RouterNotifier state changed, notifying router');
      _routeListener?.call();
    });

    // TODO: Add listeners for authentication state changes
    // Example:
    // ref.listen(authStateProvider, (previous, next) {
    //   logInfo('Auth state changed: ${next.isAuthenticated}');
    //   // Trigger router refresh
    // });

    // TODO: Add listeners for other global state that affects routing
    // Example: feature flags, user preferences, etc.
  }

  /// Redirect logic for handling protected routes
  ///
  /// This method is called by GoRouter's redirect parameter
  /// to determine if a redirect is needed based on current state.
  ///
  /// Returns null if no redirect is needed, or a path string to redirect to.
  String? redirect(String location) {
    logDebug('Router redirect check for location: $location');

    // TODO: Implement authentication checks
    // Example:
    // final isAuthenticated = ref.read(authStateProvider).isAuthenticated;
    // if (!isAuthenticated && _requiresAuth(location)) {
    //   return '/login';
    // }

    // No redirect needed
    return null;
  }

  /// Check if a route requires authentication
  ///
  /// This can be used in redirect logic to protect authenticated routes
  bool _requiresAuth(String location) {
    // TODO: Implement based on route configuration
    // Example:
    // return RouteGroups.authenticatedRoutes
    //     .any((route) => location.startsWith(route.path));
    return false;
  }

  /// Refresh the router
  ///
  /// This method can be called to manually trigger a router refresh,
  /// which will re-evaluate all redirects and route configurations.
  void refresh() {
    logInfo('Manual router refresh triggered');
    ref.invalidateSelf();
  }

  // ==================== Listenable Implementation ====================

  /// Adds a listener callback for GoRouter to monitor state changes
  ///
  /// GoRouter uses this to know when to refresh the route configuration.
  /// When [_routeListener] is called, GoRouter will re-evaluate redirects.
  @override
  void addListener(VoidCallback listener) {
    _routeListener = listener;
    logDebug('Router listener added');
  }

  /// Removes the listener callback
  ///
  /// Called by GoRouter when it's disposed.
  @override
  void removeListener(VoidCallback listener) {
    _routeListener = null;
    logDebug('Router listener removed');
  }
}
