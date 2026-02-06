import 'package:draaxi/src/common/widgets/back_button.dart';
import 'package:draaxi/src/common/widgets/primary_button.dart';
import 'package:draaxi/src/common/widgets/primary_text_form_field.dart';
import 'package:draaxi/src/router/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SendVerificationScreen extends StatefulWidget {
  const SendVerificationScreen({super.key});

  @override
  State<SendVerificationScreen> createState() => _SendVerificationScreenState();
}

class _SendVerificationScreenState extends State<SendVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailPhoneController = TextEditingController();

  @override
  void dispose() {
    _emailPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                  // Title
                  Text(
                    'Verification email or phone number',
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Email or Phone Number Text Form Field
                  PrimaryTextFormField(
                    hintText: 'Email or phone number',
                    controller: _emailPhoneController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  // Send OTP Button
                  PrimaryButton(
                    text: 'Send OTP',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Navigate to forgot password screen
                        context.goNamed(ARouter.forgotPassword);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
