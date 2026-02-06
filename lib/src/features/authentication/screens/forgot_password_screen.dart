import 'package:draaxi/src/common/widgets/back_button.dart';
import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:draaxi/src/common/widgets/primary_text_form_field.dart';
import 'package:draaxi/src/features/authentication/providers/auth_providers.dart';
import 'package:draaxi/src/features/authentication/repository/auth_repository.dart';
import 'package:draaxi/src/router/router.dart';
import 'package:draaxi/utils/constant/texts.dart';
import 'package:draaxi/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = AHelperFunction.isDarkMode(context);

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
                            'Forgot Password',
                            style: textTheme.headlineMedium?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Enter your email address to receive a verification code',
                            textAlign: TextAlign.center,
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
                  // Email Input Field
                  PrimaryTextFormField(
                    hintText: ATexts.email,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  // Continue Button
                  PrimaryButton(
                    text: 'Continue',
                    isLoading: _isSubmitting,
                    enabled: !_isSubmitting,
                    onPressed: _handleContinue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  Future<void> _handleContinue() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authRepository = ref.read(authRepositoryProvider);
    final email = _emailController.text.trim();

    try {
      final response = await authRepository.sendForgotOtp(email: email);

      // Extract reset_token from response
      final resetToken = response['reset_token'] as String?;
      if (resetToken == null || resetToken.isEmpty) {
        _showSnackBar('Failed to receive reset token. Please try again.');
        return;
      }

      // Set OTP verification type to forgot password with reset token
      ref.read(otpVerificationProvider.notifier).setType(
            OtpVerificationType.forgotPassword,
            contactDetail: email,
            token: resetToken,
          );

      // Navigate to OTP verification screen
      if (mounted) {
        context.goNamed(ARouter.forgotPasswordOtpVerification);
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showSnackBar(e.message);
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

