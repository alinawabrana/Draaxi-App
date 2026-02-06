import 'package:flutter/material.dart';

class AElevatedButtonTheme {
  static ElevatedButtonThemeData lightButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: Color(0xFFEDAE10), width: 1),
      backgroundColor: Color(0xFFEDAE10),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15.5),
    ),
  );

  static ElevatedButtonThemeData darkButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: Color(0xFFEDAE10), width: 1),
      backgroundColor: Color(0xFFEDAE10),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 15.5),
    ),
  );
}
