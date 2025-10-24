import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

/// Authentication user model
/// Represents a user in the application
@freezed
abstract class AuthUser with _$AuthUser {
  const AuthUser._();

  /// Creates a new [AuthUser] instance
  const factory AuthUser({
    required String uid,
    String? email,
    String? displayName,
    String? photoURL,
    @Default(false) bool emailVerified,
    String? phoneNumber,
  }) = _AuthUser;

  /// Create AuthUser from Firebase User
  factory AuthUser.fromFirebaseUser(firebase_auth.User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      emailVerified: user.emailVerified,
      phoneNumber: user.phoneNumber,
    );
  }

  /// Creates an [AuthUser] from JSON
  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);
}
