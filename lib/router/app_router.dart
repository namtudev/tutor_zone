import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/auth/views/screens/forgot_password_screen.dart';
import 'package:tutor_zone/features/auth/views/screens/profile_screen.dart';
import 'package:tutor_zone/features/auth/views/screens/sign_in_screen.dart';
import 'package:tutor_zone/features/auth/views/screens/sign_up_screen.dart';
import 'package:tutor_zone/features/dashboard/views/screens/dashboard_screen.dart';
import 'package:tutor_zone/features/home/views/screens/main_shell_screen.dart';
import 'package:tutor_zone/features/payments/views/screens/payments_screen.dart';
import 'package:tutor_zone/features/reports/views/screens/monthly_summary_screen.dart';
import 'package:tutor_zone/features/settings/views/screens/settings_screen.dart';
import 'package:tutor_zone/features/students/views/screens/student_profile_screen.dart';
import 'package:tutor_zone/features/students/views/screens/students_list_screen.dart';
import 'package:tutor_zone/features/timer/views/screens/session_timer_screen.dart';
import 'package:tutor_zone/router/route_config.dart';
import 'package:tutor_zone/router/router_listenable.dart';

part 'app_router.g.dart';

// ==================== Navigator Keys ====================

/// Root navigator key for the entire application
final _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Navigator key for the dashboard branch
final _dashboardNavKey = GlobalKey<NavigatorState>(
  debugLabel: 'dashboard',
);

/// Navigator key for the students branch
final _studentsNavKey = GlobalKey<NavigatorState>(
  debugLabel: 'students',
);

/// Navigator key for the timer branch
final _timerNavKey = GlobalKey<NavigatorState>(
  debugLabel: 'timer',
);

/// Navigator key for the payments branch
final _paymentsNavKey = GlobalKey<NavigatorState>(
  debugLabel: 'payments',
);

/// Navigator key for the reports branch
final _reportsNavKey = GlobalKey<NavigatorState>(
  debugLabel: 'reports',
);

/// Navigator key for the settings branch
final _settingsNavKey = GlobalKey<NavigatorState>(
  debugLabel: 'settings',
);

// ==================== Router Provider ====================

/// Main router configuration using GoRouter with StatefulShellRoute
///
/// This router provides:
/// - Tab-based navigation with state preservation
/// - URL synchronization for web and deep linking
/// - Type-safe routing with named routes
/// - Nested navigation for detail screens
/// - Talker logging for debugging
@riverpod
GoRouter router(Ref ref) {
  final routerNotifier = ref.watch(routerListenableProvider.notifier);

  return GoRouter(
    // Global navigator key
    navigatorKey: _rootNavigatorKey,

    // Start at sign in (redirect will handle auth)
    initialLocation: Routes.signIn.path,

    // Enable debug logging in debug mode
    debugLogDiagnostics: true,

    // Observe route changes with Talker
    observers: [
      TalkerRouteObserver(getTalkerInstance()),
    ],

    // Refresh router when notifier changes (e.g., auth state)
    refreshListenable: routerNotifier,

    // Redirect logic for protected routes
    redirect: (context, state) {
      return routerNotifier.redirect(state.uri.toString());
    },

    // Route configuration
    routes: [
      // ==================== Auth Routes ====================
      GoRoute(
        path: Routes.signIn.path,
        name: Routes.signIn.name,
        pageBuilder: (context, state) => NoTransitionPage(
          key: state.pageKey,
          child: const SignInScreen(),
        ),
      ),
      GoRoute(
        path: Routes.signUp.path,
        name: Routes.signUp.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: Routes.forgotPassword.path,
        name: Routes.forgotPassword.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: Routes.profile.path,
        name: Routes.profile.name,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),

      // Main shell route with bottom navigation
      StatefulShellRoute.indexedStack(
        // Builder for the shell scaffold with navigation
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              // Return the main shell screen with the navigation shell
              return MainShellScreen(navigationShell: navigationShell);
            },

        // Define navigation branches (one per tab)
        branches: [
          // ==================== Branch 0: Dashboard ====================
          StatefulShellBranch(
            navigatorKey: _dashboardNavKey,
            routes: [
              GoRoute(
                path: Routes.dashboard.path,
                name: Routes.dashboard.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const DashboardScreen(),
                ),
              ),
            ],
          ),

          // ==================== Branch 1: Students ====================
          StatefulShellBranch(
            navigatorKey: _studentsNavKey,
            routes: [
              GoRoute(
                path: Routes.students.path,
                name: Routes.students.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const StudentsListScreen(),
                ),
                // Nested routes for student details
                routes: [
                  GoRoute(
                    path: Routes.studentProfile.path, // ':id'
                    name: Routes.studentProfile.name,
                    pageBuilder: (context, state) {
                      final studentId = state.pathParameters['id'];
                      if (studentId == null) {
                        logError('Student ID is null in route parameters');
                        return const NoTransitionPage(
                          child: NotFoundScreen(),
                        );
                      }
                      return NoTransitionPage(
                        key: state.pageKey,
                        child: StudentProfileScreen(studentId: studentId),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ==================== Branch 2: Timer ====================
          StatefulShellBranch(
            navigatorKey: _timerNavKey,
            routes: [
              GoRoute(
                path: Routes.timer.path,
                name: Routes.timer.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const SessionTimerScreen(),
                ),
              ),
            ],
          ),

          // ==================== Branch 3: Payments ====================
          StatefulShellBranch(
            navigatorKey: _paymentsNavKey,
            routes: [
              GoRoute(
                path: Routes.payments.path,
                name: Routes.payments.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const PaymentsScreen(),
                ),
              ),
            ],
          ),

          // ==================== Branch 4: Reports ====================
          StatefulShellBranch(
            navigatorKey: _reportsNavKey,
            routes: [
              GoRoute(
                path: Routes.reports.path,
                name: Routes.reports.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const MonthlySummaryScreen(),
                ),
              ),
            ],
          ),

          // ==================== Branch 5: Settings ====================
          StatefulShellBranch(
            navigatorKey: _settingsNavKey,
            routes: [
              GoRoute(
                path: Routes.settings.path,
                name: Routes.settings.name,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],

    // Error handler for 404 and navigation errors
    errorBuilder: (context, state) {
      logError('Router error: ${state.error}');
      return const NotFoundScreen();
    },
  );
}

// ==================== Error Screens ====================

/// 404 Not Found screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              '404 - Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go(Routes.dashboard.path),
              icon: const Icon(Icons.home),
              label: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
