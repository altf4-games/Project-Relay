import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cyberpunk/DevTool Color Palette
  static const Color voidBlack = Color(0xFF121212);
  static const Color deepCharcoal = Color(0xFF1E1E1E);
  static const Color electricGreen = Color(0xFF00FF94);
  static const Color neonBlue = Color(0xFF00F0FF);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color warningYellow = Color(0xFFFFD700);
  static const Color errorRed = Color(0xFFFF3B30);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: voidBlack,
      primaryColor: electricGreen,
      colorScheme: const ColorScheme.dark(
        primary: electricGreen,
        secondary: neonBlue,
        surface: deepCharcoal,
        error: errorRed,
      ),

      // Monospace Typography
      textTheme: GoogleFonts.jetBrainsMonoTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textWhite, displayColor: textWhite),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: voidBlack,
        elevation: 0,
        titleTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        iconTheme: const IconThemeData(color: electricGreen),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: deepCharcoal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: textGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: electricGreen, width: 2),
        ),
        labelStyle: GoogleFonts.jetBrainsMono(color: textGrey),
        hintStyle: GoogleFonts.jetBrainsMono(color: textGrey),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electricGreen,
          foregroundColor: voidBlack,
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  // Card Theme (applied directly to Card widgets due to type compatibility)
  static CardTheme get cardTheme {
    return CardTheme(
      color: deepCharcoal,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
