import 'package:flutter/material.dart';

/// Type of snackbar message
enum SnackbarType {
  /// Success message (green checkmark icon)
  success,

  /// Error message (red error icon)
  error,

  /// Info message (blue info icon)
  info,
}

/// Minimal, reusable snackbar utility for displaying messages
///
/// Features:
/// - Floating behavior with rounded corners
/// - Custom icons for success/error/info
/// - Consistent styling across the app
/// - Uses default Material theme colors
///
/// Example usage:
/// ```dart
/// AppSnackbar.show(context, 'Operation successful', SnackbarType.success);
/// AppSnackbar.showSuccess(context, 'Signed in successfully');
/// AppSnackbar.showError(context, 'Invalid credentials');
/// AppSnackbar.showInfo(context, 'Check your email');
/// ```
class AppSnackbar {
  AppSnackbar._(); // Private constructor to prevent instantiation

  /// Show a snackbar with the specified type
  static void show(
    BuildContext context,
    String message,
    SnackbarType type,
  ) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(type),
            color: _getIconColor(type),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show a success snackbar (green checkmark icon)
  static void showSuccess(BuildContext context, String message) {
    show(context, message, SnackbarType.success);
  }

  /// Show an error snackbar (red error icon)
  static void showError(BuildContext context, String message) {
    show(context, message, SnackbarType.error);
  }

  /// Show an info snackbar (blue info icon)
  static void showInfo(BuildContext context, String message) {
    show(context, message, SnackbarType.info);
  }

  /// Get the appropriate icon for the snackbar type
  static IconData _getIcon(SnackbarType type) {
    return switch (type) {
      SnackbarType.success => Icons.check_circle,
      SnackbarType.error => Icons.error,
      SnackbarType.info => Icons.info,
    };
  }

  /// Get the appropriate icon color for the snackbar type
  static Color _getIconColor(SnackbarType type) {
    return switch (type) {
      SnackbarType.success => Colors.green,
      SnackbarType.error => Colors.red,
      SnackbarType.info => Colors.blue,
    };
  }
}

/// Extension on BuildContext for convenient snackbar access
extension SnackbarExtension on BuildContext {
  /// Show a success snackbar
  void showSuccessSnackBar(String message) {
    AppSnackbar.showSuccess(this, message);
  }

  /// Show an error snackbar
  void showErrorSnackBar(String message) {
    AppSnackbar.showError(this, message);
  }

  /// Show an info snackbar
  void showInfoSnackBar(String message) {
    AppSnackbar.showInfo(this, message);
  }
}
