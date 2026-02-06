import 'package:draaxi/utils/constant/texts.dart';
import 'package:draaxi/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ABackButton extends StatelessWidget {
  const ABackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = AHelperFunction.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: SizedBox(
        height: 30,
        child: TextButton(
          onPressed: () => context.pop(),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_ios,
                size: 15,
                color: isDark
                    ? const Color(0xFFF7F7F7)
                    : const Color(0xFF414141),
              ),
              const SizedBox(width: 5),
              Text(
                ATexts.back,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? const Color(0xFFF7F7F7)
                      : const Color(0xFF414141),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
