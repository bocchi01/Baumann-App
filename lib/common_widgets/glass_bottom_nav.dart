// file: glass_bottom_nav.dart
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Imposta per simulare "Liquid Glass" in stile iOS 26.
/// - Blur adattivo (meno intenso in dark per evitare milkiness)
/// - Tint dinamico tramite CupertinoDynamicColor
/// - Bordo, ombra e micro-parallax
/// - Hide-on-scroll con gap tra contenuto e glass
/// - Edge glow leggero sul bordo superiore
class GlassBottomBar extends StatefulWidget {
  const GlassBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.hideOnScrollController,
    this.minimizedHeight = 28.0,
    this.expandedHeight = 64.0,
    this.backgroundOpacity = 0.65,
    this.enableParallax = true,
    this.enableEdgeGlow = true,
    this.reduceTransparency = false, // fallback per accessibilità/vecchi device
  });

  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Passa il controller di scroll del contenuto per attivare hide-on-scroll.
  final ScrollController? hideOnScrollController;

  /// Altezza della barra quando "minimized" (nascosta quasi del tutto).
  final double minimizedHeight;

  /// Altezza normale della barra.
  final double expandedHeight;

  /// Opacità della tinta glass.
  final double backgroundOpacity;

  /// Abilita parallax leggero.
  final bool enableParallax;

  /// Abilita glow sul bordo superiore.
  final bool enableEdgeGlow;

  /// Se true, disabilita blur e usa sfondo solido (accessibilità).
  final bool reduceTransparency;

  @override
  State<GlassBottomBar> createState() => _GlassBottomBarState();
}

class _GlassBottomBarState extends State<GlassBottomBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _progress;

  // Dinamiche di colore ispirate a iOS 26
  static const CupertinoDynamicColor _glassTint =
      CupertinoDynamicColor.withBrightness(
    color: Color(0x66FFFFFF), // light mode base
    darkColor: Color(0x55FFFFFF), // dark mode: meno opaco
  );

  static const CupertinoDynamicColor _borderColor =
      CupertinoDynamicColor.withBrightness(
    color: Color(0x33FFFFFF),
    darkColor: Color(0x22FFFFFF),
  );

  static const CupertinoDynamicColor _shadowColor =
      CupertinoDynamicColor.withBrightness(
    color: Color(0x22000000),
    darkColor: Color(0x33000000),
  );

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    _progress = CurvedAnimation(
      parent: _anim,
      curve: Curves.fastLinearToSlowEaseIn,
    );

    final ScrollController? sc = widget.hideOnScrollController;
    if (sc != null) {
      sc.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.hideOnScrollController?.removeListener(_onScroll);
    _anim.dispose();
    super.dispose();
  }

  void _onScroll() {
    final ScrollController sc = widget.hideOnScrollController!;
    // Semplice logica: se si scorre verso il basso, minimizza; verso l'alto, espandi
    final bool scrollingDown =
        sc.position.userScrollDirection == ScrollDirection.reverse;
    final double target = scrollingDown ? 1.0 : 0.0;
    _anim.animateTo(
      target,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }

  // Sigma blur adattivo: meno in dark
  double _adaptiveBlurSigma(Brightness brightness) {
    // Valori consigliati: 10–16 in light, 8–12 in dark
    const double baseLight = 14.0;
    const double baseDark = 10.0;
    return brightness == Brightness.dark ? baseDark : baseLight;
  }

  // Piccolo parallax in px
  double _parallaxOffsetPx() {
    if (!widget.enableParallax) return 0;
    // 0–4 px based on progress
    return 4.0 * (_progress.value);
  }

  @override
  Widget build(BuildContext context) {
    final Brightness? brightness = CupertinoTheme.of(context).brightness;
    final Color resolvedTint = CupertinoDynamicColor.resolve(_glassTint, context);
    final Color resolvedBorder =
        CupertinoDynamicColor.resolve(_borderColor, context);
    final Color resolvedShadow =
        CupertinoDynamicColor.resolve(_shadowColor, context);

    final double height = Tween<double>(
      begin: widget.expandedHeight,
      end: widget.minimizedHeight,
    ).transform(_progress.value);

    final double blurSigma = widget.reduceTransparency
        ? 0.0
        : _adaptiveBlurSigma(brightness ?? Brightness.light);
    final Color bgColor = resolvedTint.withValues(alpha: widget.backgroundOpacity);

    return AnimatedBuilder(
      animation: _anim,
      builder: (BuildContext context, Widget? child) {
        return IgnorePointer(
          ignoring: _progress.value > 0.95, // quasi nascosta: non cliccabile
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              bottom: true,
              child: Container(
                margin: const EdgeInsets.only(
                  bottom: 8.0,
                ), // gap visivo (stile App Store)
                height: height,
                child: Transform.translate(
                  offset: Offset(0, _parallaxOffsetPx()),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      // Shadow per elevazione
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: resolvedShadow,
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      borderRadius: const BorderRadius.all(Radius.circular(22)),
                      border: Border.all(color: resolvedBorder, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(22)),
                      child: Stack(
                        children: <Widget>[
                          // Frosting (blur + tint)
                          if (blurSigma > 0)
                            BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: blurSigma,
                                sigmaY: blurSigma,
                              ),
                              child: Container(color: bgColor),
                            )
                          else
                            // Fallback solido per Reduce Transparency
                            Container(color: bgColor.withValues(alpha: 1.0)),
                          // Gradienti sottili per profondità
                          IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Colors.white.withValues(
                                      alpha: brightness == Brightness.dark ? 0.04 : 0.08,
                                    ),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Edge glow superiore
                          if (widget.enableEdgeGlow)
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 180),
                                opacity: 0.35 -
                                    0.30 *
                                        _progress
                                            .value, // meno glow quando minimizzata
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: <Color>[
                                        Colors.white.withValues(
                                          alpha: brightness == Brightness.dark
                                              ? 0.10
                                              : 0.20,
                                        ),
                                        Colors.white.withValues(alpha: 0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Contenuto interattivo: icone + labels
                          _BarContent(
                            items: widget.items,
                            currentIndex: widget.currentIndex,
                            onTap: widget.onTap,
                            minimized: _progress.value > 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BarContent extends StatelessWidget {
  const _BarContent({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.minimized,
  });

  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool minimized;

  @override
  Widget build(BuildContext context) {
    final CupertinoThemeData theme = CupertinoTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List<Widget>.generate(items.length, (int index) {
          final BottomNavigationBarItem item = items[index];
          final bool selected = index == currentIndex;

          final Color iconColor = selected
              ? theme.primaryColor
              : CupertinoDynamicColor.resolve(
                  const CupertinoDynamicColor.withBrightness(
                    color: Color(0xAA000000),
                    darkColor: Color(0xCCFFFFFF),
                  ),
                  context,
                );

          final double iconSize = minimized ? 22 : 26;

          return Expanded(
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 6.0,
              ),
              onPressed: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconTheme(
                    data: IconThemeData(color: iconColor, size: iconSize),
                    child: selected ? item.activeIcon : item.icon,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: SizedBox(
                      height: minimized ? 0 : 18,
                      child: Opacity(
                        opacity: minimized ? 0 : 0.95,
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          child: item.label == null
                              ? const SizedBox.shrink()
                              : Text(
                                  item.label!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
