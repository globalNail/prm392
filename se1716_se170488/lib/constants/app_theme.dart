import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color.fromARGB(255, 16, 86, 184);
  static const _foregroundColor = Color.fromARGB(255, 227, 226, 222);
  static const _seedColor = Color.fromARGB(255, 34, 76, 113);

  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor.withValues(alpha: 0.8),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor, // màu nền nút Add
      foregroundColor: _foregroundColor, // màu icon
    ),
    // AppBar theme
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),

    // Card theme
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryColor.withValues(alpha: 0.2), // màu nền nút Add
      foregroundColor: _foregroundColor, // màu icon
    ),
  );
}

// Constants cho spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

// Constants cho border radius
class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
}
