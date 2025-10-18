import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';

/// Route names for type-safe navigation
class RoutePath {
  RoutePath._();

  static const String splash = '/splash';
  static const String home = '/';
  static const String notFound = '/not-found';
}

/// App router configuration using GoRouter
final GoRouter appRouter = GoRouter(
  initialLocation: RoutePath.home,
  debugLogDiagnostics: true,
  observers: [_LoggingNavigatorObserver()],
  routes: [GoRoute(path: RoutePath.home, name: 'home', builder: (context, state) => const HomeScreen())],
  errorBuilder: (context, state) => const NotFoundScreen(),
);

/// Observer for logging navigation events
class _LoggingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    logInfo('Navigated to: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    logInfo('Popped from: ${route.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    logInfo('Removed: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    logInfo('Replaced ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
  }
}

/// Placeholder home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutor Zone')),
      body: const Center(child: Text('Welcome to Tutor Zone')),
    );
  }
}

/// Placeholder not found screen
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('404 - Page Not Found'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.go(RoutePath.home), child: const Text('Go Home')),
          ],
        ),
      ),
    );
  }
}
