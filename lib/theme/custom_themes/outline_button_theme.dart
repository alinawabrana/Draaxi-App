import 'package:flutter/material.dart';

class AOutlinedButtonTheme {
  static OutlinedButtonThemeData lightButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: Color(0xFFEDAE10), width: 1),
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF414141),
      padding: EdgeInsets.symmetric(vertical: 15.5),
    ),
  );

  static OutlinedButtonThemeData darkButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: Color(0xFFEDAE10), width: 1),
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFE8E8E8),
      padding: EdgeInsets.symmetric(vertical: 15.5),
    ),
  );
}
