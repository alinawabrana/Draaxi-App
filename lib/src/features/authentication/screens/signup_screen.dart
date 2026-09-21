import 'package:country_code_picker/country_code_picker.dart';
import 'package:draaxi/src/common/widgets/back_button.dart';
import 'package:draaxi/src/common/widgets/dropdown_form_field.dart';
import 'package:draaxi/src/common/widgets/phone_form_field.dart';
import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:draaxi/src/common/widgets/primary_text_form_field.dart';
import 'package:draaxi/src/common/widgets/social_login_section.dart';
import 'package:draaxi/src/features/authentication/providers/auth_providers.dart';
import 'package:draaxi/src/features/authentication/repository/auth_repository.dart';
import 'package:draaxi/src/router/router.dart';
import 'package:draaxi/utils/constant/texts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  static const Map<String, _PhoneRule> _phoneValidationRules = {
    '+234': _PhoneRule.exact(10),
    '+27': _PhoneRule.exact(9),
    '+20': _PhoneRule.range(8, 11),
    '+213': _PhoneRule.exact(9),
    '+212': _PhoneRule.exact(9),
    '+244': _PhoneRule.exact(9),
    '+258': _PhoneRule.exact(9),
    '+251': _PhoneRule.exact(9),
    '+254': _PhoneRule.exact(9),
    '+233': _PhoneRule.exact(9),
    '+255': _PhoneRule.exact(9),
    '+256': _PhoneRule.exact(9),
    '+249': _PhoneRule.exact(9),
    '+260': _PhoneRule.exact(9),
    '+263': _PhoneRule.exact(9),
    '+237': _PhoneRule.range(8, 9),
    '+216': _PhoneRule.exact(8),
    '+218': _PhoneRule.exact(9),
    '+92': _PhoneRule.exact(10),
    '+91': _PhoneRule.exact(10),
  };

  static const List<String> _allowedCountryIsoCodes = [
    'NG',
    'ZA',
    'EG',
    'DZ',
    'MA',
    'AO',
    'MZ',
    'ET',
    'KE',
    'GH',
    'TZ',
    'UG',
    'SD',
    'ZM',
    'ZW',
    'CM',
    'TN',
    'LY',
    'PK',
    'IN',
  ];

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isTermsAccepted = false;
  CountryCode _selectedCountryCode = CountryCode.fromDialCode('+234');
  bool _isSubmitting = false;
  String? _selectedGender;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ABackButton(),
              const SizedBox(height: 6),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(ATexts.signUp, style: textTheme.headlineMedium),
                      const SizedBox(height: 24),
                      PrimaryTextFormField(
                        hintText: 'First Name',
                        controller: _firstNameController,
                        textInputAction: TextInputAction.next,
                        validator: _validateFirstName,
                      ),
                      const SizedBox(height: 20),
                      PrimaryTextFormField(
                        hintText: 'Last Name',
                        controller: _lastNameController,
                        textInputAction: TextInputAction.next,
                        validator: _validateLastName,
                      ),
                      const SizedBox(height: 20),
                      PrimaryTextFormField(
                        hintText: ATexts.email,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),
                      DropdownFormField(
                        hintText: 'Gender',
                        value: _selectedGender,
                        items: const [
                          DropdownMenuItem<String>(
                            value: 'male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'other',
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        validator: _validateGender,
                      ),
                      const SizedBox(height: 20),
                      PhoneFormField(
                        phoneNumberController: _phoneNumberController,
                        phoneNumberValidator: _validatePhoneNumber,
                        selectedCountryCode: _selectedCountryCode,
                        countryFilter: _allowedCountryIsoCodes,
                        onCountryChanged: (countryCode) {
                          setState(() {
                            _selectedCountryCode = countryCode;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      PrimaryTextFormField(
                        hintText: 'Password',
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.next,
                        validator: _validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      PrimaryTextFormField(
                        hintText: 'Confirm Password',
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        textInputAction: TextInputAction.done,
                        validator: _validateConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isTermsAccepted = !_isTermsAccepted;
                              });
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isTermsAccepted
                                    ? const Color(0xFF43A048)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _isTermsAccepted
                                      ? const Color(0xFF43A048)
                                      : const Color(0xFFB8B8B8),
                                  width: 1,
                                ),
                              ),
                              child: _isTermsAccepted
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFB8B8B8),
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'By signing up, you agree to the ',
                                  ),
                                  TextSpan(
                                    text: ATexts.termsOfService,
                                    style: const TextStyle(
                                      color: Color(0xFFEDAE10),
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: ATexts.privacyPolicy,
                                    style: const TextStyle(
                                      color: Color(0xFFEDAE10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        text: ATexts.signUp,
                        isLoading: _isSubmitting,
                        enabled: !_isSubmitting,
                        onPressed: _handleSubmit,
                      ),
                      const SizedBox(height: 17),
                      // Social login section
                      SocialLoginSection(
                        richTextPrefix: ATexts.alreadyHaveAccount,
                        richTextAction: ATexts.signIn,
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

  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
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

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) {
      return 'Phone number must contain digits only';
    }
    final dialCode = _selectedCountryCode.dialCode;
    final rule = dialCode != null ? _phoneValidationRules[dialCode] : null;
    if (rule == null) {
      return 'Selected country is not supported yet.';
    }
    if (!rule.validate(digitsOnly)) {
      return rule.errorMessage;
    }
    return null;
  }

  String? _validateGender(String? value) {
    if (value == null || value.isEmpty) {
      return 'Gender is required';
    }
    return null;
  }


  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dialCode = _selectedCountryCode.dialCode;
    if (dialCode == null ||
        dialCode.isEmpty ||
        !_phoneValidationRules.containsKey(dialCode)) {
      _showSnackBar(
        'Selected country is not supported yet. Please choose another.',
      );
      return;
    }

    if (!_isTermsAccepted) {
      _showSnackBar('Please accept the terms to continue.');
      return;
    }

    final authRepository = ref.read(authRepositoryProvider);

    setState(() {
      _isSubmitting = true;
    });

    try {
      final sanitizedPhoneNumber = _phoneNumberController.text.replaceAll(
        RegExp(r'\D'),
        '',
      );

      // Combine first name and last name into a single name field
      final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();

      final response = await authRepository.signUp(
        name: fullName,
        email: _emailController.text.trim(),
        phone: sanitizedPhoneNumber,
        countryCode: dialCode,
        gender: _selectedGender ?? '',
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        role: 'rider',
      );

      // Extract token from response
      final token = response['token'] as String?;
      if (token == null || token.isEmpty) {
        _showSnackBar('Failed to receive authentication token. Please try again.');
        return;
      }

      // Store token and contact detail in OTP verification state
      ref.read(otpVerificationProvider.notifier).setType(
            OtpVerificationType.phoneVerification,
            contactDetail: _emailController.text.trim(),
            token: token,
          );

      if (!mounted) return;
      context.goNamed(ARouter.otpVerification);
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

class _PhoneRule {
  const _PhoneRule._(this.min, this.max);

  const _PhoneRule.exact(int length) : this._(length, length);

  const _PhoneRule.range(int min, int max) : this._(min, max);

  final int min;
  final int max;

  bool validate(String digits) => digits.length >= min && digits.length <= max;

  String get errorMessage => min == max
      ? 'Phone number must be exactly $min digits'
      : 'Phone number must be between $min and $max digits';
}
