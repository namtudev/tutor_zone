import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_config.freezed.dart';

/// Type-safe route definition with immutable collections
///
/// Usage:
/// ```dart
/// context.goNamed(Routes.dashboard.name);
/// context.go(Routes.studentProfile.pathWithParams({'id': '123'}));
/// ```
@freezed
abstract class AppRoute with _$AppRoute {
  const AppRoute._();

  const factory AppRoute({
    /// Route name for named navigation
    required String name,

    /// Route path (can include path parameters like ':id')
    required String path,

    /// List of path parameter names (e.g., ['id', 'tab'])
    @Default(IListConst([])) IList<String> pathParameters,

    /// Optional query parameters
    @Default(IListConst([])) IList<String> queryParameters,

    /// Whether this route requires authentication
    @Default(true) bool requiresAuth,
  }) = _AppRoute;

  /// Build path with parameter substitution
  /// Example: '/students/:id'.withParams({'id': '123'}) => '/students/123'
  String pathWithParams(Map<String, String> params) {
    var result = path;
    for (final entry in params.entries) {
      result = result.replaceAll(':${entry.key}', entry.value);
    }
    return result;
  }
}

/// All application routes
///
/// Organized by feature and navigation hierarchy
class Routes {
  Routes._();

  // ==================== Auth ====================
  static const signIn = AppRoute(
    name: 'sign-in',
    path: '/sign-in',
    requiresAuth: false,
  );

  static const signUp = AppRoute(
    name: 'sign-up',
    path: '/sign-up',
    requiresAuth: false,
  );

  static const forgotPassword = AppRoute(
    name: 'forgot-password',
    path: '/forgot-password',
    requiresAuth: false,
  );

  static const profile = AppRoute(
    name: 'profile',
    path: '/profile',
  );

  // ==================== Dashboard ====================
  static const dashboard = AppRoute(
    name: 'dashboard',
    path: '/dashboard',
  );

  // ==================== Students ====================
  static const students = AppRoute(
    name: 'students',
    path: '/students',
  );

  static const studentProfile = AppRoute(
    name: 'student-profile',
    path: ':id', // Relative path under /students
    pathParameters: IListConst(['id']),
  );

  // ==================== Timer ====================
  static const timer = AppRoute(
    name: 'timer',
    path: '/timer',
  );

  // ==================== Payments ====================
  static const payments = AppRoute(
    name: 'payments',
    path: '/payments',
  );

  // ==================== Reports ====================
  static const reports = AppRoute(
    name: 'reports',
    path: '/reports',
  );

  // ==================== Settings ====================
  static const settings = AppRoute(
    name: 'settings',
    path: '/settings',
  );

  // ==================== Error ====================
  static const notFound = AppRoute(
    name: 'not-found',
    path: '/404',
    requiresAuth: false,
  );

  /// All routes as an immutable list
  static final all = IList<AppRoute>(const [
    signIn,
    signUp,
    forgotPassword,
    profile,
    dashboard,
    students,
    studentProfile,
    timer,
    payments,
    reports,
    settings,
    notFound,
  ]);
}

/// Route groups for easier management
class RouteGroups {
  RouteGroups._();

  /// Main navigation routes (shown in bottom nav / nav rail)
  static final navigation = IList<AppRoute>(const [
    Routes.dashboard,
    Routes.students,
    Routes.timer,
    Routes.payments,
    Routes.reports,
    Routes.settings,
  ]);

  /// Student-related routes
  static final studentRoutes = IList<AppRoute>(const [
    Routes.students,
    Routes.studentProfile,
  ]);

  /// Routes that require authentication
  static final authenticatedRoutes = IList<AppRoute>(
    Routes.all.where((route) => route.requiresAuth),
  );

  /// Public routes (no auth required)
  static final publicRoutes = IList<AppRoute>(
    Routes.all.where((route) => !route.requiresAuth),
  );
}

/// Route navigation items for UI rendering
@freezed
abstract class NavigationItem with _$NavigationItem {
  const factory NavigationItem({
    required String label,
    required AppRoute route,
    required String icon,
    required String selectedIcon,
  }) = _NavigationItem;
}

/// Navigation configuration for main tabs
class NavigationConfig {
  NavigationConfig._();

  /// Main navigation items matching the order in MainShellScreen
  static final items = IList<NavigationItem>(const [
    NavigationItem(
      label: 'Dashboard',
      route: Routes.dashboard,
      icon: 'dashboard_outlined',
      selectedIcon: 'dashboard',
    ),
    NavigationItem(
      label: 'Students',
      route: Routes.students,
      icon: 'people_outline',
      selectedIcon: 'people',
    ),
    NavigationItem(
      label: 'Timer',
      route: Routes.timer,
      icon: 'timer_outlined',
      selectedIcon: 'timer',
    ),
    NavigationItem(
      label: 'Payments',
      route: Routes.payments,
      icon: 'payments_outlined',
      selectedIcon: 'payments',
    ),
    NavigationItem(
      label: 'Reports',
      route: Routes.reports,
      icon: 'analytics_outlined',
      selectedIcon: 'analytics',
    ),
    NavigationItem(
      label: 'Settings',
      route: Routes.settings,
      icon: 'settings_outlined',
      selectedIcon: 'settings',
    ),
  ]);

  /// Get navigation index for a given route path
  static int? getIndexForPath(String path) {
    // Extract the base path (e.g., '/students/123' -> '/students')
    final basePath = path.split('/').take(2).join('/');

    for (var i = 0; i < items.length; i++) {
      if (items[i].route.path == basePath) {
        return i;
      }
    }
    return null;
  }

  /// Get route for a navigation index
  static AppRoute? getRouteForIndex(int index) {
    if (index < 0 || index >= items.length) return null;
    return items[index].route;
  }
}
