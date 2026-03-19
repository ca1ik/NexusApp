import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nexus_app/core/constants/theme_constants.dart';

enum NexusThemeType { mirror, fracture, arena }

abstract final class AppTheme {
  static ThemeData buildMirrorTheme() => _build(
    bg: ThemeConstants.mirrorBg,
    primary: ThemeConstants.mirrorPrimary,
    secondary: ThemeConstants.mirrorSecondary,
    surface: ThemeConstants.mirrorSurface,
    accent: ThemeConstants.mirrorAccent,
  );

  static ThemeData buildFractureTheme() => _build(
    bg: ThemeConstants.fractureBg,
    primary: ThemeConstants.fracturePrimary,
    secondary: ThemeConstants.fractureSecondary,
    surface: ThemeConstants.fractureSurface,
    accent: ThemeConstants.fractureAccent,
  );

  static ThemeData buildArenaTheme() => _build(
    bg: ThemeConstants.arenaBg,
    primary: ThemeConstants.arenaPrimary,
    secondary: ThemeConstants.arenaSecondary,
    surface: ThemeConstants.arenaSurface,
    accent: ThemeConstants.arenaAccent,
  );

  static ThemeData _build({
    required Color bg,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color accent,
  }) {
    final base = ThemeData.dark();

    TextTheme textTheme;
    try {
      textTheme = GoogleFonts.rajdhaniTextTheme(base.textTheme);
    } catch (_) {
      textTheme = base.textTheme;
    }

    textTheme = textTheme.copyWith(
      displayLarge: (textTheme.displayLarge ?? const TextStyle()).copyWith(
        color: ThemeConstants.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 32,
        letterSpacing: 2,
      ),
      titleLarge: (textTheme.titleLarge ?? const TextStyle()).copyWith(
        color: ThemeConstants.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      bodyMedium: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
        color: ThemeConstants.textPrimary,
        fontSize: 15,
      ),
      labelSmall: (textTheme.labelSmall ?? const TextStyle()).copyWith(
        color: ThemeConstants.textSecondary,
        fontSize: 12,
      ),
    );

    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: ThemeConstants.fractureAccent,
      ),
      scaffoldBackgroundColor: bg,
      cardColor: surface,
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withAlpha(80)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary.withAlpha(60)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: ThemeConstants.textDisabled),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.5,
            fontFamily: textTheme.bodyMedium?.fontFamily,
          ),
        ),
      ),
      dividerColor: primary.withAlpha(30),
      iconTheme: IconThemeData(color: accent),
    );
  }
}
