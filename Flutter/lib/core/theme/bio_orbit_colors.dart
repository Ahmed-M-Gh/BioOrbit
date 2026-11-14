import 'package:flutter/material.dart';

class BioOrbitColors {
  // Space Deep Backgrounds
  static const Color spaceDeepBg = Color(0xFF050914);
  static const Color spaceSecondaryBg = Color(0xFF0E182D);
  static const Color spaceCardBg = Color(0xFF14223D);

  // Medical & Orbital Accents
  static const Color medicalPulseGreen = Color(0xFF00E676);
  static const Color orbitalCyan = Color(0xFF00E5FF);
  static const Color boneAiPurple = Color(0xFF7C4DFF);
  static const Color warningAmber = Color(0xFFFFB300);
  static const Color emergencyRed = Color(0xFFFF5252);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
}

class BioOrbitTheme {
  static ThemeData get spaceMedicalTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: BioOrbitColors.spaceDeepBg,
      primaryColor: BioOrbitColors.orbitalCyan,
      colorScheme: const ColorScheme.dark(
        primary: BioOrbitColors.orbitalCyan,
        secondary: BioOrbitColors.medicalPulseGreen,
        tertiary: BioOrbitColors.boneAiPurple,
        surface: BioOrbitColors.spaceCardBg,
        error: BioOrbitColors.emergencyRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: BioOrbitColors.spaceSecondaryBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: BioOrbitColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
      cardTheme: CardThemeData(
        color: BioOrbitColors.spaceCardBg,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: BioOrbitColors.orbitalCyan.withOpacity(0.18),
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BioOrbitColors.spaceSecondaryBg,
        labelStyle: const TextStyle(color: BioOrbitColors.textSecondary),
        hintStyle: TextStyle(
          color: BioOrbitColors.textSecondary.withOpacity(0.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: BioOrbitColors.orbitalCyan.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: BioOrbitColors.orbitalCyan.withOpacity(0.25),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: BioOrbitColors.orbitalCyan,
            width: 1.8,
          ),
        ),
      ),
    );
  }
}
