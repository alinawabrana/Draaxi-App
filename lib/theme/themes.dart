import 'package:draaxi/theme/custom_themes/bottom_navigation_bar_theme.dart';
import 'package:draaxi/theme/custom_themes/elevated_button_theme.dart';
import 'package:draaxi/theme/custom_themes/outline_button_theme.dart';
import 'package:draaxi/theme/custom_themes/text_button_theme.dart';
import 'package:draaxi/theme/custom_themes/text_field_theme.dart';
import 'package:draaxi/theme/custom_themes/text_theme.dart';
import 'package:draaxi/utils/constant/colors.dart';
import 'package:flutter/material.dart';

class ATheme {
  static ThemeData lightModeThemes = ThemeData(
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AColor.scaffoldBackgroundLight,
    textTheme: ATextTheme.lightTextTheme,
    inputDecorationTheme: ATextFieldTheme.lightTextFormTheme,
    elevatedButtonTheme: AElevatedButtonTheme.lightButtonTheme,
    outlinedButtonTheme: AOutlinedButtonTheme.lightButtonTheme,
    textButtonTheme: ATextButtonTheme.lightButtonTheme,
    bottomNavigationBarTheme:
        ABottomNavigationBarTheme.lightBottomNavigationBarTheme,
    brightness: Brightness.light,
  );

  static ThemeData darkModeThemes = ThemeData(
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: AColor.scaffoldBackgroundDark,
    textTheme: ATextTheme.darkTextTheme,
    inputDecorationTheme: ATextFieldTheme.darkTextFormTheme,
    elevatedButtonTheme: AElevatedButtonTheme.darkButtonTheme,
    outlinedButtonTheme: AOutlinedButtonTheme.darkButtonTheme,
    textButtonTheme: ATextButtonTheme.darkButtonTheme,
    bottomNavigationBarTheme:
        ABottomNavigationBarTheme.darkBottomNavigationBarTheme,
    brightness: Brightness.dark,
  );
}
