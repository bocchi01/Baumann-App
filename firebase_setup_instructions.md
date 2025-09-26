# Firebase Setup Instructions

## ✅ Code Integration Complete

The app now includes Firebase Auth integration:
- `firebase_core` and `firebase_auth` dependencies added
- Firebase initialized in `main.dart`
- `FirebaseAuthRepository` class created with email/password authentication
- Italian error messages for common auth scenarios

## 🔧 Firebase Console Configuration Required

To complete the setup, you need to:

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Create a project" or use existing project
   - Enable Authentication > Sign-in method > Email/Password

2. **Add iOS App**
   ```bash
   # Get iOS bundle ID from:
   cat ios/Runner/Info.plist | grep -A1 CFBundleIdentifier
   ```
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/GoogleService-Info.plist`

3. **Add macOS App**
   ```bash
   # Get macOS bundle ID from:
   cat macos/Runner/Info.plist | grep -A1 CFBundleIdentifier
   ```
   - Download `GoogleService-Info.plist` for macOS
   - Place in `macos/Runner/GoogleService-Info.plist`

4. **Add Android App**
   ```bash
   # Get Android package name from:
   cat android/app/build.gradle | grep applicationId
   ```
   - Download `google-services.json`
   - Place in `android/app/google-services.json`
   - Add to `android/app/build.gradle`:
   ```gradle
   plugins {
     id 'com.google.gms.google-services'
   }
   ```

## 🚀 Testing

Once Firebase is configured, you can:
- Test registration with new email/password
- Test login with existing credentials
- View users in Firebase Console > Authentication

## 📝 Next Steps

Consider adding:
- Google/Apple Sign-In (requires additional packages)
- Firestore for user profiles and subscription data
- Firebase Analytics for usage tracking
- Push notifications via Firebase Messaging