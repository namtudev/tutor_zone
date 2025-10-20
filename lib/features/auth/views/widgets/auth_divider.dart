import 'package:flutter/material.dart';

/// Divider with text for separating authentication methods
/// Typically used to separate email/password from social sign-in
class AuthDivider extends StatelessWidget {
  const AuthDivider({
    this.text = 'OR',
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
