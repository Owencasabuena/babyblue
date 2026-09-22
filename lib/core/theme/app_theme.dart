import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Baby Blues design system.
///
/// Warm, calming colour palette suited for a maternal mental-health app.
/// Uses [Outfit] for headings and [Inter] for body text.
class AppTheme {
  AppTheme._();

  // ── Colour Palette ──────────────────────────────────────────────
  static const Color primaryLavender = Color(0xFF7C6FAE);
  static const Color primaryLight = Color(0xFFB8AED8);
  static const Color accentPeach = Color(0xFFF4A896);
  static const Color accentRose = Color(0xFFE8828A);
  static const Color surfaceWhite = Color(0xFFF0F6FB);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF2D2438);
  static const Color textMuted = Color(0xFF8E849B);
  static const Color successGreen = Color(0xFF6BBF8A);
  static const Color errorRed = Color(0xFFD9534F);

  // Background gradient (top → bottom).
  static const Color _bgTop = Color(0xFFE3F0FA);
  static const Color _bgBottom = Color(0xFFD6E9F8);

  /// Soft vertical gradient for page backgrounds.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [_bgTop, _bgBottom],
  );

  /// Colours mapped to mood scores 1 → 5.
  static const List<Color> moodColors = [
    Color(0xFF8B9DC3), // 1 – Very Low  (muted blue)
    Color(0xFFA8B8D8), // 2 – Low       (light periwinkle)
    Color(0xFFE2C391), // 3 – Okay      (warm sand)
    Color(0xFFF4A896), // 4 – Good      (peach)
    Color(0xFFB5D6A7), // 5 – Great     (soft green)
  ];

  // ── Theme Data ──────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final baseText = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: surfaceWhite,

      // Colour scheme.
      colorScheme: const ColorScheme.light(
        primary: primaryLavender,
        primaryContainer: primaryLight,
        secondary: accentPeach,
        secondaryContainer: accentRose,
        surface: surfaceWhite,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textDark,
      ),

      // Typography.
      textTheme: baseText.copyWith(
        headlineLarge: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryLavender,
        ),
      ),

      // Cards — soft white with subtle lavender border.
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: primaryLight.withAlpha(51), // ~20 %
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      ),

      // Elevated buttons — primary lavender pill.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLavender,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text fields — rounded with subtle border.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryLight.withAlpha(77)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryLight.withAlpha(77)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryLavender, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textMuted.withAlpha(153),
        ),
      ),

      // Bottom navigation.
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryLavender,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // App bar — transparent, centred title.
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
    );
  }
}
