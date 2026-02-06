import 'package:draaxi/src/common/widgets/back_button.dart';
import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:draaxi/src/common/widgets/primary_text_form_field.dart';
import 'package:draaxi/src/common/widgets/social_login_section.dart';
import 'package:draaxi/src/features/authentication/providers/auth_providers.dart';
import 'package:draaxi/src/features/authentication/repository/auth_repository.dart';
import 'package:draaxi/src/router/router.dart';
import 'package:draaxi/utils/constant/texts.dart';
import 'package:draaxi/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ABackButton(),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(ATexts.signIn, style: textTheme.headlineMedium),
                      const SizedBox(height: 30),
                      PrimaryTextFormField(
                        hintText: 'Email or Phone Number',
                        controller: _emailOrPhoneController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateIdentifier,
                      ),
                      const SizedBox(height: 20),
                      PrimaryTextFormField(
                        hintText: 'Enter Your Password',
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 16,
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
                      const SizedBox(height: 10),
                      // Forget password text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              context.goNamed(ARouter.forgotPassword);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forget password?',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFF44336),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        text: ATexts.logIn,
                        isLoading: _isLoggingIn,
                        enabled: !_isLoggingIn,
                        onPressed: _handleLogin,
                      ),
                      // Social login section
                      SocialLoginSection(
                        richTextPrefix: ATexts.dontHaveAccount,
                        richTextAction: ATexts.signUp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email or phone is required.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'The password field is required.';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    final authRepository = ref.read(authRepositoryProvider);

    try {
      await authRepository.login(
        identifier: _emailOrPhoneController.text.trim(),
        password: _passwordController.text,
      );

      // Token is automatically stored in authRepository
      // Navigate to home screen on successful login
      if (mounted) {
        context.goNamed(ARouter.home);
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
          _isLoggingIn = false;
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
