import 'package:draaxi/src/common/widgets/back_button.dart';
import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:draaxi/src/features/authentication/providers/auth_providers.dart';
import 'package:draaxi/src/features/authentication/repository/auth_repository.dart';
import 'package:draaxi/src/router/router.dart';
import 'package:draaxi/utils/helpers/helper_function.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const int _otpLength = 4;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (index) => FocusNode(),
  );

  bool _isVerifying = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1) {
      // Move to next field
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field, unfocus
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      // Move to previous field on backspace
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
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
                          isForgotFlow
                              ? 'Forgot Password'
                              : 'Email verification',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isForgotFlow
                              ? 'Code has been send to ${otpState.contactDetail ?? "***** ***70"}'
                              : 'Code has been sent to ${otpState.contactDetail ?? "your email"}',
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
                // OTP Input Fields with extra horizontal padding
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_otpLength, (index) {
                      final hasValue = _controllers[index].text.isNotEmpty;
                      return SizedBox(
                        width: 50,
                        height: 48,
                        child: TextFormField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF414141),
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: hasValue
                                ? const Color(0xFFFFF1B1)
                                : (isDark
                                      ? Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor
                                      : Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: hasValue
                                    ? const Color(0xFFF6CD56)
                                    : const Color(0xFFD0D0D0),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: hasValue
                                    ? const Color(0xFFF6CD56)
                                    : const Color(0xFFD0D0D0),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: hasValue
                                    ? const Color(0xFFF6CD56)
                                    : const Color(0xFFD0D0D0),
                                width: 1,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) => _onOtpChanged(index, value),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                // Resend code RichText
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Color(0xFFD0D0D0) : Color(0xFF5A5A5A),
                        ),
                        children: [
                          const TextSpan(text: "Didn't receive code? "),
                          TextSpan(
                            text: 'Resend again',
                            style: const TextStyle(color: Color(0xFFEDAE10)),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO: Handle resend code
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                // Verify Button
                PrimaryButton(
                  text: 'Verify',
                  isLoading: _isVerifying,
                  enabled: !_isVerifying,
                  onPressed: _handleVerifyOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleVerifyOtp() async {
    if (_isVerifying) return;

    final otp = _controllers.map((controller) => controller.text).join();
    if (otp.length != _otpLength) {
      _showSnackBar('Please enter the 4-digit OTP.');
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    final authRepository = ref.read(authRepositoryProvider);
    final otpState = ref.read(otpVerificationProvider);

    try {
      // Use verifySignupOtp for signup flow (phoneVerification type)
      // Use verifyOtp for other flows
      if (otpState.type == OtpVerificationType.phoneVerification) {
        // Get token from state
        final token = otpState.token;
        if (token == null || token.isEmpty) {
          _showSnackBar('Authentication token is missing. Please try signing up again.');
          return;
        }
        await authRepository.verifySignupOtp(otp: otp, token: token);
        if (!mounted) return;
        context.goNamed(ARouter.signIn);
      } else if (otpState.type == OtpVerificationType.forgotPassword) {
        // Get token from state
        final token = otpState.token;
        if (token == null || token.isEmpty) {
          _showSnackBar('Authentication token is missing. Please try again.');
          return;
        }
        await authRepository.verifyForgotOtp(otp: otp, token: token);
        if (!mounted) return;
        context.goNamed(ARouter.setNewPassword);
      } else {
        await authRepository.verifyOtp(otp: otp);
        if (!mounted) return;
        context.goNamed(ARouter.setPassword);
      }
    } on ApiException catch (e) {
      _showSnackBar(e.message);
    } catch (_) {
      _showSnackBar('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
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
