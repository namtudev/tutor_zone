import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_zone/core/access_mode/app_access_mode.dart';
import 'package:tutor_zone/core/common_widgets/app_snackbar.dart';
import 'package:tutor_zone/features/auth/controllers/auth_controller.dart';
import 'package:tutor_zone/features/auth/utils/auth_validators.dart';
import 'package:tutor_zone/features/auth/views/ui_states/auth_state.dart';
import 'package:tutor_zone/features/auth/views/widgets/auth_button.dart';
import 'package:tutor_zone/features/auth/views/widgets/auth_divider.dart';
import 'package:tutor_zone/features/auth/views/widgets/auth_text_field.dart';
import 'package:tutor_zone/features/auth/views/widgets/google_sign_in_button.dart';
import 'package:tutor_zone/router/route_path.dart';

/// Custom sign-in screen with email/password and Google Sign-In
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes for feedback
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      switch (next) {
        case Authenticated():
          context.showSuccessSnackBar('Signed in successfully');
        case AuthError(:final message):
          context.showErrorSnackBar(message);
        default:
          break;
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState == const AuthState.loading();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App logo/title
                    Icon(
                      Icons.school,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tutor Zone',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Email field
                    AuthTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: AuthValidators.validateEmail,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    AuthTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      isPassword: true,
                      validator: AuthValidators.validatePassword,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSignIn(),
                    ),
                    const SizedBox(height: 8),

                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : () => context.push(RoutePath.forgotPassword),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign in button
                    AuthButton(
                      onPressed: _handleSignIn,
                      text: 'Sign In',
                      isLoading: isLoading,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final router = GoRouter.of(context);
                              await ref.read(appAccessModeProvider.notifier).setMode(AppAccessMode.local);
                              if (!mounted) {
                                return;
                              }
                              router.go(RoutePath.dashboard);
                            },
                      icon: const Icon(Icons.offline_pin),
                      label: const Text('Continue without account'),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    const AuthDivider(),
                    const SizedBox(height: 24),

                    // Google sign-in button
                    const GoogleSignInButton(),
                    const SizedBox(height: 24),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: isLoading ? null : () => context.push(RoutePath.signUp),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
