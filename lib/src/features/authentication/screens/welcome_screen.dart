import 'package:draaxi/src/router/router.dart';
import 'package:draaxi/utils/constant/images.dart';
import 'package:draaxi/utils/constant/texts.dart';
import 'package:draaxi/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 280,
                width: size.width,
                child: Image.asset(AImages.welcomeScreen, fit: BoxFit.cover),
              ),
              const SizedBox(height: 29),
              Text(
                ATexts.welcomeTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                ATexts.welcomeDescription,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AHelperFunction.isDarkMode(context)
                      ? const Color(0xFFD0D0D0)
                      : null,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        context.goNamed(ARouter.signUp);
                      },
                      child: Text(
                        ATexts.createAccount,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: size.width,
                    child: OutlinedButton(
                      onPressed: () {
                        context.goNamed(ARouter.signIn);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEDAE10),
                      ),
                      child: Text(
                        ATexts.logIn,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFEDAE10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
