import 'package:flutter/material.dart';

class AppTheme {
  // Private Constructor to prevent instantiation
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // 1. Color Scheme: The Core Palette
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF7C4DFF),       // Electric Violet
      onPrimary: Colors.white,
      secondary: Color(0xFF64FFDA),     // Neon Teal
      onSecondary: Colors.black,
      tertiary: Color(0xFFFF4081),      // Pink
      surface: Color(0xFF1E1E2C),       // Cards/Sheets
      background: Color(0xFF121218),    // Main Background
      error: Color(0xFFCF6679),
    ),

    // 2. Background Colors
    scaffoldBackgroundColor: const Color(0xFF121218),
    canvasColor: const Color(0xFF1E1E2C),

    // 3. AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // 4. Card Theme
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E2C),
      elevation: 4,
      shadowColor: const Color(0xFF7C4DFF).withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),

    // 5. Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: const Color(0xFF7C4DFF).withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    // 6. Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E2C),
      contentPadding: const EdgeInsets.all(20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
      ),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
    ),
  );
}