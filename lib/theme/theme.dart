import 'package:flutter/material.dart';

// --------------------------------------------------
// TEMA UFFICIALE DELL'APP ISTITUTO BAUMANN
// --------------------------------------------------
// Versione Definitiva - Palette colori basata sul logo ufficiale.
// --------------------------------------------------

class AppTheme {
  static const String _fontFamily = 'Montserrat';

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
      scaffoldBackgroundColor: background,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.light(
        primary: baumannPrimaryBlue,
        secondary: baumannSecondaryBlue,
        tertiary: baumannAccentOrange,
        surface: background,
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
        backgroundColor: background,
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
      cardTheme: CardTheme(
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
}

extension ColorWithValues on Color {
  /// Replica l'API sperimentale `withValues` delle versioni più recenti di Flutter.
  /// Permette di aggiornare selettivamente i componenti del colore garantendo
  /// compatibilità con gli SDK stabili.
  Color withValues({
    double? alpha,
    double? red,
    double? green,
    double? blue,
  }) {
    int resolveComponent(double? component, int original) {
      if (component == null) return original;
      final double normalized = component > 1 ? component / 255 : component;
      return (normalized.clamp(0.0, 1.0) * 255).round();
    }

    final int a = resolveComponent(alpha, this.alpha);
    final int r = resolveComponent(red, this.red);
    final int g = resolveComponent(green, this.green);
    final int b = resolveComponent(blue, this.blue);

    return Color.fromARGB(a, r, g, b);
  }
}
