import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_zone/core/debug_log/logger.dart';
import 'package:tutor_zone/router/route_path.dart';

/// Profile screen using Firebase UI Auth
/// Displays user profile and allows sign-out
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return firebase_ui_auth.ProfileScreen(
      providers: [
        firebase_ui_auth.EmailAuthProvider(),
      ],
      actions: [
        firebase_ui_auth.SignedOutAction((context) {
          logInfo('User signed out from profile');
          context.go(RoutePath.signIn);
        }),
      ],
    );
  }
}
