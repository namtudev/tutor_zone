import 'package:flutter/material.dart';

/// Reusable text field for authentication forms
/// Supports email, password, and general text input with validation
class AuthTextField extends StatefulWidget {
  /// Creates a new [AuthTextField]
  const AuthTextField({
    required this.controller,
    required this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.validator,
    this.enabled = true,
    this.autofillHints,
    this.textInputAction,
    this.onFieldSubmitted,
    super.key,
  });

  /// Text editing controller
  final TextEditingController controller;

  /// Label text
  final String labelText;

  /// Hint text
  final String? hintText;

  /// Keyboard type
  final TextInputType keyboardType;

  /// Whether this is a password field
  final bool isPassword;

  /// Validation function
  final String? Function(String?)? validator;

  /// Whether the field is enabled
  final bool enabled;

  /// Autofill hints
  final Iterable<String>? autofillHints;

  /// Text input action
  final TextInputAction? textInputAction;

  /// Callback when field is submitted
  final void Function(String)? onFieldSubmitted;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword && _obscureText,
      enabled: widget.enabled,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
