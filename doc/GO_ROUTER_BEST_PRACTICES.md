# GoRouter Best Practices Guide

**Last Updated**: January 19, 2025
**Project**: Tutor Zone
**Approach**: Manual routing (without go_router_builder code generation)
**GoRouter Version**: 16.2.5+

## Table of Contents

1. [Introduction](#introduction)
2. [Basic Setup](#basic-setup)
3. [Route Configuration](#route-configuration)
4. [Navigation Methods](#navigation-methods)
5. [Route Parameters](#route-parameters)
6. [Nested Routes & Shell Routes](#nested-routes--shell-routes)
7. [Route Guards & Redirects](#route-guards--redirects)
8. [Error Handling](#error-handling)
9. [Deep Linking](#deep-linking)
10. [Best Practices](#best-practices)
11. [Common Pitfalls](#common-pitfalls)
12. [Migration & Updates](#migration--updates)

---

## Introduction

**GoRouter** is a declarative routing package for Flutter that uses the Router API to provide a convenient, URL-based API for navigating between screens. It supports:

- ✅ Declarative route definitions
- ✅ Deep linking
- ✅ URL-based navigation
- ✅ Nested routes and shell routes
- ✅ Route guards and redirects
- ✅ Type-safe navigation
- ✅ Query parameters and path parameters
- ✅ Custom page transitions

### Why Manual Routing?

This guide focuses on **manual routing** (without `go_router_builder` code generation) because:

- **Flexibility**: Full control over route configuration
- **Simplicity**: No build_runner steps or generated files
- **Transparency**: All routing logic is visible and explicit
- **Debugging**: Easier to trace and debug route issues

---

## Basic Setup

### 1. Add Dependency

```yaml
# pubspec.yaml
dependencies:
  go_router: ^16.2.5
```

### 2. Create Router Configuration

```dart
// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true, // Enable for development

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/details',
      builder: (context, state) => const DetailsScreen(),
    ),
  ],

  errorBuilder: (context, state) => ErrorScreen(error: state.error),
);
```

### 3. Integrate with MaterialApp

```dart
// lib/app.dart
import 'package:flutter/material.dart';
import 'package:tutor_zone/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tutor Zone',
      routerConfig: router,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}
```

---

## Route Configuration

### Basic Route Definition

```dart
GoRoute(
  path: '/profile',
  name: 'profile', // Optional: for named navigation
  builder: (context, state) => const ProfileScreen(),
)
```

### Route with Parameters

```dart
GoRoute(
  path: '/user/:userId',
  name: 'user_detail',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return UserDetailScreen(userId: userId);
  },
)
```

### Route with Query Parameters

```dart
GoRoute(
  path: '/search',
  name: 'search',
  builder: (context, state) {
    // Access query parameters
    final query = state.uri.queryParameters['q'] ?? '';
    final filter = state.uri.queryParameters['filter'] ?? 'all';

    return SearchScreen(query: query, filter: filter);
  },
)
```

### Route with Extra Data

```dart
GoRoute(
  path: '/product/:productId',
  builder: (context, state) {
    final productId = state.pathParameters['productId']!;

    // Access extra data passed during navigation
    final product = state.extra as Product?;

    return ProductScreen(
      productId: productId,
      product: product, // May be null if not provided
    );
  },
)
```

### Nested Routes (Sub-routes)

```dart
GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
  routes: [
    GoRoute(
      path: 'account', // Relative path -> /settings/account
      builder: (context, state) => const AccountSettingsScreen(),
    ),
    GoRoute(
      path: 'notifications', // -> /settings/notifications
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
  ],
)
```

---

## Navigation Methods

### 1. context.go() - Replace Current Route

**Use when**: You want to replace the current route (like tabs or primary navigation)

```dart
// Navigate to a path
context.go('/home');

// Navigate with path parameters
context.go('/user/123');

// Navigate with query parameters
context.go('/search?q=flutter&filter=active');

// Navigate with extra data
context.go(
  '/product/456',
  extra: Product(id: '456', name: 'Widget'),
);
```

### 2. context.push() - Push New Route

**Use when**: You want to add a new route to the stack (like details pages)

```dart
// Push a new route
context.push('/details');

// Push with parameters
context.push('/user/123');

// Push with query params and extra
context.push(
  '/product/789?source=list',
  extra: {'fromCache': true},
);
```

### 3. context.pop() - Pop Current Route

**Use when**: You want to go back to the previous route

```dart
// Simple pop
context.pop();

// Pop with result
context.pop({'success': true});

// In the previous screen, handle result:
final result = await context.push('/edit');
if (result != null && result['success'] == true) {
  // Handle success
}
```

### 4. context.goNamed() - Named Navigation

**Use when**: You prefer named routes for type safety

```dart
// Navigate by name
context.goNamed('user_detail', pathParameters: {'userId': '123'});

// With query parameters
context.goNamed(
  'search',
  queryParameters: {'q': 'flutter', 'page': '1'},
);

// With extra data
context.goNamed(
  'product',
  pathParameters: {'productId': '456'},
  extra: productObject,
);
```

### 5. context.pushNamed() - Push Named Route

```dart
context.pushNamed(
  'user_detail',
  pathParameters: {'userId': '123'},
);
```

### 6. context.replace() / context.pushReplacement()

**Use when**: You want to replace the current route in the stack

```dart
// Replace current route
context.pushReplacement('/success');

// Replace with named route
context.pushReplacementNamed('success');
```

### Navigation Method Comparison

| Method | Stack Effect | Use Case |
|--------|-------------|----------|
| `go()` | Replaces entire stack | Primary navigation, tabs |
| `push()` | Adds to stack | Details, modals |
| `pop()` | Removes top | Go back |
| `replace()` | Replaces top | Success screens, after actions |

---

## Route Parameters

### Path Parameters

```dart
// Define route with path parameter
GoRoute(
  path: '/article/:articleId/comment/:commentId',
  builder: (context, state) {
    final articleId = state.pathParameters['articleId']!;
    final commentId = state.pathParameters['commentId']!;

    return CommentScreen(
      articleId: articleId,
      commentId: commentId,
    );
  },
)

// Navigate
context.go('/article/123/comment/456');
```

### Query Parameters

```dart
// Access in route
GoRoute(
  path: '/products',
  builder: (context, state) {
    final category = state.uri.queryParameters['category'];
    final minPrice = state.uri.queryParameters['minPrice'];
    final maxPrice = state.uri.queryParameters['maxPrice'];

    return ProductListScreen(
      category: category,
      minPrice: minPrice != null ? double.tryParse(minPrice) : null,
      maxPrice: maxPrice != null ? double.tryParse(maxPrice) : null,
    );
  },
)

// Navigate with query parameters
context.go('/products?category=electronics&minPrice=100&maxPrice=500');

// Using goNamed with Map
context.goNamed(
  'products',
  queryParameters: {
    'category': 'electronics',
    'minPrice': '100',
    'maxPrice': '500',
  },
);
```

### Extra Data (Non-URL State)

```dart
// Pass complex objects that shouldn't be in URL
class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});
}

// Navigate with extra
context.push(
  '/product/123',
  extra: Product(id: '123', name: 'Widget', price: 29.99),
);

// Receive in route
GoRoute(
  path: '/product/:productId',
  builder: (context, state) {
    final productId = state.pathParameters['productId']!;
    final product = state.extra as Product?;

    if (product != null) {
      // Use the full product object
      return ProductDetailScreen(product: product);
    } else {
      // Fetch product by ID
      return ProductDetailScreen.fromId(productId);
    }
  },
)
```

---

## Nested Routes & Shell Routes

### Nested Routes (Parent-Child Hierarchy)

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/courses',
      builder: (context, state) => const CoursesScreen(),
      routes: [
        GoRoute(
          path: ':courseId', // Becomes /courses/:courseId
          builder: (context, state) {
            final courseId = state.pathParameters['courseId']!;
            return CourseDetailScreen(courseId: courseId);
          },
          routes: [
            GoRoute(
              path: 'lessons/:lessonId', // Becomes /courses/:courseId/lessons/:lessonId
              builder: (context, state) {
                final courseId = state.pathParameters['courseId']!;
                final lessonId = state.pathParameters['lessonId']!;
                return LessonScreen(
                  courseId: courseId,
                  lessonId: lessonId,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
```

### ShellRoute (Persistent UI)

**Use when**: You want a persistent UI shell (like bottom navigation) around child routes

```dart
final router = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/students',
          builder: (context, state) => const StudentsScreen(),
        ),
        GoRoute(
          path: '/sessions',
          builder: (context, state) => const SessionsScreen(),
        ),
        GoRoute(
          path: '/payments',
          builder: (context, state) => const PaymentsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
```

### MainShell Implementation

```dart
// lib/features/shell/main_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({required this.child, super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<String> _routes = [
    '/dashboard',
    '/students',
    '/sessions',
    '/payments',
    '/settings',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    // Update selected index based on current route
    final currentRoute = GoRouterState.of(context).matchedLocation;
    _selectedIndex = _routes.indexOf(currentRoute);
    if (_selectedIndex == -1) _selectedIndex = 0;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Students',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Sessions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
```

### Breaking Out of ShellRoute

**Use when**: You need a route outside the shell (like login, fullscreen pages)

```dart
final router = GoRouter(
  routes: [
    // Route OUTSIDE shell (no bottom nav)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // ShellRoute with bottom nav
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        // ... other shell routes
      ],
    ),

    // Route OUTSIDE shell (fullscreen detail)
    GoRoute(
      path: '/student/:studentId/fullscreen',
      builder: (context, state) {
        final studentId = state.pathParameters['studentId']!;
        return StudentFullscreenScreen(studentId: studentId);
      },
    ),
  ],
);
```

### Nested ShellRoutes

```dart
ShellRoute(
  builder: (context, state, child) => OuterShell(child: child),
  routes: [
    GoRoute(path: '/a', builder: (context, state) => const ScreenA()),

    // Nested shell inside outer shell
    ShellRoute(
      builder: (context, state, child) => InnerShell(child: child),
      routes: [
        GoRoute(path: '/b', builder: (context, state) => const ScreenB()),
        GoRoute(path: '/c', builder: (context, state) => const ScreenC()),
      ],
    ),
  ],
)
```

---

## Route Guards & Redirects

### Global Redirect (Authentication)

```dart
final router = GoRouter(
  initialLocation: '/',

  // Global redirect - runs for EVERY navigation
  redirect: (context, state) {
    final isAuthenticated = /* check auth state */;
    final isGoingToLogin = state.matchedLocation == '/login';
    final isPublicRoute = _publicRoutes.contains(state.matchedLocation);

    // 1. If not authenticated and not going to public route
    if (!isAuthenticated && !isPublicRoute) {
      // Save intended destination
      return '/login?from=${Uri.encodeComponent(state.matchedLocation)}';
    }

    // 2. If authenticated and trying to access login
    if (isAuthenticated && isGoingToLogin) {
      // Check for redirect destination
      final from = state.uri.queryParameters['from'];
      return from ?? '/dashboard';
    }

    // 3. Allow navigation
    return null;
  },

  routes: [ /* routes */ ],
);

const _publicRoutes = {'/login', '/signup', '/forgot-password'};
```

### Route-Level Redirect

```dart
GoRoute(
  path: '/admin',
  redirect: (context, state) {
    final userRole = /* get user role */;

    if (userRole != 'admin') {
      return '/unauthorized';
    }

    return null; // Allow access
  },
  builder: (context, state) => const AdminDashboard(),
)
```

### Redirect with Query Parameters

```dart
redirect: (context, state) {
  final isAuthenticated = /* check */;

  if (!isAuthenticated) {
    // Preserve query parameters in redirect
    final currentUri = state.uri;
    return '/login?from=${Uri.encodeComponent(currentUri.toString())}';
  }

  return null;
}
```

### Refresh Listenable (Reactive Redirects)

**Use when**: You want redirects to re-evaluate when auth state changes

```dart
// lib/router/router_listenable.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouterListenable extends ChangeNotifier {
  RouterListenable(this.ref, this.authState) {
    ref.listen<AsyncValue>(
      authStateChangesProvider,
      (previous, next) {
        notifyListeners(); // Trigger router refresh
      },
    );
  }

  final Ref ref;
  final AsyncValue authState;
}

// In router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    refreshListenable: RouterListenable(ref, authState),

    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      // ... redirect logic
    },

    routes: [ /* routes */ ],
  );
});
```

### Conditional Route Access

```dart
GoRoute(
  path: '/premium-content',
  redirect: (context, state) {
    final user = /* get current user */;

    if (user == null) {
      return '/login';
    }

    if (!user.isPremium) {
      return '/subscription?required=true';
    }

    return null; // Allow access
  },
  builder: (context, state) => const PremiumContentScreen(),
)
```

---

## Error Handling

### Error Builder

```dart
final router = GoRouter(
  routes: [ /* routes */ ],

  // Custom error page
  errorBuilder: (context, state) {
    return ErrorScreen(
      error: state.error,
      uri: state.uri,
      onRetry: () => context.go('/'),
    );
  },
);
```

### Error Screen Implementation

```dart
// lib/features/error/error_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorScreen extends StatelessWidget {
  final Exception? error;
  final Uri? uri;
  final VoidCallback? onRetry;

  const ErrorScreen({
    this.error,
    this.uri,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (uri != null)
                Text(
                  'Path: ${uri.toString()}',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Error: ${error.toString()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry ?? () => context.go('/'),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 404 Handling

```dart
// All unmatched routes will trigger errorBuilder
// No need for explicit 404 route
```

---

## Deep Linking

### URL Strategy

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart'; // For web

void main() {
  // Remove # from web URLs (optional)
  setPathUrlStrategy();

  runApp(const App());
}
```

### Deep Link Handling

```dart
// Routes automatically handle deep links
// Example: myapp://tutor-zone.com/student/123

GoRoute(
  path: '/student/:studentId',
  builder: (context, state) {
    final studentId = state.pathParameters['studentId']!;
    return StudentDetailScreen(studentId: studentId);
  },
)

// The route will work for:
// - Web: https://tutor-zone.com/student/123
// - Deep link: myapp://tutor-zone.com/student/123
// - In-app: context.go('/student/123')
```

### Platform Configuration

**Android (android/app/src/main/AndroidManifest.xml)**:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="tutor-zone.com" />
</intent-filter>
```

**iOS (ios/Runner/Info.plist)**:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

---

## Best Practices

### ✅ DO: Use Named Routes for Type Safety

```dart
// Define route names as constants
abstract class RoutePath {
  static const home = '/';
  static const login = '/login';
  static const studentDetail = 'student_detail'; // Name for named navigation
}

// Use in routes
GoRoute(
  path: '/student/:studentId',
  name: RoutePath.studentDetail,
  builder: (context, state) => /* ... */,
)

// Navigate using name
context.goNamed(
  RoutePath.studentDetail,
  pathParameters: {'studentId': '123'},
);
```

### ✅ DO: Centralize Route Definitions

```dart
// lib/router/route_paths.dart
abstract class RoutePath {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const studentDetail = '/student/:studentId';
  static const sessionDetail = '/session/:sessionId';
}

// lib/router/route_names.dart
abstract class RouteName {
  static const studentDetail = 'student_detail';
  static const sessionDetail = 'session_detail';
}
```

### ✅ DO: Use context.go() for Primary Navigation

```dart
// Tab/Bottom navigation
onTap: (index) {
  switch (index) {
    case 0:
      context.go('/dashboard');
      break;
    case 1:
      context.go('/students');
      break;
    case 2:
      context.go('/sessions');
      break;
  }
}
```

### ✅ DO: Use context.push() for Secondary Navigation

```dart
// Opening details or modal screens
onPressed: () {
  context.push('/student/${student.id}');
}
```

### ✅ DO: Handle Loading States in Redirects

```dart
redirect: (context, state) {
  final authState = /* get auth state */;

  // Handle loading state
  if (authState is AsyncLoading) {
    return '/splash'; // Show splash while checking auth
  }

  final isAuthenticated = authState.value != null;
  // ... rest of redirect logic
}
```

### ✅ DO: Preserve Deep Links After Login

```dart
redirect: (context, state) {
  final isAuthenticated = /* check */;
  final isGoingToLogin = state.matchedLocation == '/login';

  if (!isAuthenticated && !isGoingToLogin) {
    // Save the intended destination
    return '/login?from=${Uri.encodeComponent(state.matchedLocation)}';
  }

  if (isAuthenticated && isGoingToLogin) {
    // Restore the intended destination
    final from = state.uri.queryParameters['from'];
    return from ?? '/dashboard';
  }

  return null;
}
```

### ✅ DO: Use ShellRoute for Persistent UI

```dart
// Use ShellRoute for bottom nav, side drawer, etc.
ShellRoute(
  builder: (context, state, child) => MainShell(child: child),
  routes: [
    GoRoute(path: '/dashboard', /* ... */),
    GoRoute(path: '/students', /* ... */),
    // ... other routes that share the shell
  ],
)
```

### ✅ DO: Encode/Decode Special Characters

```dart
// GoRouter handles this automatically
// But be aware when manually constructing URLs

// ✅ Good - let GoRouter handle it
context.goNamed(
  'search',
  queryParameters: {'q': 'hello world'},
);

// ❌ Bad - manual URL construction
context.go('/search?q=hello world'); // Space not encoded
```

---

## Common Pitfalls

### ❌ Don't: Manually Call Navigator.pop()

```dart
// ❌ Bad - breaks GoRouter's stack management
Navigator.of(context).pop();

// ✅ Good - use GoRouter's pop
context.pop();
```

### ❌ Don't: Mix go() and push() Incorrectly

```dart
// ❌ Bad - using go() for details (replaces stack)
onPressed: () => context.go('/student/${student.id}'),

// ✅ Good - use push() for details
onPressed: () => context.push('/student/${student.id}'),
```

### ❌ Don't: Forget to Return null in Redirects

```dart
// ❌ Bad - might cause infinite redirect
redirect: (context, state) {
  if (condition) {
    return '/other';
  }
  // Missing return null!
}

// ✅ Good - explicit null return
redirect: (context, state) {
  if (condition) {
    return '/other';
  }
  return null; // Allow navigation
}
```

### ❌ Don't: Create Redirect Loops

```dart
// ❌ Bad - creates infinite loop
GoRoute(
  path: '/a',
  redirect: (context, state) => '/b',
),
GoRoute(
  path: '/b',
  redirect: (context, state) => '/a', // Loops back!
),

// ✅ Good - clear redirect logic
GoRoute(
  path: '/a',
  redirect: (context, state) {
    final condition = /* ... */;
    return condition ? '/b' : null;
  },
),
GoRoute(
  path: '/b',
  builder: (context, state) => const ScreenB(),
),
```

### ❌ Don't: Use BuildContext After Async Operations

```dart
// ❌ Bad - context might be invalid
Future<void> _submit() async {
  await someAsyncOperation();
  context.go('/success'); // Might throw error if widget unmounted
}

// ✅ Good - check mounted
Future<void> _submit() async {
  await someAsyncOperation();
  if (!mounted) return;
  context.go('/success');
}
```

### ❌ Don't: Hardcode Route Paths

```dart
// ❌ Bad - hardcoded paths
context.go('/student/123');

// ✅ Good - use constants
context.go('${RoutePath.students}/123');

// ✅ Better - use named routes
context.goNamed(
  RouteName.studentDetail,
  pathParameters: {'studentId': '123'},
);
```

### ❌ Don't: Ignore Error Handling

```dart
// ❌ Bad - no error handling
final router = GoRouter(
  routes: [ /* routes */ ],
);

// ✅ Good - custom error page
final router = GoRouter(
  routes: [ /* routes */ ],
  errorBuilder: (context, state) => ErrorScreen(error: state.error),
);
```

### ❌ Don't: Access State Parameters Without Null Checks

```dart
// ❌ Bad - might throw if parameter is missing
final userId = state.pathParameters['userId']!;

// ✅ Good - handle missing parameters
final userId = state.pathParameters['userId'];
if (userId == null) {
  return const ErrorScreen(message: 'User ID is required');
}
```

---

## Migration & Updates

### From GoRouter 13.x to 14.x+

**Breaking Changes:**
- `GoRouteData.onExit` now takes 2 parameters: `BuildContext context, GoRouterState state`
- `state.queryParameters` → `state.uri.queryParameters`

```dart
// Old (13.x)
final param = state.queryParameters['id'];

// New (14.x+)
final param = state.uri.queryParameters['id'];
```

### From Provider to Riverpod (Router Integration)

```dart
// Old (with Provider)
ChangeNotifierProvider<AuthNotifier>(
  create: (_) => AuthNotifier(),
)

// New (with Riverpod)
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    refreshListenable: RouterListenable(ref, authState),
    redirect: (context, state) { /* ... */ },
    routes: [ /* ... */ ],
  );
});
```

### Updating Route Definitions

```dart
// When updating routes, test thoroughly:
// 1. Deep links
// 2. Back button behavior
// 3. Redirects and guards
// 4. Query parameters
// 5. Navigation from all entry points
```

---

## Additional Resources

- **Official Documentation**: https://pub.dev/packages/go_router
- **Flutter Navigation Docs**: https://docs.flutter.dev/ui/navigation
- **Project Router**: `lib/router/app_router.dart`
- **Firebase Auth Integration**: `doc/FIREBASE_AUTH_RIVERPOD_GO_ROUTER_BEST_PRACTICES.md`

---

## Quick Reference

### Navigation Cheat Sheet

```dart
// Replace current route
context.go('/path');

// Push new route
context.push('/path');

// Go back
context.pop();

// Named navigation
context.goNamed('name', pathParameters: {}, queryParameters: {});

// With extra data
context.push('/path', extra: object);

// Replace top of stack
context.pushReplacement('/path');
```

### Route Definition Cheat Sheet

```dart
// Basic route
GoRoute(
  path: '/path',
  builder: (context, state) => Screen(),
)

// With parameters
GoRoute(
  path: '/item/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ItemScreen(id: id);
  },
)

// With redirect
GoRoute(
  path: '/admin',
  redirect: (context, state) => checkAuth() ? null : '/login',
  builder: (context, state) => AdminScreen(),
)

// Nested routes
GoRoute(
  path: '/parent',
  builder: (context, state) => ParentScreen(),
  routes: [
    GoRoute(path: 'child', builder: (context, state) => ChildScreen()),
  ],
)
```

---

**Status**: ✅ Production-Ready
**Maintainer**: Tutor Zone Development Team
**Last Reviewed**: January 19, 2025
