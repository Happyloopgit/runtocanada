import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:run_to_canada/core/theme/app_colors.dart';
import 'package:run_to_canada/core/theme/app_text_styles.dart';
import 'package:run_to_canada/core/widgets/custom_button.dart';
import 'package:run_to_canada/core/widgets/custom_text_field.dart';
import 'package:run_to_canada/core/widgets/error_message.dart';
import '../providers/auth_providers.dart';

/// Forgot password screen
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authController = ref.read(authControllerProvider.notifier);

      final success = await authController.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (success) {
        setState(() => _emailSent = true);
      }
    }
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Icon
                const Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: AppColors.primary,
                ),

                const SizedBox(height: 24),

                // Header
                Text(
                  'Forgot Password?',
                  style: AppTextStyles.displayMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  "No worries! Enter your email and we'll send you instructions to reset your password.",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Error message
                if (authState.errorMessage != null && !_emailSent) ...[
                  ErrorMessage(message: authState.errorMessage!),
                  const SizedBox(height: 16),
                ],

                if (_emailSent) ...[
                  // Success message
                  const SuccessMessage(
                    message:
                        'Password reset email sent! Please check your inbox and follow the instructions.',
                  ),

                  const SizedBox(height: 24),

                  // Back to login button
                  CustomButton(
                    text: 'Back to Login',
                    onPressed: _navigateBack,
                    icon: Icons.arrow_back,
                  ),

                  const SizedBox(height: 16),

                  // Resend email button
                  CustomTextButton(
                    text: 'Resend Email',
                    onPressed: () {
                      setState(() => _emailSent = false);
                    },
                  ),
                ] else ...[
                  // Email field
                  EmailTextField(
                    controller: _emailController,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    enabled: !authState.isLoading,
                    onSubmitted: (_) => _handleResetPassword(),
                  ),

                  const SizedBox(height: 24),

                  // Reset password button
                  CustomButton(
                    text: 'Send Reset Link',
                    onPressed: _handleResetPassword,
                    isLoading: authState.isLoading,
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 24),

                  // Back to login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      CustomTextButton(
                        text: 'Back to Login',
                        onPressed: _navigateBack,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
