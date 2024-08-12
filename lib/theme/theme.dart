import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      surface: Colors.orangeAccent,
      primary: Colors.black,
      secondary: Colors.black
  ),
  textTheme: TextTheme(
      bodyMedium: TextStyle(fontFamily: "JosefinSans"),
      headlineMedium: TextStyle(fontFamily: "JosefinSans"),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: Colors.orangeAccent, // Color del CircularProgressIndicator en Light Mode
  ),
  appBarTheme: AppBarTheme(
    titleTextStyle: TextStyle(
      fontFamily: 'JosefinSans',
      fontSize: 20,
    ),
  ),

);

ThemeData darkMode = ThemeData(

    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.orangeAccent,
    primary: Colors.white,
      secondary: Colors.black
    ),
    textTheme: TextTheme(
        bodyMedium: TextStyle(fontFamily: "JosefinSans"),
        headlineMedium: TextStyle(fontFamily: "JosefinSans"),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Colors.orangeAccent, // Color del CircularProgressIndicator en Light Mode
    ),

    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontFamily: 'JosefinSans',
      ),
    ),

);