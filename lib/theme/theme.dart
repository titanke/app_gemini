import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      surface: Colors.orangeAccent,
    primary: Color.fromARGB(255, 247, 134, 5),
      secondary: Colors.black
  ),

);

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.orangeAccent,
    primary: Color.fromARGB(255, 230, 196, 157),
      secondary: Colors.black
    )
);