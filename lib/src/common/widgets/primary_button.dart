import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.isLoading = false,
    this.enabled = true,
  });

  final String text;
  final VoidCallback onPressed;
  final double? width;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: width ?? size.width,
      child: ElevatedButton(
        onPressed: (!enabled || isLoading) ? null : onPressed,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                text,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
      ),
    );
  }
}
