import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

/// Google Sign-In button using OAuthProviderButton
/// Uses GoogleProvider from firebase_ui_oauth_google
class GoogleSignInButton extends StatelessWidget {
  /// Creates a new [GoogleSignInButton]
  const GoogleSignInButton({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    return OAuthProviderButton(
      provider: GoogleProvider(
        clientId: '', // TODO set web client ID for linux/windows
      ),
    );
  }
}
