import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/features/auth/models/data/auth_user.dart';

part 'auth_repository.g.dart';

/// Authentication repository provider
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(firebase_auth.FirebaseAuth.instance);
}

/// Current user stream provider
@riverpod
Stream<AuthUser?> authStateChanges(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
}

/// Current user provider
@riverpod
AuthUser? currentUser(Ref ref) {
  final asyncUser = ref.watch(authStateChangesProvider);
  return asyncUser.whenOrNull(data: (user) => user);
}

/// Authentication repository
/// Handles all Firebase Authentication operations
class AuthRepository {
  /// Creates a new [AuthRepository] with the given Firebase Auth instance
  AuthRepository(this._firebaseAuth);

  final firebase_auth.FirebaseAuth _firebaseAuth;

  /// Stream of authentication state changes
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user != null) {
        logInfo('Auth state changed: User signed in - ${user.email}');
        return AuthUser.fromFirebaseUser(user);
      } else {
        logInfo('Auth state changed: User signed out');
        return null;
      }
    });
  }

  /// Get current user
  AuthUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user != null ? AuthUser.fromFirebaseUser(user) : null;
  }

  /// Get Firebase User (for Firebase UI Auth)
  firebase_auth.User? get firebaseUser => _firebaseAuth.currentUser;

  /// Sign in with email and password
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      logInfo('Signing in with email: $email');
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      logInfo('Sign in successful: ${credential.user?.email}');
      return AuthUser.fromFirebaseUser(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      logError('Sign in failed', e, stackTrace);
      throw _handleAuthException(e);
    }
  }

  /// Create user with email and password
  Future<AuthUser> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      logInfo('Creating user with email: $email');
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      logInfo('User created successfully: ${credential.user?.email}');
      return AuthUser.fromFirebaseUser(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      logError('User creation failed', e, stackTrace);
      throw _handleAuthException(e);
    }
  }

  /// Sign in with credential (for Google Sign-In)
  Future<AuthUser> signInWithCredential(
    firebase_auth.AuthCredential credential,
  ) async {
    try {
      logInfo('Signing in with credential');
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      logInfo('Credential sign in successful: ${userCredential.user?.email}');
      return AuthUser.fromFirebaseUser(userCredential.user!);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      logError('Credential sign in failed', e, stackTrace);
      throw _handleAuthException(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      logInfo('Signing out user');
      await _firebaseAuth.signOut();
      logInfo('Sign out successful');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      logError('Sign out failed', e, stackTrace);
      throw _handleAuthException(e);
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      logInfo('Sending password reset email to: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      logInfo('Password reset email sent successfully');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      logError('Password reset email failed', e, stackTrace);
      throw _handleAuthException(e);
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      logInfo('Sending email verification to: ${user.email}');
      await user.sendEmailVerification();
      logInfo('Email verification sent successfully');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      logError('Email verification failed', e, stackTrace);
      throw _handleAuthException(e);
    }
  }

  /// Update display name
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      logInfo('Updating display name to: $displayName');
      await user.updateDisplayName(displayName);
      await user.reload();
      logInfo('Display name updated successfully');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      logError('Display name update failed', e, stackTrace);
      throw _handleAuthException(e);
    }
  }

  /// Update photo URL
  Future<void> updatePhotoURL(String photoURL) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      logInfo('Updating photo URL');
      await user.updatePhotoURL(photoURL);
      await user.reload();
      logInfo('Photo URL updated successfully');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      logError('Photo URL update failed', e, stackTrace);
      throw _handleAuthException(e);
    }
  }

  /// Delete user account
  Future<void> deleteUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      logWarning('Deleting user account: ${user.email}');
      await user.delete();
      logInfo('User account deleted successfully');
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      logError('User deletion failed', e, stackTrace);
      throw _handleAuthException(e);
    }
  }

  /// Handle Firebase Auth exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please sign in again.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}
