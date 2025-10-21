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
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
      logInfo('AuthController: Sign in successful - ${user.email}');
    } catch (e, stackTrace) {
      state = AuthState.error(e.toString());
      logError('AuthController: Sign in failed', e, stackTrace);
    }
  }

  /// Create user with email and password
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = AuthState.authenticated(user);
      logInfo('AuthController: User created - ${user.email}');
    } catch (e, stackTrace) {
      state = AuthState.error(e.toString());
      logError('AuthController: User creation failed', e, stackTrace);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.signOut();
      state = const AuthState.unauthenticated();
      logInfo('AuthController: Sign out successful');
    } catch (e, stackTrace) {
      state = AuthState.error(e.toString());
      logError('AuthController: Sign out failed', e, stackTrace);
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.sendPasswordResetEmail(email);
      logInfo('AuthController: Password reset email sent - $email');
    } catch (e, stackTrace) {
      logError('AuthController: Password reset email failed', e, stackTrace);
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.sendEmailVerification();
      logInfo('AuthController: Email verification sent');
    } catch (e, stackTrace) {
      logError('AuthController: Email verification failed', e, stackTrace);
    }
  }

  /// Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.updateDisplayName(displayName);
      logInfo('AuthController: Display name updated - $displayName');

      // Refresh state
      final updatedUser = repository.currentUser;
      if (updatedUser != null) {
        state = AuthState.authenticated(updatedUser);
      }
    } catch (e, stackTrace) {
      logError('AuthController: Display name update failed', e, stackTrace);
    }
  }

  /// Delete user account
  Future<void> deleteUser() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.deleteUser();
      state = const AuthState.unauthenticated();
      logInfo('AuthController: User account deleted');
    } catch (e, stackTrace) {
      logError('AuthController: User deletion failed', e, stackTrace);
    }
  }
}
