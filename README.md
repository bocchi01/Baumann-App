# Posture App

Flutter prototype featuring immutable data models and a complete authentication flow powered by Riverpod. Use it as a foundation for a posture coaching experience.

## Features

- Mock authentication repository with email/password, Google, and Apple entry points.
- Riverpod `Notifier`-based controller exposing loading/error states and navigation orchestration.
- Responsive login/registration screen with validation, loading feedback, and error snackbars.
- Reusable data models (`UserModel`, `PosturePath`, etc.) with JSON serialization helpers.

## Setup

```bash
flutter pub get
```

### iOS 26 Native System UI Integration

**Architettura ibrida**: Flutter per il contenuto + UIKit nativo per tutti i componenti di sistema.

#### Componenti Implementati

1. **Native Glass Tab Bar** (UITabBar)
   - Hardware-accelerated blur (`UIBlurEffect.systemThinMaterial`)
   - Floating design con gap 8px, corner radius 22px
   - Hide-on-scroll automatico
   - SF Symbols icons

2. **Share Sheet** (UIActivityViewController)
   - Condivisione testo, URL, immagini, file
   - Categorie iOS 26 native (Messages, Mail, AirDrop, etc.)

3. **Action Sheet & Alerts** (UIAlertController)
   - Blur translucido nativo
   - SF Symbols per icone azioni
   - Styles: default, destructive, cancel

4. **Date/Time Picker** (UIDatePicker)
   - Wheels picker in sheet nativo
   - Mode: date, time, dateTime
   - Min/max constraints

5. **Haptic Feedback** (UIFeedbackGenerator)
   - Impact (light/medium/heavy)
   - Selection change
   - Notification (success/warning/error)

#### Platform Channels

- `glass_tab_bar`: Tab bar navigation
- `system_ui`: Share, alerts, pickers, haptics

Dynamic colors live in `AppTheme.liquidGlass*`. Cupertino scaffolds resolve their background against the Liquid Glass surface so system translucency can shine through.

📖 **Documentazione completa**:
- [Native Glass Tab Bar Migration Guide](docs/native_glass_tab_bar_migration.md)
- [iOS System UI Integration Guide](docs/ios_system_ui_integration.md)

### Fonts

Google Fonts runtime fetching is enabled so the Montserrat family loads automatically at startup. If you need an offline build, bundle the fonts once with:

```bash
flutter pub run google_fonts:flutter_fonts
```

After bundling you can safely flip `GoogleFonts.config.allowRuntimeFetching` back to `false` in `lib/main.dart`.

## Run the app

```bash
flutter run
```

### macOS keychain fix

macOS debug builds rely on the system Keychain to persist Firebase Auth sessions. Keychain Sharing is now enabled directly in the Xcode project so the correct entitlements flow through the normal signing process.

To configure your environment:

1. Open `macos/Runner.xcworkspace` in Xcode.
2. Select the **Runner** target → **Signing & Capabilities** tab and pick your Apple Development Team. Xcode will generate the provisioning profile and keep the `com.example.postureApp` keychain group in sync.
3. Run `flutter run -d macos` as usual. The bundle already includes the keychain entitlement, so Firebase Auth can save credentials without extra steps.

If you rotate teams or need to reapply the entitlement for a custom build pipeline, the legacy helper script (`tool/dev_sign.sh`) is still available, but it now expects a fully provisioned build and is no longer required for day-to-day development.

### iOS local network permission

On real devices running iOS 14+, the debugger requires Local Network access for the Dart observatory. The app now performs both a Flutter-side multicast probe **and** an iOS-native `NWBrowser` Bonjour scan during startup to surface the permission dialog automatically.

If the sheet still doesn’t appear:

1. Delete the app from the device, then reinstall it with `flutter run` (ensures the native probe executes on first launch).
2. Or visit **Settings → Privacy & Security → Local Network**, toggle the app off and back on, and relaunch.
3. As a last resort, reset privacy settings via **Settings → General → Transfer or Reset iPhone → Reset → Reset Location & Privacy**.

With both probes active, the dialog should appear within a few seconds of launch while attached to the debugger.

## Structure highlights

- `lib/models/` – immutable data transfer objects with `fromJson`/`toJson` methods.
- `lib/auth/auth_repository.dart` – abstract contract plus mock implementation for auth flows.
- `lib/controllers/auth_controller.dart` – Riverpod controller handling state, errors, and navigation.
- `lib/screens/` – UI for authentication and a simple post-login home screen.
- `lib/navigation/app_router.dart` – global navigator key used for controller-driven routing.

## Testing

Add your own test suites under the `test/` directory and run them with:

```bash
flutter test
```
