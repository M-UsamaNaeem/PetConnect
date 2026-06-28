import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Pet Connect';

  // --- GEMINI AI API KEY (update here only) ---
  static const String geminiApiKey = 'AIzaSyDmeR2QQ2HHYr7m4UU-9ztTPAnE4TDlhlg';

  // ═══════════════════════════════════════════════════════════════
  //  GEN-Z WARM COLOR PALETTE
  // ═══════════════════════════════════════════════════════════════

  // --- LIGHT PALETTE ---
  static const Color modernBackground = Color(0xFFFFF8F0);  // Warm cream
  static const Color modernSurface = Colors.white;
  static const Color creamLight = Color(0xFFFFF3E8);         // Lighter cream

  // --- DARK PALETTE ---
  static const Color darkBackground = Color(0xFF0F0F1A);    // Deep navy
  static const Color darkSurface = Color(0xFF1C1C2E);       // Charcoal surface
  static const Color darkCard = Color(0xFF252538);           // Dark card

  // --- PRIMARY ACCENT COLORS ---
  static const Color primaryColor = Color(0xFFFF6B6B);      // Coral
  static const Color secondaryColor = Color(0xFFE8DEF8);    // Soft lavender
  static const Color accentPink = Color(0xFFF8BBD0);        // Blush pink
  static const Color accentMint = Color(0xFFA8E6CF);        // Mint green
  static const Color accentYellow = Color(0xFFFFF3CD);      // Soft yellow
  static const Color accentPeach = Color(0xFFFFD4B8);       // Peach

  // --- BUTTON / NAV COLORS ---
  static const Color darkCapsule = Color(0xFF2D2D3A);       // Dark charcoal (buttons & nav)
  static const Color darkCapsuleLight = Color(0xFF3A3A4E);  // Slightly lighter

  // --- TEXT COLORS ---
  static const Color textPrimary = Color(0xFF2D2D2D);       // Soft black
  static const Color textSecondary = Color(0xFF888888);      // Grey
  static const Color textWarm = Color(0xFF5C4B3A);          // Warm brown text

  // --- LEGACY COLORS (kept for backward compatibility) ---
  static const Color greyText = Color(0xFF757575);
  static const Color likeColor = Color(0xFFFF6B6B);         // Now coral
  static const Color errorColor = Color(0xFFE53935);

  // Dark/Light specific
  static const Color darkMessageBubble = Color(0xFF2D2D3A);
  static const Color lightMessageBubble = Color(0xFFFF6B6B);
  static const Color darkPrimary = Colors.white;

  // ═══════════════════════════════════════════════════════════════
  //  GEN-Z GRADIENTS
  // ═══════════════════════════════════════════════════════════════

  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lavenderGradient = LinearGradient(
    colors: [Color(0xFFE8DEF8), Color(0xFFD0BCFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF2D2D3A), Color(0xFF1C1C2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFFA8E6CF), Color(0xFF7BD4B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient storyRingGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFF8BBD0), Color(0xFFE8DEF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════
  //  SPACING & SHAPES
  // ═══════════════════════════════════════════════════════════════

  static const double cardRadius = 24.0;
  static const double buttonRadius = 30.0;
  static const double inputRadius = 16.0;
  static const double pillRadius = 50.0;
  static const double navBarRadius = 40.0;

  static const double paddingLarge = 24.0;
  static const double paddingMedium = 16.0;
  static const double paddingSmall = 8.0;

  // --- FONT SIZES ---
  static const double fontSmall = 12.0;
  static const double fontMedium = 14.0;
  static const double fontLarge = 16.0;
  static const double fontXLarge = 18.0;
  static const double fontHeading = 28.0;
  static const double fontHero = 36.0;

  // ═══════════════════════════════════════════════════════════════
  //  SHADOWS
  // ═══════════════════════════════════════════════════════════════

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFFFF6B6B).withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> navShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 24,
      offset: const Offset(0, -4),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}
