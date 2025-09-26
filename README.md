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

## Run the app

```bash
flutter run
```

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
