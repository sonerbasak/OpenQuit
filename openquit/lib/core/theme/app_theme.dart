import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // ─── Palette ───────────────────────────────────────────────────────────────
  static const Color _seed = Color(0xFF7C5CFC);

  static const Color darkBg = Color(0xFF0A0A0F);
  static const Color darkCard = Color(0xFF13131A);
  static const Color darkCardHigh = Color(0xFF1C1C28);

  // Accent gradient stops used across the app
  static const Color gradientStart = Color(0xFF7C5CFC);
  static const Color gradientMid = Color(0xFFB06EFF);
  static const Color gradientEnd = Color(0xFFFF6B9D);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientMid, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF2193B0), Color(0xFF6DD5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF8008), Color(0xFFFFC837)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.dark,
      ).copyWith(
        surface: darkBg,
        surfaceContainerHighest: darkCardHigh,
        primary: _seed,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _seed, width: 1.5),
        ),
        labelStyle: TextStyle(color: Colors.white.withAlpha(153)),
        prefixIconColor: Colors.white.withAlpha(120),
      ),
    );
  }

  // ─── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seed,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }
}
