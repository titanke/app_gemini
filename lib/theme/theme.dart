import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      surface: Colors.orangeAccent,
      primary: Colors.black,
      secondary: Colors.black
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Colors.orangeAccent, // Color del CircularProgressIndicator en Light Mode
  ),

);

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.orangeAccent,
    primary: Colors.white,
      secondary: Colors.black
    ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Colors.orangeAccent, // Color del CircularProgressIndicator en Light Mode
  ),

);