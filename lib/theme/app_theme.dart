import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryDeepForest = Color(0xFF1B4332);
  static const Color accentClayOrange = Color(0xFFE07A5F);
  static const Color backgroundWarmOffWhite = Color(0xFFF5F0E8);
  static const Color textCharcoal = Color(0xFF1C1C1C);

  // Specific Palette from Design System
  static const Color primary = Color(0xFF012D1D);
  static const Color primaryContainer = Color(0xFF1B4332);
  static const Color onPrimaryContainer = Color(0xFF86AF99);

  static const Color secondary = Color(0xFF9A442D);
  static const Color secondaryContainer = Color(0xFFFC9174);
  static const Color onSecondaryContainer = Color(0xFF742814);

  static const Color surface = Color(0xFFFCF9F8);
  static const Color onSurface = Color(0xFF1B1B1B);
  static const Color outline = Color(0xFF717973);

  static const double defaultRadius = 16.0;

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        secondaryContainer: secondaryContainer,
        surface: surface,
        onSurface: onSurface,
        outline: outline,
      ),
      scaffoldBackgroundColor: backgroundWarmOffWhite,
      fontFamily: 'Work Sans',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w700,
          color: textCharcoal,
          fontSize: 48,
          height: 1.1,
          letterSpacing: -0.02 * 48,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w700,
          color: textCharcoal,
          fontSize: 32,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w600,
          color: textCharcoal,
          fontSize: 24,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w600,
          color: textCharcoal,
          fontSize: 20,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Work Sans',
          fontWeight: FontWeight.w400,
          color: textCharcoal,
          fontSize: 18,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Work Sans',
          fontWeight: FontWeight.w400,
          color: textCharcoal,
          fontSize: 16,
          height: 1.6,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w700,
          color: textCharcoal,
          fontSize: 14,
          height: 1.2,
          letterSpacing: 0.05 * 14,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Work Sans',
          fontWeight: FontWeight.w500,
          color: textCharcoal,
          fontSize: 12,
          height: 1.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentClayOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultRadius),
          ),
          elevation: 2,
          shadowColor: textCharcoal.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Space Grotesk',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundWarmOffWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: BorderSide(color: textCharcoal.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: BorderSide(color: textCharcoal.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Space Grotesk',
          fontWeight: FontWeight.w700,
          color: textCharcoal,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
          side: BorderSide(
            color: textCharcoal.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
      ),
    );
  }
}
