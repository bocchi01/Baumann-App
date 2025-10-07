// native_glass_tab_bar.dart
// Baumann Posture App - Native iOS Glass Tab Bar Platform Channel
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Controller Flutter per comunicare con la UITabBar nativa iOS
class NativeGlassTabBarController {
  static const MethodChannel _channel = MethodChannel('glass_tab_bar');
  static StreamController<int>? _tapController;
  static StreamController<bool>? _visibilityController;

  /// Inizializza i tabs nativi
  static Future<void> setTabs(List<NativeTabItem> tabs) async {
    final payload = {
      'tabs': tabs.map((t) => t.toMap()).toList(),
    };
    await _channel.invokeMethod('setTabs', payload);
  }

  /// Cambia il tab selezionato programmaticamente
  static Future<void> setSelectedIndex(int index) async {
    await _channel.invokeMethod('setSelectedIndex', {'index': index});
  }

  /// Mostra/nascondi la tab bar con animazione
  static Future<void> show(bool shown) async {
    await _channel.invokeMethod('show', {'shown': shown});
  }

  /// Stream di eventi tap sui tab
  static Stream<int> get onTap {
    _tapController ??= StreamController<int>.broadcast();
    
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onTap') {
        final args = (call.arguments as Map?) ?? {};
        final index = (args['index'] as int?) ?? 0;
        _tapController?.add(index);
      } else if (call.method == 'onVisibilityChanged') {
        final args = (call.arguments as Map?) ?? {};
        final shown = (args['shown'] as bool?) ?? true;
        _visibilityController?.add(shown);
      }
    });
    
    return _tapController!.stream;
  }

  /// Stream di eventi visibilità (nascosto/mostrato)
  static Stream<bool> get onVisibilityChanged {
    _visibilityController ??= StreamController<bool>.broadcast();
    
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onTap') {
        final args = (call.arguments as Map?) ?? {};
        final index = (args['index'] as int?) ?? 0;
        _tapController?.add(index);
      } else if (call.method == 'onVisibilityChanged') {
        final args = (call.arguments as Map?) ?? {};
        final shown = (args['shown'] as bool?) ?? true;
        _visibilityController?.add(shown);
      }
    });
    
    return _visibilityController!.stream;
  }

  /// Cleanup
  static void dispose() {
    _tapController?.close();
    _visibilityController?.close();
    _tapController = null;
    _visibilityController = null;
  }
}

/// Modello per un tab item nativo
class NativeTabItem {
  final String title;
  final String? systemIcon; // SF Symbol name (e.g., "house", "flame", "person.2")

  const NativeTabItem({
    required this.title,
    this.systemIcon,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        if (systemIcon != null) 'systemIcon': systemIcon,
      };
}

/// Widget wrapper: gestisce padding bottom per evitare overlap con UITabBar nativa
/// e sincronizza la navigazione tra Flutter e iOS
class NativeGlassTabScaffold extends StatefulWidget {
  const NativeGlassTabScaffold({
    required this.tabs,
    required this.pages,
    this.initialIndex = 0,
    this.onIndexChanged,
    this.hideOnScroll = true,
    super.key,
  }) : assert(tabs.length == pages.length && tabs.length > 0);

  final List<NativeTabItem> tabs;
  final List<Widget> pages;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;
  final bool hideOnScroll;

  @override
  State<NativeGlassTabScaffold> createState() => _NativeGlassTabScaffoldState();
}

class _NativeGlassTabScaffoldState extends State<NativeGlassTabScaffold> {
  int _currentIndex = 0;
  late StreamSubscription<int> _tapSubscription;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Inizializza tabs nativi dopo il primo frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await NativeGlassTabBarController.setTabs(widget.tabs);
        await NativeGlassTabBarController.setSelectedIndex(_currentIndex);
      } catch (e) {
        debugPrint('⚠️  Errore inizializzazione tab bar nativa: $e');
      }
    });

    // Ascolta tap dalla barra nativa
    _tapSubscription = NativeGlassTabBarController.onTap.listen((index) {
      if (!mounted) return;
      setState(() => _currentIndex = index);
      widget.onIndexChanged?.call(index);
    });
  }

  @override
  void dispose() {
    _tapSubscription.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(NativeGlassTabScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Se cambiano i tab, aggiorna la barra nativa
    if (widget.tabs != oldWidget.tabs) {
      NativeGlassTabBarController.setTabs(widget.tabs);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Contenuto a tutto schermo, va sotto la tab bar (che ha trasparenza)
    // Non usiamo CupertinoPageScaffold qui per evitare nesting con gli scaffold interni
    return IndexedStack(
      index: _currentIndex,
      children: widget.pages,
    );
  }
}

/// Widget helper per gestire hide-on-scroll automatico
class NativeTabBarScrollWrapper extends StatefulWidget {
  const NativeTabBarScrollWrapper({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<NativeTabBarScrollWrapper> createState() =>
      _NativeTabBarScrollWrapperState();
}

class _NativeTabBarScrollWrapperState
    extends State<NativeTabBarScrollWrapper> {
  ScrollDirection? _lastDirection;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification) {
      final direction = notification.direction;
      
      // Previeni chiamate ripetute
      if (direction == _lastDirection) return false;
      _lastDirection = direction;

      if (direction == ScrollDirection.reverse) {
        // Scrolling down → nascondi
        NativeGlassTabBarController.show(false);
      } else if (direction == ScrollDirection.forward) {
        // Scrolling up → mostra
        NativeGlassTabBarController.show(true);
      }
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: widget.child,
    );
  }
}
