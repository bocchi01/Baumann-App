// glass_surface.dart
// Widget contenitore riutilizzabile con stile sobrio e coerente
// Usato per card e superfici elevate nell'app

import 'package:flutter/cupertino.dart';

/// Superficie con stile glass sobrio
/// Fornisce un contenitore consistente per card e contenuti elevati
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    required this.child,
    this.padding,
    this.borderRadius = 16.0,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    // Usa colori adattivi per light/dark mode
    final bool isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        // Background neutro adattivo
        color: isDark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(borderRadius),
        // Bordo sottile per definizione
        border: Border.all(
          color: isDark
              ? CupertinoColors.separator.darkColor
              : CupertinoColors.separator.color,
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}
