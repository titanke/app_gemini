import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      surface: Colors.orange,
    primary: Colors.black,
      secondary: Colors.black
  ),

);

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.orange,
    primary: Colors.black,
      secondary: Colors.black
    )
);