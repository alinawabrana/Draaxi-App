import 'package:flutter/material.dart';

class ATextButtonTheme {
  static TextButtonThemeData lightButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      foregroundColor: Color(0xFFB8B8B8),
    ),
  );

  static TextButtonThemeData darkButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      foregroundColor: Color(0xFFD0D0D0),
    ),
  );
}
