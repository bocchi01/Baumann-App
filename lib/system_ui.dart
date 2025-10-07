// system_ui.dart
// Baumann Posture App - Native iOS System UI Components
import 'dart:async';
import 'package:flutter/services.dart';

/// Bridge per componenti di sistema iOS 26 nativi
class SystemUI {
  static const MethodChannel _channel = MethodChannel('system_ui');
  static StreamController<int>? _actionController;
  static StreamController<int>? _alertController;
  static StreamController<String>? _dateController;

  // MARK: - Share

  /// Condivide contenuto usando UIActivityViewController
  /// 
  /// Supporta:
  /// - [text]: Testo semplice
  /// - [url]: URL da condividere
  /// - [files]: Lista di percorsi file (deve essere in app sandbox)
  /// - [imageData]: Dati immagine raw (Uint8List)
  /// - [subject]: Subject per email (opzionale)
  static Future<void> share({
    String? text,
    String? url,
    List<String>? files,
    Uint8List? imageData,
    String? subject,
  }) async {
    await _channel.invokeMethod('share', <String, dynamic>{
      if (text != null) 'text': text,
      if (url != null) 'url': url,
      if (files != null && files.isNotEmpty) 'files': files,
      if (imageData != null) 'imageData': imageData,
      if (subject != null) 'subject': subject,
    });
  }

  // MARK: - Action Sheet

  /// Mostra un action sheet nativo iOS con blur translucido
  /// 
  /// ```dart
  /// await SystemUI.actionSheet(
  ///   title: 'Opzioni',
  ///   message: 'Cosa vuoi fare?',
  ///   actions: [
  ///     ActionItem('Condividi', icon: 'square.and.arrow.up'),
  ///     ActionItem('Elimina', style: 'destructive', icon: 'trash'),
  ///     ActionItem('Annulla', style: 'cancel'),
  ///   ],
  ///   onSelected: (index) => print('Selected: $index'),
  /// );
  /// ```
  static Future<void> actionSheet({
    String? title,
    String? message,
    required List<ActionItem> actions,
    void Function(int index)? onSelected,
  }) async {
    _actionController ??= StreamController<int>.broadcast();

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onActionSelected') {
        final args = (call.arguments as Map?) ?? {};
        final index = (args['index'] as int?) ?? 0;
        _actionController?.add(index);
      }
    });

    if (onSelected != null) {
      final subscription = _actionController!.stream.listen(onSelected);
      await _channel.invokeMethod('actionSheet', <String, dynamic>{
        if (title != null) 'title': title,
        if (message != null) 'message': message,
        'actions': actions.map((e) => e.toMap()).toList(),
      });
      // Cleanup dopo un delay per permettere callback
      Future<void>.delayed(const Duration(milliseconds: 500), subscription.cancel);
    } else {
      await _channel.invokeMethod('actionSheet', <String, dynamic>{
        if (title != null) 'title': title,
        if (message != null) 'message': message,
        'actions': actions.map((e) => e.toMap()).toList(),
      });
    }
  }

  // MARK: - Alert Dialog

  /// Mostra un alert dialog nativo iOS
  /// 
  /// ```dart
  /// await SystemUI.alert(
  ///   title: 'Attenzione',
  ///   message: 'Sei sicuro?',
  ///   actions: [
  ///     ActionItem('Conferma', style: 'destructive'),
  ///     ActionItem('Annulla', style: 'cancel'),
  ///   ],
  ///   onSelected: (index) {
  ///     if (index == 0) // Confermato
  ///   },
  /// );
  /// ```
  static Future<void> alert({
    String? title,
    String? message,
    required List<ActionItem> actions,
    void Function(int index)? onSelected,
  }) async {
    _alertController ??= StreamController<int>.broadcast();

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onAlertAction') {
        final args = (call.arguments as Map?) ?? {};
        final index = (args['index'] as int?) ?? 0;
        _alertController?.add(index);
      }
    });

    if (onSelected != null) {
      final subscription = _alertController!.stream.listen(onSelected);
      await _channel.invokeMethod('alert', <String, dynamic>{
        if (title != null) 'title': title,
        if (message != null) 'message': message,
        'actions': actions.map((e) => e.toMap()).toList(),
      });
      Future<void>.delayed(const Duration(milliseconds: 500), subscription.cancel);
    } else {
      await _channel.invokeMethod('alert', <String, dynamic>{
        if (title != null) 'title': title,
        if (message != null) 'message': message,
        'actions': actions.map((e) => e.toMap()).toList(),
      });
    }
  }

  // MARK: - Date Picker

  /// Mostra un date/time picker nativo iOS in sheet
  /// 
  /// [mode]: 'date', 'time', o 'dateTime'
  /// [initialDate]: Data iniziale in formato ISO8601
  /// [minDate]: Data minima (opzionale)
  /// [maxDate]: Data massima (opzionale)
  /// 
  /// Ritorna la data selezionata in formato ISO8601, o null se cancellato
  static Future<String?> datePicker({
    String mode = 'date',
    String? initialDate,
    String? minDate,
    String? maxDate,
  }) async {
    _dateController ??= StreamController<String>.broadcast();

    final completer = Completer<String?>();
    StreamSubscription<String>? subscription;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onDateSelected') {
        final args = (call.arguments as Map?) ?? {};
        final date = (args['date'] as String?) ?? '';
        _dateController?.add(date);
      } else if (call.method == 'onDateCancelled') {
        completer.complete(null);
      }
    });

    subscription = _dateController!.stream.listen((date) {
      if (!completer.isCompleted) {
        completer.complete(date);
      }
    });

    await _channel.invokeMethod('datePicker', <String, dynamic>{
      'mode': mode,
      if (initialDate != null) 'initialDate': initialDate,
      if (minDate != null) 'minDate': minDate,
      if (maxDate != null) 'maxDate': maxDate,
    });

    final result = await completer.future;
    await subscription.cancel();
    return result;
  }

  // MARK: - Haptic Feedback

  /// Genera feedback aptico nativo iOS
  /// 
  /// Tipi supportati:
  /// - `light`, `medium`, `heavy`: Impact feedback
  /// - `selection`: Selection change feedback
  /// - `success`, `warning`, `error`: Notification feedback
  static Future<void> haptic(HapticType type) async {
    await _channel.invokeMethod('haptic', <String, dynamic>{
      'type': type.name,
    });
  }

  // MARK: - Cleanup

  /// Cleanup stream controllers
  static void dispose() {
    _actionController?.close();
    _alertController?.close();
    _dateController?.close();
    _actionController = null;
    _alertController = null;
    _dateController = null;
  }
}

// MARK: - Models

/// Item per action sheet o alert
class ActionItem {
  final String label;
  final String style; // 'default' | 'destructive' | 'cancel'
  final String? icon; // SF Symbol name (es. 'trash', 'square.and.arrow.up')

  const ActionItem(
    this.label, {
    this.style = 'default',
    this.icon,
  });

  Map<String, dynamic> toMap() => <String, dynamic>{
        'label': label,
        'style': style,
        if (icon != null) 'icon': icon,
      };
}

/// Tipo di feedback aptico
enum HapticType {
  light,
  medium,
  heavy,
  selection,
  success,
  warning,
  error,
}
