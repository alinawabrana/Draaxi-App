import 'package:flutter/material.dart';

class CircularAction extends StatelessWidget {
  const CircularAction({
    super.key,
    required this.progressValue,
    this.icon,
    this.label,
    required this.onPressed,
  }) : assert(
         icon != null || label != null,
         'Either icon or label must be provided',
       );

  final double progressValue; // 0.0..1.0
  final IconData? icon;
  final String? label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 92),
      child: SizedBox(
        width: 86,
        height: 86,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 86,
              height: 86,
              child: CircularProgressIndicator(
                value: progressValue.clamp(0.0, 1.0),
                strokeWidth: 4,
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFEC400)),
                backgroundColor: const Color(0xFFFFF1B1),
              ),
            ),
            Material(
              color: const Color(0xFFFEC400),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Center(
                    child: icon != null
                        ? Icon(icon, size: 18, color: const Color(0xFF5A5A5A))
                        : Text(
                            label!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF5A5A5A),
                                ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
