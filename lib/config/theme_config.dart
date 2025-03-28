import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: Colors.green, // Green accents
      onPrimary: Colors.white,
      background: Color(0xFFFAF3E0), // Off-white background
      onBackground: Colors.black,
    ),
    scaffoldBackgroundColor: Color(0xFFFAF3E0), // Off-white
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: const Color.fromRGBO(76, 175, 80, 1),
      onPrimary: Colors.black,
      background: Colors.black,
      onBackground: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green,
      foregroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
      ),
    ),
  );
}
