import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color bg = Color(0xFF060A0F);
  static const Color surface = Color(0xFF0D1117);
  static const Color surface2 = Color(0xFF161B22);
  static const Color accent = Color(0xFF00F5A0);
  static const Color accentBlue = Color(0xFF00D9F5);
  static const Color accentOrange = Color(0xFFFFB830);
  static const Color accentRed = Color(0xFFFF4757);
  static const Color textPrimary = Color(0xFFE8E8F0);
  static const Color textMuted = Color(0xFF6B7385);
  static const Color border = Color(0xFF1E2430);
  static const Color cardBg = Color(0xFF0D1117);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentBlue,
          surface: surface,
          background: bg,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          const TextTheme(
            displayLarge:
                TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
            displayMedium:
                TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
            headlineLarge:
                TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
            headlineMedium:
                TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
            titleLarge:
                TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(color: textPrimary),
            bodyMedium: TextStyle(color: textMuted),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bg,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: accent,
          unselectedItemColor: textMuted,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
        cardTheme: CardTheme(
          color: cardBg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: border, width: 1),
          ),
        ),
      );
}

// Text Styles
class AppText {
  static TextStyle mono(
          {double size = 12,
          Color color = AppTheme.textMuted,
          FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.jetBrainsMono(
          fontSize: size, color: color, fontWeight: weight);

  static TextStyle display(
          {double size = 28,
          Color color = AppTheme.textPrimary,
          FontWeight weight = FontWeight.w800}) =>
      GoogleFonts.spaceGrotesk(
          fontSize: size, color: color, fontWeight: weight);

  static TextStyle body({double size = 14, Color color = AppTheme.textMuted}) =>
      GoogleFonts.spaceGrotesk(fontSize: size, color: color);
}
