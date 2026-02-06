import 'package:flutter/material.dart';

class PrimaryTextFormField extends StatelessWidget {
  const PrimaryTextFormField({
    super.key,
    required this.hintText,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.onChanged,
    this.suffixIcon,
    this.textInputAction,
    this.keyboardType,
  });

  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: TextFormField(
            controller: controller,
            validator: validator,
            obscureText: obscureText,
            onChanged: onChanged,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
              suffixIcon: suffixIcon,
              errorStyle: textTheme.bodySmall?.copyWith(height: 1),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
