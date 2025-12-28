import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:run_to_canada/core/constants/route_constants.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/custom_button.dart';
import 'package:run_to_canada/core/widgets/custom_text_field.dart';
import 'package:run_to_canada/core/widgets/error_message.dart';
import '../providers/auth_providers.dart';

/// Login screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authController = ref.read(authControllerProvider.notifier);

      final success = await authController.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        // Navigate to home screen after successful login
        Navigator.pushReplacementNamed(context, RouteConstants.home);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authController = ref.read(authControllerProvider.notifier);

    final success = await authController.signInWithGoogle();

    if (success && mounted) {
      // Navigate to home screen after successful login
      Navigator.pushReplacementNamed(context, RouteConstants.home);
    }
  }

  void _navigateToSignup() {
    Navigator.pushNamed(context, RouteConstants.signup);
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, RouteConstants.forgotPassword);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // App logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 120,
                  width: 120,
                ),

                const SizedBox(height: 24),

                // Welcome text
                Text(
                  'Welcome Back!',
                  style: AppTextStyles.displayMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign in to continue your journey to Canada',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Error message
                if (authState.errorMessage != null) ...[
                  ErrorMessage(message: authState.errorMessage!),
                  const SizedBox(height: 16),
                ],

                // Success message
                if (authState.successMessage != null) ...[
                  SuccessMessage(message: authState.successMessage!),
                  const SizedBox(height: 16),
                ],

                // Email field
                EmailTextField(
                  controller: _emailController,
                  autofocus: false,
                  textInputAction: TextInputAction.next,
                  enabled: !authState.isLoading,
                ),

                const SizedBox(height: 16),

                // Password field
                PasswordTextField(
                  controller: _passwordController,
                  requireStrength: false,
                  textInputAction: TextInputAction.done,
                  enabled: !authState.isLoading,
                  onSubmitted: (_) => _handleLogin(),
                ),

                const SizedBox(height: 8),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: CustomTextButton(
                    text: 'Forgot Password?',
                    onPressed: _navigateToForgotPassword,
                  ),
                ),

                const SizedBox(height: 24),

                // Login button
                CustomButton(
                  text: 'Sign In',
                  onPressed: _handleLogin,
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 24),

                // Google Sign-In button
                OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : _handleGoogleSignIn,
                  icon: const FaIcon(FontAwesomeIcons.google, size: 20),
                  label: Text(
                    'Continue with Google',
                    style: AppTextStyles.labelLarge,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: BorderSide(color: AppColors.border),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTextStyles.bodyMedium,
                    ),
                    CustomTextButton(
                      text: 'Sign Up',
                      onPressed: _navigateToSignup,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
