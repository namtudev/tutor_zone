import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/auth/controllers/auth_controller.dart';
import 'package:tutor_zone/features/auth/views/ui_states/auth_state.dart';
import 'package:tutor_zone/router/route_config.dart';

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

    // Listen to authentication state changes
    ref.listen(authControllerProvider, (previous, next) {
      logInfo('Auth state changed in router: ${_getAuthStateDescription(next)}');
      // Trigger router refresh when auth state changes
      _routeListener?.call();
    });
  }

  /// Get description of auth state for logging
  String _getAuthStateDescription(AuthState state) {
    return switch (state) {
      Authenticated(:final user) => 'Authenticated: ${user.email}',
      Unauthenticated() => 'Unauthenticated',
      Loading() => 'Loading',
      Initial() => 'Initial',
      Error(:final message) => 'Error: $message',
    };
  }

  /// Redirect logic for handling protected routes
  ///
  /// This method is called by GoRouter's redirect parameter
  /// to determine if a redirect is needed based on current state.
  ///
  /// Returns null if no redirect is needed, or a path string to redirect to.
  String? redirect(String location) {
    logDebug('Router redirect check for location: $location');

    final authState = ref.read(authControllerProvider);
    final isAuthenticated = switch (authState) {
      Authenticated() => true,
      _ => false,
    };

    final isAuthRoute = _isAuthRoute(location);
    final requiresAuth = _requiresAuth(location);

    logDebug('Location: $location, isAuth: $isAuthenticated, '
        'isAuthRoute: $isAuthRoute, requiresAuth: $requiresAuth');

    // If user is authenticated and trying to access auth routes, redirect to dashboard
    if (isAuthenticated && isAuthRoute) {
      logInfo('Authenticated user accessing auth route, redirecting to dashboard');
      return Routes.dashboard.path;
    }

    // If user is not authenticated and trying to access protected route, redirect to sign in
    if (!isAuthenticated && requiresAuth) {
      logInfo('Unauthenticated user accessing protected route, redirecting to sign in');
      return Routes.signIn.path;
    }

    // No redirect needed
    return null;
  }

  /// Check if a route is an authentication route
  bool _isAuthRoute(String location) {
    return location == Routes.signIn.path ||
        location == Routes.forgotPassword.path;
  }

  /// Check if a route requires authentication
  ///
  /// This can be used in redirect logic to protect authenticated routes
  bool _requiresAuth(String location) {
    // Check if location matches any authenticated route
    return RouteGroups.authenticatedRoutes.any((route) {
      // Handle both exact matches and path prefixes
      return location == route.path || location.startsWith('${route.path}/');
    });
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
