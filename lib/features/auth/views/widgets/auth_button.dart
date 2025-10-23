import 'package:flutter/material.dart';

/// Primary action button for authentication forms
/// Shows loading indicator when isLoading is true
class AuthButton extends StatelessWidget {
  /// Creates a new [AuthButton]
  const AuthButton({
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    super.key,
  });

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button text
  final String text;

  /// Whether to show loading indicator
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(text),
      ),
    );
  }
}
