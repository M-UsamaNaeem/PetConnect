import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

class AppThemes {
  // ═══════════════════════════════════════════════════════════════
  //  GEN-Z LIGHT THEME
  // ═══════════════════════════════════════════════════════════════
  static final ThemeData modernTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppConstants.modernBackground,
    primaryColor: AppConstants.primaryColor,
    colorScheme: const ColorScheme.light(
      primary: AppConstants.primaryColor,
      secondary: AppConstants.secondaryColor,
      surface: Colors.white,
      tertiary: AppConstants.accentMint,
    ),

    // --- FONT ---
    textTheme: GoogleFonts.fredokaTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w800),
        displaySmall: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: AppConstants.textSecondary, fontWeight: FontWeight.w500),
        bodySmall: TextStyle(color: AppConstants.textSecondary, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(color: AppConstants.textPrimary, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(color: AppConstants.textSecondary, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: AppConstants.textSecondary, fontWeight: FontWeight.w500),
      ),
    ),

    // --- APP BAR ---
    appBarTheme: AppBarTheme(
      backgroundColor: AppConstants.modernBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppConstants.textPrimary),
      titleTextStyle: GoogleFonts.fredoka(
        color: AppConstants.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    ),

    // --- CARDS ---
    cardColor: Colors.white,
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // --- INPUT ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
    ),

    // --- ELEVATED BUTTON (Dark Capsule) ---
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.darkCapsule,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        textStyle: GoogleFonts.fredoka(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // --- OUTLINED BUTTON ---
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppConstants.textPrimary,
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        textStyle: GoogleFonts.fredoka(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // --- TEXT BUTTON ---
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppConstants.primaryColor,
        textStyle: GoogleFonts.fredoka(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // --- CHIP ---
    chipTheme: ChipThemeData(
      backgroundColor: AppConstants.secondaryColor,
      selectedColor: AppConstants.primaryColor,
      labelStyle: GoogleFonts.fredoka(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // --- TAB BAR ---
    tabBarTheme: TabBarThemeData(
      labelColor: AppConstants.primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: AppConstants.primaryColor,
      labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w500, fontSize: 14),
      indicatorSize: TabBarIndicatorSize.label,
    ),

    // --- DIALOG ---
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      titleTextStyle: GoogleFonts.fredoka(
        color: AppConstants.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),

    // --- BOTTOM SHEET ---
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    // --- SNACK BAR ---
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppConstants.darkCapsule,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentTextStyle: GoogleFonts.fredoka(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),

    // --- FAB ---
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppConstants.darkCapsule,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: StadiumBorder(),
    ),

    dividerColor: Colors.grey.shade100,
  );

  // ═══════════════════════════════════════════════════════════════
  //  GEN-Z DARK THEME
  // ═══════════════════════════════════════════════════════════════
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppConstants.darkBackground,
    primaryColor: AppConstants.primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: AppConstants.primaryColor,
      secondary: AppConstants.secondaryColor,
      surface: AppConstants.darkSurface,
      tertiary: AppConstants.accentMint,
    ),

    // --- FONT ---
    textTheme: GoogleFonts.fredokaTextTheme(
      const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
        bodySmall: TextStyle(color: Colors.white60, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: Colors.white60, fontWeight: FontWeight.w500),
      ),
    ),

    // --- APP BAR ---
    appBarTheme: AppBarTheme(
      backgroundColor: AppConstants.darkBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.fredoka(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    ),

    // --- CARDS ---
    cardColor: AppConstants.darkCard,
    cardTheme: CardThemeData(
      color: AppConstants.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // --- INPUT ---
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppConstants.darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(color: Colors.white38, fontWeight: FontWeight.w500),
    ),

    // --- ELEVATED BUTTON ---
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        textStyle: GoogleFonts.fredoka(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // --- OUTLINED BUTTON ---
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        textStyle: GoogleFonts.fredoka(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // --- TEXT BUTTON ---
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppConstants.primaryColor,
        textStyle: GoogleFonts.fredoka(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),

    // --- CHIP ---
    chipTheme: ChipThemeData(
      backgroundColor: AppConstants.darkCard,
      selectedColor: AppConstants.primaryColor,
      labelStyle: GoogleFonts.fredoka(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.pillRadius),
      ),
      side: BorderSide(color: Colors.white.withOpacity(0.1)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // --- TAB BAR ---
    tabBarTheme: TabBarThemeData(
      labelColor: AppConstants.primaryColor,
      unselectedLabelColor: Colors.white38,
      indicatorColor: AppConstants.primaryColor,
      labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w700, fontSize: 14),
      unselectedLabelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w500, fontSize: 14),
      indicatorSize: TabBarIndicatorSize.label,
    ),

    // --- DIALOG ---
    dialogTheme: DialogThemeData(
      backgroundColor: AppConstants.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      titleTextStyle: GoogleFonts.fredoka(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),

    // --- BOTTOM SHEET ---
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppConstants.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),

    // --- SNACK BAR ---
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppConstants.darkCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentTextStyle: GoogleFonts.fredoka(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),

    // --- FAB ---
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: StadiumBorder(),
    ),

    dividerColor: Colors.white12,
  );
}
