# iOS 26 System UI Integration Guide

## Overview

La Baumann Posture App utilizza un'**architettura ibrida**: **Flutter per il contenuto** + **UIKit nativo per i componenti di sistema**. Questo garantisce:

- ✅ **Fedeltà 100%** alle linee guida iOS 26 HIG
- ✅ **Blur e translucenza** hardware-accelerated nativi
- ✅ **Accessibilità** completa gestita da UIKit
- ✅ **Haptic feedback** preciso e responsivo
- ✅ **Performance** ottimali su tutti i device

## Architettura

```
┌─────────────────────────────────────┐
│   Flutter UI Layer (Content)        │
│   - Screens, Widgets, Business Logic│
└──────────────┬──────────────────────┘
               │
               │ Method Channels
               │
┌──────────────▼──────────────────────┐
│   Platform Bridge (Dart)            │
│   - SystemUI class                  │
│   - NativeGlassTabBarController     │
└──────────────┬──────────────────────┘
               │
               │ FlutterMethodChannel
               │
┌──────────────▼──────────────────────┐
│   iOS Native Layer (Swift/UIKit)    │
│   - SystemUIBridge                  │
│   - NativeGlassTabBarController     │
│   - UIActivityViewController        │
│   - UIAlertController               │
│   - UIDatePicker                    │
│   - UIFeedbackGenerator             │
└─────────────────────────────────────┘
```

## Componenti Implementati

### 1. Share Sheet (UIActivityViewController)

**Swift**: Gestisce condivisione di testo, URL, file e immagini.

**Dart API**:
```dart
await SystemUI.share(
  text: 'Ciao da Baumann!',
  url: 'https://example.com',
  imageData: imageBytes, // Uint8List
  subject: 'Email subject',
);
```

**Features**:
- ✅ Categorie iOS 26 (Messages, Mail, AirDrop, etc.)
- ✅ Validazione sicurezza file (solo app sandbox)
- ✅ iPad popover positioning
- ✅ Subject per email

### 2. Action Sheet (UIAlertController)

**Swift**: Alert style `.actionSheet` con blur nativo.

**Dart API**:
```dart
await SystemUI.actionSheet(
  title: 'Opzioni',
  message: 'Cosa vuoi fare?',
  actions: [
    ActionItem('Condividi', icon: 'square.and.arrow.up'),
    ActionItem('Elimina', style: 'destructive', icon: 'trash'),
    ActionItem('Annulla', style: 'cancel'),
  ],
  onSelected: (index) => print('Selected: $index'),
);
```

**Styles**:
- `default`: Azione normale
- `destructive`: Rosso, azione pericolosa
- `cancel`: Bold, chiude l'action sheet

**SF Symbols**: Icone native iOS (es. `trash`, `square.and.arrow.up`, `star`)

### 3. Alert Dialog (UIAlertController)

**Swift**: Alert style `.alert`.

**Dart API**:
```dart
await SystemUI.alert(
  title: 'Attenzione',
  message: 'Questa azione non può essere annullata.',
  actions: [
    ActionItem('Elimina', style: 'destructive'),
    ActionItem('Annulla', style: 'cancel'),
  ],
  onSelected: (index) {
    if (index == 0) // Confermato
  },
);
```

### 4. Date/Time Picker (UIDatePicker)

**Swift**: `UIDatePicker` con stile `.wheels` in sheet con toolbar.

**Dart API**:
```dart
// Date picker
final date = await SystemUI.datePicker(
  mode: 'date',
  initialDate: DateTime.now().toIso8601String(),
  minDate: '2024-01-01T00:00:00Z',
  maxDate: '2025-12-31T23:59:59Z',
);

// Time picker
final time = await SystemUI.datePicker(mode: 'time');

// Date + Time picker
final dateTime = await SystemUI.datePicker(mode: 'dateTime');
```

**Ritorna**: ISO8601 string o `null` se cancellato.

### 5. Haptic Feedback (UIFeedbackGenerator)

**Swift**: Usa `UIImpactFeedbackGenerator`, `UISelectionFeedbackGenerator`, `UINotificationFeedbackGenerator`.

**Dart API**:
```dart
await SystemUI.haptic(HapticType.light);      // Impact leggero
await SystemUI.haptic(HapticType.medium);     // Impact medio
await SystemUI.haptic(HapticType.heavy);      // Impact pesante
await SystemUI.haptic(HapticType.selection);  // Selection change
await SystemUI.haptic(HapticType.success);    // Notifica successo
await SystemUI.haptic(HapticType.warning);    // Notifica warning
await SystemUI.haptic(HapticType.error);      // Notifica errore
```

### 6. Native Glass Tab Bar (UITabBar)

Già implementato - vedi [Native Glass Tab Bar Migration Guide](native_glass_tab_bar_migration.md).

## File Structure

```
ios/Runner/
├── SystemUIBridge.swift              # Bridge per share, alerts, pickers, haptics
├── NativeGlassTabBarController.swift # Controller tab bar nativa
└── AppDelegate.swift                 # Setup channels + embedding

lib/
├── system_ui.dart                    # Dart wrapper per SystemUIBridge
├── native_glass_tab_bar.dart         # Dart wrapper per tab bar
└── screens/
    └── system_ui_demo_screen.dart    # Demo completa di tutti i componenti
```

## Sicurezza e Privacy

### File Sharing

