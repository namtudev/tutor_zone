import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/auth/models/repositories/auth_repository.dart';
import 'package:tutor_zone/features/auth/views/ui_states/auth_state.dart';

part 'auth_controller.g.dart';

/// Auth controller provider (Riverpod v3)
/// Manages authentication state and operations
@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    // Listen to auth state changes
    ref.listen(authStateChangesProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            state = AuthState.authenticated(user);
            logInfo('AuthController: User authenticated - ${user.email}');
          } else {
            state = const AuthState.unauthenticated();
            logInfo('AuthController: User unauthenticated');
          }
        },
        loading: () {
          state = const AuthState.loading();
          logInfo('AuthController: Loading auth state');
        },
        error: (error, _) {
          state = AuthState.error(error.toString());
          logError('AuthController: Auth state error', error);
        },
      );
    });

    // Return initial state based on current user
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser != null) {
      logInfo('AuthController: Initial state - Authenticated');
      return AuthState.authenticated(currentUser);
    } else {
      logInfo('AuthController: Initial state - Unauthenticated');
      return const AuthState.unauthenticated();
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    state = await AuthState.guard(
      () => repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );

    // Log result
    switch (state) {
      case Authenticated(:final user):
        logInfo('AuthController: Sign in successful - ${user.email}');
      case AuthError(:final message):
        logError('AuthController: Sign in failed', message);
      default:
        break;
    }
  }

  /// Create user with email and password
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    state = await AuthState.guard(
      () => repository.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );

    // Log result
    switch (state) {
      case Authenticated(:final user):
        logInfo('AuthController: User created - ${user.email}');
      case AuthError(:final message):
        logError('AuthController: User creation failed', message);
      default:
        break;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 1));
    });
    state = const AuthState.loading();
    final repository = ref.read(authRepositoryProvider);
    state = await AuthState.guardVoid(() => repository.signOut());

    // Log result
    switch (state) {
      case Unauthenticated():
        logInfo('AuthController: Sign out successful');
      case AuthError(:final message):
        logError('AuthController: Sign out failed', message);
      default:
        break;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    final repository = ref.read(authRepositoryProvider);
    final result = await AuthState.guardVoid(
      () => repository.sendPasswordResetEmail(email),
    );

    // Log result (doesn't update state, just logs)
    switch (result) {
      case Unauthenticated():
        logInfo('AuthController: Password reset email sent - $email');
      case AuthError(:final message):
        logError('AuthController: Password reset email failed', message);
      default:
        break;
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    final repository = ref.read(authRepositoryProvider);
    final result = await AuthState.guardVoid(
      () => repository.sendEmailVerification(),
    );

    // Log result (doesn't update state, just logs)
    switch (result) {
      case Unauthenticated():
        logInfo('AuthController: Email verification sent');
      case AuthError(:final message):
        logError('AuthController: Email verification failed', message);
      default:
        break;
    }
  }

  /// Update display name
  Future<void> updateDisplayName(String displayName) async {
    final repository = ref.read(authRepositoryProvider);

    // Perform update and get refreshed user
    final result = await AuthState.guardVoid(
      () => repository.updateDisplayName(displayName),
    );

    // Log and refresh state if successful
    switch (result) {
      case Unauthenticated():
        logInfo('AuthController: Display name updated - $displayName');
        // Refresh state with updated user
        final updatedUser = repository.currentUser;
        if (updatedUser != null) {
          state = AuthState.authenticated(updatedUser);
        }
      case AuthError(:final message):
        logError('AuthController: Display name update failed', message);
      default:
        break;
    }
  }

  /// Delete user account
  Future<void> deleteUser() async {
    final repository = ref.read(authRepositoryProvider);
    state = await AuthState.guardVoid(() => repository.deleteUser());

    // Log result
    switch (state) {
      case Unauthenticated():
        logInfo('AuthController: User account deleted');
      case AuthError(:final message):
        logError('AuthController: User deletion failed', message);
      default:
        break;
    }
  }
}
