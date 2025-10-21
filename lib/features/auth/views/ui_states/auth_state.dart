import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tutor_zone/features/auth/models/data/auth_user.dart';

part 'auth_state.freezed.dart';

/// Authentication state (Freezed v3 sealed class for union types)
/// Represents the current authentication status of the user
@freezed
sealed class AuthState with _$AuthState {
  const AuthState._();

  /// Initial state - authentication status unknown
  const factory AuthState.initial() = Initial;

  /// Loading state - authentication in progress
  const factory AuthState.loading() = Loading;

  /// Authenticated state - user is signed in
  const factory AuthState.authenticated(AuthUser user) = Authenticated;

  /// Unauthenticated state - user is signed out
  const factory AuthState.unauthenticated() = Unauthenticated;

  /// Error state - authentication error occurred
  const factory AuthState.error(String message, {StackTrace? stackTrace}) = AuthError;

  /// Guard method for authenticated operations
  /// Mimics AsyncValue.guard behavior for cleaner error handling
  /// Returns AuthState.authenticated on success, AuthState.error on failure
  static Future<AuthState> guard(Future<AuthUser> Function() future) async {
    try {
      final user = await future();
      return AuthState.authenticated(user);
    } catch (err, stack) {
      return AuthState.error(err.toString(), stackTrace: stack);
    }
  }

  /// Guard method for void operations (like signOut)
  /// Returns AuthState.unauthenticated on success, AuthState.error on failure
  static Future<AuthState> guardVoid(Future<void> Function() future) async {
    try {
      await future();
      return const AuthState.unauthenticated();
    } catch (err, stack) {
      return AuthState.error(err.toString(), stackTrace: stack);
    }
  }
}
