import 'package:draaxi/src/common/widgets/back_button.dart';
import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:draaxi/src/common/widgets/primary_text_form_field.dart';
import 'package:draaxi/src/features/authentication/providers/auth_providers.dart';
import 'package:draaxi/src/features/authentication/repository/auth_repository.dart';
import 'package:draaxi/src/router/router.dart';
import 'package:draaxi/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = AHelperFunction.isDarkMode(context);
    final otpState = ref.watch(otpVerificationProvider);
    final isForgotFlow = otpState.type == OtpVerificationType.forgotPassword;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ABackButton(),
                  const SizedBox(height: 30),
                  // Title and Description with extra horizontal padding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            isForgotFlow ? 'Set New Password' : 'Set password',
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isForgotFlow
                                ? 'Set your new password'
                                : 'Set your password',
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? const Color(0xFFD0D0D0)
                                  : const Color(0xFFA0A0A0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Password Text Form Field
                  PrimaryTextFormField(
                    hintText: 'Enter Your Password',
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    validator: _validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        size: 16,
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: isDark
                            ? const Color(0xFFD0D0D0)
                            : const Color(0xFF414141),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Confirm Password Text Form Field
                  PrimaryTextFormField(
                    hintText: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    validator: _validateConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        size: 16,
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: isDark
                            ? const Color(0xFFD0D0D0)
                            : const Color(0xFF414141),
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password requirement text
                  Text(
                    'Atleast 1 number or a special character.',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFD0D0D0)
                          : const Color(0xFFA6A6A6),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  // Register/Save Button
                  PrimaryButton(
                    text: isForgotFlow ? 'Save' : 'Register',
                    isLoading: _isSubmitting,
                    enabled: !_isSubmitting,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Confirm password is required';
    }
    if (value.trim() != _passwordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authRepository = ref.read(authRepositoryProvider);
    final otpState = ref.read(otpVerificationProvider);
    final isForgotFlow = otpState.type == OtpVerificationType.forgotPassword;

    try {
      // Use resetPassword for forgot password flow, setPassword for other flows
      if (isForgotFlow) {
        // Get reset_token from state
        final resetToken = otpState.token;
        if (resetToken == null || resetToken.isEmpty) {
          _showSnackBar('Reset token is missing. Please try again.');
          return;
        }
        await authRepository.resetPassword(
          password: _passwordController.text.trim(),
          passwordConfirmation: _confirmPasswordController.text.trim(),
          resetToken: resetToken,
        );
        // Navigate to login screen after successful password reset
        ref.read(otpVerificationProvider.notifier).reset();
        if (mounted) {
          context.goNamed(ARouter.signIn);
        }
      } else {
        await authRepository.setPassword(
          password: _passwordController.text.trim(),
          passwordConfirmation: _confirmPasswordController.text.trim(),
        );
        ref.read(otpVerificationProvider.notifier).reset();
        if (mounted) {
          context.goNamed(ARouter.home);
        }
      }
    } on ApiException catch (e) {
      _showSnackBar(e.message);
    } catch (_) {
      _showSnackBar('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
