# Firebase Auth + Riverpod v3 + GoRouter Best Practices

**Last Updated**: January 19, 2025
**Project**: Tutor Zone
**Approach**: Manual routing (without go_router_builder code generation)

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Firebase Authentication Setup](#firebase-authentication-setup)
3. [Riverpod v3 State Management](#riverpod-v3-state-management)
4. [GoRouter Configuration](#gorouter-configuration)
5. [Authentication Flow](#authentication-flow)
6. [Route Protection](#route-protection)
7. [Code Examples](#code-examples)
8. [Testing Strategies](#testing-strategies)
9. [Common Pitfalls](#common-pitfalls)

---

## Architecture Overview

### Component Responsibilities

```
┌─────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
│  ┌────────────┐  ┌────────────┐  ┌────────────────────────┐ │
│  │  GoRouter  │  │  Riverpod  │  │  Firebase Auth         │ │
│  │  (Routes)  │──│ (State Mgmt│──│  (Authentication)      │ │
│  └────────────┘  └────────────┘  └────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
         │                │                    │
         ▼                ▼                    ▼
    Navigation      Auth State           User Session
    & Guards        Providers            Management
```

**Key Principles:**
- **Firebase Auth** manages user authentication and session
- **Riverpod v3** exposes auth state reactively to the app
- **GoRouter** handles navigation and route protection based on auth state
- **Stream-based** approach for real-time auth state updates

---

## Firebase Authentication Setup

### 1. Initialize Firebase in bootstrap.dart

```dart
// lib/bootstrap.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tutor_zone/config/firebase_options_dev.dart' as dev;
import 'package:tutor_zone/config/firebase_options_staging.dart' as staging;
import 'package:tutor_zone/config/firebase_options_prod.dart' as prod;
import 'package:tutor_zone/flavors.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Select Firebase options based on flavor
  final firebaseOptions = switch (F.appFlavor) {
    Flavor.dev => dev.DefaultFirebaseOptions.currentPlatform,
    Flavor.staging => staging.DefaultFirebaseOptions.currentPlatform,
    Flavor.production => prod.DefaultFirebaseOptions.currentPlatform,
  };

  await Firebase.initializeApp(options: firebaseOptions);

  // Optional: Connect to Auth Emulator for dev
  if (F.appFlavor == Flavor.dev) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }
}
```

### 2. Authentication Methods

**Email/Password Sign In:**
```dart
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

// Sign up
Future<UserCredential> signUp(String email, String password) async {
  try {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Send email verification
    await credential.user?.sendEmailVerification();

    return credential;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      throw Exception('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      throw Exception('An account already exists for that email.');
    }
    rethrow;
  }
}

// Sign in
Future<UserCredential> signIn(String email, String password) async {
  try {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      throw Exception('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      throw Exception('Wrong password provided.');
    }
    rethrow;
  }
}

// Sign out
Future<void> signOut() async {
  await _auth.signOut();
}
```

**Google Sign In:**
```dart
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential> signInWithGoogle() async {
  // Trigger authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  if (googleUser == null) {
    throw Exception('Google sign in aborted');
  }

  // Obtain auth details
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  // Create credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}
```

---

## Riverpod v3 State Management

### 1. Auth State Stream Provider

**Key Principle**: Use `StreamProvider` to expose Firebase's `authStateChanges()` stream.

```dart
// lib/features/auth/controllers/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

// Auth state stream provider (Riverpod v3)
@riverpod
Stream<User?> authStateChanges(Ref ref) {  // Note: Just 'Ref', not 'AuthStateChangesRef'
  return FirebaseAuth.instance.authStateChanges();
}

// Current user provider (derived from stream)
@riverpod
User? currentUser(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
}
```

### 2. Auth Repository Pattern

```dart
// lib/features/auth/controllers/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(FirebaseAuth.instance);
}

class AuthRepository {
  AuthRepository(this._auth);

  final FirebaseAuth _auth;

  // Auth state stream
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign up with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.sendEmailVerification();
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase Auth exceptions
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found for that email.');
      case 'wrong-password':
        return Exception('Wrong password provided.');
      case 'email-already-in-use':
        return Exception('An account already exists for that email.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      case 'invalid-email':
        return Exception('The email address is invalid.');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}
```

### 3. Auth Controller (UI Actions)

```dart
// lib/features/auth/controllers/auth_controller.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/features/auth/controllers/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  // Sign in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  // Sign up
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  // Sign out
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(authRepositoryProvider).signOut();
    });
  }
}
```

---

## GoRouter Configuration

### 1. Router with Auth State Integration

**Key Pattern**: Use `refreshListenable` to rebuild routes when auth state changes.

```dart
// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_zone/features/auth/controllers/auth_controller.dart';
import 'package:tutor_zone/features/auth/screens/login_screen.dart';
import 'package:tutor_zone/features/dashboard/screens/dashboard_screen.dart';
import 'package:tutor_zone/router/router_listenable.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state for route refresh
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: RoutePath.login,

    // Refresh routes when auth state changes
    refreshListenable: RouterListenable(ref, authState),

    redirect: (context, state) {
      // Get current auth state
      final isLoading = authState is AsyncLoading;
      final isAuthenticated = authState.value != null;

      final isGoingToLogin = state.matchedLocation == RoutePath.login;
      final isGoingToPublic = _publicRoutes.contains(state.matchedLocation);

      // Show splash/loading while checking auth
      if (isLoading) {
        return RoutePath.splash;
      }

      // Redirect to login if not authenticated and trying to access protected route
      if (!isAuthenticated && !isGoingToPublic) {
        return '${RoutePath.login}?from=${Uri.encodeComponent(state.matchedLocation)}';
      }

      // Redirect to home if authenticated and trying to access login
      if (isAuthenticated && isGoingToLogin) {
        // Check for redirect query parameter
        final from = state.uri.queryParameters['from'];
        return from ?? RoutePath.home;
      }

      // No redirect needed
      return null;
    },

    routes: [
      GoRoute(
        path: RoutePath.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePath.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePath.home,
        builder: (context, state) => const DashboardScreen(),
      ),
      // ... more routes
    ],

    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

// Route paths
abstract class RoutePath {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const profile = '/profile';
  static const settings = '/settings';
}

// Public routes (accessible without authentication)
const _publicRoutes = {
  RoutePath.splash,
  RoutePath.login,
};
```

### 2. RouterListenable for Auth State

```dart
// lib/router/router_listenable.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Makes GoRouter refresh when auth state changes
class RouterListenable extends ChangeNotifier {
  RouterListenable(this.ref, this.authState) {
    // Listen to auth state changes
    ref.listen<AsyncValue>(
      authStateChangesProvider,
      (previous, next) {
        // Notify GoRouter to rebuild when auth state changes
        notifyListeners();
      },
    );
  }

  final Ref ref;
  final AsyncValue authState;
}
```

### 3. Route Guards (Alternative Pattern)

For more complex route protection, you can use per-route redirects:

```dart
GoRoute(
  path: RoutePath.profile,
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authStateChangesProvider);

    final isAuthenticated = authState.value != null;
    if (!isAuthenticated) {
      return '${RoutePath.login}?from=${Uri.encodeComponent(state.matchedLocation)}';
    }

    return null; // Allow navigation
  },
  builder: (context, state) => const ProfileScreen(),
),
```

---

## Authentication Flow

### 1. Login Screen with State Management

```dart
// lib/features/auth/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_zone/features/auth/controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(authControllerProvider.notifier);
    await controller.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // Handle result
    final state = ref.read(authControllerProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _signIn,
                child: authState.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. Listen to Auth State Changes

```dart
// In your widget
@override
Widget build(BuildContext context, WidgetRef ref) {
  // Listen to auth state
  ref.listen(authStateChangesProvider, (previous, next) {
    next.when(
      data: (user) {
        if (user != null) {
          // User signed in
          logInfo('User signed in: ${user.email}');
        } else {
          // User signed out
          logInfo('User signed out');
        }
      },
      loading: () => logDebug('Auth state loading...'),
      error: (error, stack) => logError('Auth error', error, stack),
    );
  });

  // ... rest of build method
}
```

---

## Route Protection

### 1. Global Redirect Strategy

**Best Practice**: Use a single top-level `redirect` function in GoRouter.

```dart
redirect: (context, state) {
  final container = ProviderScope.containerOf(context);
  final authState = container.read(authStateChangesProvider);

  final isLoading = authState is AsyncLoading;
  final isAuthenticated = authState.value != null;

  final currentPath = state.matchedLocation;
  final isPublicRoute = _publicRoutes.contains(currentPath);

  // 1. Show loading while checking auth
  if (isLoading && currentPath != RoutePath.splash) {
    return RoutePath.splash;
  }

  // 2. Redirect to login if not authenticated
  if (!isAuthenticated && !isPublicRoute) {
    return '${RoutePath.login}?from=${Uri.encodeComponent(currentPath)}';
  }

  // 3. Redirect to home if already authenticated and on login page
  if (isAuthenticated && currentPath == RoutePath.login) {
    final from = state.uri.queryParameters['from'];
    return from ?? RoutePath.home;
  }

  // 4. Allow navigation
  return null;
},
```

### 2. Deep Linking with Auth

```dart
// Handle deep links while preserving auth flow
redirect: (context, state) {
  final container = ProviderScope.containerOf(context);
  final authState = container.read(authStateChangesProvider);

  final isAuthenticated = authState.value != null;
  final targetPath = state.matchedLocation;

  if (!isAuthenticated && !_publicRoutes.contains(targetPath)) {
    // Save deep link destination
    return '${RoutePath.login}?from=${Uri.encodeComponent(targetPath)}';
  }

  return null;
},
```

### 3. Role-Based Access Control

```dart
// Add user role provider
@riverpod
Future<UserRole> userRole(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return UserRole.guest;

  // Fetch role from Firestore or custom claims
  final idTokenResult = await user.getIdTokenResult();
  final role = idTokenResult.claims?['role'] as String?;

  return UserRole.fromString(role);
}

// Use in redirect
redirect: (context, state) {
  final container = ProviderScope.containerOf(context);
  final roleAsync = container.read(userRoleProvider);

  return roleAsync.when(
    data: (role) {
      if (state.matchedLocation.startsWith('/admin') && role != UserRole.admin) {
        return RoutePath.home; // Redirect non-admins
      }
      return null;
    },
    loading: () => RoutePath.splash,
    error: (_, __) => RoutePath.login,
  );
},
```

---

## Testing Strategies

### 1. Testing Auth Repository

```dart
// test/features/auth/auth_repository_test.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_zone/features/auth/controllers/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    late MockFirebaseAuth mockAuth;
    late AuthRepository repository;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      repository = AuthRepository(mockAuth);
    });

    test('signInWithEmailAndPassword returns UserCredential on success', () async {
      final credential = await repository.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(credential.user, isNotNull);
      expect(credential.user!.email, 'test@example.com');
    });

    test('signOut signs out user', () async {
      await repository.signOut();
      expect(mockAuth.currentUser, isNull);
    });
  });
}
```

### 2. Testing Auth State Provider

```dart
// test/features/auth/auth_controller_test.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  test('authStateChanges emits user when signed in', () async {
    final container = ProviderContainer.test(
      overrides: [
        authRepositoryProvider.overrideWithValue(
          AuthRepository(MockFirebaseAuth(signedIn: true)),
        ),
      ],
    );
    addTearDown(container.dispose);

    final authState = await container.read(authStateChangesProvider.future);
    expect(authState, isNotNull);
  });
}
```

### 3. Testing Router Redirects

```dart
// test/router/app_router_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('redirects to login when not authenticated', (tester) async {
    final container = ProviderContainer.test(
      overrides: [
        authStateChangesProvider.overrideWith((ref) => Stream.value(null)),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp.router(
          routerConfig: container.read(routerProvider),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should be on login screen
    expect(find.text('Login'), findsOneWidget);
  });
}
```

---

## Common Pitfalls

### ❌ Don't: Use `ref.read` to watch auth state in UI

```dart
// BAD - won't rebuild when auth state changes
final user = ref.read(currentUserProvider);
```

### ✅ Do: Use `ref.watch` to reactively watch auth state

```dart
// GOOD - rebuilds when auth state changes
final user = ref.watch(currentUserProvider);
```

---

### ❌ Don't: Forget to handle loading states

```dart
// BAD - doesn't handle AsyncLoading
redirect: (context, state) {
  final user = authState.value;
  if (user == null) return '/login';
  return null;
},
```

### ✅ Do: Handle all AsyncValue states

```dart
// GOOD - handles loading, data, and error
redirect: (context, state) {
  if (authState is AsyncLoading) return '/splash';
  if (authState.value == null) return '/login';
  return null;
},
```

---

### ❌ Don't: Create multiple auth state streams

```dart
// BAD - creates separate streams
final stream1 = FirebaseAuth.instance.authStateChanges();
final stream2 = FirebaseAuth.instance.authStateChanges();
```

### ✅ Do: Use a single provider for auth state

```dart
// GOOD - single source of truth
@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return FirebaseAuth.instance.authStateChanges();
}
```

---

### ❌ Don't: Use `context.go()` immediately after sign in

```dart
// BAD - manual navigation after auth change
await signIn();
context.go('/home');
```

### ✅ Do: Let GoRouter's redirect handle navigation

```dart
// GOOD - GoRouter automatically redirects based on auth state
await signIn();
// Router's refreshListenable detects change and redirects automatically
```

---

### ❌ Don't: Ignore deep link query parameters

```dart
// BAD - loses intended destination
if (!isAuthenticated) return '/login';
```

### ✅ Do: Preserve deep link with query parameters

```dart
// GOOD - preserves intended destination
if (!isAuthenticated) {
  return '/login?from=${Uri.encodeComponent(state.matchedLocation)}';
}
```

---

## Additional Resources

- **Firebase Auth Documentation**: https://firebase.google.com/docs/auth/flutter/start
- **Riverpod Documentation**: https://riverpod.dev
- **GoRouter Documentation**: https://pub.dev/packages/go_router
- **Project Riverpod v3 Guide**: `/doc/riverpod_v3`
- **Project Firebase Setup**: `/doc/FIREBASE_SETUP.md`

---

## Changelog

| Date | Changes |
|------|---------|
| 2025-01-19 | Initial document created with best practices for Firebase Auth + Riverpod v3 + GoRouter integration |

---

**Status**: ✅ Production-Ready
**Maintainer**: Tutor Zone Development Team
