import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// --------------------------------------------------
// TEMA UFFICIALE DELL'APP ISTITUTO BAUMANN
// --------------------------------------------------
// Versione Definitiva - Palette colori basata sul logo ufficiale.
// --------------------------------------------------

class AppTheme {
  static const String _fontFamily = 'Montserrat';

  /// Base surface color inspired by the iOS Liquid Glass system background.
  static const CupertinoDynamicColor liquidGlassBackground =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xFFF7F9FB),
        darkColor: Color(0xFF0B0E13),
      );

  /// Subtle tint applied to glass surfaces to keep highlights legible.
  static const CupertinoDynamicColor liquidGlassTint =
      CupertinoDynamicColor.withBrightness(
        color: Color(0xCCFFFFFF),
        darkColor: Color(0x99FFFFFF),
      );

  /// Soft border color matching the system glass chroma separation.
  static const CupertinoDynamicColor liquidGlassBorder =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x40FFFFFF),
        darkColor: Color(0x59FFFFFF),
      );

  /// Shadow color used to lift floating glass elements from content.
  static const CupertinoDynamicColor liquidGlassShadow =
      CupertinoDynamicColor.withBrightness(
        color: Color(0x330A162E),
        darkColor: Color(0x66000000),
      );

  // --- PALETTE COLORI UFFICIALE ---

  /// Colore primario: il blu istituzionale estratto dal banner ufficiale.
  static const Color baumannPrimaryBlue = Color(0xFF2E5B94);

  /// Colore di accento: l'arancione vibrante estratto direttamente dal logo.
  /// Usato per le call-to-action e gli elementi da evidenziare.
  static const Color baumannAccentOrange = Color(0xFFF37021);

  /// Colore secondario: una versione più chiara e armonica del blu primario.
  static const Color baumannSecondaryBlue = Color(0xFF5C85C1);

  /// Colore per gli sfondi principali dell'app.
  static const Color background = Color(0xFFF7F8FA);

  /// Colore per il testo principale.
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Colore per il testo secondario o descrizioni.
  static const Color textSecondary = Color(0xFF6B7280);

  /// Colore per i bordi o i divisori.
  static const Color border = Color(0xFFE5E7EB);

  // --- TEMA GENERALE DELL'APP ---

  static ThemeData get themeData {
    return ThemeData(
      // Impostazioni colori principali
      primaryColor: baumannPrimaryBlue,
      scaffoldBackgroundColor: liquidGlassBackground,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.light(
        primary: baumannPrimaryBlue,
        secondary: baumannSecondaryBlue,
        tertiary: baumannAccentOrange,
        surface: liquidGlassBackground,
        onSurface: textPrimary,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),

      // Impostazioni Tipografia
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Stile per le AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: baumannPrimaryBlue),
        titleTextStyle: TextStyle(
          fontFamily: 'Montserrat',
          color: baumannPrimaryBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Stile per le Card
      cardTheme: CardThemeData(
        elevation: 2.0,
        color: Colors.white,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: const BorderSide(color: border, width: 1.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),

      // Stile per i Bottoni Principali
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: baumannPrimaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Stile per i campi di testo
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: baumannPrimaryBlue, width: 2.0),
        ),
        labelStyle: const TextStyle(color: textSecondary),
      ),
    );
  }

  static CupertinoThemeData get cupertinoThemeData {
    return CupertinoThemeData(
      primaryColor: baumannPrimaryBlue,
      primaryContrastingColor: Colors.white,
      scaffoldBackgroundColor: liquidGlassBackground,
      textTheme: const CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          color: textPrimary,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        actionTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: baumannPrimaryBlue,
        ),
      ),
    );
  }
}

extension ColorWithValues on Color {
  /// Replica l'API sperimentale `withValues` delle versioni più recenti di Flutter.
  /// Permette di aggiornare selettivamente i componenti del colore garantendo
  /// compatibilità con gli SDK stabili.
  Color withValues({double? alpha, double? red, double? green, double? blue}) {
    int resolveComponent(double? component, double original) {
      final double effective = component ?? original;
      final double normalized = effective > 1 ? effective / 255 : effective;
      return (normalized.clamp(0.0, 1.0) * 255).round();
    }

    final int a = resolveComponent(alpha, this.a);
    final int r = resolveComponent(red, this.r);
    final int g = resolveComponent(green, this.g);
    final int b = resolveComponent(blue, this.b);

    return Color.fromARGB(a, r, g, b);
  }
}
