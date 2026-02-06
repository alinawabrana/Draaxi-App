import 'package:draaxi/utils/constant/images.dart';
import 'package:draaxi/utils/constant/texts.dart';
import 'package:draaxi/utils/helpers/helper_function.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:draaxi/src/router/router.dart';

class SocialLoginSection extends StatelessWidget {
  const SocialLoginSection({
    super.key,
    required this.richTextPrefix,
    required this.richTextAction,
    this.onActionTap,
  });

  final String richTextPrefix;
  final String richTextAction;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = AHelperFunction.isDarkMode(context);

    return Column(
      children: [
        const SizedBox(height: 20),
        // Divider with "or" text
        Row(
          children: [
            Expanded(
              child: Divider(color: const Color(0xFFB8B8B8), thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFB8B8B8),
                ),
              ),
            ),
            Expanded(
              child: Divider(color: const Color(0xFFB8B8B8), thickness: 1),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Social login icons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialIconButton(
              imagePath: AImages.gmail,
              onTap: () {
                // TODO: Handle Gmail login
              },
            ),
            const SizedBox(width: 15),
            _SocialIconButton(
              imagePath: AImages.facebook,
              onTap: () {
                // TODO: Handle Facebook login
              },
            ),
            const SizedBox(width: 15),
            _SocialIconButton(
              imagePath: AImages.apple,
              onTap: () {
                // TODO: Handle iCloud login
              },
            ),
          ],
        ),
        const SizedBox(height: 32),
        // RichText for account prompt
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFFD0D0D0)
                    : const Color(0xFF5A5A5A),
              ),
              children: [
                TextSpan(text: '$richTextPrefix '),
                TextSpan(
                  text: richTextAction,
                  style: const TextStyle(color: Color(0xFFEDAE10)),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (onActionTap != null) {
                        onActionTap!();
                      } else {
                        if (richTextAction == ATexts.signUp) {
                          context.goNamed(ARouter.signUp);
                        } else {
                          context.goNamed(ARouter.signIn);
                        }
                      }
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({required this.imagePath, required this.onTap});

  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = AHelperFunction.isDarkMode(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFFD0D0D0),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            imagePath,
            width: 21,
            height: 21,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
