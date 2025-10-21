import 'package:flutter/material.dart';

/// Primary action button for authentication forms
/// Shows loading indicator when isLoading is true
class AuthButton extends StatelessWidget {
  const AuthButton({
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final String text;
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
