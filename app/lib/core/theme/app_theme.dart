import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color voidBlack = Color(0xFF111217);
  static const Color deepCharcoal = Color(0xFF181B1F);
  static const Color surfaceGrey = Color(0xFF1F1F1F);
  static const Color borderGrey = Color(0xFF2F2F2F);
  static const Color electricGreen = Color(0xFF00FF94);
  static const Color neonBlue = Color(0xFF00B8D9);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF888888);
  static const Color warningYellow = Color(0xFFFFAB00);
  static const Color errorRed = Color(0xFFFF5630);
  
  static const Color offWhite = Color(0xFFF5F5F7);
  static const Color paperWhite = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE1E1E1);
  static const Color deepNavy = Color(0xFF0A192F);
  static const Color signalOrange = Color(0xFFFF5722);

  static ThemeData darkTheme([Color? accentColor]) {
    final accent = accentColor ?? electricGreen;
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: voidBlack,
      primaryColor: accent,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: neonBlue,
        surface: surfaceGrey,
        error: errorRed,
      ),
      textTheme: GoogleFonts.jetBrainsMonoTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textWhite, displayColor: textWhite),
      appBarTheme: AppBarTheme(
        backgroundColor: deepCharcoal,
        elevation: 0,
        titleTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textWhite,
        ),
        iconTheme: IconThemeData(color: accent, size: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: deepCharcoal,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderGrey, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: borderGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: accent, width: 1),
        ),
        labelStyle: GoogleFonts.jetBrainsMono(color: textGrey, fontSize: 12),
        hintStyle: GoogleFonts.jetBrainsMono(color: textGrey, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: voidBlack,
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 1),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  static ThemeData lightTheme([Color? accentColor]) {
    // Convert bright accent colors to darker versions for light theme
    Color accent;
    if (accentColor != null) {
      if (accentColor == electricGreen) {
        accent = const Color(0xFF00A866); // Darker green
      } else if (accentColor == neonBlue) {
        accent = const Color(0xFF0088A8); // Darker blue
      } else if (accentColor.value == Colors.purple.value) {
        accent = const Color(0xFF7B1FA2); // Darker purple
      } else if (accentColor.value == Colors.orange.value) {
        accent = const Color(0xFFE65100); // Darker orange
      } else if (accentColor.value == Colors.pink.value) {
        accent = const Color(0xFFC2185B); // Darker pink
      } else {
        accent = deepNavy;
      }
    } else {
      accent = deepNavy;
    }
    
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: offWhite,
      primaryColor: accent,
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: signalOrange,
        surface: paperWhite,
        error: errorRed,
      ),
      textTheme: GoogleFonts.jetBrainsMonoTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: deepNavy, displayColor: deepNavy),
      appBarTheme: AppBarTheme(
        backgroundColor: paperWhite,
        elevation: 0,
        titleTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: deepNavy,
        ),
        iconTheme: IconThemeData(color: accent, size: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paperWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: lightBorder, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: accent, width: 1),
        ),
        labelStyle: GoogleFonts.jetBrainsMono(color: textGrey, fontSize: 12),
        hintStyle: GoogleFonts.jetBrainsMono(color: textGrey, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: paperWhite,
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent, width: 1),
          textStyle: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
