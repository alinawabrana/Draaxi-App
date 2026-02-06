import 'package:draaxi/utils/constant/colors.dart';
import 'package:flutter/material.dart';

class ABottomNavigationBarTheme {
  static BottomNavigationBarThemeData lightBottomNavigationBarTheme =
      BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFFEDAE10),
        unselectedItemColor: const Color(0xFF414141),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFFEDAE10),
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF414141),
        ),
        type: BottomNavigationBarType.fixed,
      );

  static BottomNavigationBarThemeData darkBottomNavigationBarTheme =
      BottomNavigationBarThemeData(
        backgroundColor: AColor.scaffoldBackgroundDark,
        elevation: 0,
        selectedItemColor: const Color(0xFFEDAE10),
        unselectedItemColor: const Color(0xFFD0D0D0),
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFFEDAE10),
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFFD0D0D0),
        ),
        type: BottomNavigationBarType.fixed,
      );
}