**Validazione**:
```swift
guard FileManager.default.isReadableFile(atPath: url.path),
      url.path.contains(NSTemporaryDirectory()) ||
      url.path.contains(NSHomeDirectory()) else {
    continue // Scarta file fuori sandbox
}
```

**Best Practices**:
- ✅ Condividi solo file dentro app sandbox
- ✅ Usa `NSTemporaryDirectory()` per file generati runtime
- ❌ Non esporre percorsi assoluti non sanitizzati
- ❌ Non condividere dati sensibili senza conferma utente

### Input Sanitization

**Dart**:
```dart
// ✅ Valida input prima di passare al bridge
if (files.isNotEmpty) {
  await SystemUI.share(files: files.where((f) => 
    f.startsWith('/private/var/') // App sandbox
  ).toList());
}
```

### Logging

**Swift**:
```swift
// ❌ MAI loggare dati condivisi
// print("Sharing: \(activityItems)") 

// ✅ Log solo eventi
print("Share sheet presented")
```

## Accessibilità

### Reduce Transparency

UIKit gestisce automaticamente il fallback:
- `UIAlertController`: Background opaco quando Reduce Transparency è ON
- `UIDatePicker`: No blur effects
- `UITabBar`: Background solido con blur disabilitato

### High Contrast

Colori dinamici si adattano automaticamente:
```swift
UIColor.label          // Contrast ratio compliant
UIColor.separator      // Più visibile in high contrast
UIColor.systemFill     // Aumenta opacità
```

### VoiceOver

Tutti i componenti nativi supportano VoiceOver:
- **Action Sheet**: "Button. Condividi. Tap to activate."
- **Alert**: "Alert. Attenzione. Message: ..."
- **Date Picker**: "Date picker. Scroll to change value."
- **Tab Bar**: "Home tab, 1 of 4. Double tap to activate."

## Performance

### Rendering

- **Blur**: GPU-accelerated via Metal
- **Animations**: Core Animation con timing curve hardware
- **Haptics**: Taptic Engine, latenza < 10ms
- **Main Thread**: Tutti i channel calls sono async, non bloccanti

### Memory

- **Share Sheet**: Rilascia automaticamente dopo dismiss
- **Image Sharing**: Passa direttamente `UIImage`, no file I/O overhead
- **Stream Controllers**: Cleanup con `SystemUI.dispose()`

## Testing

### Demo Screen

Usa `SystemUIDemo` per testare tutti i componenti:

```dart
Navigator.of(context).push(
  CupertinoPageRoute(
    builder: (_) => const SystemUIDemo(),
  ),
);
```

**Checkpoint**:
1. ✅ Share text → Opens UIActivityViewController
2. ✅ Share image → Screenshot condiviso correttamente
3. ✅ Action sheet → Blur translucido visibile, icone SF Symbols
4. ✅ Alert → Buttons styled correctly (destructive rosso)
5. ✅ Date picker → Wheels picker in sheet con toolbar
6. ✅ Haptics → Taptic Engine risponde, intensità corretta
7. ✅ Dark mode → Tutti i componenti si adattano

### Device Testing

```bash
# Simulatore
flutter run -d "iPhone 16 Pro"

# Device reale (raccomandato per blur + haptics)
flutter run -d <device-id>
```

## Troubleshooting

### Share sheet non appare

**Causa**: `activityItems` vuoto.

**Fix**: Verifica che almeno uno tra `text`, `url`, `files`, `imageData` sia fornito.

### Action sheet callback non ricevuto

**Causa**: Stream controller non inizializzato.

**Fix**: 
```dart
// ✅ Passa callback
await SystemUI.actionSheet(
  actions: [...],
  onSelected: (i) => print('Selected: $i'), // ← Importante!
);
```

### Date picker ritorna null

**Causa**: Utente ha tappato "Cancel" o swipe down dismiss.

**Fix**: Gestisci il caso null:
```dart
final date = await SystemUI.datePicker(mode: 'date');
if (date != null) {
  // Usa la data
} else {
  // Cancellato
}
```

### Haptics non funzionano su simulatore

**Causa**: Simulatore non supporta Taptic Engine.

**Fix**: Testa su device reale.

### "No such module 'UIKit'" in VS Code

**Causa**: Falso positivo dell'analyzer quando apri file Swift.

**Fix**: Ignora, il progetto compila correttamente:
```bash
cd ios && xcodebuild -workspace Runner.xcworkspace -scheme Runner -destination 'generic/platform=iOS' build
```

## Future Enhancements

### Context Menu (UIContextMenuInteraction)

Richiede PlatformView overlay per ricevere long-press:

```swift
// TODO: Implementare overlay view con UIContextMenuInteraction
let interaction = UIContextMenuInteraction(delegate: self)
overlayView.addInteraction(interaction)
```

### Color Picker (UIColorPickerViewController)

iOS 14+:

```swift
let picker = UIColorPickerViewController()
picker.selectedColor = UIColor.systemBlue
picker.delegate = self
present(picker, animated: true)
```

### System Modals

- **UIDocumentPickerViewController**: File picker nativo
- **UIImagePickerController**: Camera/photo library (già supportato da image_picker plugin)
- **MFMailComposeViewController**: Mail compose nativo

---

**Data implementazione**: 7 Ottobre 2025  
**iOS Deployment Target**: 15.0+  
**Flutter SDK**: 3.27.1  
**Xcode**: 16.2+
