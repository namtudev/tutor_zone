import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

/// Google Sign-In button using OAuthProviderButton
/// Uses GoogleProvider from firebase_ui_oauth_google
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.clientId,
    super.key,
  });

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return OAuthProviderButton(
      provider: GoogleProvider(
        clientId: clientId,
      ),
    );
  }
}
